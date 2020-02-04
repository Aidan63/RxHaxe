package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.disposables.SerialAssignment;
import rx.Subscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.schedulers.IScheduler;

// todo test
class Timestamp<T> implements IObservable<Timestamped<T>>
{
	final source : IObservable<T>;

	final scheduler : IScheduler;

	public function new(_source : IObservable<T>, _scheduler : IScheduler)
	{
		source    = _source;
		scheduler = _scheduler;
	}

	public function subscribe(_observer : IObserver<Timestamped<T>>) : ISubscription
	{
		final timestamp_observer = Observer.create(
			_observer.onCompleted,
			_observer.onError,
			_v -> _observer.onNext(new Timestamped(_v, scheduler.now())));

		return source.subscribe(timestamp_observer);
	}
}
