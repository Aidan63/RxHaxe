package rx;

import rx.observables.Timestamped;
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

class Observable<T> implements IObservable<T>
{
	function new()
	{
		//
	}

	public function subscribe(_observer : IObserver<T>) : ISubscription
		return Subscription.empty();

	public static function subscribeFunction<T>(_observable : IObservable<T>, ?_onNext : (_value : T) -> Void, ?_onError : (_error : String) -> Void, ?_onComplete : () -> Void) : ISubscription
		return _observable.subscribe(new Observer(_onComplete, _onError, _onNext));

	static public function empty<T>() : IObservable<T>
		return new Empty();

	static public function error(_error : String) : IObservable<String>
		return new Error(_error);

	static public function of_never<T>() : IObservable<T>
		return new Never();

	static public function of_return<T>(_value : T) : IObservable<T>
		return new Return(_value);

	static public function create<T>(_function : (_observer : IObserver<T>) -> ISubscription) : IObservable<T>
		return new Create(_function);

	static public function defer<T>(_observableFactory : () -> IObservable<T>) : IObservable<T>
		return new Defer(_observableFactory);

	static public function of<T>(_args : T) : IObservable<T>
		return new Return(_args);

	static public function of_enum<T>(_args : Array<T>) : IObservable<T>
	{
		return new Create(observer -> {
			for (v in _args)
			{
				observer.onNext(v);
			}

			observer.onCompleted();

			return Subscription.empty();
		});
	}

	static public function fromRange(_initial : Int = 0, _step : Int = 1, _limit : Int) : IObservable<Int>
		return Observable.create(observer -> {
			var i = _initial;

			while (i < _limit)
			{
				observer.onNext(i);
				i += _step;
			}

			observer.onCompleted();

			return Subscription.empty();
		});

	static public function find<T>(_observable : IObservable<T>, _comparer : (_value : T) -> Bool) : IObservable<T>
		return new Find(_observable, _comparer);

	static public function filter<T>(_observable : IObservable<T>, _comparer : (_value : T) -> Bool) : IObservable<T>
		return new Filter(_observable, _comparer);

	static public function distinctUntilChanged<T>(_observable : IObservable<T>, _comparer : (_a : T, _b : T) -> Bool) : IObservable<T>
		return new DistinctUntilChanged(_observable, _comparer);

	static public function distinct<T>(_observable : IObservable<T>, _comparer : (_a : T, _b : T) -> Bool) : IObservable<T>
		return new Distinct(_observable, _comparer);

	static public function delay<T>(_source : IObservable<T>, _dueTime : Float, ?_scheduler : IScheduler) : IObservable<T>
	{
		return new Delay<T>(_source, Timer.stamp() + _dueTime, _scheduler.or(Scheduler.timeBasedOperations));
	}

	static public function timestamp<T>(_source : IObservable<T>, ?_scheduler : IScheduler) : IObservable<Timestamped<T>>
	{
		return new Timestamp<T>(_source, _scheduler.or(Scheduler.timeBasedOperations));
	}

	static public function scan<T, R>(_observable : IObservable<T>, ?_seed : R , _accumulator : R->T->R) : IObservable<R>
	{
		return new Scan(_observable, _seed, _accumulator);
	}

	static public function last<T>(_observable : IObservable<T>, ?_source : T) : IObservable<T>
		return new Last(_observable, _source);

	static public function first<T>(_observable : IObservable<T>, ?_source : T) : IObservable<T>
		return new First(_observable, _source);

	static public function defaultIfEmpty<T>(_observable : IObservable<T>, _source : T) : IObservable<T>
		return new DefaultIfEmpty(_observable, _source);

	static public function contains<T>(_observable : IObservable<T>, _source : T) : IObservable<Bool>
	{
		return new Contains(_observable, v -> v == _source);
	}

	static public function concat<T>(_observable : IObservable<T>, _source : Array<IObservable<T>>) : IObservable<T>
	{
		return new Concat([ _observable ].concat(_source));
	}

	static public function combineLatest<T, R>(_observable : IObservable<T>, _source : Array<IObservable<T>>, _combinator : Array<T>->R) : IObservable<R>
	{
		return new CombineLatest([ _observable ].concat(_source), _combinator);
	}

	static public function of_catch<T>(_observable : IObservable<T>, _errorHandler : String->IObservable<T>) : IObservable<T>
		return new Catch(_observable, _errorHandler);

	static public function buffer<T>(_observable : IObservable<T>, _count : Int) : IObservable<Array<T>>
		return new Buffer(_observable, _count);

	static public function observer<T>(_observable : IObservable<T>, _fun : T->Void) : ISubscription
		return _observable.subscribe(new Observer(null, null, _fun));

	static public function amb<T>(_observable1 : IObservable<T>, _observable2 : IObservable<T>) : IObservable<T>
		return new Amb(_observable1, _observable2);

	static public function average<T : Float & Int>(_observable : IObservable<T>) : IObservable<Float>
		return new Average(_observable);

	static public function materialize<T>(_observable : IObservable<T>) : IObservable<Notification<T>>
		return new Materialize(_observable);

	static public function dematerialize<T>(_observable : IObservable<Notification<T>>) : IObservable<T>
		return new Dematerialize(_observable);

	static public function length<T>(_observable : IObservable<T>) : IObservable<Int>
		return new Length(_observable);

	static public function drop<T>(_observable : IObservable<T>, _n : Int) : IObservable<T>
		return skip(_observable, _n);

	static public function skip<T>(_observable : IObservable<T>, _n : Int) : IObservable<T>
		return new Skip(_observable, _n);

	static public function skip_until<T>(_observable1 : IObservable<T>, _observable2 : IObservable<T>) : IObservable<T>
		return new SkipUntil(_observable1, _observable2);

	static public function take<T>(_observable : IObservable<T>, _n : Int) : IObservable<T>
		return new Take(_observable, _n);

	static public function take_until<T>(_observable1 : IObservable<T>, _observable2 : IObservable<T>) : IObservable<T>
		return new TakeUntil(_observable1, _observable2);

	static public function take_last<T>(_observable : IObservable<T>, _n : Int) : IObservable<T>
		return new TakeLast(_observable, _n);

	static public function single<T>(_observable : IObservable<T>) : IObservable<T>
		return new Single(_observable);

	static public function append<T>(_observable1 : IObservable<T>, _observable2 : IObservable<T>) : IObservable<T>
		return new Append(_observable1, _observable2);

	static public function map<T, R>(_observable : IObservable<T>, _f : T->R) : IObservable<R>
		return new Map(_observable, _f);

	static public function merge<T>(_observable : IObservable<IObservable<T>>) : IObservable<T>
		return new Merge(_observable);

	static public function flatMap<T, R>(_observable : IObservable<T>, _f : T->IObservable<R>) : IObservable<R>
		return bind(_observable, _f);

	static public function collect<T>(_observable : IObservable<T>) : IObservable<Array<T>>
		return new Collect(_observable);
	
	static public function bind<T, R>(_observable : IObservable<T>, _f : T->IObservable<R>) : IObservable<R>
		return merge(map(_observable, _f));

	static public function subscribeOn<T>(_observable : IObservable<T>, _scheduler : IScheduler) : IObservable<T>
		return new SubscribeOnThis(_scheduler, _observable);

	static public function observeOn<T>(_observable : IObservable<T>, _scheduler : IScheduler) : IObservable<T>
		return new ObserveOnThis(_observable, _scheduler);
}
