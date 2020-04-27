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
	final observers:AtomicData<Array<IObserver<T>>>;

	static public function create<T>()
		return new Subject<T>();

	static public function async<T>()
		return new Async<T>();

	static public function replay<T>()
		return new Replay<T>();

	static public function behavior<T>(_default_value : T)
		return new Behavior(_default_value);

	function new()
	{
		observers = new AtomicData<Array<IObserver<T>>>([]);
	}

	function update(f:Array<IObserver<T>>->Array<IObserver<T>>)
		return observers.update(f);

	function sync(f:Array<IObserver<T>>->Array<IObserver<T>>)
		return observers.synchronize(f);

	function iter(_f:(_observers:IObserver<T>) -> IObserver<T>)
		return sync((os:Array<IObserver<T>>) -> os.map(_f));

	public function subscribe(_observer:IObserver<T>):ISubscription {
		update(_obs -> {
			_obs.push(_observer);

			return _obs;
		});

		return Subscription.create(() -> update(Utils.unsubscribe_observer.bind(_observer)));
	}

	public function unsubscribe()
		observers.set([]);

	public function onCompleted()
		iter((_observer:IObserver<T>) -> {
			_observer.onCompleted();
			return _observer;
		});

	public function onError(_e:String)
		iter((_observer:IObserver<T>) -> {
			_observer.onError(_e);
			return _observer;
		});

	public function onNext(_v:T)
		iter((_observer:IObserver<T>) -> {
			_observer.onNext(_v);
			return _observer;
		});
}
