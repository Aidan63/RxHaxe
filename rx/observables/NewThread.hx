package rx.observables;

import rx.Scheduler;

class NewThread extends MakeScheduled {
	public function new() {
		super(Scheduler.newThread);
	}
}
