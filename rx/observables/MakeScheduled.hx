package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.schedulers.IScheduler;

class SubscribeOnThis<T> extends Observable<T> {
	final _source:IObservable<T>;

	final scheduler:IScheduler;

	var __unsubscribe:ISubscription;

	public function new(scheduler:IScheduler, source:IObservable<T>) {
		super();
		_source = source;
		this.scheduler = scheduler;
	}

	function doUnsubscribe()
		scheduler.schedule_absolute(null, () -> __unsubscribe.unsubscribe());

	override public function subscribe(observer:IObserver<T>):ISubscription {
		scheduler.schedule_absolute(null, () -> __unsubscribe = _source.subscribe(observer));

		return Subscription.create(doUnsubscribe);
	}
}

class SubscribeOfEnum<T> extends Observable<T> {
	var _enum:Array<T>;
	var scheduler:IScheduler;

	public function new(scheduler:IScheduler, _enum:Array<T>) {
		super();
		this._enum = _enum;
		this.scheduler = scheduler;
	}

	override public function subscribe(observer:IObserver<T>):ISubscription {
		var index:Int = 0;
		return scheduler.schedule_recursive(function(self:Void->Void) {
			try {
				if (index >= _enum.length) {
					observer.onCompleted();
				} else {
					observer.onNext(_enum[index]);
					index++;
					self();
				}
			} catch (e:String) {
				observer.onError(e);
			}
		});
	}
}

/**
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationInterval.java
 *
**/
class SubscribeInterval<T> extends Observable<T> {
	var period:Float;
	var scheduler:IScheduler;

	public function new(scheduler:IScheduler, _period:Float) {
		super();
		period = _period;
		this.scheduler = scheduler;
	}

	override public function subscribe(observer:IObserver<T>):ISubscription {
		var counter = AtomicData.create(0);
		var succ = function(count:Int):Int {
			// trace(count);
			observer.onNext(cast count);
			return count + 1;
		}
		return scheduler.schedule_periodically(period, period, function() {
			AtomicData.update(succ, counter);
		});
	}
}

class MakeScheduled implements IScheduled {
	public final scheduler:IScheduler;

	public function new(_scheduler:IScheduler) {
		scheduler = _scheduler;
	}

	public function subscribe_on_this<T>(source:Observable<T>):Observable<T> {
		return new SubscribeOnThis(scheduler, source);
	}

	public function of_enum<T>(a:Array<T>):Observable<T> {
		return new SubscribeOfEnum(scheduler, a);
	}

	public function interval(val:Float):Observable<Int> {
		return new SubscribeInterval(scheduler, val);
	}
}
