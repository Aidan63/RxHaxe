package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;
/*   (* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationSingle.java
   *)
   */
class Single<T> extends Observable<T> {
    var _source:IObservable<T>;

    public function new(source:IObservable<T>) {
        super();
        _source = source;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var value:Null<T> = null;
        var has_too_many_elements = false ;
        var __unsubscribe = SingleAssignment.create();
        var single_observer = Observer.create(function() {
            if (!has_too_many_elements) {
                if (value == null) {
                    observer.onError("Sequence contains no elements");
                } else {
                    observer.onNext(value);
                    observer.onCompleted();
                }
            }
        },
        observer.onError,
        function(v:T) {
            if (value == null) {
                value = v;
            } else {
                has_too_many_elements = true;
                observer.onError("Sequence contains too many elements");
                __unsubscribe.unsubscribe();
            }
        });
        var result = _source.subscribe(single_observer);
        __unsubscribe.set(result);
        return result ;

    }
}
 