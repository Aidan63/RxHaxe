package rx.observables;

import rx.observers.IObserver;
import rx.disposables.ISubscription;
import rx.schedulers.IScheduler;

class ObserveOnThis<T> implements IObservable<T>
{
	final source : IObservable<T>;

	final scheduler : IScheduler;

	public function new(_source : IObservable<T>, _scheduler : IScheduler)
	{
		source    = _source;
		scheduler = _scheduler;
	}

    public function subscribe(_observer : IObserver<T>) : ISubscription
    {
        return source.subscribe(new Observer(
			() -> scheduler.scheduleAbsolute(0, _observer.onCompleted),
			(_error) -> scheduler.scheduleAbsolute(0, _observer.onError.bind(_error)),
			(_value) -> scheduler.scheduleAbsolute(0, _observer.onNext.bind(_value))
		));
    }
}