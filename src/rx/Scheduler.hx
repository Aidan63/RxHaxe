package rx;

import rx.schedulers.CurrentThread;
import rx.schedulers.Immediate;
import rx.schedulers.NewThread;
import rx.schedulers.Test;
import rx.schedulers.IScheduler;

class Scheduler {
	public static final currentThread = new CurrentThread();

	public static final newThread = new NewThread();

	public static final immediate = new Immediate();

	public static final test = new Test();

	public static var timeBasedOperations(get, set):IScheduler;

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
