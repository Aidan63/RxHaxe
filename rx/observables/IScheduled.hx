package rx.observables;

interface IScheduled
{
    public function subscribe_on_this<T>(observable : Observable<T>) : Observable<T>;

    public function of_enum<T>(a : Array<T>) : Observable<T>;

    public function interval(val : Float) : Observable<Int>;
}