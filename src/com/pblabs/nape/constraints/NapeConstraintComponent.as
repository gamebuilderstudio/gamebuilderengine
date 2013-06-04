package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.nape.INape2DSpatialComponent;
	import com.pblabs.nape.NapeManagerComponent;
	import com.pblabs.physics.IPhysics2DManager;
	
	import flash.geom.Point;
	
	import nape.constraint.Constraint;
	import nape.geom.Vec2;
	
	public class NapeConstraintComponent extends EntityComponent implements INape2DConstraintComponent
	{
		public function NapeConstraintComponent()
		{
			super();
		}
		
		public function resetConstraint():void
		{
			destroyConstraint();
			constructConstraint();
		}
		
		[EditorData(referenceType="componentReference")]
		public function get spatialManager():IPhysics2DManager{ return _spatialManager; }
		public function set spatialManager(value:IPhysics2DManager):void
		{
			_spatialManager = value;
		}
		
		[EditorData(referenceType="componentReference")]
		public function get spatial1():INape2DSpatialComponent { return _spatial1; }
		public function set spatial1(value:INape2DSpatialComponent):void
		{
			destroyConstraint();
			_spatial1 = value;
			constructConstraint();
		}
		
		[EditorData(referenceType="componentReference")]
		public function get spatial2():INape2DSpatialComponent { return _spatial2; }
		public function set spatial2(value:INape2DSpatialComponent):void
		{
			destroyConstraint();
			_spatial2 = value;
			constructConstraint();
		}
		
		public function get anchor1():Point
		{
			return _anchor1.toPoint();
		}
		
		public function set anchor1(value:Point):void
		{
			_anchor1 = Vec2.fromPoint(value, true);
		}
		
		public function get anchor2():Point
		{
			return _anchor2.toPoint();
		}
		
		public function set anchor2(value:Point):void
		{
			_anchor2 = Vec2.fromPoint(value, true);
		}

		public function get active():Boolean
		{
			if ( _constraint )
				_active = _constraint.active;
			return _active;
		}
		
		public function set active(value:Boolean):void
		{
			_active = value;
			if ( _constraint )
				_constraint.active = value;
		}
		
		public function get ignore():Boolean
		{
			if ( _constraint )
				_ignore = _constraint.ignore;
			return _ignore;
		}
		
		public function set ignore(value:Boolean):void
		{
			_ignore = value;
			if ( _constraint )
				_constraint.ignore = _ignore;
		}
		
		public function get stiff():Boolean
		{
			if ( _constraint )
				_stiff = _constraint.stiff;
			return _stiff;
		}
		
		public function set stiff(value:Boolean):void
		{
			_stiff = value;
			if (_constraint)
				_constraint.stiff = _stiff;
		}
		
		public function get breakUnderMaxForce():Boolean
		{
			if ( _constraint )
				_breakUnderMaxForce = _constraint.breakUnderForce;
			return _breakUnderMaxForce;
		}
		
		public function set breakUnderMaxForce(value:Boolean):void
		{
			_breakUnderMaxForce = value;
			if (_constraint)
				_constraint.breakUnderForce = _breakUnderMaxForce;
		}

		public function get breakUnderError():Boolean
		{
			if ( _constraint )
				_breakUnderError = _constraint.breakUnderError;
			return _breakUnderError;
		}
		
		public function set breakUnderError(value:Boolean):void
		{
			_breakUnderError = value;
			if (_constraint)
				_constraint.breakUnderError = _breakUnderError;
		}

		public function get maxForce():Number
		{
			if ( _constraint )
				_maxForce = _constraint.maxForce;
			return _maxForce;
		}
		
		public function set maxForce(value:Number):void
		{
			_maxForce = value;
			if (_constraint)
				_constraint.maxForce = _maxForce;
		}

		public function get maxError():Number
		{
			if ( _constraint )
				_maxError = _constraint.maxError;
			return _maxError;
		}
		
		public function set maxError(value:Number):void
		{
			_maxError = value;
			if (_constraint)
				_constraint.maxError = _maxError;
		}

		public function get frequency():Number
		{
			if ( _constraint )
				_frequency = _constraint.frequency;
			return _frequency;
		}
		
		public function set frequency(value:Number):void
		{
			_frequency = value;
			if (_constraint)
				_constraint.frequency = _frequency;
		}

		public function get damping():Number
		{
			if ( _constraint )
				_damping = _constraint.damping;
			return _damping;
		}
		
		public function set damping(value:Number):void
		{
			_damping = value;
			if (_constraint)
				_constraint.damping = _damping;
		}

		public function get constraint():Constraint
		{
			return _constraint;
		}

		protected function constructConstraint():void
		{
			_constraint = getConstraintInstance();
			if(!_constraint){
				if(!PBE.IN_EDITOR && !_delayedConstruction){
					PBE.callLater(constructConstraint);
					_delayedConstruction = true
				}
				return;
			}
			_constraint.active = _active;
			_constraint.ignore = _ignore;
			_constraint.stiff = _stiff;
			_constraint.frequency = _frequency;
			_constraint.damping = _damping;
			if(_maxForce > 0)
				_constraint.maxForce = _maxForce;
			else 
				_constraint.maxForce = Number.POSITIVE_INFINITY;
			if(_maxError > 0)
				_constraint.maxError = _maxError;
			else 
				_constraint.maxError = Number.POSITIVE_INFINITY;
			if(_spatialManager && _spatialManager is NapeManagerComponent)
				_constraint.space = (_spatialManager as NapeManagerComponent).space;
			_delayedConstruction = false;
		}
		
		protected function destroyConstraint():void
		{
			if(_spatialManager && _spatialManager is NapeManagerComponent && (_spatialManager as NapeManagerComponent).space && _constraint){
				var removed : Boolean = (_spatialManager as NapeManagerComponent).space.constraints.remove(_constraint);
			}
			if(_constraint)
				_constraint.space = null;
			_constraint = null;
		}
		
		protected function getConstraintInstance():Constraint
		{
			//return new Constraint();
			return null;
		}
		
		override protected function onAdd():void
		{
			super.onAdd();
			constructConstraint();
		}
		
		override protected function onRemove():void
		{
			destroyConstraint();
			super.onRemove();
		}
		
		protected var _constraint:Constraint;
		protected var _spatialManager:IPhysics2DManager;
		protected var _spatial1:INape2DSpatialComponent;
		protected var _spatial2:INape2DSpatialComponent;
		protected var _anchor1:Vec2 = Vec2.weak();
		protected var _anchor2:Vec2 = Vec2.weak();
		protected var _active:Boolean = true;
		protected var _ignore:Boolean = false;
		protected var _stiff:Boolean = true;
		protected var _frequency:Number = 10;
		protected var _damping:Number = 0.5;
		protected var _breakUnderMaxForce:Boolean = false;
		protected var _breakUnderError:Boolean = false;
		protected var _maxForce : Number = 0;
		protected var _maxError : Number = 0;
		private var _delayedConstruction : Boolean = false;
		
	}
}