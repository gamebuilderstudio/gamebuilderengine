package com.pblabs.nape.constraints
{
	import com.pblabs.nape.NapeManagerComponent;
	
	import flash.geom.Point;
	
	import nape.constraint.Constraint;
	import nape.constraint.DistanceJoint;

	public class NapeDistanceJointComponent extends NapeConstraintComponent
	{
		public function NapeDistanceJointComponent()
		{
			super();
		}
		
		override public function get anchor1():Point
		{
			if ( _constraint )
				_anchor1 = (_constraint as DistanceJoint).anchor1.mul(_spatialManager.scale);
			return super.anchor1;
		}
		
		override public function set anchor1(value:Point):void
		{
			super.anchor1 = value;
			if ( _constraint )
				(_constraint as DistanceJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		override public function get anchor2():Point
		{
			if ( _constraint )
				_anchor2 = (_constraint as DistanceJoint).anchor2.mul(_spatialManager.scale);
			return super.anchor2;
		}
		
		override public function set anchor2(value:Point):void
		{
			super.anchor2 = value;
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
			if(!_spatial1 || !_spatial1.body || !_spatial2 || !_spatial2.body || !_spatialManager || (_spatialManager is NapeManagerComponent && !(_spatialManager as NapeManagerComponent).space)){
				return null;
			}
			var invScale:Number = _spatialManager.inverseScale;
			return new DistanceJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale), _jointMin*invScale, _jointMax*invScale);
		}
		
		private var _jointMin:Number = 20;
		private var _jointMax:Number = 20;
	}
}