package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;

class Error<T> implements IObservable<T> {
	var err:String;

	public function new(err:String) {
		this.err = err;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		observer.onError(err);
		return Subscription.empty();
	}
}
