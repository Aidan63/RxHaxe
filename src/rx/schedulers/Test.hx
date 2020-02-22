package rx.schedulers;

import rx.disposables.ISubscription;

using Safety;

/**
 * Implementation based on:
 * /usr/local/src/RxJava/rxjava-core/src/main/java/rx/schedulers/TestScheduler.java
 */
class TestBase implements Base {
	final queue:List<TimedAction>;

	var time:Float;

	public function new() {
		queue = new List<TimedAction>();
		time = 0;
	}

	public function now():Float
		return time;

	public function schedule_absolute(_dueTime:Null<Float>, _action:() -> Void):ISubscription {
		final execTime = _dueTime.or(now());
		final discardableAction = DiscardableAction.create(() -> {
			_action();
			return Subscription.empty();
		});

		queue.add(new TimedAction(discardableAction.action, execTime));

		return discardableAction.unsubscribe();
	}

	public function trigger_actions(_targetTime:Float) {
		while (!queue.isEmpty()) {
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
		trigger_actions(time);

	public function advance_time_to(_delay:Float)
		trigger_actions(_delay);

	public function advance_time_by(_delay:Float)
		trigger_actions(time + _delay);

	public function reset() {
		queue.clear();
		time = 0;
	}
}

class Test extends MakeScheduler {
	final testScheduler:TestBase;

	public function new() {
		super(new TestBase());

		testScheduler = cast baseScheduler;
	}

	public function trigger_actions(_targetTime)
		testScheduler.trigger_actions(_targetTime);

	public function trigger_actions_until_now()
		testScheduler.trigger_actions_until_now();

	public function advance_time_to(_delay)
		testScheduler.advance_time_to(_delay);

	public function advance_time_by(_delay)
		testScheduler.advance_time_by(_delay);

	public function reset()
		testScheduler.reset();
}
