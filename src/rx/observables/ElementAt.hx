package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class ElementAt<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var _index:Int;

	public function new(source:IObservable<T>, index:Int) {
		_source = source;
		_index = index;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		// lock
		var counter = AtomicData.create(0);
		var __subscription = SingleAssignment.create();
		var elementAt_observer = Observer.create(function() {
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(value:T) {
			AtomicData.update_if(function(c:Int) return c == _index, function(c:Int) {
				observer.onNext(value);
				observer.onCompleted();
				__subscription.unsubscribe();
				return c;
			}, counter);
			AtomicData.update(Utils.succ, counter);
		});
		__subscription.set(_source.subscribe(elementAt_observer));
		return __subscription;
	}
}
