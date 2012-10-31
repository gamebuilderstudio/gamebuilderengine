package com.pblabs.nape.constraints
{
	import com.pblabs.nape.NapeSpatialComponent;
	
	import nape.constraint.Constraint;
	import nape.constraint.MotorJoint;

	public class NapeMotorJointComponent extends NapeConstraintComponent
	{
		public function NapeMotorJointComponent()
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
		
		public function get ratio():Number
		{
			if ( _constraint )
				_ratio = (_constraint as MotorJoint).ratio;
			return _ratio;
		}
		
		public function set ratio(value:Number):void
		{
			_ratio = value;
			if ( _constraint )
				(_constraint as MotorJoint).ratio = _ratio;
		}
		
		public function get rate():Number
		{
			if ( _constraint )
				_rate = (_constraint as MotorJoint).rate;
			return _rate;
		}
		
		public function set rate(value:Number):void
		{
			_rate = value;
			if ( _constraint )
				(_constraint as MotorJoint).rate = _rate;
		}
		
		
		override protected function destroyConstraint():void
		{
			(_constraint as MotorJoint).body1 = null;
			(_constraint as MotorJoint).body2 = null;
			super.destroyConstraint();
		}
		
		override protected function getConstraintInstance():Constraint
		{
			var invScale:Number = _spatialManager.inverseScale;
			return new MotorJoint(_spatial1.body, _spatial2.body, _rate, _ratio);
		}
		
		private var _spatial1:NapeSpatialComponent;
		private var _spatial2:NapeSpatialComponent;
		private var _ratio:Number = 1;
		private var _rate:Number = 0;
	}
}