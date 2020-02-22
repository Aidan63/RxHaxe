package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class Contains<T> implements IObservable<Bool> {
	var _source:IObservable<T>;
	var _hasValue:T->Bool;

	public function new(source:IObservable<T>, hasValue:T->Bool) {
		_source = source;
		_hasValue = hasValue;
	}

	public function subscribe(observer:IObserver<Bool>):ISubscription {
		var __subscription = SingleAssignment.create();
		var state = AtomicData.create(false);
		var contains_observer = Observer.create(function() {
			AtomicData.update_if(function(s:Bool) {
				return s == false;
			}, function(s:Bool) {
				observer.onNext(s);
				return s;
			}, state);
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(v:T) {
			AtomicData.update_if(function(s:Bool) {
				return s == false && _hasValue(v);
			}, function(s:Bool) {
				s = true;
				observer.onNext(s);
				__subscription.unsubscribe();
				return s;
			}, state);
		});

		__subscription.set(_source.subscribe(contains_observer));
		return __subscription;
	}
}
