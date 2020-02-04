package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.Observer;

class Append<T> implements IObservable<T>
{
	final source1 : IObservable<T>;
	final source2 : IObservable<T>;

	public function new(_source1 : IObservable<T>, _source2 : IObservable<T>)
	{
		source1 = _source1;
		source2 = _source2;
	}

	public function subscribe(_observer : IObserver<T>) : ISubscription
	{
		final unsubscribe = Composite.create();
		final o1_observer = Observer.create(
			() -> unsubscribe.add(source2.subscribe(_observer)),
			_observer.onError,
			_observer.onNext);

		unsubscribe.add(source1.subscribe(o1_observer));

		return unsubscribe;
	}
}
