package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBUtil;
	import com.pblabs.nape.NapeSpatialComponent;
	
	import nape.constraint.AngleJoint;
	import nape.constraint.Constraint;
	import nape.geom.Vec2;

	public class NapeAngleJointComponent extends NapeConstraintComponent
	{
		public function NapeAngleJointComponent()
		{
			super();
		}
		
		public function get jointMin():Number
		{
			if ( _constraint )
				_jointMin = PBUtil.getDegreesFromRadians((_constraint as AngleJoint).jointMin);
			return _jointMin;
		}
		
		public function set jointMin(value:Number):void
		{
			_jointMin = value;
			if ( _constraint )
				(_constraint as AngleJoint).jointMin = PBUtil.getRadiansFromDegrees(_jointMin);
		}
		
		public function get jointMax():Number
		{
			if ( _constraint )
				_jointMax = PBUtil.getDegreesFromRadians((_constraint as AngleJoint).jointMax);
			return _jointMax;
		}
		
		public function set jointMax(value:Number):void
		{
			_jointMax = value;
			if ( _constraint )
				(_constraint as AngleJoint).jointMax = PBUtil.getRadiansFromDegrees(_jointMax);
		}
		
		public function get ratio():Number
		{
			if ( _constraint )
				_ratio = (_constraint as AngleJoint).ratio;
			return _ratio;
		}
		
		public function set ratio(value:Number):void
		{
			_ratio = value;
			if ( _constraint )
				(_constraint as AngleJoint).ratio = _ratio;
		}
		
		override protected function destroyConstraint():void
		{
			if(_constraint){
				(_constraint as AngleJoint).body1 = null;
				(_constraint as AngleJoint).body2 = null;
			}
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			if(!_spatial1 || !_spatial1.body || !_spatial2 || !_spatial2.body || !_spatialManager){
				return null;
			}
			var invScale:Number = _spatialManager.inverseScale;
			var instance:AngleJoint = new AngleJoint(_spatial1.body, _spatial2.body, PBUtil.getRadiansFromDegrees(_jointMin), PBUtil.getRadiansFromDegrees(_jointMax), _ratio);
			return instance;
		}
		
		private var _jointMin:Number = 0;
		private var _jointMax:Number = 0;
		private var _ratio:Number = 1;
	}
}