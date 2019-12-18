package rx;

import rx.Core.RxObserver;
import rx.observers.CheckedObserver;
import rx.observers.SynchronizedObserver;
import rx.observers.AsyncLockObserver;
import rx.observers.IObserver;

using Safety;

class Observer<T> implements IObserver<T>
{
    final observer : RxObserver<T>;

    public function new(?_on_completed:Void -> Void, ?_on_error:String -> Void, _on_next:T -> Void)
    {
        observer = {
            onCompleted : _on_completed,
            onError     : _on_error,
            onNext      : _on_next
        };
    }

    public function onCompleted()
        observer.onCompleted();

    public function onError(_e : String)
        observer.onError(_e);

    public function onNext(_x : T)
        observer.onNext(_x);

    static public function create<T>(?_onCompleted : () -> Void, ?_onError : (_error : String) -> Void, _onNext : (_value : T) -> Void)
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