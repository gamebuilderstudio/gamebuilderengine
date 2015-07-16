package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.triggers.ITriggerComponent;
	
	public class BaseAction implements IAction, ITickedObject
	{
		protected var _stopped:Boolean = false;
		protected var _destroyed : Boolean = false;
		protected var _ignoreTimeScale:Boolean = false;
		protected var _addedToProcessManager : Boolean = false;

		public function BaseAction()
		{
		}
		
		public function onTick(deltaTime:Number):void
		{
			if(_addedToProcessManager)
				execute();
		}
		
		public function execute():*
		{
			if(_type == ActionType.PERSISTANT && !_addedToProcessManager){
				_addedToProcessManager = true;
				PBE.processManager.addTickedObject(this);
			}
			_stopped = false;
			return null;
		}
		
		public function updateGlobalExpressionProperty():void { }
		public function clearGlobalExpressionProperty():void { }
		
		public function stop():void { 
			if(_type == ActionType.PERSISTANT && _addedToProcessManager){
				_addedToProcessManager = false;
				PBE.processManager.removeTickedObject(this);
			}
			_stopped = true; 
		}
		
		public function destroy():void
		{
			if(_type == ActionType.PERSISTANT && _addedToProcessManager){
				_addedToProcessManager = false;
				PBE.processManager.removeTickedObject(this);
			}
			_owner = null;
			_destroyed = true;
		}
		
		public function getPropertyReferenceValue(property : PropertyReference, defaultValue : * = null):String
		{
			if(property && (property.property.indexOf("@") != -1 || property.property.indexOf("#") != -1 || property.property.indexOf("!") != -1))
				return this.owner.owner.getProperty(property, defaultValue);
			return property.property;
		}

		public function getExpressionValue(expression : ExpressionReference):*
		{
			return ExpressionReference.getExpressionValue(expression, _owner.owner);
		}
		
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val : Boolean):void{
			_ignoreTimeScale = val;
		}

		protected var _owner : ITriggerComponent;
		[EditorData(ignore="true")]
		public function get owner():ITriggerComponent { return _owner; }
		public function set owner(value:ITriggerComponent):void
		{
			_owner=value;
			if(_owner is ITickedObject){
				this.ignoreTimeScale = (_owner as ITickedObject).ignoreTimeScale;
			}
		}
		
		protected var _label : String
		public function get label():String { return _label; }
		public function set label(value:String):void
		{
			_label=value;
		}
		
		protected var _type : ActionType = ActionType.ONETIME;
		public function get type():ActionType{ return _type; }

		public function get isDestroyed():Boolean{ return _destroyed; }
		public function get isStopped():Boolean{ return _stopped; }
	}
}