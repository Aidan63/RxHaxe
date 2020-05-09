package rx.schedulers;

import haxe.Timer;
import rx.schedulers.ISchedulerBase.ScheduledWork;
import rx.disposables.ISubscription;

class CurrentThreadScheduler extends MakeScheduler
{
	public function new()
	{
		super(new CurrentThreadBase());
	}
}

private class CurrentThreadBase implements ISchedulerBase
{
	var async : AsyncLock;

	public function new()
	{
		async = new AsyncLock();
	}

	public function now() return Timer.stamp();

	public function enqueue(_action : ScheduledWork)
	{
		try
		{
			async.wait(_action);
		}
		catch (_error : String)
		{
			async = new AsyncLock();

			throw _error;
		}
	}

	public function scheduleAbsolute(_dueTime : Float, _action : ScheduledWork) : ISubscription
	{
		final dueAt       = _dueTime == 0 ? now() : _dueTime;
		final action      = Utils.createSleepingAction(_action, dueAt, now());
		final discardable = new DiscardableAction(action);

		enqueue(discardable.action);

		return discardable.unsubscribe();
	}
}
