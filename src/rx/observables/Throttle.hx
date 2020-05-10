package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.disposables.SerialAssignment;
import rx.Subscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.schedulers.IScheduler;

typedef ThrottleState<T> = {
	var latestValue:Null<T>;
	var hasValue:Bool;
	var id:Float;
}

// todo test
class Throttle<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var _scheduler:IScheduler;
	var _dueTime:Int;

	public function new(source:IObservable<T>, dueTime:Int, scheduler:IScheduler) {
		_source = source;
		_dueTime = dueTime;
		_scheduler = scheduler;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		// lock
		var __subscription = new Composite();
		var cancelable = new SerialAssignment();
		__subscription.add(cancelable);

		var state = new AtomicData({
			latestValue: null,
			hasValue: false,
			id: 0.0
		});
		function __on_next(currentid:Float) {
			// lock
			state.update_if(function(s:ThrottleState<T>) {
				return s.hasValue && s.id == currentid;
			}, function(s:ThrottleState<T>) {
				observer.onNext(s.latestValue);
				s.hasValue = false;
				return s;
			});
		};

		var throttle_observer = new Observer(function() {
			// lock
			cancelable.unsubscribe();
			state.update(function(s:ThrottleState<T>) {
				if (s.hasValue) {
					observer.onNext(s.latestValue);
				}
				s.hasValue = false;
				s.id = s.id + 1;
				return s;
			});
			observer.onCompleted();
		}, function(e:String) {
			// lock
			cancelable.unsubscribe();
			state.update(function(s:ThrottleState<T>) {
				s.hasValue = false;
				s.id = s.id + 1;
				return s;
			});
			observer.onError(e);
		}, function(value:T) {
			var currentid:Float = 0;
			state.update(function(s:ThrottleState<T>) {
				s.hasValue = true;
				s.latestValue = value;
				s.id = s.id + 1;
				currentid = s.id;
				return s;
			});
			var d = _scheduler.scheduleAbsolute(_dueTime, function() {
				__on_next(currentid);
				return Subscription.empty();
			});
			cancelable.set(d);
		});

		__subscription.add(_source.subscribe(throttle_observer));
		return __subscription;
	}
}
