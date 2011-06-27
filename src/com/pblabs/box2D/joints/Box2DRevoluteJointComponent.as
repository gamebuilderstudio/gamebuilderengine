package com.pblabs.box2D.joints
{
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import Box2DAS.Dynamics.Joints.b2RevoluteJoint;
	import Box2DAS.Dynamics.Joints.b2RevoluteJointDef;
	import com.pblabs.box2D.Box2DManagerComponent;
	import com.pblabs.box2D.Box2DSpatialComponent;
	import com.pblabs.engine.entity.EntityComponent;
	import flash.geom.Point;
	
	
	public class Box2DRevoluteJointComponent extends EntityComponent {
		//-----------------------------------------------------------------------------
		//
		//  Properties
		//
		//-----------------------------------------------------------------------------
		
		private var jointDef:b2RevoluteJointDef;
		
		private var updatedReferenceAngle:Boolean;
		
		private var disposing:Boolean;
		
		
		//-------------------------------------
		//  joint
		//-------------------------------------
		
		private var _joint:b2RevoluteJoint;
		
		public function get joint():b2RevoluteJoint {
				return _joint;
			}
		
		
		//-------------------------------------
		//  spatialManager
		//-------------------------------------
		
		private var _spatialManager:Box2DManagerComponent;
		
		public function get spatialManager():Box2DManagerComponent {
				return _spatialManager;
	        }
		
		public function set spatialManager(value:Box2DManagerComponent):void {
				if (value == _spatialManager)
						return;
				
				if (_joint) {
						disposeJoint();
						
						_spatialManager = value;
						
						setupJoint();
					} else {
							_spatialManager = value;
						}
	        }
		
		
		//-------------------------------------
		//  spatial1
		//-------------------------------------
		
		private var _spatial1:Box2DSpatialComponent;
		
		public function get spatial1():Box2DSpatialComponent {
				return _spatial1;
			}
		
		public function set spatial1(value:Box2DSpatialComponent):void {
				_spatial1 = value;
				
				jointDef.bodyA = value.body;
				
				updatedReferenceAngle = false;
				
				if (_joint)
						resetJoint();
			}
		
		
		//-------------------------------------
		//  spatial2
		//-------------------------------------
		
		private var _spatial2:Box2DSpatialComponent;
		
		public function get spatial2():Box2DSpatialComponent {
				return _spatial2;
			}
		
		public function set spatial2(value:Box2DSpatialComponent):void {
				_spatial2 = value;
				
				jointDef.bodyB = value.body;
				
				updatedReferenceAngle = false;
				
				if (_joint)
						resetJoint();
			}
		
		
		//-------------------------------------
		//  anchor1
		//-------------------------------------
		
		public function get anchor1():Point {
				var anchor1:Point = new Point(jointDef.localAnchorA.x, jointDef.localAnchorA.y);
				
				return anchor1;
			}
		
		public function set anchor1(value:Point):void {
				jointDef.localAnchorA.x = value.x;
				jointDef.localAnchorA.y = value.y;
				
				if (_joint)
						resetJoint();
			}
		
		
		//-------------------------------------
		//  anchor2
		//-------------------------------------
		
		public function get anchor2():Point {
				var anchor2:Point = new Point(jointDef.localAnchorB.x, jointDef.localAnchorB.y);
				
				return anchor2;
			}
		
		public function set anchor2(value:Point):void {
				jointDef.localAnchorB.x = value.x;
				jointDef.localAnchorB.y = value.y;
				
				if (_joint)
						resetJoint();
			}
		
		
		//-------------------------------------
		//  worldAnchor
		//-------------------------------------
		
		private var _worldAnchor:Point;
		
		public function get worldAnchor():Point {
				return _worldAnchor;
			}
		
		public function set worldAnchor(value:Point):void {
				if (_spatial1 == null || _spatial2 == null) {
						throw new Error("worldAnchor can only be adjusted when both spatial references have been provided.");
						return;
					}
				
				if (_spatial1.body == null || _spatial2.body == null) {
						throw new Error("worldAnchor can only be adjusted if both spatials are already active in the world.");
						return;
					}
				
				_worldAnchor = value;
				
				updateAnchors();
				
				if (_joint)
						resetJoint();
			}
		
		
		//-------------------------------------
		//  referenceAngle
		//-------------------------------------
		
		public function get referenceAngle():Number {
				return jointDef.referenceAngle;
			}
		
		public function set referenceAngle(value:Number):void {
				jointDef.referenceAngle = value;
				
				if (_joint)
						resetJoint();
			}
		
		
		//-------------------------------------
		//  lowerAngle
		//-------------------------------------
		
		public function get lowerAngle():Number {
				if (_joint)
						return _joint.GetLowerLimit();
				
				return jointDef.lowerAngle;
			}
		
		public function set lowerAngle(value:Number):void {
				jointDef.lowerAngle = value;
				
				if (_joint)
						_joint.SetLimits(value, _joint.GetUpperLimit());
			}
		
		
		//-------------------------------------
		//  upperAngle
		//-------------------------------------
		
		public function get upperAngle():Number {
				if (_joint)
						return _joint.GetUpperLimit();
				
				return jointDef.upperAngle;
			}
		
		public function set upperAngle(value:Number):void {
				jointDef.upperAngle = value;
				
				if (_joint)
						_joint.SetLimits(_joint.GetLowerLimit(), value);
			}
		
		
		//-------------------------------------
		//  maxMotorTorque
		//-------------------------------------
		
		public function get maxMotorTorque():Number {
				if (_joint)
						return _joint.GetMotorTorque();
				
				return jointDef.maxMotorTorque;
			}
		
		public function set maxMotorTorque(value:Number):void {
				jointDef.maxMotorTorque = value;
				
				if (_joint)
						_joint.SetMaxMotorTorque(value);
			}
		
		
		//-------------------------------------
		//  motorSpeed
		//-------------------------------------
		
		public function get motorSpeed():Number {
				if (_joint)
						return _joint.GetMotorSpeed();
				
				return jointDef.motorSpeed;
			}
		
		public function set motorSpeed(value:Number):void {
				jointDef.motorSpeed = value;
				
				if (_joint)
						_joint.SetMotorSpeed(value);
			}
		
		
		//-------------------------------------
		//  enableLimit
		//-------------------------------------
		
		public function get enableLimit():Boolean {
				if (_joint)
						return _joint.IsLimitEnabled();
				
				return jointDef.enableLimit;
			}
		
		public function set enableLimit(value:Boolean):void {
				jointDef.enableLimit = value;
				
				if (_joint)
						_joint.EnableLimit(value);
			}
		
		
		//-------------------------------------
		//  enableMotor
		//-------------------------------------
		
		public function get enableMotor():Boolean {
				if (_joint)
						return _joint.IsMotorEnabled();
				
				return jointDef.enableMotor;
			}
		
		public function set enableMotor(value:Boolean):void {
				jointDef.enableMotor = value;
				
				if (_joint)
						_joint.EnableMotor(value);
			}
		
		
		//-------------------------------------
		//  collideConnected
		//-------------------------------------
		
		public function get collideConnected():Boolean {
				return jointDef.collideConnected;
			}
		
		public function set collideConnected(value:Boolean):void {
				jointDef.collideConnected = value;
				
				if (_joint)
						resetJoint();
			}
		
		
		//-------------------------------------
		//  angle
		//-------------------------------------
		
		public function get angle():Number {
				if (_joint)
						return joint.GetJointAngle();
				
				return 0;
			}
		
		
		//-----------------------------------------------------------------------------
		//
		//  Constructor
		//
		//-----------------------------------------------------------------------------
		
		public function Box2DRevoluteJointComponent():void {
				initialize();
			}
		
		
		//-----------------------------------------------------------------------------
		//
		//  Methods
		//
		//-----------------------------------------------------------------------------
		
		override protected function onAdd():void {
				super.onAdd();
				
				setup();
			}
		
		
        override protected function onReset():void {
				super.onReset();
				
				setup();
	        }
        
        override protected function onRemove():void {
				disposing = true;
				
				dispose();
				
				super.onRemove();
	        }
		
		
		//-------------------------------------
		//
		//  Initialize
		//
		//-------------------------------------
		
		private function initialize():void {
				jointDef = new b2RevoluteJointDef();
			}
		
		
		//-------------------------------------
		//
		//  Setup
		//
		//-------------------------------------
		
		private function setup():void {
				if (disposing)
						return;
				
				if (_spatialManager == null) return;
				if (_spatial1 == null) return;
				if (_spatial2 == null) return;
				if (_spatial1.body == null) return;
				if (_spatial2.body == null) return;
				
				setupJoint();
			}
		
		private function dispose():void {
				disposeJoint();
			}
		
		
		//-------------------------------------
		//  joint
		//-------------------------------------
		
		private function setupJoint():void {
				if (_joint)
						disposeJoint();
				
				//We have to update our jointDef body references because the body
				//references in our spatial components were probably only populated
				//after their body definitions were instantiated into the world as
				//body instances. We would not have noticed this...
				updateBodies();
				updateReferenceAngle();
				
				_spatialManager.addJoint(jointDef, this, setupJointCompleteHandler);
			}
		
		private function setupJointCompleteHandler(joint:b2Joint):void {
				_joint = joint as b2RevoluteJoint;
				_joint.SetUserData(this);
			}
		
		private function disposeJoint():void {
				if (_joint == null)
						return;
				
				_spatialManager.removeJoint(_joint);
				
				_joint = null;
			}
		
		
		//-------------------------------------
		//
		//  Box2DRevoluteJointComponent
		//
		//-------------------------------------
		
		private function resetJoint():void {
				if (disposing)
						return;
				
				disposeJoint();
				setupJoint();
			}
		
		private function updateBodies():void {
				jointDef.bodyA = _spatial1.body;
				jointDef.bodyB = _spatial2.body;
			}
		
		private function updateReferenceAngle():void {
				if (updatedReferenceAngle)
						return;
				
				updatedReferenceAngle = true;
				
				referenceAngle = spatial2.body.GetAngle() - spatial1.body.GetAngle();
			}
		
		private function updateAnchors():void {
				var worldPoint:V2 = V2.fromP(_worldAnchor);
				var point1:V2 = spatial1.body.GetLocalPoint(worldPoint);
				var point2:V2 = spatial2.body.GetLocalPoint(worldPoint);
				
				anchor1 = new Point(point1.x, point1.y);
				anchor2 = new Point(point2.x, point2.y);
			}
	}
}