package rx.observables;

import rx.Observer;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.disposables.SingleAssignment;
import rx.disposables.Composite;

class Amb<T> extends Observable<T>
{
    final source1 : IObservable<T>;
    final source2 : IObservable<T>;

    public function new(_source1 : IObservable<T>, _source2 : IObservable<T>)
    {
        super();

        source1 = _source1;
        source2 = _source2;
    }

    override public function subscribe(_observer : IObserver<T>) : ISubscription
    {
        if (source2 == null)
        {
            return source1.subscribe(_observer);
        }

        final subscriptionA = SingleAssignment.create();
        final subscriptionB = SingleAssignment.create();

        final unsubscribe = Composite.create();
        unsubscribe.add(subscriptionA);
        unsubscribe.add(subscriptionB);

        inline function unsubscribeA()
            subscriptionA.unsubscribe();
        inline function unsubscribeB()
            subscriptionB.unsubscribe();

        final observerA = Observer.create(
            () -> {
                unsubscribeB();
                _observer.onCompleted();
            },
            (e : String) -> {
                unsubscribeB();
                _observer.onError(e);
            },
            (v : T) -> {
                unsubscribeB();
                _observer.onNext(v);
            }
        );
        final observerB = Observer.create(
            () -> {
                unsubscribeA();
                _observer.onCompleted();
            },
            (e : String) -> {
                unsubscribeA();
                _observer.onError(e);
            },
            (v : T) -> {
                unsubscribeA();
                _observer.onNext(v);
            }
        );
        
        subscriptionA.set(source1.subscribe(observerA));
        subscriptionB.set(source2.subscribe(observerB));

        return unsubscribe;

    }
}
 