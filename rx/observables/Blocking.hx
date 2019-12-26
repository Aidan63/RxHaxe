package rx.observables;

import rx.Observer;
import rx.observables.IObservable;
import rx.notifiers.Notification;
import hx.concurrent.lock.RLock;

/**
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/observables/BlockingObservable.java
 */
class Blocking<T> {
	final mutex:RLock;

	final queue:Array<Notification<T>>;

	final materialize:Materialize<T>;

	var index:Int;

	public function new(observable:IObservable<T>) {
		mutex = new RLock();
		queue = [];

		final observer = Observer.create(null, null, (n:Notification<T>) -> {
			mutex.acquire();
			queue.push(n);
			mutex.release();
		});

		materialize = new Materialize(observable);
		materialize.subscribe(observer);
		index = 0;
	}

	public function hasNext():Bool
		return index < queue.length;

	public function next():T {
		final v = queue[index++];

		return switch v {
			case OnCompleted: throw "No_more_elements";
			case OnError(e): throw e;
			case OnNext(vv): return vv;
		}
	}

	static public function to_enum<T>(observable:IObservable<T>)
		return new Blocking(observable);

	static public function single<T>(observable:IObservable<T>)
		return to_enum(new rx.observables.Single(observable)).next();
}
