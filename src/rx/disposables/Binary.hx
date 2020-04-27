package rx.disposables;

/**
 * Subscription which contains two child subscriptions.
 * When unsubscribing both children are unsubscribed.
 */
class Binary implements ISubscription
{
	/**
	 * Stores the unsubscribed state of the two subscriptions.
	 */
	final state : AtomicData<Bool>;

	/**
	 * The first disposable subscription.
	 */
	final first : ISubscription;

	/**
	 * The second disposable subscription.
	 */
	final second : ISubscription;

	/**
	 * Creates a new binary subscription from two existing subscriptions.
	 * @param _first First subscription.
	 * @param _second Second subscription.
	 */
	public function new(_first : ISubscription, _second : ISubscription)
	{
		first  = _first;
		second = _second;
		state  = new AtomicData(false);
	}

	/**
	 * Disposes of this subscription, unsubscribing from both of the child subscriptions.
	 */
	public function unsubscribe()
	{
		final wasUnsubscribed = state.compare_and_set(false, true);
		if (!wasUnsubscribed)
		{
			first.unsubscribe();
			second.unsubscribe();
		}
	}

	/**
	 * Gets the current children subscription state.
	 * @return true if currently subscribed, false otherwise.
	 */
	public function isUnsubscribed()
		return state.unsafe_get();
}
