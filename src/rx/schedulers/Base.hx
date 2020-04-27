package rx.schedulers;

import rx.disposables.ISubscription;

interface Base
{
	public function now() : Float;

	public function schedule_absolute(due_time : Float, action : () -> Void) : ISubscription;
}