package rx.observers;

@:generic class AsyncLockObserver<T> implements IObserver<T>
{
	final asyncLock : AsyncLock;

	final observer : ObserverBase<T>;

	public function new(_onCompleted : ()->Void, _onError : String->Void, _onNext : T->Void)
	{
		asyncLock = new AsyncLock();
		observer   = new ObserverBase(
			() -> asyncLock.wait(() -> _onCompleted()),
			e -> asyncLock.wait(() -> _onError(e)),
			v -> asyncLock.wait(() -> _onNext(v)));
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
