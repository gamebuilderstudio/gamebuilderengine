package com.pblabs.triggers.actions
{
	import com.pblabs.animation.Tween;
	import com.pblabs.animation.easing.Linear;
	import com.pblabs.engine.core.IAnimatedObject;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.triggers.ITriggerComponent;
	
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class InterpolateAction extends BaseAction
	{
		/**
		 * The property being tweened
		 **/
		[TypeHint(type="com.pblabs.engine.entity.PropertyReference")]
		public var propertyReference:PropertyReference;
		/**
		 * The expression value to tween the property from
		 **/
		public var fromValueReference : ExpressionReference;
		/**
		 * The expression value to tween the property to
		 **/
		public var valueReference : ExpressionReference;
		/**
		 * The animation duration in seconds
		 **/
		public var durationReference : ExpressionReference = new ExpressionReference("5");
		/**
		 * The amount of dealy before the begins in seconds
		 **/
		public var delayReference : ExpressionReference = new ExpressionReference("0");
		/**
		 * The amount of dealy before the begins in seconds
		 **/
		public var repeatCountReference : ExpressionReference = new ExpressionReference("1");
		
		public var easingClass : String = getQualifiedClassName(Linear);
		public var easingFunction : String = "easeNone";
		public var pingpong : Boolean = false;
		public var runtoCompletion : Boolean = true;

		private var _duration : Number;
		private var _delay : Number;
		private var _repeat : Number;
		private var _tween : Tween;
		private var _propertyToTween : *;
		private var _action : IAction;
		
		override public function execute():*
		{
			if(_tween && _tween.running && runtoCompletion)
				return;
			
			_duration = Number(getExpressionValue(durationReference));
			_delay = Number(getExpressionValue(delayReference));
			_repeat = Number(getExpressionValue(repeatCountReference));
			var easeClazz : Class = getDefinitionByName(easingClass) as Class;
			if(_tween)
				_tween.dispose();
			var ignoreTimeScale : Boolean = false;
			if(this.owner){
				if(this.owner is ITickedObject)
					ignoreTimeScale = (this.owner as ITickedObject).ignoreTimeScale;
				if(this.owner is IAnimatedObject)
					ignoreTimeScale = (this.owner as IAnimatedObject).ignoreTimeScale;
			}
			_tween = new Tween(this.owner ? this.owner.owner : null, propertyReference, _duration, ( (getExpressionValue(fromValueReference) is Point) ? getExpressionValue(fromValueReference) as Point : Number(getExpressionValue(fromValueReference)) ), ( (getExpressionValue(valueReference) is Point) ? getExpressionValue(valueReference) as Point : Number(getExpressionValue(valueReference)) ), easeClazz[easingFunction], onComplete, _delay, pingpong, _repeat, 0, 0, ignoreTimeScale);
			return;
		}
		
		public function onComplete(tween : Tween):void
		{
			if(_action){
				_action.owner = this.owner;
				_action.execute();
			}
		}
		
		override public function stop():void
		{
			if(_tween && !runtoCompletion)
				_tween.stop();
		}
		
		override public function destroy():void
		{
			if(_tween)
				_tween.dispose();
			_tween = null;
			
			_action = null;
			
			if(fromValueReference)
				fromValueReference.destroy()
			if(valueReference)
				valueReference.destroy()
			if(durationReference)
				durationReference.destroy()
			if(delayReference)
				delayReference.destroy()
			if(repeatCountReference)
				repeatCountReference.destroy()
			super.destroy();
		}

		override public function set owner(value:ITriggerComponent):void
		{
			super.owner = value;
			if(value && _tween){
				if(value is ITickedObject)
					_tween.ignoreTimeScale = (value as ITickedObject).ignoreTimeScale;
				if(value is IAnimatedObject)
					_tween.ignoreTimeScale = (value as IAnimatedObject).ignoreTimeScale;
			}
			if(_action)
				_action.owner = value;
		}

		/**
		 * The action to execute each time the timer fires a tick signal
		 **/
		[TypeHint(type="com.pblabs.triggers.actions.IAction")]
		public function get action():IAction { return _action; }
		public function set action(value : IAction) : void
		{
			_action = value;
			_action.owner = this.owner;
		}
	}
}