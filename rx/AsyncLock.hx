package rx;

import rx.AtomicData;

typedef RxAsyncLockState = {
    var queue:List<Void -> Void>;
    var is_acquired:Bool;
    var has_faulted:Bool;
}

class AsyncLock
{
    final lock : AtomicData<RxAsyncLockState>;

    public function new()
    {
        var async : RxAsyncLockState = {
            queue       : new List<Void -> Void>(),
            is_acquired : false,
            has_faulted : false
        }

        lock = AtomicData.create(async);
    }

    static public function create()
        return new AsyncLock();

    public function dispose()
        AtomicData.update(l -> {
            l.queue.clear();
            l.has_faulted = true;
            return l;
        }, lock);

    public function wait(_action : () -> Void)
    {
        final old_state = AtomicData.update_if(
            (l : RxAsyncLockState) -> !l.has_faulted,
            (l : RxAsyncLockState) -> {
                l.queue.push(_action);
                l.is_acquired = true;
                
                return l;
            }, lock);

        final is_owner = !old_state.is_acquired;

        if (is_owner)
        {
            while (true)
            {
                var work = AtomicData.synchronize(l -> {
                    if (l.queue.isEmpty())
                    {
                        var value = l -> {
                            l.is_acquired = false;
                            return l;
                        }(lock.data);

                        AtomicData.unsafe_set(value, cast lock);

                        return null;
                    }
                    else
                    {
                        return l.queue.pop();
                    }
                }, lock);

                if (work != null)
                {
                    var w = work;
                    try
                    {
                        w();
                    }
                    catch (_error : String)
                    {
                        dispose();

                        throw _error;
                    }
                }
                else
                {
                    break;
                }
            }
        }
    }
}