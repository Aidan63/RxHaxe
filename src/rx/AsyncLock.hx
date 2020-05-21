package rx;

typedef RxAsyncLockState = {
	var queue : Array<()->Void>;
	var isAcquired : Bool;
	var hasFaulted : Bool;
}

class AsyncLock
{
	final lock : AtomicData<RxAsyncLockState>;

	public function new()
	{
		lock = new AtomicData<RxAsyncLockState>({
			queue      : new Array<()->Void>(),
			isAcquired : false,
			hasFaulted : false
		});
	}

	/**
	 * Clears all actions from the queue and sets it to faulted to prevent any further tasks being ran.
	 */
	public function dispose()
	{
		lock.update(l -> {
			l.queue.resize(0);
			l.hasFaulted = true;
			return l;
		});
	}

	/**
	 * Queues a function for execution
	 * If the caller acquires the lock and becomes the owner, the queue is processed.
	 * If the lock is already owned, the action is queued and will get processed by the owner.
	 * @param _action Function to queue for execution.
	 */
	public function wait(_action:() -> Void)
	{
		final oldState = lock.update_if(
			l -> !l.hasFaulted,
			l -> {
				l.queue.push(_action);
				l.isAcquired = true;

				return l;
			});

		final hasNoOwner = !oldState.isAcquired;

		if (hasNoOwner)
		{
			while (true)
			{
				final work = lock.synchronize(l -> {
					if (l.queue.length == 0)
					{
						final value = (l : RxAsyncLockState) -> {
							l.isAcquired = false;
							return l;
						};

						lock.unsafe_set(value(lock.unsafe_get()));

						return null;
					}
					else
					{
						return l.queue.pop();
					}
				});

				if (work != null)
				{
					try
					{
						work();
					}
					catch (_error : String)
					{
						dispose();

						throw _error;
					}
				}
				else
				{
					break;
				}
			}
		}
	}
}