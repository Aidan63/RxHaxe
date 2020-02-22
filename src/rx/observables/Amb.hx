package rx.observables;

import rx.Observer;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.disposables.SingleAssignment;
import rx.disposables.Composite;

/**
 * Given two source Observables, emit all of the items from only the first of these Observables to emit an item or notification.
 * 
 * When you pass a number of source Observables to Amb, it will pass through the emissions and notifications of exactly one of these Observables: the first one that sends a notification to Amb, either by emitting an item or sending an onError or onCompleted notification.
 * Amb will ignore and discard the emissions and notifications of all of the other source Observables.
 * 
 * http://reactivex.io/documentation/operators/amb.html
 */
class Amb<T> implements IObservable<T>
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
		final subscriptionA = SingleAssignment.create();
		final subscriptionB = SingleAssignment.create();

		final unsubscribe = Composite.create();
		unsubscribe.add(subscriptionA);
		unsubscribe.add(subscriptionB);

		final observerA = Observer.create(
			() -> {
				subscriptionB.unsubscribe();
				_observer.onCompleted();
			},
			error -> {
				subscriptionB.unsubscribe();
				_observer.onError(error);
			},
			value -> {
				subscriptionB.unsubscribe();
				_observer.onNext(value);
			});
		final observerB = Observer.create(
			() -> {
				subscriptionA.unsubscribe();
				_observer.onCompleted();
			},
			error -> {
				subscriptionA.unsubscribe();
				_observer.onError(error);
			},
			value -> {
				subscriptionA.unsubscribe();
				_observer.onNext(value);
			});

		subscriptionA.set(source1.subscribe(observerA));
		subscriptionB.set(source2.subscribe(observerB));

		return unsubscribe;
	}
}
