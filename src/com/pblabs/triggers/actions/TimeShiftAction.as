package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.scripting.ExpressionReference;
	
	public class TimeShiftAction extends BaseAction
	{
		public function TimeShiftAction(){
			super();
			_type = ActionType.PERSISTANT;
		}
		/**
		 * The time scale of the game. If you throttle this value the game will either speed up or slow down. 
		 **/
		public var timeScaleExpression : ExpressionReference = new ExpressionReference("1");

		private var _timeScale : Number = 1;

		override public function execute():*
		{
			_timeScale = Number(getExpressionValue(timeScaleExpression));
			PBE.processManager.timeScale = _timeScale;
			return;
		}
	}
}