package rx;

import haxe.Timer;
import rx.Subscription;
import rx.observers.IObserver;
import rx.disposables.ISubscription;

class Utils
{
	static public function try_finally<T>(_func : () -> T, _final : () -> Void) : Null<T>
	{
		try
		{
			final result = _func();

			_final();

			return result;
		}
		catch (_error : String)
		{
			_final();

			throw _error;
		}

		return null;
	}

	inline static public function unsubscribe_observer<T>(_observer : IObserver<T>, _observers : Array<IObserver<T>>) : Array<IObserver<T>>
		return _observers.filter(o -> o != _observer);

	static public function createSleepingAction(_action : () -> Void, _execTime : Float, _now : Float) : () -> ISubscription
	{
#if sys
		return () -> {
			final delay = Math.floor(_execTime - _now);

			if (delay > 0)
			{
				Sys.sleep(delay);
			}

			_action();

			return Subscription.empty();
		}
#else
		return () -> {
			final delay = Math.floor(_execTime - _now);

			if (delay > 0)
			{
				final t = Timer.delay(_action, delay * 1000);

				return Subscription.create(() -> t.stop());
			}
			else
			{
				_action();

				return Subscription.empty();
			}
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
