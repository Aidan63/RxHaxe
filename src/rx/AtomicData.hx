package rx;

import hx.concurrent.lock.RLock;

class AtomicData<T> {
	public var data:T;

	public final mutex:RLock;

	function new(_initial_value:T) {
		mutex = new RLock();
		data = _initial_value;
	}

	public static function clone<T>(_v:T):T {
		return switch Type.typeof(_v) {
			case TNull: null;
			case TInt, TFloat, TBool, TEnum(_), TFunction, TUnknown: _v;
			default: Reflect.copy(_v);
		}
	}

	static public function with_lock<T, B>(_ad:AtomicData<T>, _f:() -> B):B {
		_ad.mutex.acquire();

		var value = _f();

		_ad.mutex.release();

		return value;
	}

	static public function create<T>(_initial_value:T)
		return new AtomicData<T>(_initial_value);

	static public function get<T>(_ad:AtomicData<T>)
		return with_lock(_ad, () -> _ad.data);

	static public function unsafe_get<T>(_ad:AtomicData<T>)
		return _ad.data;

	static public function set<T>(_value:T, _ad:AtomicData<T>)
		return with_lock(_ad, () -> _ad.data = _value);

	static public function unsafe_set<T>(_value:T, _ad:AtomicData<T>)
		return _ad.data = _value;

	static public function get_and_set<T>(_value:T, _ad:AtomicData<T>)
		return with_lock(_ad, () -> {
			var result = clone(_ad.data);
			_ad.data = _value;
			return result;
		});

	static public function update<T>(_f:(_in:T) -> T, _ad:AtomicData<T>)
		return with_lock(_ad, () -> _ad.data = _f(_ad.data));

	static public function update_and_get<T>(_f:(_in:T) -> T, _ad:AtomicData<T>)
		return with_lock(_ad, () -> {
			var result = _f(_ad.data);
			_ad.data = result;
			return result;
		});

	static public function compare_and_set<T>(_compare_value:T, _set_value:T, _ad:AtomicData<T>)
		return with_lock(_ad, () -> {
			var result = clone(_ad.data);
			if (_ad.data == _compare_value) {
				_ad.data = _set_value;
			}
			return result;
		});

	static public function update_if<T>(_predicate:(_in:T) -> Bool, _update:(_in:T) -> T, _ad:AtomicData<T>)
		return with_lock(_ad, () -> {
			var result = clone(_ad.data);
			if (_predicate(_ad.data)) {
				_ad.data = _update(_ad.data);
			}
			return result;
		});

	static public function synchronize<T, B>(_f:(_in:T) -> B, _ad:AtomicData<T>)
		return with_lock(_ad, () -> _f(_ad.data));
}
