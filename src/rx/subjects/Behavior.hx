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

typedef BehaviorState<T> = {
	var last_notification:Notification<T>;
	var observers:Array<IObserver<T>>;
}

/**
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/BehaviorSubject.java
 */
class Behavior<T> implements IObservable<T> implements ISubject<T> {
	final state:AtomicData<BehaviorState<T>>;

	static public function create<T>(_default_value:T)
		return new Behavior<T>(_default_value);

	public function new(default_value:T) {
		state = AtomicData.create({
			last_notification: OnNext(default_value),
			observers: []
		});
	}

	public function subscribe(_observer:IObserver<T>):ISubscription {
		sync((_state:BehaviorState<T>) -> {
			_state.observers.push(_observer);

			switch _state.last_notification {
				case OnCompleted:
					_observer.onCompleted();
				case OnError(e):
					_observer.onError(e);
				case OnNext(v):
					_observer.onNext(v);
			}
		});

		return Subscription.create(() -> {
			update((_state:BehaviorState<T>) -> {
				_state.observers = Utils.unsubscribe_observer(_observer, _state.observers);

				return _state;
			});
		});
	}

	public function unsubscribe()
		update((_state:BehaviorState<T>) -> {
			_state.observers = [];
			return _state;
		});

	public function onCompleted()
		sync((_state:BehaviorState<T>) -> {
			_state.last_notification = OnCompleted;
			for (iter in _state.observers) {
				iter.onCompleted();
			}
		});

	public function onError(_error:String)
		sync((_state:BehaviorState<T>) -> {
			_state.last_notification = OnError(_error);
			for (iter in _state.observers) {
				iter.onError(_error);
			}
		});

	public function onNext(_value:T)
		sync((_state:BehaviorState<T>) -> {
			_state.last_notification = OnNext(_value);
			for (iter in _state.observers) {
				iter.onNext(_value);
			}
		});

	inline function update(f)
		return AtomicData.update(f, state);

	inline function sync(f)
		return AtomicData.synchronize(f, state);
}
