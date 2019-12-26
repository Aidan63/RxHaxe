package rx.subjects;

import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;

typedef AsyncState<T> = {
	var ?last_notification:Notification<T>;
	var is_stopped:Bool;
	var observers:Array<IObserver<T>>;
}

/**
 * Implementation based on:
 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/AsyncSubject.cs
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/AsyncSubject.java
 */
class Async<T> extends Observable<T> implements ISubject<T> {
	final state:AtomicData<AsyncState<T>>;

	static public function create<T>()
		return new Async<T>();

	function emit_last_notification(_observer:IObserver<T>, _state:AsyncState<T>)
		switch _state.last_notification {
			case OnCompleted:
				throw "Bug in AsyncSubject: should not store  notification .OnCompleted as last notificaition";
			case OnError(e):
				_observer.onError(e);
			case OnNext(v):
				_observer.onNext(v);
				_observer.onCompleted();
		}

	inline function update(f)
		return AtomicData.update(f, state);

	inline function sync(f)
		return AtomicData.synchronize(f, state);

	inline function if_not_stopped(f)
		return sync(s -> if (!s.is_stopped) f(s));

	public function new() {
		super();

		state = AtomicData.create({
			last_notification: null,
			is_stopped: false,
			observers: []
		});
	}

	override function subscribe(_observer:IObserver<T>):ISubscription {
		sync((_state:AsyncState<T>) -> {
			_state.observers.push(_observer);

			if (_state.is_stopped) {
				emit_last_notification(_observer, _state);
			}
		});

		return Subscription.create(() -> {
			update((_state:AsyncState<T>) -> {
				_state.observers = Utils.unsubscribe_observer(_observer, _state.observers);

				return _state;
			});
		});
	}

	public function unsubscribe()
		update((_state:AsyncState<T>) -> {
			_state.observers = [];
			return _state;
		});

	public function onCompleted()
		if_not_stopped((_state:AsyncState<T>) -> {
			_state.is_stopped = true;
			for (iter in _state.observers) {
				emit_last_notification(iter, _state);
			}
		});

	public function onError(_error:String)
		if_not_stopped((_state:AsyncState<T>) -> {
			_state.is_stopped = true;
			_state.last_notification = OnError(_error);
			for (iter in _state.observers) {
				iter.onError(_error);
			}
		});

	public function onNext(v:T)
		if_not_stopped((_state:AsyncState<T>) -> {
			_state.last_notification = OnNext(v);
		});
}
