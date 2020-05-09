package rx.disposables;

/**
 * A disposable subscription which only allows assigning the underlying subscription once.
 * If the subscription has already been set, further attempts to set it will result in an exception being thrown.
 */
class SingleAssignment extends Assignable
{
    /**
     * Set the underlying subscription.
     * An exception is thrown if it is already assigned.
     * @param _subscription Subscription to set.
     */
    public function set(_subscription : ISubscription)
    {
        final oldStaste = state.update_if(
            s -> !s.isUnsubscribed,
            s -> {
                if (s.subscription == null)
                {
                    s.subscription = _subscription;
                }
                else
                {
                    throw 'SingleAssignment';
                }

                return s;
            });

        __set(oldStaste, _subscription);
    }
}