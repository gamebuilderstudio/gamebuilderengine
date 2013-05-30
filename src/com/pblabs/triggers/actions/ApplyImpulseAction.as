package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.nape.INape2DSpatialComponent;
	
	import flash.geom.Point;
	
	import nape.geom.Vec2;
	
	public class ApplyImpulseAction extends BaseAction
	{
		/**
		 * The reference to the physics spatial that will be affected.  
		 **/
		public var spatialReference : PropertyReference;
		/**
		 * The impulse value to apply in the X direction. 
		 **/
		public var impulseX : ExpressionReference = new ExpressionReference("0");
		/**
		 * The impulse value to apply in the Y direction. 
		 **/
		public var impulseY : ExpressionReference = new ExpressionReference("0");
		
		private var _spatial : INape2DSpatialComponent;
		private var _impulseVal : Vec2 = Vec2.get();
		
		public function ApplyImpulseAction(){
			super();
			_type = ActionType.PERSISTANT;
		}
		
		override public function execute():*
		{
			if(!spatialReference || !impulseX || !impulseY)
				return;
			
			if(!_spatial)
				_spatial = this.owner.owner.getProperty( spatialReference ) as INape2DSpatialComponent;
			if(_spatial && _spatial.body)
			{
				_impulseVal.setxy( getExpressionValue(impulseX), getExpressionValue(impulseY) );
				_spatial.body.applyImpulse( _impulseVal );
			}
			return;
		}
		
		override public function destroy():void
		{
			_impulseVal.dispose();
			_impulseVal = null;
			impulseX.destroy();
			impulseX = null;
			impulseY.destroy();
			impulseY = null;
			_spatial = null;
			super.destroy();
		}
	}
}