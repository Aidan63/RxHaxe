package rx.schedulers;

import haxe.Timer;
import rx.disposables.ISubscription;
import rx.schedulers.ISchedulerBase.ScheduledWork;
import sys.thread.Thread;

class NewThreadScheduler extends MakeScheduler
{
	public function new()
	{
		super(new NewThreadBase());
	}
}

private class NewThreadBase implements ISchedulerBase
{
	public function new() {}

	public function now() return Timer.stamp();

	public function scheduleAbsolute(_dueTime : Float, _action : ScheduledWork) : ISubscription
	{
		if (_dueTime == 0)
		{
			_dueTime = now();
		}

		final action      = Utils.createSleepingAction(_action, _dueTime, now());
		final discardable = new DiscardableAction(action);
#if (target.threaded)
		Thread.create(discardable.action);
#else
		discardable.action();
#end
		return discardable.unsubscribe();
	}
}
