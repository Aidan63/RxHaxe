package rx.observables;

import rx.Observer;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;

class Filter<T> extends Observable<T>
{
    var source : IObservable<T>;
    var predicate : T -> Bool;

    public function new(_source : IObservable<T>, _predicate : T -> Bool)
    {
        super();

        source    = _source;
        predicate = _predicate;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var filter_observer = Observer.create(
            () ->  observer.onCompleted(),
            (e : String) -> observer.onError(e),
            (v : T) -> {
                var isPassed = false;
                try
                {
                    isPassed = predicate(v);
                }
                catch (ex:String)
                {
                    observer.onError(ex);

                    return;
                }
                if (isPassed)
                {
                    observer.onNext(v);
                }
            }
        );

        return source.subscribe(filter_observer);
    }
}
 