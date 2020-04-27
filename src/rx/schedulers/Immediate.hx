package rx.schedulers;

import haxe.Timer;
import rx.disposables.ISubscription;

class ImmediateBase implements Base
{
	public function new() {}

	public function now()
		return Timer.stamp();

	public function schedule_absolute(due_time : Float, action : Void->Void) : ISubscription
	{
		if (due_time == 0)
		{
			action();

			return Subscription.empty();
		}
		else
		{
			return Utils.create_sleeping_action(action, due_time, now)();
		}
	}
}

class Immediate extends MakeScheduler
{
	public function new()
	{
		super(new ImmediateBase());
	}
}
