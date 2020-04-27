package rx.subjects;

import rx.AtomicData;
import rx.Subscription;
import rx.Utils;
import rx.Observable;
import rx.observables.IObservable;
import rx.observers.IObserver;
import rx.subjects.ISubject;
import rx.disposables.ISubscription;
import rx.notifiers.Notification;

/**
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/BehaviorSubject.java
 */
@:generic class Behavior<T> implements IObservable<T> implements ISubject<T>
{
	final state : AtomicData<BehaviorState<T>>;

	public function new(defaultValue : T)
	{
		state = new AtomicData(new BehaviorState(OnNext(defaultValue), []));
	}

	public function subscribe(_observer : IObserver<T>) : ISubscription
	{
		sync(state -> {
			state.observers.push(_observer);

			switch state.lastNotification {
				case OnCompleted:
					_observer.onCompleted();
				case OnError(e):
					_observer.onError(e);
				case OnNext(v):
					_observer.onNext(v);
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
		sync(state -> {
			state.lastNotification = OnCompleted;
			for (observable in state.observers)
			{
				observable.onCompleted();
			}
		});

	public function onError(_error : String)
		sync(state -> {
			state.lastNotification = OnError(_error);

			for (observable in state.observers)
			{
				observable.onError(_error);
			}
		});

	public function onNext(_value : T)
		sync(state -> {
			state.lastNotification = OnNext(_value);

			for (observable in state.observers)
			{
				observable.onNext(_value);
			}
		});

	function update(_func : (BehaviorState<T>)->BehaviorState<T>)
		return state.update(_func);

	function sync<B>(_func : (_in : BehaviorState<T>) -> B)
		return state.synchronize(_func);
}

@:generic private class BehaviorState<T>
{
	public var lastNotification : Notification<T>;

	public final observers : Array<IObserver<T>>;

	public function new(_lastNotification, _observers)
	{
		lastNotification = _lastNotification;
		observers        = _observers;
	}
}
