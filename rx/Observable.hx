package rx;

import haxe.Timer;
// Creating Observables
import rx.observables.Create;
// create an Observable from scratch by calling observer methods programmatically
import rx.observables.Defer;
//  — do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
import rx.observables.Empty;
import rx.observables.Never;
import rx.observables.Error;
//  — create Observables that have very precise and limited behavior
// From;// — convert some other object or data structure into an Observable
// Interval;//  — create an Observable that emits a sequence of integers spaced by a particular time interval
// Just;//  — convert an object or a set of objects into an Observable that emits that or those objects
// Range;//  — create an Observable that emits a range of sequential integers
// Repeat;//  — create an Observable that emits a particular item or sequence of items repeatedly
// Start;//  — create an Observable that emits the return value of a function
// Timer;//  — create an Observable that emits a single item after a given delay
import rx.observables.Empty;
import rx.observables.Error;
import rx.observables.Never;
import rx.observables.Return;
import rx.observables.Append;
import rx.observables.Dematerialize;
import rx.observables.Skip;
import rx.observables.Length;
import rx.observables.Map;
import rx.observables.Materialize;
import rx.observables.Merge;
import rx.observables.Single;
import rx.observables.Take;
import rx.observables.TakeLast;
import rx.observables.ObserveOnThis;
// 7-31
import rx.observables.Average;
import rx.observables.Amb;
import rx.observables.Buffer;
import rx.observables.Collect;
import rx.observables.Catch;
import rx.observables.CombineLatest;
import rx.observables.Concat;
import rx.observables.Contains;
// 8-1
import rx.observables.Defer;
import rx.observables.Create;
import rx.observables.Throttle;
import rx.observables.DefaultIfEmpty;
import rx.observables.Timestamp;
import rx.observables.Delay;
import rx.observables.Distinct;
import rx.observables.DistinctUntilChanged;
import rx.observables.Filter;
import rx.observables.Find;
import rx.observables.ElementAt;
// 8-2
import rx.observables.First;
import rx.observables.Last;
import rx.observables.IgnoreElements;
import rx.observables.SkipUntil;
import rx.observables.Scan;
// 8-3
import rx.observables.TakeUntil;
import rx.observables.MakeScheduled;
import rx.observables.Blocking;
import rx.observables.CurrentThread;
import rx.observables.Immediate;
import rx.observables.NewThread;
import rx.observables.Test;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.schedulers.IScheduler;

using Safety;

// type +'a observable = 'a observer -> subscription
/*Internal module. (see Rx.Observable)
 *
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/Observable.java
 */
class Observable<T> implements IObservable<T> {
	function new() {
		//
	}

	public static final currentThread = new CurrentThread();

	public static final newThread = new NewThread();

	public static final immediate = new Immediate();

	public static final test = new Test();

	public function subscribe(_observer:IObserver<T>):ISubscription
		return Subscription.empty();

	public static function subscribeFunction<T>(_observable : Observable<T>, ?_onNext : (_value : T) -> Void, ?_onError : (_error : String) -> Void = null, ?_onComplete : () -> Void = null)
		return _observable.subscribe(Observer.create(_onComplete, _onError, _onNext));

	static public function empty<T>()
		return new Empty<T>();

	static public function error(_error:String)
		return new Error(_error);

	static public function of_never()
		return new Never();

	static public function of_return<T>(_value:T)
		return new Return(_value);

	static public function create<T>(_function:(_observer:IObserver<T>) -> ISubscription)
		return new Create(_function);

	static public function defer<T>(_observableFactory:() -> Observable<T>)
		return new Defer(_observableFactory);

	static public function of<T>(_args:T):Observable<T>
		return new Return(_args);

	static public function of_enum<T>(_args:Array<T>):Observable<T>
		return new Create((_observer:IObserver<T>) -> {
			for (i in 0..._args.length) {
				_observer.onNext(_args[i]);
			}
			_observer.onCompleted();
			return Subscription.empty();
		});

	static public function fromRange(_initial:Int = 0, _step:Int = 1, _limit:Int)
		return Observable.create((_observer:IObserver<Int>) -> {
			var i = _initial;
			while (i < _limit) {
				_observer.onNext(i);
				i += _step;
			}
			_observer.onCompleted();
			return Subscription.empty();
		});

	static public function find<T>(_observable:Observable<T>, ?_comparer:(_value:T) -> Bool)
		return new Find(_observable, _comparer);

	static public function filter<T>(_observable:Observable<T>, ?_comparer:(_value:T) -> Bool)
		return new Filter(_observable, _comparer);

