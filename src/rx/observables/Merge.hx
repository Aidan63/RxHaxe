package rx.observables;

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
		var observer = Observer.synchronize(actual_observer);
		var __unsubscribe = Composite.create();
		var is_stopped = AtomicData.create(false);
		var child_counter = AtomicData.create(0);
		var parent_completed = false;
		var stop = function() {
			var was_stopped = AtomicData.compare_and_set(false, true, is_stopped);
			if (!was_stopped)
				__unsubscribe.unsubscribe();
			return was_stopped;
		};

		var stop_if_and_do = function(cond:Bool, thunk:Void->Void) {
			if ((!AtomicData.get(is_stopped)) && cond) {
				var was_stopped = stop();
				if (!was_stopped)
					thunk();
			}
		};

		var child_observer = Observer.create(function() {
			var count = AtomicData.update_and_get(Utils.pred, child_counter);
			stop_if_and_do((count == 0 && parent_completed), observer.onCompleted);
		}, function(e:String) {
			stop_if_and_do(true, (function() {
				observer.onError(e);
			}));
		}, function(v:T) {
			if (!(AtomicData.get(is_stopped)))
				observer.onNext(v);
		});

		var parent_observer = Observer.create(
			() -> {
				parent_completed = true;
				var count = AtomicData.get(child_counter);
				stop_if_and_do((count == 0), observer.onCompleted);
			},
			observer.onError,
			(_v : IObservable<T>) -> {
				if (!AtomicData.get(is_stopped))
				{
					AtomicData.update(Utils.succ, child_counter);
					final child_subscription = _v.subscribe(child_observer);
					__unsubscribe.add(child_subscription);
				}
			});

		var parent_subscription = _source.subscribe(parent_observer);
		var subscription = Composite.create([parent_subscription, __unsubscribe]);

		return subscription;
	}
}
