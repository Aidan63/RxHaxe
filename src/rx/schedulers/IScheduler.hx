package rx.schedulers;

import rx.schedulers.ISchedulerBase.ScheduledWork;
import rx.disposables.ISubscription;

interface IScheduler extends ISchedulerBase
{
	function scheduleRelative(_delay : Float, _action : ScheduledWork) : ISubscription;

	function scheduleRecursive(_action : (_work : ScheduledWork)->Void) : ISubscription;

	function schedulePeriodically(_initialDelay : Float, _period : Float, _action : ScheduledWork) : ISubscription;
}