	static public function distinctUntilChanged<T>(_observable:Observable<T>, ?_comparer:(_a:T, _b:T) -> Bool)
		return new DistinctUntilChanged(_observable, _comparer.or((_a, _b) -> _a == _b));

	static public function distinct<T>(_observable:Observable<T>, ?_comparer:(_a:T, _b:T) -> Bool)
		return new Distinct(_observable, _comparer.or((_a, _b) -> _a == _b));

	static public function delay<T>(_source:Observable<T>, _dueTime:Float, ?_scheduler:IScheduler)
		return new Delay<T>(_source, Timer.stamp() + _dueTime, _scheduler.or(Scheduler.timeBasedOperations));

	static public function timestamp<T>(_source:Observable<T>, ?_scheduler:IScheduler)
		return new Timestamp<T>(_source, _scheduler.or(Scheduler.timeBasedOperations));

	static public function scan<T, R>(_observable:Observable<T>, ?_seed:R, _accumulator:R->T->R)
		return new Scan(_observable, _seed, _accumulator);

	static public function last<T>(_observable:Observable<T>, ?_source:T)
		return new Last(_observable, _source);

	static public function first<T>(_observable:Observable<T>, ?_source:T)
		return new First(_observable, _source);

	static public function defaultIfEmpty<T>(_observable:Observable<T>, _source:T)
		return new DefaultIfEmpty(_observable, _source);

	static public function contains<T>(_observable:Observable<T>, _source:T)
		return new Contains(_observable, (v) -> v == _source);

	static public function concat<T>(_observable:Observable<T>, _source:Array<Observable<T>>)
		return new Concat([_observable].concat(_source));

	static public function combineLatest<T, R>(_observable:Observable<T>, _source:Array<Observable<T>>, _combinator:Array<T>->R)
		return new CombineLatest([_observable].concat(_source), _combinator);

	static public function of_catch<T>(_observable:Observable<T>, _errorHandler:String->Observable<T>)
		return new Catch(_observable, _errorHandler);

	static public function buffer<T>(_observable:Observable<T>, _count:Int)
		return new Buffer(_observable, _count);

	static public function observer<T>(_observable:Observable<T>, _fun:T->Void)
		return _observable.subscribe(Observer.create(null, null, _fun));

	static public function amb<T>(_observable1:Observable<T>, _observable2:Observable<T>)
		return new Amb(_observable1, _observable2);

	static public function average<T>(_observable:Observable<T>)
		return new Average(_observable);

	static public function materialize<T>(_observable:Observable<T>)
		return new Materialize(_observable);

	static public function dematerialize<T>(_observable:Observable<Notification<T>>)
		return new Dematerialize(_observable);

	static public function length<T>(_observable:Observable<T>)
		return new Length(_observable);

	static public function drop<T>(_observable:Observable<T>, _n:Int)
		return skip(_observable, _n);

	static public function skip<T>(_observable:Observable<T>, _n:Int)
		return new Skip(_observable, _n);

	static public function skip_until<T>(_observable1:Observable<T>, _observable2:Observable<T>)
		return new SkipUntil(_observable1, _observable2);

	static public function take<T>(_observable:Observable<T>, _n:Int)
		return new Take(_observable, _n);

	static public function take_until<T>(_observable1:Observable<T>, _observable2:Observable<T>)
		return new TakeUntil(_observable1, _observable2);

	static public function take_last<T>(_observable:Observable<T>, _n:Int)
		return new TakeLast(_observable, _n);

	static public function single<T>(_observable:Observable<T>)
		return new Single(_observable);

	static public function append<T>(_observable1:Observable<T>, _observable2:Observable<T>)
		return new Append(_observable1, _observable2);

	static public function map<T, R>(_observable:Observable<T>, _f:T->R)
		return new Map(_observable, _f);

	static public function merge<T>(_observable:Observable<Observable<T>>)
		return new Merge(_observable);

	static public function flatMap<T, R>(_observable:Observable<T>, _f:T->Observable<R>)
		return bind(_observable, _f);

	static public function collect<T>(_observable:Observable<T>)
		return new Collect(_observable);
	
	static public function bind<T, R>(_observable:Observable<T>, _f:T->Observable<R>)
		return merge(map(_observable, _f));

	static public function subscribeOn<T>(_observable : Observable<T>, _scheduler : rx.schedulers.MakeScheduler)
		return new SubscribeOnThis(_scheduler, _observable);

	static public function observeOn<T>(_observable : Observable<T>, _scheduler : rx.schedulers.MakeScheduler)
		return new ObserveOnThis(_observable, _scheduler);
}
