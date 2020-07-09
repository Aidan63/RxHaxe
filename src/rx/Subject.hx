package rx;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.subjects.ISubject;
import rx.AtomicData;
import rx.Subscription;

/**
 * Implementation based on :
 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/Subject.cs
 */
@:generic class Subject<T> implements IObservable<T> implements ISubject<T>
{
	final observers : AtomicData<Array<IObserver<T>>>;

	public function new()
	{
		observers = new AtomicData<Array<IObserver<T>>>([]);
	}

	public function subscribe(_observer : IObserver<T>):ISubscription
	{
		observers.update(_array -> {
			_array.push(_observer);

			return _array;
		});

		return Subscription.create(() -> observers.update(_array -> {
			_array.remove(_observer);

			return _array;
		}));
	}

	public function unsubscribe()
		observers.update(_array -> {
			_array.resize(0);

			return _array;
		});

	public function onCompleted()
	{
		for (observer in observers.unsafe_get())
		{
			observer.onCompleted();
		}
	}

	public function onError(_e : String)
	{
		for (observer in observers.unsafe_get())
		{
			observer.onError(_e);
		}
	}

	public function onNext(_v : T)
	{
		for (observer in observers.unsafe_get())
		{
			observer.onNext(_v);
		}
	}
}
