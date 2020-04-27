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
		lock = new AtomicData({
			queue      : new Array<()->Void>(),
			isAcquired : false,
			hasFaulted : false
		});
	}

	public function dispose()
		lock.update(l -> {
			l.queue.resize(0);
			l.hasFaulted = true;
			return l;
		});

	public function wait(_action:() -> Void)
	{
		final oldState = lock.update_if(
			l -> !l.hasFaulted,
			l -> {
				l.queue.push(_action);
				l.isAcquired = true;

				return l;
			});

		final isOwner = !oldState.isAcquired;

		if (isOwner)
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