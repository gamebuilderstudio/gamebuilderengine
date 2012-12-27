package com.pblabs.triggers.actions
{
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.triggers.ITriggerComponent;
	
	public class BaseAction implements IAction
	{
		public function BaseAction()
		{
		}
		
		public function execute():*
		{
			return null;
		}
		
		public function stop():void { }
		
		public function destroy():void
		{
			_owner = null;
		}
		
		public function getExpressionValue(expression : ExpressionReference):*
		{
			var value : *;
			if(expression){
				expression.selfContext = _owner.owner.Self;
				value = expression.value;
				if(!value || value == "null" || value == "undefined")
					value = expression.expression;
			}
			return value;
		}

		protected var _owner : ITriggerComponent;
		public function get owner():ITriggerComponent { return _owner; }
		public function set owner(value:ITriggerComponent):void
		{
			_owner=value;
		}
		
		protected var _label : String
		public function get label():String { return _label; }
		public function set label(value:String):void
		{
			_label=value;
		}
		
		protected var _type : ActionType = ActionType.ONETIME;
		public function get type():ActionType{ return _type; }
	}
}