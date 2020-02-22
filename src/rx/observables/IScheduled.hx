package rx.observables;

interface IScheduled {
	public function subscribe_on_this<T>(observable:IObservable<T>):IObservable<T>;

	public function of_enum<T>(a:Array<T>):IObservable<T>;

	public function interval(val:Float):IObservable<Int>;
}
