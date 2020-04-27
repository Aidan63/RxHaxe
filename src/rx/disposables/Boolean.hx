package rx.disposables;

/**
 * Basic idempotent subscription type which invokes a function when unsubscribed.
 */
class Boolean implements ISubscription
{
	var state : AtomicData<Bool>;

	var action : ()->Void;
	
	/**
	 * Create a new boolean subscription which will call the provided function when unsubscribed.
	 * @param _action Function to call when this subscription is unsubscribed.
	 */
	public function new(_action : ()->Void)
	{
		action = _action;
		state  = new AtomicData(false);
	}

	/**
	 * Disposes of this subscription, invoking the function if it is still subscribed.
	 */
	public function unsubscribe()
	{
		final wasUnsubscribed = state.compare_and_set(false, true);
		if (!wasUnsubscribed)
		{
			action();
		}
	}

	/**
	 * Gets the current subscription state.
	 * @return true if currently subscribed, false otherwise.
	 */
	public function isUnsubscribed()
		return state.unsafe_get();
}
