package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBUtil;
	import com.pblabs.nape.NapeSpatialComponent;
	
	import nape.constraint.Constraint;
	import nape.constraint.WeldJoint;
	import nape.geom.Vec2;

	public class NapeWeldJointComponent extends NapeConstraintComponent
	{
		public function NapeWeldJointComponent()
		{
			super();
		}
		
		public function get spatial1():NapeSpatialComponent
		{
			return _spatial1;
		}
		
		public function set spatial1(value:NapeSpatialComponent):void
		{
			_spatial1 = value;
		}
		
		public function get spatial2():NapeSpatialComponent
		{
			return _spatial2;
		}
		
		public function set spatial2(value:NapeSpatialComponent):void
		{
			_spatial2 = value;
		}
		
		
		public function get anchor1():Vec2
		{
			if ( _constraint )
				_anchor1 = (_constraint as WeldJoint).anchor1.mul(_spatialManager.scale);
			return _anchor1;
		}
		
		public function set anchor1(value:Vec2):void
		{
			_anchor1 = value;
			if ( _constraint )
				(_constraint as WeldJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		public function get anchor2():Vec2
		{
			if ( _constraint )
				_anchor2 = (_constraint as WeldJoint).anchor2.mul(_spatialManager.scale);
			return _anchor2;
		}
		
		public function set anchor2(value:Vec2):void
		{
			_anchor2 = value;
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
				(_constraint as WeldJoint).phase = PBUtil.getRadiansFromDegrees((_constraint as WeldJoint).phase);
		}
		
		override protected function destroyConstraint():void
		{
			(_constraint as WeldJoint).body1 = null;
			(_constraint as WeldJoint).body2 = null;
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			var invScale:Number = _spatialManager.inverseScale;
			return new WeldJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale), PBUtil.getRadiansFromDegrees(_phase));
		}
		
		private var _spatial1:NapeSpatialComponent;
		private var _spatial2:NapeSpatialComponent;
		private var _anchor1:Vec2;
		private var _anchor2:Vec2;
		private var _phase:Number = 0;
	}
}