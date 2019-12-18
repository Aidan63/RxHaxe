package rx.observables;

import rx.Observer;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;

class Last<T> extends Observable<T>
{
    final source : IObservable<T>;

    final defaultValue : Null<T>;

    public function new(_source : IObservable<T>, _defaultValue : Null<T>)
    {
        super();

        source       = _source;
        defaultValue = _defaultValue;
    }

    override public function subscribe(observer : IObserver<T>) : ISubscription
    {
        var notPublished = true;
        var lastValue    = null;

        final defaultIfEmpty_observer = Observer.create(
            () -> {
                if (notPublished)
                {
                    if (defaultValue != null)
                    {
                        observer.onNext(defaultValue);
                    }
                    else
                    {
                        observer.onError("sequence is empty");
                    }
                }
                else
                {
                    if (lastValue != null)
                    {
                        observer.onNext(lastValue);
                    }
                    else
                    {
                        observer.onError("sequence is empty");
                    }
                }

                observer.onCompleted();
            },
            (e : String) -> observer.onError(e),
            (v : T) -> {
                notPublished = false;
                lastValue    = v;
            }
        );
        
        return source.subscribe(defaultIfEmpty_observer);
    }
}
 