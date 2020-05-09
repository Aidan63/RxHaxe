package rx.subjects;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;

/**
 * Implementation based on:
 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/AsyncSubject.cs
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/AsyncSubject.java
 */
@:generic class Async<T> implements IObservable<T> implements ISubject<T>
{
	final state : AtomicData<AsyncState<T>>;

	public function new()
	{
		state = new AtomicData(new AsyncState<T>(null, false, []));
	}

	public function subscribe(_observer : IObserver<T>) : ISubscription
	{
		state.synchronize(state -> {
			state.observers.push(_observer);

			if (state.isStopped)
			{
				emit_last_notification(_observer, state);
			}
		});

		return Subscription.create(() -> {
			state.update(state -> {
				state.observers.remove(_observer);

				return state;
			});
		});
	}

	public function unsubscribe()
		state.update(state -> {
			state.observers.resize(0);
			return state;
		});

	public function onCompleted()
		if_not_stopped(state -> {
			state.isStopped = true;
			for (observer in state.observers)
			{
				emit_last_notification(observer, state);
			}
		});

	public function onError(_error : String)
		if_not_stopped(state -> {
			state.isStopped        = true;
			state.lastNotification = OnError(_error);

			for (observer in state.observers)
			{
				observer.onError(_error);
			}
		});

	public function onNext(_next : T)
		if_not_stopped(state -> {
			state.lastNotification = OnNext(_next);
		});

	function emit_last_notification(_observer : IObserver<T>, _state : AsyncState<T>)
		switch _state.lastNotification {
			case OnCompleted:
				throw "Bug in AsyncSubject: should not store notification OnCompleted as last notificaition";
			case OnError(e):
				_observer.onError(e);
			case OnNext(v):
				_observer.onNext(v);
				_observer.onCompleted();
		}

	function if_not_stopped<B>(_func : AsyncState<T>->B)
		return state.synchronize(s -> if (!s.isStopped) _func(s));
}

@:generic private class AsyncState<T>
{
	public var lastNotification : Null<Notification<T>>;

	public var isStopped : Bool;

	public final observers : Array<IObserver<T>>;

	public function new(_lastNotification, _isStopped, _observers)
	{
		lastNotification = _lastNotification;
		isStopped        = _isStopped;
		observers        = _observers;
	}
}
