package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Binary;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class TakeUntil<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var _other:IObservable<T>;

	public function new(source:IObservable<T>, other:IObservable<T>) {
		_source = source;
		_other = other;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var otherSubscription = new SingleAssignment();
		var other_observer = new Observer(function() {
			observer.onCompleted();
			otherSubscription.unsubscribe();
		}, function(e:String) {
			observer.onCompleted();
			otherSubscription.unsubscribe();
		}, function(v:T) {
			observer.onCompleted();
			otherSubscription.unsubscribe();
		});

		otherSubscription.set(_other.subscribe(other_observer));
		var takeUntil_observer = new Observer(function() {
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(v:T) {
			observer.onNext(v);
		});
		var sourceSubscription = _source.subscribe(takeUntil_observer);
		return new Binary(sourceSubscription, otherSubscription);
	}
}
