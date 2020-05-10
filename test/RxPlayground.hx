import rx.Observer;
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

        //

        var i = 0;

        final obs = new Observer<Bool>();
        obs.onNext(true);
        obs.onNext(false);

        final scheduler  = new NewThreadScheduler();
        final disposable = scheduler.schedulePeriodically(1, 3, () -> {
            trace('doing work');
        });

        final scheduler = new ImmediateScheduler();
        scheduler.scheduleRelative(15, () -> disposable.unsubscribe());

        Sys.sleep(10);
    }
}
