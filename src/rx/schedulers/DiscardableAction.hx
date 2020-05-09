package rx.schedulers;

import rx.disposables.ISubscription;

typedef DiscardableActionState = {
	var ready : Bool;
	var unSubscribe : ISubscription;
	var action : Null<Void->ISubscription>;
}

class DiscardableAction
{
	var state : AtomicData<DiscardableActionState>;

	public function new(_action : () -> ISubscription)
	{
		state = new AtomicData<DiscardableActionState>({
			ready       : true,
			unSubscribe : Subscription.empty(),
			action      : null
		});
		state.update(
			s -> {
				s.action      = _action;
				s.unSubscribe = Subscription.create(() -> state.update(_otherState -> {
					_otherState.ready = false;
					return _otherState;
				}));

				return s;
			});
	}

	public function wasReady()
	{
		final oldState = state.update_if(
			s -> s.ready,
			s -> {
				s.ready = false;
				return s;
			});

		return oldState.ready;
	}

	public function action()
	{
		if (wasReady())
		{
			state.update(
				s -> {
					s.unSubscribe = s.action();
					return s;
				});
		}
	}

	public function unsubscribe() return state.unsafe_get().unSubscribe;
}
