package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

// type +'a observable = 'a observer -> subscription
/* Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationMaterialize.java
 */
class Materialize<T> implements IObservable<Notification<T>> {
	var _source:IObservable<T>;

	public function new(source:IObservable<T>) {
		_source = source;
	}

	public function subscribe(observer:IObserver<Notification<T>>):ISubscription {
		var materialize_observer = Observer.create(function() {
			observer.onNext(OnCompleted);
			observer.onCompleted();
		}, function(e:String) {
			observer.onNext(OnError(e));
			observer.onCompleted();
		}, function(v:T) {
			observer.onNext(OnNext(v));
		});

		return _source.subscribe(materialize_observer);
	}
}
