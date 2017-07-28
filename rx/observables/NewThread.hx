
package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Scheduler;

class NewThread extends  MakeScheduled
{   
    public function new (){
        super();
        scheduler=Scheduler.newThread;
    }
}