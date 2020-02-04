package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class ConcatAppend<T> implements IObservable<T> {
	var _source1:IObservable<T>;
	var _source2:IObservable<T>;
	var _unsubscribe:Composite;

	public function new(source1:IObservable<T>, source2:IObservable<T>, unsubscribe:Composite) {
		_source1 = source1;
		_source2 = source2;
		_unsubscribe = unsubscribe;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var o1_observer = Observer.create(function() {
			_unsubscribe.add(_source2.subscribe(observer));
		}, observer.onError, function(v:T) {
			observer.onNext(v);
		});

		_unsubscribe.add(_source1.subscribe(o1_observer));
		return _unsubscribe;
	}
}

class Concat<T> implements IObservable<T> {
	var _source:Array<IObservable<T>>;

	public function new(source:Array<IObservable<T>>) {
		_source = source;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var __unsubscribe = Composite.create();
		var acc = _source[0];
		for (i in 1..._source.length) {
			acc = new ConcatAppend(acc, _source[i], __unsubscribe);
		}
		acc.subscribe(observer);

		return __unsubscribe;
	}
}
