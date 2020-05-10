package rx;

import rx.schedulers.CurrentThreadScheduler;
import rx.schedulers.ImmediateScheduler;
import rx.schedulers.NewThreadScheduler;
import rx.schedulers.TestScheduler;
import rx.schedulers.IScheduler;

class Scheduler {
	public static final currentThread = new CurrentThreadScheduler();

	public static final newThread = new NewThreadScheduler();

	public static final immediate = new ImmediateScheduler();

	public static final test = new TestScheduler();

	public static var timeBasedOperations (get, set) : IScheduler;

	static var _timeBasedOperations:IScheduler;

	inline static function get_timeBasedOperations() {
		if (_timeBasedOperations == null) {
			_timeBasedOperations = Scheduler.currentThread;
		}

		return _timeBasedOperations;
	}

	inline static function set_timeBasedOperations(x:IScheduler)
		return _timeBasedOperations = x;
}
