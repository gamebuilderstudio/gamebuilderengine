package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBUtil;
	import com.pblabs.nape.NapeSpatialComponent;
	
	import flash.geom.Point;
	
	import nape.constraint.Constraint;
	import nape.constraint.WeldJoint;
	import nape.geom.Vec2;

	public class NapeWeldJointComponent extends NapeConstraintComponent
	{
		public function NapeWeldJointComponent()
		{
			super();
		}
		
		override public function get anchor1():Point
		{
			if ( _constraint )
				_anchor1 = (_constraint as WeldJoint).anchor1.mul(_spatialManager.scale);
			return super.anchor1;
		}
		
		override public function set anchor1(value:Point):void
		{
			super.anchor1 = value;
			if ( _constraint )
				(_constraint as WeldJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		override public function get anchor2():Point
		{
			if ( _constraint )
				_anchor2 = (_constraint as WeldJoint).anchor2.mul(_spatialManager.scale);
			return super.anchor2;
		}
		
		override public function set anchor2(value:Point):void
		{
			super.anchor2 = value;
			if ( _constraint )
				(_constraint as WeldJoint).anchor2 = _anchor2.mul(_spatialManager.inverseScale);
		}

		public function get phase():Number
		{
			if ( _constraint )
				_phase = PBUtil.getDegreesFromRadians((_constraint as WeldJoint).phase);
			return _phase;
		}
		
		public function set phase(value:Number):void
		{
			_phase = value;
			if ( _constraint )
				(_constraint as WeldJoint).phase = PBUtil.getRadiansFromDegrees(_phase);
		}
		
		override protected function destroyConstraint():void
		{
			if(_constraint){
				(_constraint as WeldJoint).body1 = null;
				(_constraint as WeldJoint).body2 = null;
			}
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			if(!_spatial1 || !_spatial1.body || !_spatial2 || !_spatial2.body || !_spatialManager){
				return null;
			}
			var invScale:Number = _spatialManager.inverseScale;
			return new WeldJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale), PBUtil.getRadiansFromDegrees(_phase));
		}
		
		private var _phase:Number = 0;
	}
}