package rx;

import hx.concurrent.lock.RLock;

/**
 * Object which allows thread safe access and modification to some underlying data.
 * This class uses cloning so care needs to be taken when choosing the underlying data type.
 * Ints, Floats, Booleans, Functions, and enums are simply returned.
 * Classes are returned unless they are of the `RxAssignableState` or `RxCompositeState` in which case their `clone` function is called.
 * Anonymouse objects are cloned via reflection.
 * 
 * Should probably set up restraints / a clonable interface to make it more generic.
 */
@:generic class AtomicData<T>
{
	/**
	 * Underlying data.
	 */
	var data : T;

	/**
	 * Mutex to prevent simultaneous access from multiple threads.
	 */
	final mutex : RLock;

	public function new(_initialValue : T)
	{
		mutex = new RLock();
		data  = _initialValue;
	}

	/**
	 * Returns the underlying data.
	 * The mutex lock is released before this function returns.
	 */
	public function get()
		return with_lock(() -> data);

	/**
	 * Returns the underlying data without acquiring the mutex.
	 */
	public function unsafe_get()
		return data;

	/**
	 * Updates the value of the underlying data.
	 * @param _value New value.
	 */
	public function set(_value : T)
		return with_lock(() -> data = _value);

	/**
	 * Updates the value of the underlying data without acquiring the mutex.
	 * @param _value New value.
	 */
	public function unsafe_set(_value : T)
		return data = _value;

	/**
	 * Returns the current value and updates it with a new value.
	 * @param _value New value.
	 * @return Value before updating to the new value.
	 */
	public function get_and_set(_value : T)
		return with_lock(() -> {
			final oldData = clone();
			data = _value;
			return oldData;
		});

	/**
	 * Acquires the mutex and calls the provided function passing the data in.
	 * The data is then updated to the value returned by the function.
	 * @param _func Function to call.
	 */
	public function update(_func : (_in : T) -> T)
		with_lock(() -> data = _func(data));

	/**
	 * Acquires the mutex and calls the provided function passing the data in.
	 * The data is then updated to the value returned by the function.
	 * @param _func Function to call.
	 * @return Updated underlying data.
	 */
	public function update_and_get(_func: (_in : T) -> T)
		return with_lock(() -> data = _func(data));

	/**
	 * Updates the underlying data only if its equal to another value.
	 * @param _compareValue Value the underlying data must be equal to.
	 * @param _setValue Value to update the underlying data to.
	 * @return Value before it was updated.
	 */
	public function compare_and_set(_compareValue : T, _setValue : T)
		return with_lock(() -> {
			final result = clone();
			if (data == _compareValue)
			{
				data = _setValue;
			}
			return result;
		});

	/**
	 * Upddates the underlying value with the result of the update function only if the predicate function returns true.
	 * @param _predicate Function to call to see if the update function should be called.
	 * @param _update Function to update the underlying data.
	 * @return Underlying data before it was updated.
	 */
	public function update_if(_predicate : (_in : T) -> Bool, _update : (_in : T) -> T)
		return with_lock(() -> {
			final result = clone();
			if (_predicate(data))
			{
				data = _update(data);
			}
			return result;
		});

	/**
	 * Calls the provided function passing in the underlying data.
	 * @param _f Function to call.
	 * @return return value of the function.
	 */
	public function synchronize<B>(_func : (_in : T) -> B)
		return with_lock(() -> _func(data));

	function with_lock<B>(_f : () -> B)
	{
		mutex.acquire();

		final value = _f();

		mutex.release();

		return value;
	}

	function clone()
	{
		return switch Type.typeof(data)
		{
			case TNull: null;
			case TInt, TFloat, TBool, TEnum(_), TFunction, TUnknown, TClass(_): data;
			case _: Reflect.copy(data);
		}
	}
}
