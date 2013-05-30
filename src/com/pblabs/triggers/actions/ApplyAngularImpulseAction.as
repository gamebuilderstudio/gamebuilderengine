package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.nape.INape2DSpatialComponent;
	
	import flash.geom.Point;
	
	import nape.geom.Vec2;
	
	public class ApplyAngularImpulseAction extends BaseAction
	{
		/**
		 * The reference to the physics spatial that will be affected.  
		 **/
		public var spatialReference : PropertyReference;
		/**
		 * The impulse value to apply in the X direction. 
		 **/
		public var impulseRef : ExpressionReference = new ExpressionReference("0");
		
		private var _spatial : INape2DSpatialComponent;
		
		public function ApplyAngularImpulseAction(){
			super();
			_type = ActionType.PERSISTANT;
		}
		
		override public function execute():*
		{
			if(!spatialReference || !impulseRef)
				return;
			
			if(!_spatial)
				_spatial = this.owner.owner.getProperty( spatialReference ) as INape2DSpatialComponent;
			if(_spatial && _spatial.body)
			{
				_spatial.body.applyAngularImpulse( Number(getExpressionValue(impulseRef)) );
			}
			return;
		}
		
		override public function destroy():void
		{
			_spatial = null;
			impulseRef.destroy();
			impulseRef = null;
			super.destroy();
		}
	}
}