package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.schedulers.IScheduler;

@:generic class SubscribeOnThis<T> implements IObservable<T>
{
	final source : IObservable<T>;

	final scheduler : IScheduler;

	var unsubscribe : ISubscription;

	public function new(_scheduler : IScheduler, _source : IObservable<T>)
	{
		source    = _source;
		scheduler = _scheduler;
	}

	function doUnsubscribe()
	{
		scheduler.scheduleAbsolute(0, () -> unsubscribe.unsubscribe());
	}

	public function subscribe(_observer : IObserver<T>) : ISubscription
	{
		scheduler.scheduleAbsolute(0, () -> unsubscribe = source.subscribe(_observer));

		return Subscription.create(doUnsubscribe);
	}
}

class SubscribeOfEnum<T> implements IObservable<T> {
	var _enum:Array<T>;
	var scheduler:IScheduler;

	public function new(scheduler:IScheduler, _enum:Array<T>) {
		this._enum = _enum;
		this.scheduler = scheduler;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var index:Int = 0;
		return scheduler.scheduleRecursive(function(self:Void->Void) {
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
class SubscribeInterval<T> implements IObservable<T> {
	var period:Float;
	var scheduler:IScheduler;

	public function new(scheduler:IScheduler, _period:Float) {
		period = _period;
		this.scheduler = scheduler;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var counter = new AtomicData(0);
		var succ = function(count:Int):Int {
			// trace(count);
			observer.onNext(cast count);
			return count + 1;
		}
		return scheduler.schedulePeriodically(period, period, function() {
			counter.update(succ);
		});
	}
}

class MakeScheduled implements IScheduled {
	public final scheduler:IScheduler;

	public function new(_scheduler:IScheduler) {
		scheduler = _scheduler;
	}

	public function subscribe_on_this<T>(source:IObservable<T>):IObservable<T> {
		return new SubscribeOnThis(scheduler, source);
	}

	public function of_enum<T>(a:Array<T>):IObservable<T> {
		return new SubscribeOfEnum(scheduler, a);
	}

	public function interval(val:Float):IObservable<Int> {
		return new SubscribeInterval(scheduler, val);
	}
}
