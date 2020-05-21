package rx.disposables;

typedef RxAssignableState = {
	var isUnsubscribed : Bool;
	var subscription : Null<ISubscription>;
}

/**
 * Base re-assignable subscription type.
 * Should not be called itself, ability to re-assign the subscription is only availble when inheriting this class.
 * When the subscription is re-assigned the subscribed state persists.
 * If a new subscription is assigned and the old one had previously been disposed, unsubscribe will immediately be called on the newly assigned subscription.
 */
class Assignable implements ISubscription
{
	final state : AtomicData<RxAssignableState>;

	public function new(_subscription : Null<ISubscription> = null)
	{
		state = new AtomicData<RxAssignableState>({
			isUnsubscribed : false,
			subscription : _subscription
		});
	}

	/**
	 * Returns if the current assigned subscription is active.
	 * @return True if currently subscribed, false otherwise.
	 */
	public function isUnsubscribed()
		return state.unsafe_get().isUnsubscribed;

	/**
	 * Dispose of the current active subscription.
	 */
	public function unsubscribe()
	{
		final oldState = state.update_if(
			s -> !s.isUnsubscribed,
			s -> {
				s.isUnsubscribed = true;
				return s;
			});

		final was_unsubscribed = oldState.isUnsubscribed;
		final subscription     = oldState.subscription;

		if (!was_unsubscribed && subscription != null)
		{
			subscription.unsubscribe();
		}
	}

	/**
	 * Call when replacing the assigned subscription.
	 * @param _oldState The old subscription state.
	 * @param _subscription The new subscription object.
	 */
	function __set(_oldState : RxAssignableState, _subscription : ISubscription)
	{
		var was_unsubscribed = _oldState.isUnsubscribed;
		if (was_unsubscribed)
		{
			_subscription.unsubscribe();
		}
	}
}
