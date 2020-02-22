package rx.schedulers;

class TimedAction {
	public final discardableAction:() -> Void;
	public final execTime:Float;

	public function new(_discardableAction:() -> Void, _execTime:Float) {
		discardableAction = _discardableAction;
		execTime = _execTime;
	}

	public function equal(_ta1:TimedAction, _ta2:TimedAction):Bool
		return _ta1.execTime == _ta2.execTime;
}
