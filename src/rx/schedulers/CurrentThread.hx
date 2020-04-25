package rx.schedulers;

import haxe.Timer;
import rx.disposables.ISubscription;

class CurrentThreadBase implements Base
{
	var async : AsyncLock;

	public function new()
	{
		async = AsyncLock.create();
	}

	public function now() return Timer.stamp();

	public function enqueue(_action : () -> Void, _execTime : Float)
	{
		try
		{
			async.wait(_action);
		}
		catch (_error : String)
		{
			async = AsyncLock.create();

			throw _error;
		}
	}

	public function schedule_absolute(_dueTime : Float, _action : () -> Void) : ISubscription
	{
		final dueAt       = _dueTime == 0 ? now() : _dueTime;
		final action1     = Utils.create_sleeping_action(_action, dueAt, now);
		final discardable = DiscardableAction.create(action1);

		enqueue(discardable.action, dueAt);

		return discardable.unsubscribe();
	}
}

class CurrentThread extends MakeScheduler
{
	public function new()
	{
		super(new CurrentThreadBase());
	}
}
