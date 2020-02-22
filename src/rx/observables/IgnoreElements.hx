package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class IgnoreElements<T> implements IObservable<T> {
	var _source:IObservable<T>;

	public function new(source:IObservable<T>) {
		_source = source;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var ignoreElements_observer = Observer.create(function() {
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(v:T) {});
		return _source.subscribe(ignoreElements_observer);
	}
}
