package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.Observer;

typedef BufferState<T> = {
	var list:Array<T>;
}

class Buffer<T> implements IObservable<Array<T>> {
	var source:IObservable<T>;
	var count:Int;

	public function new(_source:IObservable<T>, _count:Int) {
		source = _source;
		count = _count;
	}

	public function subscribe(_observer:IObserver<Array<T>>):ISubscription {
		// lock
		final state = AtomicData.create({list: []});
		final buffer_observer = Observer.create(() -> {
			// lock
			AtomicData.update_if((s : BufferState<T>) -> s.list.length > 0, (s : BufferState<T>) -> {
				_observer.onNext(s.list);
				return s;
			}, state);
			_observer.onCompleted();
		}, (_error : String) -> {
				// lock
				AtomicData.update_if((s : BufferState<T>) -> s.list.length > 0, (s : BufferState<T>) -> {
					_observer.onNext(s.list);
					return s;
				}, state);

				_observer.onError(_error);
			}, (_value:T) -> {
				// lock
				AtomicData.update_if((s : BufferState<T>) -> s.list.length < count, (s : BufferState<T>) -> {
					s.list.push(_value);

					if (s.list.length == count) {
						_observer.onNext(s.list);
						s.list.resize(0);
					}

					return s;
				}, state);
			});

		return source.subscribe(buffer_observer);
	}
}
