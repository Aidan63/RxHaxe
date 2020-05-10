package rx.observers;

using Safety;

import hx.concurrent.lock.RLock;

@:generic class SynchronizedObserver<T> implements IObserver<T>
{
	final mutex : RLock;
	
	final onCompletedImpl : () -> Void;

	final onErrorImpl : (_error : String) -> Void;

	final onNextImpl : (_value : T) -> Void;

	public function new(?_onCompleted : () -> Void, ?_onError : (_error : String) -> Void, ?_onNext : (_value : T) -> Void)
	{
		mutex           = new RLock();
		onCompletedImpl = _onCompleted.or(() -> {});
		onErrorImpl     = _onError.or(e -> throw e);
		onNextImpl      = _onNext.or(v -> {});
	}

	public function onError(_error : String)
	{
		mutex.acquire();
		onErrorImpl(_error);
		mutex.release();
	}

	public function onNext(_value : T)
	{
		mutex.acquire();
		onNextImpl(_value);
		mutex.release();
	}

	public function onCompleted()
	{
		mutex.acquire();
		onCompletedImpl();
		mutex.release();
	}
}
