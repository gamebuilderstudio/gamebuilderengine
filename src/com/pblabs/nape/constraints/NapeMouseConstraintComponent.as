package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.core.InputKey;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.nape.INape2DSpatialComponent;
	import com.pblabs.nape.NapeManagerComponent;
	
	import flash.geom.Point;
	
	import nape.constraint.Constraint;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;

	public class NapeMouseConstraintComponent extends NapePivotJointComponent implements ITickedObject
	{
		private var _stagePoint : Point = new Point();
		private var _ignoreTimeScale : Boolean = false;
		
		public function NapeMouseConstraintComponent()
		{
			super();
			_active = false;
			_stiff = false;
		}
		
		public function onTick(deltaTime:Number):void
		{
			if(!_constraint){
				constructConstraint();
			}
			if(!_constraint || !_spatialManager)
				return;

			_stagePoint.setTo(PBE.mainStage.mouseX, PBE.mainStage.mouseY);
			if(PBE.inputManager.keyJustPressed(InputKey.MOUSE_BUTTON.keyCode))
			{
				if(_spatialManager is NapeManagerComponent)
				{
					var allSpatials : Vector.<INape2DSpatialComponent> = (_spatialManager as NapeManagerComponent).spatialObjectList;
					var len : int = allSpatials.length;
					
					var wp:Vec2 = Vec2.get(_stagePoint.x, _stagePoint.y);
					var objectFound : Boolean = false;
					for (var i:int = 0; i < len; i++) 
					{
						var currentSpatial : INape2DSpatialComponent = allSpatials[i];
						if(!currentSpatial.pointOccupied(_stagePoint, null, null, true))
							continue;
							
						var body:Body = currentSpatial.body;
						if (body.isDynamic() || body.isKinematic()) 
						{
							(_constraint as PivotJoint).body2 = body;
							(_constraint as PivotJoint).anchor2.set( body.worldPointToLocal(wp, true) );
							(_constraint as PivotJoint).active = true;
							objectFound = true;
							break;
						}
					}
					// recycle nodes.
					wp.dispose();
					if(objectFound && (_constraint as PivotJoint).body2)
						_constraint.active = true;
					else
						disableConstraint();
				}
			}else if(PBE.inputManager.keyJustReleased(InputKey.MOUSE_BUTTON.keyCode)){
				disableConstraint();
			}
			if(_constraint && _constraint.active && (_constraint as PivotJoint).body2 && (_constraint as PivotJoint).body2.space){
				(_constraint as PivotJoint).anchor1.setxy(_stagePoint.x * _spatialManager.inverseScale, _stagePoint.y * _spatialManager.inverseScale);
				//(_constraint as PivotJoint).body2.angularVel *= 0.9;
			}
		}
		
		private function disableConstraint():void
		{
			if(!_constraint) return;
			
			_constraint.active = false;
			(_constraint as PivotJoint).body2 = null;
		}
		
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val:Boolean):void
		{
			_ignoreTimeScale = val;
		}
		
		[EditorData(referenceType="componentReference")]
		override public function get spatial1():INape2DSpatialComponent { return _spatial1; }
		override public function set spatial1(value:INape2DSpatialComponent):void
		{
			Logger.warn(this, "set spatial1", "Spatial 1 not used for this constraint");
		}
		
		[EditorData(referenceType="componentReference")]
		override public function get spatial2():INape2DSpatialComponent { return _spatial2; }
		override public function set spatial2(value:INape2DSpatialComponent):void
		{
			Logger.warn(this, "set spatial2", "Spatial 2 not used for this constraint");
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
			if(!_spatialManager || !(_spatialManager as NapeManagerComponent).space){
				return null;
			}
			var invScale:Number = _spatialManager.inverseScale;
			return new PivotJoint((_spatialManager as NapeManagerComponent).space.world, null, _anchor1.mul(invScale), _anchor2.mul(invScale));
		}
		
		override protected function onAdd():void
		{
			PBE.processManager.addTickedObject(this);
			super.onAdd();
		}
		
		override protected function onRemove():void
		{
			PBE.processManager.removeTickedObject(this);
			super.onRemove();
		}
		
		override protected function drawConstraint():void
		{
			
		}
	}
}