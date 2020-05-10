package rx.observers;

using Safety;

@:generic class ObserverBase<T> implements IObserver<T>
{
	final state : AtomicData<Bool>;

	final onCompletedImpl : () -> Void;

	final onErrorImpl : (_error : String) -> Void;

	final onNextImpl : (_value : T) -> Void;

	public function new(?_onCompleted : () -> Void, ?_onError : (_error : String) -> Void, ?_onNext : (_value : T) -> Void)
	{
		state           = new AtomicData(false);
		onCompletedImpl = _onCompleted.or(() -> {});
		onErrorImpl     = _onError.or(e -> throw e);
		onNextImpl      = _onNext.or(v -> {});
	}

	public function onCompleted()
	{
		final wasStopped = stop();

		if (!wasStopped)
		{
			onCompletedImpl();
		}
	}

	public function stop() return state.compare_and_set(false, true);

	public function onError(_error : String)
	{
		final wasStopped = stop();
		if (!wasStopped)
		{
			onErrorImpl(_error);
		}
	}

	public function onNext(_value : T)
	{
		if (!state.unsafe_get())
		{
			onNextImpl(_value);
		}
	}
}
