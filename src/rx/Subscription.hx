package rx;

import rx.disposables.Boolean;

class Subscription
{
	/**
	 * Create a basic subscription which will not perform any action when unsubscribed.
	 * @return Boolean subscription.
	 */
	inline static public function empty() return create(() -> {});

	/**
	 * Create a subscription which will run the provided function when unsubscribed.
	 * The function is wrapped in a boolean subscription for idempotency.
	 * @param _unsubscribe Function to call on un-subscription.
	 * @return Boolean subscription.
	 */
	inline static public function create(_unsubscribe : () -> Void) return new Boolean(_unsubscribe);
}
