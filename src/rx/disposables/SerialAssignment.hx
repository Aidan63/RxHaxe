package rx.disposables;

/**
 * Subscription that allows changing the underlying subscription object.
 */
class SerialAssignment extends Assignable
{
    /**
     * Change the subscription. The existing subscription is unsubscribed when replaced.
     * @param _subscription New subscription.
     */
    public function set(_subscription : ISubscription)
    {
        final oldState = state.update_if(
            s -> !s.isUnsubscribed,
            s -> {
                s.subscription = _subscription;
                return s;
            }
        );

        final sub = oldState.subscription;
        if (sub != null)
        {
            sub.unsubscribe();
        }

        __set(oldState, _subscription);
    }
}