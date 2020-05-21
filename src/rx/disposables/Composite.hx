package rx.disposables;

using Safety;

typedef RxCompositeState = {
	var isUnsubscribed : Bool;
	var subscriptions : Array<ISubscription>;
}

/**
 * Composite subscriptions can manage any number of child subscriptions.
 * The overall state of the composite subscription is maintained and propagated to all child subscriptions added.
 */
class Composite implements ISubscription
{
	var state : AtomicData<RxCompositeState>;

	public function new(_subscriptions : Array<ISubscription> = null)
	{
		state = new AtomicData<RxCompositeState>({
			isUnsubscribed : false,
			subscriptions  : _subscriptions.or([])
		});
	}

	/**
	 * Gets the current subscription state.
	 * @return true if currently subscribed, false otherwise.
	 */
	public function isUnsubscribed()
		return state.unsafe_get().isUnsubscribed;

	/**
	 * Disposes of this subscription, and all child subscriptions.
	 */
	public function unsubscribe()
	{
		final oldState = state.update_if(
			s -> !s.isUnsubscribed,
			s -> {
				s.isUnsubscribed = true;
				return s;
			});
		final wasUnsubscribed = oldState.isUnsubscribed;
		final subscriptions   = oldState.subscriptions;

		if (!wasUnsubscribed)
		{
			unsubscribe_from_all(subscriptions);
		}
	}

	/**
	 * Adds a child subscription if the composite subscription has not been disposed.
	 * If the composite subscription has already been disposed the provided subscription will not be added, but it will be unsubscribed.
	 * @param _subscription Subscription to be managed by the composite subscription.
	 */
	public function add(_subscription : ISubscription)
	{
		final oldState = state.update_if(
			s -> !s.isUnsubscribed,
			s -> {
				s.subscriptions.push(_subscription);
				return s;
			});

		if (oldState.isUnsubscribed)
		{
			_subscription.unsubscribe();
		}
	}

	/**
	 * Remove the provided subscription from the composite if it has not yet had its subscription disposed.
	 * @param _subscription Subscription to remove.
	 */
	public function remove(_subscription : ISubscription)
	{
		final oldState = state.update_if(
			s -> !s.isUnsubscribed,
			s -> {
				s.subscriptions = s.subscriptions.filter(s -> s != _subscription);
				return s;
			});

		if (!oldState.isUnsubscribed)
		{
			_subscription.unsubscribe();
		}
	}

	/**
	 * Remove all child subscriptions from this composite subscription.
	 * If this composite subscription was not disposed of then the child subscriptions will not be. 
	 */
	public function clear()
	{
		final oldState = state.update_if(
			s -> !s.isUnsubscribed,
			s -> {
				s.subscriptions = [];
				return s;
			});
		
		final wasUnsubscribed = oldState.isUnsubscribed;
		final subscriptions   = oldState.subscriptions;

		if (!wasUnsubscribed)
		{
			unsubscribe_from_all(subscriptions);
		}
	}

	function unsubscribe_from_all(_subscriptions : Array<ISubscription>)
	{
		final exceptions = Lambda.fold(_subscriptions, (unsubscribe : ISubscription, excp : Array<String>) -> {
			try
			{
				unsubscribe.unsubscribe();
			}
			catch (exception : String)
			{
				excp.push(exception);
			}

			return excp;
		}, []);

		if (exceptions.length > 0)
		{
			throw exceptions.toString();
		}
	}
}
