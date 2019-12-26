package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.Observer;

class Append<T> extends Observable<T> {
	final source1:IObservable<T>;
	final source2:IObservable<T>;

	public function new(_source1:IObservable<T>, _source2:IObservable<T>) {
		super();

		source1 = _source1;
		source2 = _source2;
	}

	override public function subscribe(observer:IObserver<T>):ISubscription {
		final unsubscribe = Composite.create();
		final o1_observer = Observer.create(() -> unsubscribe.add(source2.subscribe(observer)), observer.onError, (v:T) -> observer.onNext(v));

		unsubscribe.add(source1.subscribe(o1_observer));

		return unsubscribe;
	}
}
