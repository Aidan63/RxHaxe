package rx.schedulers;

import rx.schedulers.ISchedulerBase.ScheduledWork;
import rx.disposables.ISubscription;

class TestScheduler extends MakeScheduler
{
	final testScheduler : TestBase;

	public function new()
	{
		super(new TestBase());

		testScheduler = cast baseScheduler;
	}

	public function trigger_actions(_targetTime)
	{
		testScheduler.trigger_actions(_targetTime);
	}

	public function trigger_actions_until_now()
	{
		testScheduler.trigger_actions_until_now();
	}

	public function advance_time_to(_delay)
	{
		testScheduler.advance_time_to(_delay);
	}

	public function advance_time_by(_delay)
	{
		testScheduler.advance_time_by(_delay);
	}

	public function reset()
	{
		testScheduler.reset();
	}
}

/**
 * Implementation based on:
 * /usr/local/src/RxJava/rxjava-core/src/main/java/rx/schedulers/TestScheduler.java
 */
private class TestBase implements ISchedulerBase
{
	final queue : List<TimedAction>;

	var time : Float;

	public function new()
	{
		queue = new List<TimedAction>();
		time  = 0;
	}

	public function now() return time;

	public function scheduleAbsolute(_dueTime : Float, _action : ScheduledWork) : ISubscription
	{
		final execTime          = _dueTime == 0 ? now() : _dueTime;
		final discardableAction = new DiscardableAction(() -> {
			_action();
			return Subscription.empty();
		});

		queue.add(new TimedAction(discardableAction.action, execTime));

		return discardableAction.unsubscribe();
	}

	public function trigger_actions(_targetTime:Float)
	{
		while (!queue.isEmpty())
		{
			final timedAction = queue.first();
			if (timedAction.execTime > _targetTime)
				break;

			queue.pop();
			time = timedAction.execTime == 0 ? time : timedAction.execTime;
			timedAction.discardableAction();
		}

		time = _targetTime;
	}

	public function trigger_actions_until_now()
	{
		trigger_actions(time);
	}

	public function advance_time_to(_delay : Float)
	{
		trigger_actions(_delay);
	}

	public function advance_time_by(_delay : Float)
	{
		trigger_actions(time + _delay);
	}

	public function reset()
	{
		queue.clear();
		time = 0;
	}
}
