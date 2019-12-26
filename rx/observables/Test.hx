package rx.observables;

import rx.Scheduler;

class Test extends MakeScheduled {
	public function new() {
		super(Scheduler.test);
	}
}
