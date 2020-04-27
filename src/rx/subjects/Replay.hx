package rx.subjects;

import rx.observables.IObservable;
import rx.AtomicData;
import rx.Subscription;
import rx.Utils;
import rx.Observable;
import rx.observers.IObserver;
import rx.subjects.ISubject;
import rx.disposables.ISubscription;
import rx.notifiers.Notification;

/**
 * Implementation based on:
 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/ReplaySubject.cs
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/ReplaySubject.java
 */
@:generic class Replay<T> implements IObservable<T> implements ISubject<T>
{
	final state : AtomicData<ReplayState<T>>;

	public function new()
	{
		state = new AtomicData(new ReplayState<T>(new List(), false, []));
	}

	public function subscribe(_observer : IObserver<T>) : ISubscription
	{
		sync((_state:ReplayState<T>) -> {
			_state.observers.push(_observer);

			for (iter in _state.queue) {
				switch iter {
					case OnCompleted:
						_observer.onCompleted();
					case OnError(e):
						_observer.onError(e);
					case OnNext(v):
						_observer.onNext(v);
				}
			}
		});

		return Subscription.create(() -> {
			update(state -> {
				state.observers.remove(_observer);

				return state;
			});
		});
	}

	public function unsubscribe()
		update(state -> {
			state.observers.resize(0);
			return state;
		});

	public function onCompleted()
		if_not_stopped((_state:ReplayState<T>) -> {
			_state.isStopped = true;
			_state.queue.add(OnCompleted);
			for (iter in _state.observers) {
				iter.onCompleted();
			}
		});

	public function onError(_error:String)
		if_not_stopped((_state:ReplayState<T>) -> {
			_state.isStopped = true;
			_state.queue.add(OnError(_error));
			for (iter in _state.observers) {
				iter.onError(_error);
			}
		});

	public function onNext(_value:T)
		if_not_stopped((_state:ReplayState<T>) -> {
			_state.queue.add(OnNext(_value));
			for (iter in _state.observers) {
				iter.onNext(_value);
			}
		});

	function update(f)
		return state.update(f);

	function sync(f)
		return state.synchronize(f);

	function if_not_stopped(f)
		return sync((s) -> if (!s.isStopped) f(s));
}

@:generic private class ReplayState<T>
{
	public var queue : List<Notification<T>>;

	public var isStopped : Bool;

	public final observers : Array<IObserver<T>>;

	public function new(_queue, _isStopped, _observers)
	{
		queue     = _queue;
		isStopped = _isStopped;
		observers = _observers;
	}
}
