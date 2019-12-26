package rx;

typedef RxSubject<T> = RxObserver<T>->RxObservable<T>;

// type 'a subject = 'a observer * 'a observable
typedef RxObservable<T> = RxObserver<T>->RxSubscription;
typedef RxSubscription = Void->Void;

typedef RxObserver<T> = {
	var onCompleted:() -> Void;
	var onError:(_error:String) -> Void;
	var onNext:(_value:T) -> Void;
}
