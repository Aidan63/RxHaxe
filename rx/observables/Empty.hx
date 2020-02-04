package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;

class Empty<T> implements IObservable<T> {
	public function new()
	{
		//
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		observer.onCompleted();
		return Subscription.empty();
	}
}
