package rx;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.subjects.ISubject;
import rx.subjects.Async;
import rx.subjects.Replay;
import rx.subjects.Behavior;
import rx.AtomicData;
import rx.Subscription;
import rx.Observable;
import rx.Utils;

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

	function update(_func : Array<IObserver<T>>->Array<IObserver<T>>)
		return observers.update(_func);

	function sync(_func : Array<IObserver<T>>->Array<IObserver<T>>)
		return observers.synchronize(_func);

	function iter(_func : (_observers : IObserver<T>) -> IObserver<T>)
		return sync(os -> os.map(_func));

	public function subscribe(_observer : IObserver<T>):ISubscription
	{
		update(_obs -> {
			_obs.push(_observer);

			return _obs;
		});

		return Subscription.create(() -> update(Utils.unsubscribe_observer.bind(_observer)));
	}

	public function unsubscribe()
		observers.set([]);

	public function onCompleted()
		iter(_observer -> {
			_observer.onCompleted();
			return _observer;
		});

	public function onError(_e:String)
		iter(_observer -> {
			_observer.onError(_e);
			return _observer;
		});

	public function onNext(_v:T)
		iter(_observer -> {
			_observer.onNext(_v);
			return _observer;
		});
}
