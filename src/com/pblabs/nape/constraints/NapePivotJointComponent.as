package com.pblabs.nape.constraints
{
	import com.pblabs.nape.NapeSpatialComponent;
	
	import flash.geom.Point;
	
	import nape.constraint.Constraint;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;

	public class NapePivotJointComponent extends NapeConstraintComponent
	{
		public function NapePivotJointComponent()
		{
			super();
		}
		
		override public function get anchor1():Point
		{
			if ( _constraint )
				_anchor1 = (_constraint as PivotJoint).anchor1.mul(_spatialManager.scale);
			return super.anchor1;
		}
		
		override public function set anchor1(value:Point):void
		{
			super.anchor1 = value;
			if ( _constraint )
				(_constraint as PivotJoint).anchor1 = _anchor1.mul(_spatialManager.inverseScale);
		}
		
		override public function get anchor2():Point
		{
			if ( _constraint )
				_anchor2 = (_constraint as PivotJoint).anchor2.mul(_spatialManager.scale);
			return super.anchor2;
		}
		
		override public function set anchor2(value:Point):void
		{
			super.anchor2 = value;
			if ( _constraint )
				(_constraint as PivotJoint).anchor2 = _anchor2.mul(_spatialManager.inverseScale);
		}

		override protected function destroyConstraint():void
		{
			if(_constraint){
				(_constraint as PivotJoint).body1 = null;
				(_constraint as PivotJoint).body2 = null;
			}
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			if(!_spatial1 || !_spatial1.body || !_spatial2 || !_spatial2.body || !_spatialManager){
				return null;
			}
			var invScale:Number = _spatialManager.inverseScale;
			return new PivotJoint(_spatial1.body, _spatial2.body, _anchor1.mul(invScale), _anchor2.mul(invScale));
		}
	}
}