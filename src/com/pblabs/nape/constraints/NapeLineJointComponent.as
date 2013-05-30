package com.pblabs.nape.constraints
{
	import com.pblabs.nape.NapeSpatialComponent;
	
	import flash.geom.Point;
	
	import nape.constraint.Constraint;
	import nape.constraint.LineJoint;
	import nape.geom.Vec2;

	public class NapeLineJointComponent extends NapeConstraintComponent
	{
		public function NapeLineJointComponent()
		{
			super();
		}
		
		override public function get anchor1():Point
		{
			if ( _constraint )
				_anchor1 = (_constraint as LineJoint).anchor1.mul(_spatialManager.scale);
			return super.anchor1;
		}
		
		override public function set anchor1(value:Point):void
		{
			super.anchor1 = value;
			if ( _constraint )
				(_constraint as LineJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		override public function get anchor2():Point
		{
			if ( _constraint )
				_anchor2 = (_constraint as LineJoint).anchor2.mul(_spatialManager.scale);
			return super.anchor2;
		}
		
		override public function set anchor2(value:Point):void
		{
			super.anchor2 = value;
			if ( _constraint )
				(_constraint as LineJoint).anchor2 = _anchor2.mul(_spatialManager.inverseScale);
		}

		public function get direction():Point
		{
			if ( _constraint )
				_direction = (_constraint as LineJoint).direction.mul(_spatialManager.scale);
			return _direction.toPoint();
		}
		
		public function set direction(value:Point):void
		{
			_direction = Vec2.fromPoint(value, true);
			if ( _constraint )
				(_constraint as LineJoint).direction = _direction.mul(_spatialManager.inverseScale);
		}
		
		public function get jointMin():Number
		{
			if ( _constraint )
				_jointMin = (_constraint as LineJoint).jointMin * _spatialManager.scale;
			return _jointMin;
		}
		
		public function set jointMin(value:Number):void
		{
			_jointMin = value;
			if ( _constraint )
				(_constraint as LineJoint).jointMin = _jointMin * _spatialManager.inverseScale;
		}
		
		public function get jointMax():Number
		{
			if ( _constraint )
				_jointMax = (_constraint as LineJoint).jointMax * _spatialManager.scale;
			return _jointMax;
		}
		
		public function set jointMax(value:Number):void
		{
			_jointMax = value;
			if ( _constraint )
				(_constraint as LineJoint).jointMax = _jointMax * _spatialManager.inverseScale;
		}
		
		override protected function destroyConstraint():void
		{
			if(_constraint){
				(_constraint as LineJoint).body1 = null;
				(_constraint as LineJoint).body2 = null;
			}
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			if(!_spatial1 || !_spatial1.body || !_spatial2 || !_spatial2.body || !_spatialManager){
				return null;
			}
			var invScale:Number = _spatialManager.inverseScale;
			return new LineJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale), _direction.mul(invScale), _jointMin*invScale, _jointMax*invScale);
		}
		
		private var _direction:Vec2 = Vec2.weak();
		private var _jointMin:Number = 0;
		private var _jointMax:Number = 0;
	}
}