package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Binary;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class TakeUntil<T> extends Observable<T> {
	var _source:IObservable<T>;
	var _other:IObservable<T>;

	public function new(source:IObservable<T>, other:IObservable<T>) {
		super();
		_source = source;
		_other = other;
	}

	override public function subscribe(observer:IObserver<T>):ISubscription {
		var otherSubscription = SingleAssignment.create();
		var other_observer = Observer.create(function() {
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
		var takeUntil_observer = Observer.create(function() {
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(v:T) {
			observer.onNext(v);
		});
		var sourceSubscription = _source.subscribe(takeUntil_observer);
		return Binary.create(sourceSubscription, otherSubscription);
	}
}
