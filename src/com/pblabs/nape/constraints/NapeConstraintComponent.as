package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.nape.NapeManagerComponent;
	import com.pblabs.physics.IPhysics2DConstraint;
	import com.pblabs.physics.IPhysics2DManager;
	
	import nape.constraint.Constraint;
	
	public class NapeConstraintComponent extends EntityComponent implements IPhysics2DConstraint
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
		
		public function get spatialManager():IPhysics2DManager
		{
			return _spatialManager;
		}
		
		public function set spatialManager(value:IPhysics2DManager):void
		{
			_spatialManager = value;
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
		
		public function get ingore():Boolean
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
			if(_spatialManager && _spatialManager is NapeManagerComponent)
				_constraint.space = (_spatialManager as NapeManagerComponent).space;
			_delayedConstruction = false;
		}
		
		protected function destroyConstraint():void
		{
			if(_constraint)
				_constraint.space = null;
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
		
		override protected function onReset():void
		{
			if(!_constraint)
				resetConstraint();
			super.onReset();
		}

		protected var _constraint:Constraint;
		protected var _spatialManager:IPhysics2DManager;
		
		private var _active:Boolean = true;
		private var _ignore:Boolean = false;
		private var _stiff:Boolean = true;
		private var _frequency:Number = 10;
		private var _damping:Number = 0.5;
		private var _delayedConstruction : Boolean = false;
		
	}
}