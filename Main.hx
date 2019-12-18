package;

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

class Main
{
	static function main()
	{	  
        // var r = new haxe.unit.TestRunner();
       	// r.add(new TestAtomicData());
       	// r.add(new TestAsyncLock());
		// r.add(new TestSubscription());
		// r.add(new TestObserver());
		// r.add(new TestSubject());
		// r.add(new TestScheduler());
		// r.add(new TestObservable());
        // // add other TestCases here

        // // finally, run the tests
        // r.run();

		final rep = Replay.create();
		final threadScheduler = new rx.observables.NewThread();
		final mainSheduler    = new SpecificThread(Thread.current());

		threadScheduler
			.subscribe_on_this(Observable.create(_observer -> {
				trace('performing some long running task on ${ Threads.current }...');

				Threads.sleep(3000);

				_observer.onNext([ Std.random(10), Std.random(10), Std.random(10) ]);
				_observer.onCompleted();

				return Subscription.empty();
			}))
			.subscribe(Observer.create((_v : Array<Int>) -> rep.onNext(_v)));
		mainSheduler
			.subscribe_on_this(rep)
			.subscribe(Observer.create(printArray));
		mainSheduler
			.subscribe_on_this(rep)
			.subscribe(Observer.create(printArray));

		Threads.sleep(4000);
		var func1 : () -> Void = Thread.readMessage(true);
		var func2 : () -> Void = Thread.readMessage(true);
		func1();
		func2();
    }

	static function printArray(_array : Array<Int>)
		trace(_array);
}

class SpecificThread extends MakeScheduled
{
	public function new(thread : Thread) {
        super();
        scheduler = new SpecificThreadScheduler(thread);
    }
}

class SpecificThreadBase implements rx.schedulers.Base {
	final thread : Thread;

    public function new(_thread) {
		thread = _thread;
    }

    public function now():Float {

        return Timer.stamp();

    }

    public function schedule_absolute(due_time:Null<Float>, action:Void -> Void):ISubscription {
        if (due_time == null) {
            due_time = now();
        }
        var action1 = Utils.create_sleeping_action(action, due_time, now);
        var discardable = DiscardableAction.create(action1);
        
		thread.sendMessage(action);
		
        return discardable.unsubscribe();

    }
}

class SpecificThreadScheduler extends rx.schedulers.MakeScheduler {
    public function new(thread : Thread) {
        super();
        baseScheduler = new SpecificThreadBase(thread);

    }

}
