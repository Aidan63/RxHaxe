package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.Observer;

/**
 * Emit the emissions from two or more Observables without interleaving them.
 * 
 * The `Append` operator concatenates the output of multiple Observables so that they act like a single Observable, with all of the items emitted by the first Observable being emitted before any of the items emitted by the second Observable (and so forth, if there are more than two).
 * 
 * `Append` waits to subscribe to each additional Observable that you pass to it until the previous Observable completes.
 * Note that because of this, if you try to concatenate a “hot” Observable, that is, one that begins emitting items immediately and before it is subscribed to, Concat will not see, and therefore will not emit, any items that Observable emits before all previous Observables complete and Concat subscribes to the “hot” Observable.
 * 
 * http://reactivex.io/documentation/operators/concat.html
 */
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
		final observer    = Observer.create(
			() -> unsubscribe.add(source2.subscribe(_observer)),
			_observer.onError,
			_observer.onNext);

		unsubscribe.add(source1.subscribe(observer));

		return unsubscribe;
	}
}
