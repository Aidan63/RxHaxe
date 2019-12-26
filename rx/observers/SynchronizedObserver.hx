package rx.observers;

import rx.Utils;
import rx.Core.RxObserver;
import hx.concurrent.lock.RLock;

class SynchronizedObserver<T> implements IObserver<T> {
	/* Original implementation:
	 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Core/Reactive/Internal/SynchronizedObserver.cs
	 */
	var mutex:RLock;
	var observer:RxObserver<T>;

	public function new(?on_completed:Void->Void, ?on_error:String->Void, on_next:T->Void) {
		mutex = new RLock();
		observer = {
			onCompleted: on_completed,
			onError: on_error,
			onNext: on_next
		};
	}

	function with_lock<T>(f:T->Void, ?a:T) {
		mutex.acquire();
		f(a);
		mutex.release();
	}

	public function onError(e:String) {
		with_lock(observer.onError, e);
	}

	public function onNext(x:T) {
		with_lock(observer.onNext, x);
	}

	public function onCompleted() {
		mutex.acquire();
		observer.onCompleted();
		mutex.release();
	}

	inline static public function create<T>(observer:IObserver<T>) {
		return new SynchronizedObserver<T>(observer.onCompleted, observer.onError, observer.onNext);
	}
}
