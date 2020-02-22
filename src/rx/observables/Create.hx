package rx.observables;

import rx.disposables.ISubscription;
import rx.observers.IObserver;

class Create<T> implements IObservable<T> {
	/**
	 * The function which will be called when an observer subscribes.
	 */
	final subscriptionFunction:(_observer:IObserver<T>) -> ISubscription;

	public function new(_subscriptionFunction:(_observer:IObserver<T>) -> ISubscription) {
		subscriptionFunction = _subscriptionFunction;
	}

	public function subscribe(_observer:IObserver<T>):ISubscription
		return subscriptionFunction(_observer);
}
