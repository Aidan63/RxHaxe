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
		var __subscription = new SingleAssignment();
		var state = new AtomicData(false);
		var contains_observer = new Observer(function() {
			state.update_if(function(s:Bool) {
				return s == false;
			}, function(s:Bool) {
				observer.onNext(s);
				return s;
			});
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(v:T) {
			state.update_if(function(s:Bool) {
				return s == false && _hasValue(v);
			}, function(s:Bool) {
				s = true;
				observer.onNext(s);
				__subscription.unsubscribe();
				return s;
			});
		});

		__subscription.set(_source.subscribe(contains_observer));
		return __subscription;
	}
}
