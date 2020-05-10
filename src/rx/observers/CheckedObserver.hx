package rx.observers;

using Safety;

import rx.Utils;

private enum CheckState {
	Idle;
	Busy;
	Done;
}

/* In the original implementation, synchronization for the observer state
 * is obtained through CAS (compare-and-swap) primitives, but in OCaml we
 * don't have a standard/portable CAS primitive, so I'm using a mutex.
 * (see https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Core/Reactive/Internal/CheckedObserver.cs)
 */
@:generic class CheckedObserver<T> implements IObserver<T>
{
	final state : AtomicData<CheckState>;

	final onCompletedImpl : () -> Void;

	final onErrorImpl : (_error : String) -> Void;

	final onNextImpl : (_value : T) -> Void;

	public function new(?_onCompleted : () -> Void, ?_onError : (_error : String) -> Void, ?_onNext : (_value : T) -> Void)
	{
		state           = new AtomicData(Idle);
		onCompletedImpl = _onCompleted.or(() -> {});
		onErrorImpl     = _onError.or(e -> throw e);
		onNextImpl      = _onNext.or(v -> {});
	}

	public function onError(_error : String)
	{
		wrap_action(() -> onErrorImpl(_error), Done);
	}

	public function onNext(_value : T)
	{
		wrap_action(() -> onNextImpl(_value), Idle);
	}

	public function onCompleted()
	{
		wrap_action(() -> onCompletedImpl(), Done);
	}

	function check(_state : CheckState)
	{
		return switch _state
		{
			case Idle : return Busy;
			case Busy : throw "Reentrancy has been detected.";
			case Done : throw "Observer has already terminated.";
		}
	}

	function check_access() return state.update(check);

	function wrap_action<T>(_func : () -> T, _newState : CheckState)
	{
		check_access();

		Utils.try_finally(_func, () -> state.set(_newState));
	}
}
