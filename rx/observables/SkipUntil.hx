package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Binary;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class SkipUntil<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var _other:IObservable<T>;

	public function new(source:IObservable<T>, other:IObservable<T>) {
		_source = source;
		_other = other;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		// lock
		var triggered = false;
		var otherSubscription = SingleAssignment.create();
		var other_observer = Observer.create(function() {
			triggered = true;
			otherSubscription.unsubscribe();
		}, function(e:String) {
			triggered = true;
			otherSubscription.unsubscribe();
		}, function(v:T) {
			triggered = true;
			otherSubscription.unsubscribe();
		});
		otherSubscription.set(_other.subscribe(other_observer));
		var skipUntil_observer = Observer.create(function() {
			if (triggered)
				observer.onCompleted();
		}, function(e:String) {
			if (triggered)
				observer.onError(e);
		}, function(v:T) {
			if (triggered)
				observer.onNext(v);
		});
		var sourceSubscription = _source.subscribe(skipUntil_observer);
		return Binary.create(sourceSubscription, otherSubscription);
	}
}
