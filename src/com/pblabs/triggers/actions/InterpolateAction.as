package com.pblabs.triggers.actions
{
	import com.pblabs.animation.Tween;
	import com.pblabs.animation.easing.Linear;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class InterpolateAction extends BaseAction
	{
		[TypeHint(type="com.pblabs.triggers.actions.IAction")]
		public var action : IAction;
		/**
		 * The property being tweened
		 **/
		[TypeHint(type="com.pblabs.engine.entity.PropertyReference")]
		public var propertyReference:PropertyReference;
		/**
		 * The expression value to tween the property to
		 **/
		public var valueReference : ExpressionReference;
		/**
		 * The animation duration in seconds
		 **/
		public var durationReference : ExpressionReference;
		/**
		 * The amount of dealy before the begins in seconds
		 **/
		public var delayReference : ExpressionReference;
		
		public var easingClass : String = getQualifiedClassName(Linear);
		public var easingFunction : String = "easeNone";

		private var _duration : Number;
		private var _delay : Number;
		private var _tween : Tween;
		private var _propertyToTween : *;
		
		override public function execute():*
		{
			_duration = Number(getExpressionValue(durationReference));
			_delay = Number(getExpressionValue(delayReference));
			var easeClazz : Class = getDefinitionByName(easingClass) as Class;
			_propertyToTween = this.owner.owner.getProperty(propertyReference);
			_tween = new Tween(this.owner ? this.owner.owner : null, propertyReference, _duration, _propertyToTween, getExpressionValue(valueReference), easeClazz[easingFunction], onComplete, _delay, false, 1, 0, 0);
			//_tween.start();
			
			return null;
		}
		
		public function onComplete(tween : Tween):void
		{
			if(action && (!action.owner || action.owner != this.owner)){
				action.owner = this.owner;
				action.execute();
			}
		}
		
		override public function stop():void
		{
			_tween.stop();
		}
		
		override public function destroy():void
		{
			_tween.dispose();
			_tween = null;
			super.destroy();
		}
	}
}