package rx.observables;

import rx.observers.IObserver;
import rx.disposables.ISubscription;
import rx.schedulers.IScheduler;

class ObserveOnThis<T> extends Observable<T>
{
	final source : Observable<T>;

	final scheduler : IScheduler;

	public function new(_source : Observable<T>, _scheduler : IScheduler)
	{
		super();

		source    = _source;
		scheduler = _scheduler;
	}

    override function subscribe(_observer : IObserver<T>) : ISubscription
    {
        return source.subscribe(Observer.create(
			() -> scheduler.schedule_absolute(null, _observer.onCompleted),
			(_error) -> scheduler.schedule_absolute(null, _observer.onError.bind(_error)),
			(_value) -> scheduler.schedule_absolute(null, _observer.onNext.bind(_value))
		));
    }
}