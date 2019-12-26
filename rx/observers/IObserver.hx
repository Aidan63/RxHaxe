package rx.observers;

interface IObserver<T> {
	public function onCompleted():Void;
	public function onError(_error:String):Void;
	public function onNext(_value:T):Void;
}
