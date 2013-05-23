package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBE;
	import com.pblabs.nape.NapeSpatialComponent;
	
	import flash.geom.Point;
	
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
		
		public function get anchor1():Point
		{
			if ( _constraint )
				_anchor1 = (_constraint as DistanceJoint).anchor1.mul(_spatialManager.scale);
			return _anchor1.toPoint();
		}
		
		public function set anchor1(value:Point):void
		{
			_anchor1 = Vec2.fromPoint(value, true);
			if ( _constraint )
				(_constraint as DistanceJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		public function get anchor2():Point
		{
			if ( _constraint )
				_anchor2 = (_constraint as DistanceJoint).anchor2.mul(_spatialManager.scale);
			return _anchor2.toPoint();
		}
		
		public function set anchor2(value:Point):void
		{
			_anchor2 = Vec2.fromPoint(value, true);
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
			if(_constraint){
				(_constraint as DistanceJoint).body1 = null;
				(_constraint as DistanceJoint).body2 = null;
			}
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			if(!_spatial1 || !_spatial1.body || !_spatial2 || !_spatial2.body || !_spatialManager){
				return null;
			}
			var invScale:Number = _spatialManager.inverseScale;
			return new DistanceJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale), _jointMin*invScale, _jointMax*invScale);
		}
		
		private var _spatial1:NapeSpatialComponent;
		private var _spatial2:NapeSpatialComponent;
		private var _anchor1:Vec2 = Vec2.weak();
		private var _anchor2:Vec2 = Vec2.weak();
		private var _jointMin:Number = 20;
		private var _jointMax:Number = 20;
	}
}