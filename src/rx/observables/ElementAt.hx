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
		var counter = new AtomicData(0);
		var __subscription = new SingleAssignment();
		var elementAt_observer = new Observer(function() {
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(value:T) {
			counter.update_if(function(c:Int) return c == _index, function(c:Int) {
				observer.onNext(value);
				observer.onCompleted();
				__subscription.unsubscribe();
				return c;
			});
			counter.update(Utils.succ);
		});
		__subscription.set(_source.subscribe(elementAt_observer));
		return __subscription;
	}
}
