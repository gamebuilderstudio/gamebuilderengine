package com.pblabs.nape
{
	import com.pblabs.physics.IPhysicsShape;
	
	import flash.geom.Point;
	
	import nape.callbacks.CbType;
	import nape.dynamics.InteractionFilter;
	import nape.phys.Material;
	import nape.shape.Shape;

	public class CollisionShape implements IPhysicsShape
	{
		public function CollisionShape()
		{
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

		public function createShape(parent:NapeSpatialComponent, forceNewInstance : Boolean = false):Shape
		{
			_parent = parent;
			
			if(!_shape || forceNewInstance)
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
			
			return _shape;
		}
		
		protected function doCreateShape():Shape
		{
			return new Shape();
		}
		
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
		
		private var _material:String;
		private var _internalMaterial:Material;
		private var _density:Number = 1.0;
		private var _friction:Number = 0.01;
		private var _rollingFriction:Number = 0.01;
		private var _restitution:Number = 0.0;
		private var _shapeScale : Point = new Point(1,1);
		private var _isTrigger:Boolean = false;
		private var _shape : Shape;
	}
}