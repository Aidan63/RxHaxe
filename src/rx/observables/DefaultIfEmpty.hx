package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class DefaultIfEmpty<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var _defaultValue:T;

	public function new(source:IObservable<T>, defaultValue:T) {
		_source = source;
		_defaultValue = defaultValue;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var hasValue:Bool = false;
		var defaultIfEmpty_observer = Observer.create(function() {
			if (!hasValue) {
				observer.onNext(_defaultValue);
			}
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(v:T) {
			hasValue = true;
			observer.onNext(v);
		});
		return _source.subscribe(defaultIfEmpty_observer);
	}
}
