package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class Find<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var _predicate:T->Bool;

	public function new(source:IObservable<T>, predicate:T->Bool) {
		_source = source;
		_predicate = predicate;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var __subscription = SingleAssignment.create();
		var find_observer = Observer.create(function() {
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(value:T) {
			var isPassed = false;
			try {
				isPassed = _predicate(value);
			} catch (ex:String) {
				observer.onError(ex);
				return;
			}
			if (isPassed) {
				observer.onNext(value);
				observer.onCompleted();
				__subscription.unsubscribe();
			}
		});
		__subscription.set(_source.subscribe(find_observer));
		return __subscription;
	}
}
