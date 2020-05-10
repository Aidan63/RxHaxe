import rx.schedulers.ISchedulerBase;
import rx.schedulers.IScheduler;
import rx.schedulers.DiscardableAction;
import rx.Utils;
import haxe.Timer;
import rx.Subscription;
import rx.schedulers.NewThreadScheduler;
import rx.disposables.ISubscription;
import rx.subjects.Replay;
import sys.thread.Thread;

using rx.Observable;
using Safety;

class RxExample {
	static function main() {
		// Basic example.
		// final observable   = Observable.of_enum([ 1, 2, 3, 4, 5 ]).buffer(2);
		// final observer     = Observer.create((_value : Array<Int>) -> trace('array of $_value'));
		// final subscription = observable.subscribe(observer);

		// Threaded example.
		final rep             = new Replay<Array<Int>>();
		final threadScheduler = new NewThreadScheduler();
		final mainSheduler    = new SpecificThreadScheduler(Thread.current());

		// Create an observable which will subscribe (run the function) on a separate thread and observer (call the subscibe function) on the main.
		Observable.create(_observer -> {
			trace('performing some long running task on ${Thread.current()}...');

			Sys.sleep(3);

			_observer.onNext([Std.random(10), Std.random(10), Std.random(10)]);
			_observer.onCompleted();

			return Subscription.empty();
		})
			.subscribeOn(threadScheduler)
			.observeOn(mainSheduler)
			.subscribeFunction((_v:Array<Int>) -> rep.onNext(_v));

		// Create two subscriptions to prove the replay subject works.
		rep.subscribeFunction(printArray);
		rep.subscribeFunction(printArray);

		// Give some time for the task to run then read a message as a function and execute it.
		// This function will pump the observer events to the two subscribers.
		Sys.sleep(4);
		final func : () -> Void = Thread.readMessage(false);
		func();

		rep.subscribeFunction(printArray);
	}

	static function printArray(_array:Array<Int>)
		trace(_array);
}

class SpecificThreadScheduler extends rx.schedulers.MakeScheduler {
	public function new(thread:Thread) {
		super(new SpecificThreadBase(thread));
	}
}

class SpecificThreadBase implements rx.schedulers.ISchedulerBase {
	final thread:Thread;

	public function new(_thread) {
		thread = _thread;
	}

	public function now():Float
		return Timer.stamp();

	public function scheduleAbsolute(due_time:Float, action:() -> Void):ISubscription {
		final action1 = Utils.createSleepingAction(action, due_time, now());
		final discardable = new DiscardableAction(action1);

		thread.sendMessage(action);

		return discardable.unsubscribe();
	}
}
