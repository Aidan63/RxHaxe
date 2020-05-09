import rx.schedulers.NewThreadScheduler;
import rx.schedulers.CurrentThreadScheduler;
import rx.schedulers.ImmediateScheduler;

class RxPlayground
{
    static function main()
    {
        // final scheduler = new NewThreadScheduler();

        // scheduler.scheduleRelative( 5, () -> trace('thread'));

        // final scheduler = new ImmediateScheduler();

        // scheduler.scheduleRelative(10, () -> trace('delayed 1'));
        // scheduler.scheduleRelative( 0, () -> trace('delayed 2'));

        // final scheduler = new CurrentThreadScheduler();

        // scheduler.scheduleRelative( 5, () -> trace('delayed 3'));
        // scheduler.scheduleRelative( 5, () -> trace('delayed 4'));
        // scheduler.scheduleRelative( 0, () -> trace('delayed 5'));

        // trace('done');

        var i = 0;

        final scheduler  = new NewThreadScheduler();
        final disposable = scheduler.schedulePeriodically(1, 3, () -> {
            trace('doing work');
        });

        final scheduler = new ImmediateScheduler();
        scheduler.scheduleRelative(15, () -> disposable.unsubscribe());

        Sys.sleep(10);
    }
}
