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
class Materialize<T> implements IObservable<Notification<T>>
{
	final source : IObservable<T>;

	public function new(_source : IObservable<T>)
	{
		source = _source;
	}

	public function subscribe(_observer : IObserver<Notification<T>>) : ISubscription
	{
		final observer = Observer.create(
			() -> {
				_observer.onNext(OnCompleted);
				_observer.onCompleted();
			},
			error -> {
				_observer.onNext(OnError(error));
				_observer.onCompleted();
			},
			value -> {
				_observer.onNext(OnNext(value));
			});

		return source.subscribe(observer);
	}
}
