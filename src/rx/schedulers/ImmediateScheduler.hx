package rx.schedulers;

import haxe.Timer;
import rx.schedulers.ISchedulerBase.ScheduledWork;
import rx.disposables.ISubscription;

class ImmediateScheduler extends MakeScheduler
{
	public function new()
	{
		super(new ImmediateBase());
	}
}

private class ImmediateBase implements ISchedulerBase
{
	public function new() {}

	public function now() return Timer.stamp();

	public function scheduleAbsolute(_dueTime : Float, _action : ScheduledWork) : ISubscription
	{
		if (_dueTime == 0)
		{
			_action();

			return Subscription.empty();
		}
		else
		{
			return Utils.createSleepingAction(_action, _dueTime, now())();
		}
	}
}
