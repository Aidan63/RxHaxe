package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;

class Distinct<T> implements IObservable<T> {
	var _source:IObservable<T>;
	var _comparer:T->T->Bool;

	public function new(source:IObservable<T>, comparer:T->T->Bool) {
		_source = source;
		_comparer = comparer;
	}

	public function subscribe(observer:IObserver<T>):ISubscription {
		var values = new List<T>();
		var distinct_observer = Observer.create(function() {
			observer.onCompleted();
		}, observer.onError, function(v:T) {
			var hasValue = Lambda.exists(values, function(x) {
				return _comparer(x, v);
			});
			if (!hasValue) {
				observer.onNext(v);
				values.add(v);
			}
		});

		return _source.subscribe(distinct_observer);
	}
}
