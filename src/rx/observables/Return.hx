package rx.observables;

import rx.disposables.ISubscription;
import rx.observers.IObserver;

class Return<T> implements IObservable<T> {
	final v:T;

	public function new(_v:T) {
		v = _v;
	}

	public function subscribe(_observer:IObserver<T>):ISubscription {
		_observer.onNext(v);
		_observer.onCompleted();

		return Subscription.empty();
	}
}
