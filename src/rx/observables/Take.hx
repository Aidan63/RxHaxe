package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;

/*(* Implementation based on:
	* https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationTake.java
	*)
 */
class Take<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var n:Int;

	public function new(source:IObservable<T>, n:Int) {
		_source = source;
		this.n = n;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		if (n < 1) {
			var __observer = new Observer<T>(null, null, function(v) {});
			var __unsubscribe = _source.subscribe(__observer);
			__unsubscribe.unsubscribe();
			return Subscription.empty();
		}

		var counter = new AtomicData(0);
		var error = false;
		var __unsubscribe = new SingleAssignment();
		var on_completed_wrapper = function() {
			if (!error && counter.get_and_set(n) < n) {
				observer.onCompleted();
			}
		}
		var on_error_wrapper = function(e) {
			if (!error && counter.get_and_set(n) < n) {
				observer.onError(e);
			}
		}

		var take_observer = new Observer(on_completed_wrapper, on_error_wrapper, function(v) {
			if (!error) {
				var count = counter.update_and_get(Utils.succ);
				if (count <= n) {
					try {
						observer.onNext(v);
					} catch (e:String) {
						error = true;
						observer.onError(e);
						__unsubscribe.unsubscribe();
					}
					if (!error && count == n) {
						observer.onCompleted();
					}
				}
				if (!error && count >= n) {
					__unsubscribe.unsubscribe();
				}
			}
		});

		var result = _source.subscribe(take_observer);
		__unsubscribe.set(result);
		return result;
	}
}
