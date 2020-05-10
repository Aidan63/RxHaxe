package rx.observables;

import rx.observers.SynchronizedObserver;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

/*  (* Implementation based on:
	* https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationMerge.java
	*)
 */
class Merge<T> implements IObservable<T> {
	var _source:IObservable<IObservable<T>>;

	public function new(source:IObservable<IObservable<T>>) {
		_source = source;
	}

	public function subscribe(actual_observer:IObserver<T>):ISubscription {
		var observer = new SynchronizedObserver(actual_observer.onCompleted, actual_observer.onError, actual_observer.onNext);
		var __unsubscribe = new Composite();
		var is_stopped = new AtomicData(false);
		var child_counter = new AtomicData(0);
		var parent_completed = false;
		var stop = function() {
			var was_stopped = is_stopped.compare_and_set(false, true);
			if (!was_stopped)
				__unsubscribe.unsubscribe();
			return was_stopped;
		};

		var stop_if_and_do = function(cond:Bool, thunk:Void->Void) {
			if ((!is_stopped.get()) && cond) {
				var was_stopped = stop();
				if (!was_stopped)
					thunk();
			}
		};

		var child_observer = new Observer(function() {
			var count = child_counter.update_and_get(Utils.pred);
			stop_if_and_do((count == 0 && parent_completed), observer.onCompleted);
		}, function(e:String) {
			stop_if_and_do(true, (function() {
				observer.onError(e);
			}));
		}, function(v:T) {
			if (!(is_stopped.get()))
				observer.onNext(v);
		});

		var parent_observer = new Observer(
			() -> {
				parent_completed = true;
				final count = child_counter.get();
				stop_if_and_do(count == 0, observer.onCompleted);
			},
			observer.onError,
			(_v : IObservable<T>) -> {
				if (!is_stopped.get())
				{
					child_counter.update(Utils.succ);
					final child_subscription = _v.subscribe(child_observer);
					__unsubscribe.add(child_subscription);
				}
			});

		var parent_subscription = _source.subscribe(parent_observer);
		var subscription = new Composite([parent_subscription, __unsubscribe]);

		return subscription;
	}
}
