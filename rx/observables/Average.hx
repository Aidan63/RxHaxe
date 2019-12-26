package rx.observables;

import rx.Observer;
import rx.observers.IObserver;
import rx.observables.IObservable;
import rx.disposables.ISubscription;

typedef AverageState = {
	var sum:Float;
	var count:Int;
}

class Average<T> extends Observable<Float> {
	final source:IObservable<T>;

	public function new(_source:IObservable<T>) {
		super();

		source = _source;
	}

	override public function subscribe(observer:IObserver<Float>):ISubscription {
		var state = AtomicData.create({sum: 0.0, count: 0});
		var average_observer = Observer.create(() -> {
			var s:AverageState = AtomicData.unsafe_get(state);

			if (s.count == 0.0) {
				observer.onError('Sequence contains no elements');
			}

			final average:Float = s.sum / s.count;

			observer.onNext(average);
			observer.onCompleted();
		}, observer.onError, (value:T) -> {
				AtomicData.update((s : AverageState) -> {
					try {
						s.sum = s.sum + cast(value);
						s.count = s.count + 1;
					} catch (ex:String) {
						observer.onError(ex);
					}

					return s;
				}, state);
			});

		return source.subscribe(average_observer);
	}
}
