package rx.disposables;

/**
 * Subscription that allows changing the underlying subscription object.
 */
class MultipleAssignment extends Assignable
{
	/**
	 * Change the subscription.
	 * @param _subscription New subscription object.
	 */
	public function set(_subscription : ISubscription)
	{
		final oldState = state.update_if(
			s -> !s.isUnsubscribed,
			s -> {
				s.subscription = _subscription;

				return s;
			});
		
		__set(oldState, _subscription);
	}
}
