package rx.disposables;

/**
 * Represents a disposable reactive subscription.
 */
interface ISubscription
{
	/**
	 * Returns if the subscription has been disposed of.
	 * @return true if the subscription has been disposed.
	 */
	public function isUnsubscribed() : Bool;

	/**
	 * Dispose of the subscription.
	 * This operation should be idempotent.
	 */
	public function unsubscribe() : Void;
}
