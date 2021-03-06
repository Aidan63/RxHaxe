package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;

/*(* Implementation based on:
	* https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationTakeLast.java
	*)
 */
class TakeLast<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var n:Int;

	public function new(source:IObservable<T>, n:Int) {
		_source = source;
		this.n = n;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var queue = new Array<T>();
		var __unsubscribe = new SingleAssignment();
		var take_last_observer = new Observer(function() {
			try {
				for (iter in queue) {
					observer.onNext(iter);
				}
				observer.onCompleted();
			} catch (e:String) {
				observer.onError(e);
			}
		}, observer.onError, function(v:T) {
			if (n > 0) {
				try {
					// BatMutex.synchronize
					queue.push(v);
					if (queue.length > n) {
						queue.shift();
					}
				} catch (e:String) {
					observer.onError(e);
					__unsubscribe.unsubscribe();
				}
			}
		});
		var result = _source.subscribe(take_last_observer);
		__unsubscribe.set(result);
		return result;
	}
}
