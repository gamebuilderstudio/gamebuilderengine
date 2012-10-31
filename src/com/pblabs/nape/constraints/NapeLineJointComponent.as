package com.pblabs.nape.constraints
{
	import com.pblabs.nape.NapeSpatialComponent;
	
	import nape.constraint.Constraint;
	import nape.constraint.LineJoint;
	import nape.geom.Vec2;

	public class NapeLineJointComponent extends NapeConstraintComponent
	{
		public function NapeLineJointComponent()
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
				_anchor1 = (_constraint as LineJoint).anchor1.mul(_spatialManager.scale);
			return _anchor1;
		}
		
		public function set anchor1(value:Vec2):void
		{
			_anchor1 = value;
			if ( _constraint )
				(_constraint as LineJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		public function get anchor2():Vec2
		{
			if ( _constraint )
				_anchor2 = (_constraint as LineJoint).anchor2.mul(_spatialManager.scale);
			return _anchor2;
		}
		
		public function set anchor2(value:Vec2):void
		{
			_anchor2 = value;
			if ( _constraint )
				(_constraint as LineJoint).anchor2 = _anchor2.mul(_spatialManager.inverseScale);
		}
		
		public function get direction():Vec2
		{
			if ( _constraint )
				_direction = (_constraint as LineJoint).direction.mul(_spatialManager.scale);
			return _anchor2;
		}
		
		public function set direction(value:Vec2):void
		{
			_direction = value;
			if ( _constraint )
				(_constraint as LineJoint).direction = _anchor2.mul(_spatialManager.inverseScale);
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
			(_constraint as LineJoint).body1 = null;
			(_constraint as LineJoint).body2 = null;
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			var invScale:Number = _spatialManager.inverseScale;
			return new LineJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale), _direction.mul(invScale), _jointMin*invScale, _jointMax*invScale);
		}
		
		private var _spatial1:NapeSpatialComponent;
		private var _spatial2:NapeSpatialComponent;
		private var _anchor1:Vec2;
		private var _anchor2:Vec2;
		private var _direction:Vec2;
		private var _jointMin:Number = 0;
		private var _jointMax:Number = 0;
	}
}