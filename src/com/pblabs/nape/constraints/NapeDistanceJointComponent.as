package com.pblabs.nape.constraints
{
	import com.pblabs.nape.NapeSpatialComponent;
	
	import nape.constraint.Constraint;
	import nape.constraint.DistanceJoint;
	import nape.geom.Vec2;

	public class NapeDistanceJointComponent extends NapeConstraintComponent
	{
		public function NapeDistanceJointComponent()
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
				_anchor1 = (_constraint as DistanceJoint).anchor1.mul(_spatialManager.scale);
			return _anchor1;
		}
		
		public function set anchor1(value:Vec2):void
		{
			_anchor1 = value;
			if ( _constraint )
				(_constraint as DistanceJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		public function get anchor2():Vec2
		{
			if ( _constraint )
				_anchor2 = (_constraint as DistanceJoint).anchor2.mul(_spatialManager.scale);
			return _anchor2;
		}
		
		public function set anchor2(value:Vec2):void
		{
			_anchor2 = value;
			if ( _constraint )
				(_constraint as DistanceJoint).anchor2 = _anchor2.mul(_spatialManager.inverseScale);
		}
		
		public function get jointMin():Number
		{
			if ( _constraint )
				_jointMin = (_constraint as DistanceJoint).jointMin * _spatialManager.scale;
			return _jointMin;
		}
		
		public function set jointMin(value:Number):void
		{
			_jointMin = value;
			if ( _constraint )
				(_constraint as DistanceJoint).jointMin = _jointMin * _spatialManager.inverseScale;
		}
		
		public function get jointMax():Number
		{
			if ( _constraint )
				_jointMax = (_constraint as DistanceJoint).jointMax * _spatialManager.scale;
			return _jointMax;
		}
		
		public function set jointMax(value:Number):void
		{
			_jointMax = value;
			if ( _constraint )
				(_constraint as DistanceJoint).jointMax = _jointMax * _spatialManager.inverseScale;
		}
		
		override protected function destroyConstraint():void
		{
			(_constraint as DistanceJoint).body1 = null;
			(_constraint as DistanceJoint).body2 = null;
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			var invScale:Number = _spatialManager.inverseScale;
			return new DistanceJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale), _jointMin*invScale, _jointMax*invScale);
		}
		
		private var _spatial1:NapeSpatialComponent;
		private var _spatial2:NapeSpatialComponent;
		private var _anchor1:Vec2;
		private var _anchor2:Vec2;
		private var _jointMin:Number = 0;
		private var _jointMax:Number = 0;
	}
}