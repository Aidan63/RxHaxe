package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

/* Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationDematerialize.java
 */
class Dematerialize<T> implements IObservable<T> {
	var _source:IObservable<Notification<T>>;

	public function new(source:IObservable<Notification<T>>) {
		_source = source;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var materialize_observer = Observer.create(null, null, function(v:Notification<T>) {
			switch (v) {
				case OnCompleted:
					{
						observer.onCompleted();
					}
				case OnError(e):
					{
						observer.onError(e);
					}
				case OnNext(vv):
					{
						observer.onNext(vv);
					}
				default:
					{}
			};
		});
		return _source.subscribe(materialize_observer);
	}
}
