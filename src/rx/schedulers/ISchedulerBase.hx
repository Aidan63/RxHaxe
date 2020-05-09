package rx.schedulers;

import rx.disposables.ISubscription;

typedef ScheduledWork = () -> Void;

interface ISchedulerBase
{
	function now() : Float;

	function scheduleAbsolute(dueTime : Float, action : ScheduledWork) : ISubscription;
}
