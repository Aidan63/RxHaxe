package rx.observers;

@:generic class AsyncLockObserver<T> implements IObserver<T>
{
	final async_lock : AsyncLock;

	final observer : ObserverBase<T>;

	public function new(_observer : IObserver<T>)
	{
		async_lock = new AsyncLock();
		observer   = new ObserverBase(
			() -> with_lock(() -> _observer.onCompleted()),
			e -> with_lock(() -> _observer.onError(e)),
			v -> with_lock(() -> _observer.onNext(v)));
	}

	function with_lock(_func : ()->Void)
	{
		async_lock.wait(_func);
	}

	public function onError(_error : String)
	{
		observer.onError(_error);
	}

	public function onNext(_value : T)
	{
		observer.onNext(_value);
	}

	public function onCompleted()
	{
		observer.onCompleted();
	}
}
