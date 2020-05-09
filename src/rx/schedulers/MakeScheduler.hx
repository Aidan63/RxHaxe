package rx.schedulers;

import haxe.Timer;
import rx.schedulers.ISchedulerBase.ScheduledWork;
import rx.disposables.ISubscription;
import rx.disposables.MultipleAssignment;
import rx.disposables.Composite;
import rx.Subscription;

class MakeScheduler implements IScheduler
{
	final baseScheduler : ISchedulerBase;

	public function new(_baseScheduler : ISchedulerBase)
	{
		baseScheduler = _baseScheduler;
	}

	public function now() return Timer.stamp();

	/**
	 * Schedule a function to be ran at some specific time in the future.
	 * @param _dueTime Due time in seconds, value should be greater than `Timer.stamp`. Provide 0 for immediate execution.
	 * @param _action Function to run.
	 * @return Subscription.
	 */
	public function scheduleAbsolute(_dueTime : Float, _action : ScheduledWork) : ISubscription
	{
		return baseScheduler.scheduleAbsolute(_dueTime, _action);
	}

	/**
	 * Schedule a function to be ran at some specific time in the future.
	 * @param _delay How many seconds in the future until the provided function is ran. Provide 0 for immediate execution.
	 * @param _action Function to run.
	 * @return Subscription
	 */
	public function scheduleRelative(_delay : Float, _action : ScheduledWork) : ISubscription
	{
		return baseScheduler.scheduleAbsolute(baseScheduler.now() + _delay, _action);
	}

	/**
	 * Schedule a function to be recursivly ran.
	 * Call the function passed as the only argument to schedule the function to be called recursivly again.
	 * @param _cont Function which decides if it shall be recursivly scheduled again.
	 * @return Subscription
	 */
	public function scheduleRecursive(_cont : (_work : ScheduledWork)->Void) : ISubscription
	{
		final childSubscription     = new MultipleAssignment(Subscription.empty());
		final parentSubscription    = new Composite([ childSubscription ]);
		final scheduledSubscription = baseScheduler.scheduleAbsolute(0, () -> schedule_k(childSubscription, parentSubscription, _cont));

		parentSubscription.add(scheduledSubscription);

		return parentSubscription;
	}

	/**
	 * Schedule a task to be repeatedly ran every x seconds.
	 * @param _initialDelay Initial delay in seconds.
	 * @param _period Number of seconds between function executions.
	 * @param _action Function to execute.
	 * @return Subscription
	 */
	public function schedulePeriodically(_initialDelay : Float, _period : Float, _action : ScheduledWork) : ISubscription
	{
		final completed = new AtomicData(false);
		final delay     = _initialDelay;

		final parentSubscription = new Composite([]);
		final unsubscribe        = scheduleRelative(delay, () -> loop(completed, _period, _action, parentSubscription));

		parentSubscription.add(unsubscribe);

		return Subscription.create(() -> {
			completed.set(true);
			parentSubscription.unsubscribe();
		});
	}

	function loop(_completed : AtomicData<Bool>, _period : Float, _action : ScheduledWork, _parent : Composite)
	{
		if (!_completed.unsafe_get())
		{
			final startedAt = now();

			_action();

			final timeTaken    = now() - startedAt;
			final delay        = _period - timeTaken;
			final unsubscribe2 = scheduleRelative(delay, () -> loop(_completed, _period, _action, _parent));

			_parent.add(unsubscribe2);
		}
	}

	function schedule_k(_childSubscription : MultipleAssignment, _parentSubscription : Composite, _k : (_work : ScheduledWork)->Void) : ISubscription
	{
		final k_subscription = _parentSubscription.isUnsubscribed()
			? Subscription.empty()
			: baseScheduler.scheduleAbsolute(0, () -> _k(() -> schedule_k(_childSubscription, _parentSubscription, _k)));

		_childSubscription.set(k_subscription);

		return _childSubscription;
	}
}
