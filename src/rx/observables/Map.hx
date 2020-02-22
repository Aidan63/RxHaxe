package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;

/*
 */
class Map<T, R> implements IObservable<R> {
	var _source:IObservable<T>;
	var _f:T->R;

	public function new(source:IObservable<T>, f:T->R) {
		_source = source;
		_f = f;
	}

	public function subscribe(observer:IObserver<R>):ISubscription {
		var map_observer = Observer.create(observer.onCompleted, observer.onError, function(v:T) {
			observer.onNext(_f(v));
		});
		return _source.subscribe(map_observer);
	}
}
