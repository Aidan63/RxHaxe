package rx.notifiers;

enum Notification<T>
{
	OnCompleted();
	OnError(_msg : String);
	OnNext(_a : T);
}
