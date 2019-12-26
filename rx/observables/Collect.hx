package rx.observables;

import rx.observers.IObserver;
import rx.disposables.ISubscription;

class Collect<T> extends Observable<Array<T>>
{
    final source : Observable<T>;

    public function new(_source : Observable<T>)
    {
        super();

        source = _source;
    }

    override function subscribe(_observer : IObserver<Array<T>>) : ISubscription
    {
        final data = [];
        return source.subscribe(Observer.create(
            () -> {
                _observer.onNext(data);
                _observer.onCompleted();
            },
            _error -> _observer.onError(_error),
            _value -> data.push(_value)
        ));
    }
}