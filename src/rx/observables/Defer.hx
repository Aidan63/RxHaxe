package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class Defer<T> implements IObservable<T> {
	var _observableFactory : Void->IObservable<T>;

	public function new(observableFactory:Void->IObservable<T>) {
		_observableFactory = observableFactory;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var _source:IObservable<T> = null;
		try {
			_source = _observableFactory();
		} catch (ex:String) {
			throw ex;

			// _source = Observable.error(ex); //error why
		}
		return _source.subscribe(observer);
	}
}
