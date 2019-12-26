package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;

class DistinctUntilChanged<T> extends Observable<T> {
	var _source:IObservable<T>;
	var _comparer:T->T->Bool;

	public function new(source:IObservable<T>, comparer:T->T->Bool) {
		super();
		_source = source;
		_comparer = comparer;
	}

	override public function subscribe(observer:IObserver<T>):ISubscription {
		var isFirst = true;
		var prevKey:Null<T> = null;
		var onNextWarp = function(value:T) {
			var currentKey:Null<T> = null;
			try {
				currentKey = value;
			} catch (exception:String) {
				observer.onError(exception);
				return;
			}
			var sameKey = false;
			if (isFirst) {
				isFirst = false;
			} else {
				try {
					sameKey = _comparer(currentKey, prevKey);
				} catch (ex:String) {
					observer.onError(ex);
					return;
				}
			}

			if (!sameKey) {
				prevKey = currentKey;
				observer.onNext(value);
			}
		};
		var distinctUntilChanged_observer = Observer.create(observer.onCompleted, observer.onError, onNextWarp);

		return _source.subscribe(distinctUntilChanged_observer);
	}
}
