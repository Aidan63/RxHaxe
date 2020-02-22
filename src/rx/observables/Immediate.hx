package rx.observables;

import rx.Scheduler;

class Immediate extends MakeScheduled {
	public function new() {
		super(Scheduler.immediate);
	}
}
