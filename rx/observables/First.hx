package rx.observables;

import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class First<T> extends Observable<T> {
	var _source:IObservable<T>;
	var _defaultValue:Null<T>;

	public function new(source:IObservable<T>, defaultValue:Null<T>) {
		super();
		_source = source;
		_defaultValue = defaultValue;
	}

	override public function subscribe(observer:IObserver<T>):ISubscription {
		var notPublished:Bool = true;
		var first_observer = Observer.create(function() {
			if (notPublished) {
				if (_defaultValue != null) {
					observer.onNext(_defaultValue);
				} else {
					observer.onError("sequence is empty");
				}
			}
			observer.onCompleted();
		}, function(e:String) {
			observer.onError(e);
		}, function(v:T) {
			if (notPublished) {
				notPublished = false;
				observer.onNext(v);
				observer.onCompleted();
			}
		});
		return _source.subscribe(first_observer);
	}
}
