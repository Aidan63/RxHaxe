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

typedef ReplayState<T> = {
	var queue:List<Notification<T>>;
	var is_stopped:Bool;
	var observers:Array<IObserver<T>>;
}

/**
 * Implementation based on:
 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/ReplaySubject.cs
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/ReplaySubject.java
 */
class Replay<T> implements IObservable<T> implements ISubject<T> {
	final state:AtomicData<ReplayState<T>>;

	inline function update(f)
		return AtomicData.update(f, state);

	inline function sync(f)
		return AtomicData.synchronize(f, state);

	inline function if_not_stopped(f)
		return sync((s) -> if (!s.is_stopped) f(s));

	static public function create<T>()
		return new Replay<T>();

	function new() {
		state = AtomicData.create({
			queue: new List<Notification<T>>(),
			is_stopped: false,
			observers: []
		});
	}

	public function subscribe(_observer:IObserver<T>):ISubscription {
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
			update((_state:ReplayState<T>) -> {
				_state.observers = Utils.unsubscribe_observer(_observer, _state.observers);

				return _state;
			});
		});
	}

	public function unsubscribe()
		update((_state:ReplayState<T>) -> {
			_state.observers = [];
			return _state;
		});

	public function onCompleted()
		if_not_stopped((_state:ReplayState<T>) -> {
			_state.is_stopped = true;
			_state.queue.add(OnCompleted);
			for (iter in _state.observers) {
				iter.onCompleted();
			}
		});

	public function onError(_error:String)
		if_not_stopped((_state:ReplayState<T>) -> {
			_state.is_stopped = true;
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
}
