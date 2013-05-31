package com.pblabs.nape.constraints
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.core.InputKey;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.nape.INape2DSpatialComponent;
	import com.pblabs.nape.NapeManagerComponent;
	import com.pblabs.nape.NapeSpatialComponent;
	
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import nape.constraint.Constraint;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;

	public class NapeMouseConstraintComponent extends NapePivotJointComponent implements ITickedObject
	{
		private var _bodyList:Array = [];
		private var _worldPoint : Point = new Point();
		private var _ignoreTimeScale : Boolean = false;
		
		public function NapeMouseConstraintComponent()
		{
			super();
		}
		
		public function onTick(deltaTime:Number):void
		{
			if(!_constraint){
				constructConstraint();
			}

			if(PBE.inputManager.keyJustPressed(InputKey.MOUSE_BUTTON.keyCode) && _constraint && _spatialManager)
			{
				_worldPoint.setTo(PBE.mainStage.mouseX, PBE.mainStage.mouseY);
				_spatialManager.getObjectsUnderPoint(_worldPoint, _bodyList);
				var wp:Vec2 = Vec2.get(PBE.mainStage.mouseX, PBE.mainStage.mouseY);
				for (var i:int = 0; i < _bodyList.length; i++) {
					var body:Body = _bodyList[i].body;
					if (body.isDynamic()) {
						(_constraint as PivotJoint).body2 = body;
						(_constraint as PivotJoint).anchor2 = body.worldPointToLocal(wp, true);
						(_constraint as PivotJoint).active = true;
						break;
					}
				}
				// recycle nodes.
				wp.dispose();
				if((_constraint as PivotJoint).body2)
					_constraint.active = true;
				_bodyList.length = 0;
			}else if(_constraint && PBE.inputManager.keyJustReleased(InputKey.MOUSE_BUTTON.keyCode)){
				_constraint.active = false;
				(_constraint as PivotJoint).body2 = null;
			}
			if(_constraint && _constraint.active && (_constraint as PivotJoint).body2){
				(_constraint as PivotJoint).anchor1.setxy(PBE.mainStage.mouseX, PBE.mainStage.mouseY);
				//(_constraint as PivotJoint).body2.angularVel *= 0.9;
			}
		}
		
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val:Boolean):void
		{
			_ignoreTimeScale = true;
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
			this.active = false;
			this.stiff = false;
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
	}
}