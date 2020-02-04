package rx.observables;

import rx.observers.IObserver;
import rx.disposables.ISubscription;

class Collect<T> implements IObservable<Array<T>>
{
    final source : IObservable<T>;

    public function new(_source : IObservable<T>)
    {
        source = _source;
    }

    public function subscribe(_observer : IObserver<Array<T>>) : ISubscription
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