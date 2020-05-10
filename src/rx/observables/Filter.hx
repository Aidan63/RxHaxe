package rx.observables;

import rx.Observer;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;

class Filter<T> implements IObservable<T> {
	var source:IObservable<T>;
	var predicate:T->Bool;

	public function new(_source:IObservable<T>, _predicate:T->Bool) {
		source = _source;
		predicate = _predicate;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var filter_observer = new Observer(() -> observer.onCompleted(), (e : String) -> observer.onError(e), (v:T) -> {
			var isPassed = false;
			try {
				isPassed = predicate(v);
			} catch (ex:String) {
				observer.onError(ex);

				return;
			}
			if (isPassed) {
				observer.onNext(v);
			}
		});

		return source.subscribe(filter_observer);
	}
}
