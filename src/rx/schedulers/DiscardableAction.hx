package rx.schedulers;

import rx.disposables.ISubscription;

class DiscardableAction
{
	var state : AtomicData<DiscardableActionState>;

	public function new(_action : () -> ISubscription)
	{
		state = new AtomicData(new DiscardableActionState(true, Subscription.empty(), null));
		state.update(
			(_state : DiscardableActionState) -> {
				_state.action      = _action;
				_state.unSubscribe = Subscription.create(() -> state.update((_otherState : DiscardableActionState) -> {
					_otherState.ready = false;
					return _otherState;
				}));

				return _state;
			});
	}

	public function was_ready()
	{
		final oldState = state.update_if(
			(_s : DiscardableActionState) -> _s.ready,
			(_s : DiscardableActionState) -> {
				_s.ready = false;
				return _s;
			});

		return oldState.ready;
	}

	public function action()
	{
		if (was_ready())
		{
			state.update(
				(_s : DiscardableActionState) -> {
					_s.unSubscribe = _s.action();
					return _s;
				});
		}
	}

	public function unsubscribe()
		return state.unsafe_get().unSubscribe;
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
