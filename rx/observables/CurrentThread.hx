package rx.observables;

import rx.Scheduler;

class CurrentThread extends MakeScheduled {
	public function new() {
		super(Scheduler.currentThread);
	}
}
