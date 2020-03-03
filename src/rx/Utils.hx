package rx;

import haxe.Timer;
import rx.Subscription;
import rx.observers.IObserver;
import rx.disposables.ISubscription;

class Utils {
	static public function try_finally<T>(_func:() -> T, _final:() -> Void):T {
		try {
			final result = _func();

			_final();

			return result;
		} catch (_error: String) {
			_final();

			throw _error;
		}

		return null;
	}

	inline static public function unsubscribe_observer<T>(_observer:IObserver<T>, _observers:Array<IObserver<T>>):Array<IObserver<T>>
		return _observers.filter(o -> o != _observer);

	static public function create_sleeping_action(action:Void->Void, exec_time:Float, now:Void->Float):Void->ISubscription {
#if sys
		return () -> {
			final delay = Math.floor((exec_time - now()));

			if (delay > 0)
				Sys.sleep(delay);

			action();

			return Subscription.empty();
		}
#else
		return () -> {
			var t:Null<Timer> = null;
			var delay:Int = Math.floor((exec_time - now()));
			if (delay > 0) {
				t = Timer.delay(action, delay * 1000);
			} else {
				action();
			}
			return Subscription.create(function() {
				if (t != null)
					t.stop();
			});
		}
#end
	}

	inline static public function current_thread_id()
#if (target.threaded)
		return sys.thread.Thread.current();
#else
		return 0;
#end

	static public function pred(i)
		return i - 1;

	static public function succ(i)
		return i + 1;

	static public function incr(i)
		return i + 1;
}
