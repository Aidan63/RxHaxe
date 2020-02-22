package rx.observers;

import rx.Utils;
import rx.Core.RxObserver;

class AsyncLockObserver<T> implements IObserver<T> {
	/* Original implementation:
	 * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Core/Reactive/Internal/AsyncLockObserver.cs
	 */
	var async_lock:AsyncLock;
	var observer:ObserverBase<T>;

	public function new(?_on_completed:Void->Void, ?_on_error:String->Void, _on_next:T->Void) {
		async_lock = AsyncLock.create();
		var __on_error = function(e) {
			with_lock(function() {
				_on_error(e);
			});
		};
		var __on_next = function(x:T) {
			with_lock(function() {
				_on_next(x);
			});
		}
		var __on_completed = function() {
			with_lock(function() {
				_on_completed();
			});
		}
		observer = new ObserverBase(__on_completed, __on_error, __on_next);
	}

	function with_lock(thunk:Void->Void) {
		async_lock.wait(thunk);
	}

	public function onError(e:String) {
		observer.onError(e);
	}

	public function onNext(x:T) {
		observer.onNext(x);
	}

	public function onCompleted() {
		observer.onCompleted();
	}

	inline static public function create<T>(observer:IObserver<T>) {
		return new AsyncLockObserver<T>(observer.onCompleted, observer.onError, observer.onNext);
	}
}
