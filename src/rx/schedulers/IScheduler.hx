package rx.schedulers;

import rx.disposables.ISubscription;

interface IScheduler extends Base {
	public function schedule_relative(_delay:Null<Float>, _action:() -> Void):ISubscription;

	public function schedule_recursive(_action:(() -> Void)->Void):ISubscription;

	public function schedule_periodically(_initial_delay:Null<Float>, _period:Null<Float>, _action:() -> Void):ISubscription;
}
