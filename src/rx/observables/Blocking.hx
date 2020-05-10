package rx.observables;

import rx.Observer;
import rx.observables.IObservable;
import rx.observables.Single;
import rx.notifiers.Notification;
import hx.concurrent.lock.RLock;

class Blocking<T>
{
	final mutex : RLock;

	final queue : Array<Notification<T>>;

	final materialize : Materialize<T>;

	var index : Int;

	public function new(_observable : IObservable<T>)
	{
		mutex = new RLock();
		queue = [];

		final observer = new Observer(
			(n : Notification<T>) -> {
				mutex.acquire();
				queue.push(n);
				mutex.release();
			});

		materialize = new Materialize(_observable);
		materialize.subscribe(observer);
		index = 0;
	}

	public function hasNext() : Bool
	{
		return index < queue.length;
	}

	public function next() : T
	{
		return switch queue[index++]
		{
			case OnCompleted:
				throw "No_more_elements";
			case OnError(e):
				throw e;
			case OnNext(v): v;
		}
	}

	static public function toEnum<T>(_observable : IObservable<T>)
	{
		return new Blocking(_observable);
	}

	static public function single<T>(_observable : IObservable<T>)
	{
		return toEnum(new Single(_observable)).next();
	}
}
