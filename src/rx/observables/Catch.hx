package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SerialAssignment;
import rx.observers.IObserver;
import rx.Observer;

class Catch<T> implements IObservable<T> {
	final source:IObservable<T>;

	final errorHandler:String->IObservable<T>;

	public function new(_source:IObservable<T>, _errorHandler:String->IObservable<T>) {
		source = _source;
		errorHandler = _errorHandler;
	}

	public function subscribe(_observer:IObserver<T>):ISubscription {
		var serialDisposable = SerialAssignment.create();

		var catch_observer = Observer.create(() -> _observer.onCompleted(), (_error : String) -> {
			var next = errorHandler(_error);
			serialDisposable.set(next.subscribe(_observer));
			_observer.onError(_error);
		}, (_value:T) -> _observer.onNext(_value));

		serialDisposable.set(source.subscribe(catch_observer));

		return serialDisposable;
	}
}
