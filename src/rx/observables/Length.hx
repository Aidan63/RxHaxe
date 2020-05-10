package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;

/** Implementation based on:
 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Linq/Observable/Count.cs
 *
 */
class Length<T> implements IObservable<Int> {
	var _source:IObservable<T>;

	public function new(source:IObservable<T>) {
		_source = source;
	}

	public function subscribe(observer:IObserver<Int>):ISubscription {
		var counter = new AtomicData(0);
		var length_observer = new Observer(function() {
			var v = counter.unsafe_get();
			observer.onNext(v);
			observer.onCompleted();
		}, observer.onError, function(v:T) {
			counter.update(Utils.succ);
		});

		return _source.subscribe(length_observer);
	}
}
