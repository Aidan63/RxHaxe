package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

typedef CombineLatestState<T> = {
	var latest:Array<T>;
	var counter:Int;
}

class CombineLatest<T, R> implements IObservable<R> {
	var _source:Array<IObservable<T>>;
	var _combinator:Array<T>->R;

	public function new(source:Array<IObservable<T>>, combinator:Array<T>->R) {
		_source = source;
		_combinator = combinator;
	}

	public function subscribe(observer:IObserver<R>):ISubscription {
		var __latest = new Array<T>();
		for (i in 0..._source.length) {
			__latest[i] = null;
		}
		var state = new AtomicData({latest: __latest, counter: _source.length});
		// lock
		var on_next = function(i:Int) {
			return function(v:T) {
				state.update(function(s:CombineLatestState<T>) {
					s.latest[i] = v;
					if (!Lambda.has(s.latest, null)) {
						observer.onNext(_combinator(s.latest));
					}
					return s;
				});
			};
		};
		// lock
		var on_completed = function() {
			state.update(function(s:CombineLatestState<T>) {
				s.counter--;
				if (s.counter == 0) {
					observer.onCompleted();
				}
				return s;
			});
		};
		var __unsubscribe = new Composite();

		for (i in 0..._source.length) {
			var combineLatest_observer = new Observer(on_completed, observer.onError, on_next(i));
			var subscription = _source[i].subscribe(combineLatest_observer);
			__unsubscribe.add(subscription);
		}
		return __unsubscribe;
	}
}
