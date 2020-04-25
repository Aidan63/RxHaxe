package rx.schedulers;

import haxe.Timer;
import rx.disposables.ISubscription;
import rx.disposables.MultipleAssignment;
import rx.disposables.Composite;
import rx.Subscription;

class MakeScheduler implements IScheduler
{
	final baseScheduler : Base;

	public function new(_baseScheduler:Base)
	{
		baseScheduler = _baseScheduler;
	}

	public function now() return Timer.stamp();

	public function schedule_absolute(_dueTime : Float, _action : () -> Void) : ISubscription
	{
		return baseScheduler.schedule_absolute(_dueTime, _action);
	}

	public function schedule_relative(_delay : Float, _action : () -> Void) : ISubscription
	{
		return baseScheduler.schedule_absolute(baseScheduler.now() + _delay, _action);
	}

	function schedule_k(_childSubscription : MultipleAssignment, _parentSubscription : Composite, _k : (() -> Void)->Void) : ISubscription
	{
		final k_subscription = _parentSubscription.is_unsubscribed()
			? Subscription.empty()
			: baseScheduler.schedule_absolute(0, () -> _k(() -> schedule_k(_childSubscription, _parentSubscription, _k)));

		_childSubscription.set(k_subscription);

		return _childSubscription;
	}

	public function schedule_recursive(_cont : (() -> Void)->Void)
	{
		final childSubscription     = MultipleAssignment.create(Subscription.empty());
		final parentSubscription    = Composite.create([ childSubscription ]);
		final scheduledSubscription = baseScheduler.schedule_absolute(0, () -> schedule_k(childSubscription, parentSubscription, _cont));

		parentSubscription.add(scheduledSubscription);

		return parentSubscription;
	}

	public function schedule_periodically(_initialDelay : Float, _period : Float, _action : () -> Void) : ISubscription
	{
		final completed = AtomicData.create(false);
		final delay     = _initialDelay;

		final parentSubscription = Composite.create([]);
		final unsubscribe        = schedule_relative(delay, () -> loop(completed, _period, _action, parentSubscription));

		parentSubscription.add(unsubscribe);

		return Subscription.create(() -> {
			AtomicData.set(true, completed);
			parentSubscription.unsubscribe();
		});
	}

	function loop(_completed : AtomicData<Bool>, _period : Float, _action : () -> Void, _parent : Composite)
	{
		if (!AtomicData.unsafe_get(_completed))
		{
			final startedAt = now();

			_action();

			final timeTaken    = now() - startedAt;
			final delay        = _period - timeTaken;
			final unsubscribe2 = schedule_relative(delay, () -> loop(_completed, _period, _action, _parent));

			_parent.add(unsubscribe2);
		}
	}
}
