package rx.observables;

import rx.Observer;
import rx.observers.IObserver;
import rx.observables.IObservable;
import rx.disposables.ISubscription;

typedef AverageState = {
	var sum : Float;
	var count : Int;
}

/**
 * Calculates the average of numbers emitted by an Observable and emits this average.
 * 
 * The `Average` operator operates on an Observable that emits integers or floats, and emits a single value: the average of all of the numbers emitted by the source Observable.
 * 
 * http://reactivex.io/documentation/operators/average.html
 */
class Average<T : Float & Int> implements IObservable<Float>
{
	final source : IObservable<T>;

	public function new(_source : IObservable<T>)
	{
		source = _source;
	}

	public function subscribe(_observer : IObserver<Float>) : ISubscription
	{
		final state    = AtomicData.create({ sum : 0.0, count : 0 });
		final observer = Observer.create(
			() -> {
				final s : AverageState = AtomicData.unsafe_get(state);

				if (s.count == 0.0)
				{
					_observer.onError('Sequence contains no elements');
				}

				final average = s.sum / s.count;

				_observer.onNext(average);
				_observer.onCompleted();
			},
			_observer.onError,
			(value : T) -> {
				AtomicData.update((s : AverageState) -> {
					s.sum   = s.sum + value;
					s.count = s.count + 1;

					return s;
				}, state);
			});

		return source.subscribe(observer);
	}
}
