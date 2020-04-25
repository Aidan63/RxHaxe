package rx.schedulers;

import rx.disposables.ISubscription;

class DiscardableAction
{
	var state : AtomicData<DiscardableActionState>;

	static public function create(_action : () -> ISubscription) : DiscardableAction
	{
		return new DiscardableAction(_action);
	}

	public function was_ready()
	{
		final oldState = AtomicData.update_if(
			(_s : DiscardableActionState) -> _s.ready,
			(_s : DiscardableActionState) -> {
				_s.ready = false;
				return _s;
			},
			state);

		return oldState.ready;
	}

	public function action()
	{
		if (was_ready())
		{
			AtomicData.update(
				(_s : DiscardableActionState) -> {
					_s.unSubscribe = _s.action();
					return _s;
				},
				state);
		}
	}

	public function unsubscribe() return AtomicData.unsafe_get(state).unSubscribe;

	function new(_action : () -> ISubscription)
	{
		state = AtomicData.create(new DiscardableActionState(true, Subscription.empty(), null));

		AtomicData.update(
			(_s : DiscardableActionState) -> {
				_s.action      = _action;
				_s.unSubscribe = Subscription.create(() -> AtomicData.update((_s1 : DiscardableActionState) -> {
					_s1.ready = false;
					return _s1;
				}, state));

				return _s;
			},
			state);
	}
}

private class DiscardableActionState
{
	public var ready : Bool;
	public var unSubscribe : ISubscription;
	public var action : Null<Void->ISubscription>;

	public function new(_ready, _unSubscribe, _action)
	{
		ready       = _ready;
		unSubscribe = _unSubscribe;
		action      = _action;
	}
}
