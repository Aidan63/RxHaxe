package rx.subjects;

import rx.observers.IObserver;
import rx.observables.IObservable;

interface ISubject<T> extends IObservable<T> extends IObserver<T>
{
    //
}