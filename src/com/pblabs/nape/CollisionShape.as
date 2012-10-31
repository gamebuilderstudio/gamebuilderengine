package com.pblabs.nape
{
	import nape.dynamics.InteractionFilter;
	import nape.phys.Material;
	import nape.shape.Shape;

	public class CollisionShape
	{
		public function CollisionShape()
		{
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
		
		public function get interactionFilter():InteractionFilter
		{
			return _interactionFilter;
		}
		
		public function set interactionFilter(value:InteractionFilter):void
		{
			_interactionFilter = value;
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		public function createShape(parent:NapeSpatialComponent):Shape
		{
			_parent = parent;
			//var bodyBits:uint = parent.objectMask.bits;
			
			var shape:Shape = doCreateShape();
			var matManager:NapeMaterialManager = (parent.spatialManager as NapeManagerComponent).materialManager;
			var materialObj:Material = matManager.getMaterial(this.material);
			if ( materialObj )
				shape.material = materialObj;
				
			//keep it for now..
			/*if ( _interactionFilter )
				shape.filter = _interactionFilter;
			else
			{
				shape.filter = new InteractionFilter( parent.collisionType ? parent.collisionType.bits : 1, parent.collidesWithTypes ? parent.collidesWithTypes.bits : -1);
			}*/
			shape.filter = new InteractionFilter( parent.collisionType ? parent.collisionType.bits : 1, parent.collidesWithTypes ? parent.collidesWithTypes.bits : -1);

			shape.userData.spatial = parent;
			
			return shape;
		}
		
		protected function doCreateShape():Shape
		{
			return new Shape();
		}
		
		protected var _parent:NapeSpatialComponent = null;
		
		private var _interactionFilter:InteractionFilter;
		private var _material:String;
	}
}