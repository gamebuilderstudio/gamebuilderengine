package com.pblabs.nape
{
	import com.pblabs.physics.IPhysics2DSpatial;
	import com.pblabs.physics.IPhysicsShape;
	
	import flash.geom.Point;
	
	import nape.callbacks.CbType;
	import nape.phys.Material;
	import nape.shape.Shape;

	public class CollisionShape implements IPhysicsShape
	{
		public function CollisionShape()
		{
		}
		
		[EditorData(defaultValue="default")]
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
			if(_shape && _shape.userData)
				_shape.userData.name = _name;
		}

		[EditorData(defaultValue="1")]
		public function get density():Number
		{
			return _density;
		}
		
		public function set density(value:Number):void
		{
			_density = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		public function get friction():Number
		{
			return _friction;
		}
		
		public function set friction(value:Number):void
		{
			_friction = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		public function get rollingFriction():Number
		{
			return _rollingFriction;
		}
		
		public function set rollingFriction(value:Number):void
		{
			_rollingFriction = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}

		public function get restitution():Number
		{
			return _restitution;
		}
		
		public function set restitution(value:Number):void
		{
			_restitution = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}

		/**
		 * Used to scale the vertices or radius of a CollisionShape during shape creation
		 * without affecting the original values
		 **/
		public function get shapeScale():Point
		{
			return _shapeScale;
		}
		
		public function set shapeScale(value:Point):void
		{
			_shapeScale = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}

		public function get material():String
		{
			return _material;
		}
		
		public function set material(value:String):void
		{
			_material = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		public function get isTrigger():Boolean
		{
			return _isTrigger;
		}
		
		public function set isTrigger(value:Boolean):void
		{
			_isTrigger = value;
			if (_parent)
				_parent.buildCollisionShapes();
		}

		public function createShape(parent:NapeSpatialComponent, overwriteWithNewInstance : Boolean = true):Shape
		{
			_parent = parent;
			if(!_shape || overwriteWithNewInstance)
				_shape = doCreateShape();
			var materialObj:Material;
			if(!_material || _material == ""){
				materialObj = internalMaterial;
			}else{
				var matManager:NapeMaterialManager = (parent.spatialManager as NapeManagerComponent).materialManager;
				materialObj = matManager.getMaterial(this.material);
			}
			if ( materialObj )
				_shape.material = materialObj;
				
			_shape.filter = parent.interactionFilter;
			if(_isTrigger){
				_shape.sensorEnabled = true;
				if(!_parent.body.cbTypes.has(SENSORS))
					_parent.body.cbTypes.add(SENSORS);
			}else{
				_shape.sensorEnabled = false;
				if(_parent.body.cbTypes.has(SENSORS))
					_parent.body.cbTypes.remove(SENSORS);
			}
			
			_shape.userData.spatial = parent;
			_shape.userData.name = _name;
			return _shape;
		}
		
		public function clearParent():void
		{
			_parent = null;
		}
		
		protected function doCreateShape():Shape
		{
			return new Shape();
		}
		
		public function get containerSpatial():IPhysics2DSpatial { return _parent; }
		
		public function get internalShape():Shape { return _shape; }
		
		public function get internalMaterial():Material
		{
			if(!_internalMaterial)
			{
				_internalMaterial = new Material(_restitution, _friction, _friction, _density, _rollingFriction);
			}else{
				_internalMaterial.elasticity = _restitution;
				_internalMaterial.dynamicFriction = _internalMaterial.staticFriction = _friction;
				_internalMaterial.density = _density;
				_internalMaterial.rollingFriction = _rollingFriction;
			}
			return _internalMaterial;
		}
		
		public static var SENSORS : CbType = new CbType();

		protected var _parent:NapeSpatialComponent = null;
		protected var _shape : Shape;
		
		private var _material:String;
		private var _internalMaterial:Material;
		private var _density:Number = 1.0;
		private var _friction:Number = 0.01;
		private var _rollingFriction:Number = 0.01;
		private var _restitution:Number = 0.0;
		private var _shapeScale : Point = new Point(1,1);
		private var _isTrigger:Boolean = false;
		private var _name : String = "body";
	}
}