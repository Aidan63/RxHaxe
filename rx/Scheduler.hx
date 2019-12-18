package rx;

import rx.schedulers.CurrentThread;
import rx.schedulers.Immediate;
import rx.schedulers.NewThread;
import rx.schedulers.Test;
import rx.schedulers.IScheduler;

class Scheduler
{
    public static final currentThread = new CurrentThread();

    public static final newThread = new NewThread();

    public static final immediate = new Immediate();

    public static final test = new Test();

    public static var timeBasedOperations (get, set) : IScheduler;

    static function get_timeBasedOperations() {
        if (__timeBasedOperations == null){
                __timeBasedOperations = Scheduler.currentThread;
        }

        return __timeBasedOperations;
    }

    static function set_timeBasedOperations(x)
        return __timeBasedOperations = x;

    static var __timeBasedOperations:IScheduler;
}