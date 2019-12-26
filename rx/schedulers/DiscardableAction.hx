package rx.schedulers;

import rx.disposables.ISubscription;

typedef DiscardableActionState = {
	var ready:Bool;
	var un_subscribe:ISubscription;
	var action:Void->ISubscription;
}

class DiscardableAction {
	static public function create(_action:() -> ISubscription):DiscardableAction
		return new DiscardableAction(_action);

	final state:AtomicData<DiscardableActionState>;

	public function was_ready() {
		final old_state = AtomicData.update_if((_s : DiscardableActionState) -> _s.ready, (_s : DiscardableActionState) -> {
			_s.ready = false;
			return _s;
		}, state);

		return old_state.ready;
	}

	public function action() {
		if (was_ready()) {
			AtomicData.update((_s : DiscardableActionState) -> {
				_s.un_subscribe = _s.action();
				return _s;
			}, state);
		}
	}

	public function unsubscribe()
		return AtomicData.unsafe_get(state).un_subscribe;

	function new(_action:() -> ISubscription) {
		final actionState:DiscardableActionState = {
			ready: true,
			un_subscribe: Subscription.empty(),
			action: null
		};
		state = AtomicData.create(actionState);

		AtomicData.update((_s : DiscardableActionState) -> {
			_s.action = _action;
			_s.un_subscribe = Subscription.create(() -> AtomicData.update((_s1 : DiscardableActionState) -> {
				_s1.ready = false;
				return _s1;
			}, state));

			return _s;
		}, state);
	}
}
