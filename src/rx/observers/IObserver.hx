package rx.observers;

interface IObserver<T>
{
	function onCompleted() : Void;
	function onError(_error : String) : Void;
	function onNext(_value : T) : Void;
}
