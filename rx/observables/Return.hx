package rx.observables;

import rx.disposables.ISubscription;
import rx.observers.IObserver;

class Return<T> extends Observable<T> {
	final v:T;

	public function new(_v:T) {
		super();

		v = _v;
	}

	override public function subscribe(_observer:IObserver<T>):ISubscription {
		_observer.onNext(v);
		_observer.onCompleted();

		return Subscription.empty();
	}
}
