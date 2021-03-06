package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;

/*  (* Implementation based on:
	* https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationSkip.java
	*)
 */
class Skip<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var n:Int;

	public function new(source:IObservable<T>, n:Int) {
		_source = source;
		this.n = n;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var counter = new AtomicData(0);
		var drop_observer = new Observer(observer.onCompleted, observer.onError, function(v:T) {
			var count = counter.update_and_get(Utils.succ);
			if (count > n)
				observer.onNext(v);
		});
		return _source.subscribe(drop_observer);
	}
}
