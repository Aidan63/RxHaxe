package rx;

import rx.observers.IObserver;

using Safety;

@:generic class Observer<T> implements IObserver<T>
{
	final onCompletedImpl : () -> Void;

	final onErrorImpl : (_error : String) -> Void;

	final onNextImpl : (_value : T) -> Void;

	public function new(?_onCompleted : () -> Void, ?_onError : (_error : String) -> Void, ?_onNext : (_value : T) -> Void)
	{
		onCompletedImpl = _onCompleted.or(() -> {});
		onErrorImpl     = _onError.or(e -> throw e);
		onNextImpl      = _onNext.or(v -> {});
	}

	/**
	 * Completes the observer.
	 */
	public function onCompleted()
	{
		onCompletedImpl();
	}

	/**
	 * Passes an error into the observer.
	 * @param _error Error message.
	 */
	public function onError(_error : String)
	{
		onErrorImpl(_error);
	}

	/**
	 * Passes the next value into the observer.
	 * @param _value Next value.
	 */
	public function onNext(_value : T)
	{
		onNextImpl(_value);
	}
}
