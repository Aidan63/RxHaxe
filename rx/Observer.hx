package rx;

import rx.Core.RxObserver;
import rx.observers.CheckedObserver;
import rx.observers.SynchronizedObserver;
import rx.observers.AsyncLockObserver;
import rx.observers.IObserver;

using Safety;

class Observer<T> implements IObserver<T>
{
    /**
     * Observer anonymous object.
     */
    final observer : RxObserver<T>;

    public function new(_on_completed : () -> Void, _on_error : (_error : String) -> Void, _on_next : (_value : T) -> Void)
    {
        observer = {
            onCompleted : _on_completed,
            onError     : _on_error,
            onNext      : _on_next
        };
    }

    /**
     * Completes the observer.
     */
    public function onCompleted()
        observer.onCompleted();

    /**
     * Passes an error into the observer.
     * @param _error Error message.
     */
    public function onError(_error : String)
        observer.onError(_error);

    /**
     * Passes the next value into the observer.
     * @param _value Next value.
     */
    public function onNext(_value : T)
        observer.onNext(_value);

    /**
     * Factory function to create an observable providing only the functions you're interested in.
     * @param _onCompleted Function to call when the subscribed observable has finished producing values. If no function is provided a no-op function is used.
     * @param _onError Function to call when the subscribed observable has produced an error. If no function is provided a function which throws the given error is used.
     * @param _onNext Function to call when the subscribed observable produces a value.
     * @return Observer object.
     */
    inline static public function create<T>(?_onCompleted : () -> Void, ?_onError : (_error : String) -> Void, _onNext : (_value : T) -> Void)
        return new Observer(
            _onCompleted.or(() -> {}),
            _onError.or((_error) -> throw _error),
            _onNext);

    inline static public function checked<T>(_observer : IObserver<T>)
        return CheckedObserver.create(_observer);

    inline static public function synchronize<T>(_observer : IObserver<T>)
        return SynchronizedObserver.create(_observer);

    inline static public function synchronize_async_lock<T>(_observer : IObserver<T>)
        return AsyncLockObserver.create(_observer);
}