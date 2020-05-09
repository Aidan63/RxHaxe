package rx.schedulers;

import rx.schedulers.ISchedulerBase.ScheduledWork;

class TimedAction
{
	public final discardableAction : ScheduledWork;
	public final execTime : Float;

	public function new(_discardableAction : ScheduledWork, _execTime : Float)
	{
		discardableAction = _discardableAction;
		execTime          = _execTime;
	}

	public function equal(_ta1 : TimedAction, _ta2 : TimedAction) : Bool
	{
		return _ta1.execTime == _ta2.execTime;
	}
}
