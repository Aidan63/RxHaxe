package;

import rx.observers.IObserver;
import rx.schedulers.IScheduler;
import rx.schedulers.DiscardableAction;
import rx.Utils;
import haxe.Timer;
import rx.observables.CurrentThread;
import rx.observables.MakeScheduled;
import hx.concurrent.thread.Threads;
import rx.schedulers.NewThread;
import rx.AtomicData;
import rx.AsyncLock;
import rx.notifiers.Notification;
import rx.Observable;
import rx.Observer;
import rx.observers.ObserverBase;
import rx.Subject;
import rx.Subscription;
import rx.Scheduler;
import rx.Core;
import rx.disposables.Boolean;
import rx.disposables.Composite;
import rx.disposables.ISubscription; 
import rx.subjects.Replay;
import rx.subjects.Behavior;
import rx.subjects.Async;
import sys.thread.Thread;

using rx.Observable;
using RxExample;
using Safety;

class RxExample
{
	static function main()
	{
		// Basic example.
		// final observable   = Observable.of_enum([ 1, 2, 3, 4, 5 ]).buffer(2);
		// final observer     = Observer.create((_value : Array<Int>) -> trace('array of $_value'));
		// final subscription = observable.subscribe(observer);

		// Threaded example.
		final rep = Replay.create();
		final threadScheduler = Scheduler.newThread;
		final mainSheduler    = new SpecificThreadScheduler(Thread.current());

		// Create an observable which will subscribe (run the function) on a separate thread and observer (call the subscibe function) on the main.
		Observable.create(_observer -> {
			trace('performing some long running task on ${ Threads.current }...');

			Threads.sleep(3000);

			_observer.onNext([ Std.random(10), Std.random(10), Std.random(10) ]);
			_observer.onCompleted();

			return Subscription.empty();
		}).subscribeOn(threadScheduler).observeOn(mainSheduler).subscribeFunction((_v : Array<Int>) -> rep.onNext(_v));

		// Create two subscriptions to prove the replay subject works.
		rep.subscribeFunction(printArray);
		rep.subscribeFunction(printArray);

		// Give some time for the task to run then read a message as a function and execute it.
		// This function will pump the observer events to the two subscribers.
		Threads.sleep(4000);
		var func : () -> Void = Thread.readMessage(false);
		func();
    }

	static function printArray(_array : Array<Int>)
		trace(_array);
}

class SpecificThreadScheduler extends rx.schedulers.MakeScheduler
{
    public function new(thread : Thread)
	{
        super(new SpecificThreadBase(thread));
    }
}

class SpecificThreadBase implements rx.schedulers.Base
{
	final thread : Thread;

    public function new(_thread)
	{
		thread = _thread;
    }

    public function now() : Float
        return Timer.stamp();

    public function schedule_absolute(due_time : Null<Float>, action : () -> Void) : ISubscription
	{
        final action1     = Utils.create_sleeping_action(action, due_time.or(now()), now);
        final discardable = DiscardableAction.create(action1);
        
		thread.sendMessage(action);
		
        return discardable.unsubscribe();
    }
}
