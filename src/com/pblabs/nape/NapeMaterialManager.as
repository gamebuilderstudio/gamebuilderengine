package com.pblabs.nape
{
	import com.pblabs.engine.entity.EntityComponent;
	
	import flash.utils.Dictionary;
	
	import nape.phys.Material;
	
	
	/**
	 * Named material storage
	 * 
	 * TODO: Should it be a entityComponent instead?..
	 * @author Pavel Belyaev
	 * 
	 */
	public class NapeMaterialManager
	{
		public function NapeMaterialManager()
		{
			super();
			setupMaterials();
		}
		
		[TypeHint(type="nape.phys.Material")]
		public function get materials():Dictionary
		{
			return _materials;
		}
		
		public function set materials(value:Dictionary):void
		{
			_materials = value;
			_materialsDirty = true;
		}
		
		public function getAllmaterials():Array
		{
			if (!_cachedArray || _materialsDirty)
			{
				_materialsDirty = false;
				_cachedArray = new Array;
				for each ( var materialVO:MaterialVO in  _materials )
					_cachedArray.push(materialVO);
			}
			return _cachedArray;
		}
		
		public function addMaterial(name:String, material:Material):void
		{
			_materialsDirty = true;
			_materials[name] = new MaterialVO(name, material);
		}
		
		public function removeMaterial(name:String):void
		{
			if ( _materials.hasOwnProperty(name) )
			{
				_materialsDirty = true;
				delete _materials[name];
			}
		}
				
		
		public function getMaterial(name:String):Material
		{
			if ( _materials[name] )
				return MaterialVO(_materials[name]).material;
			else
				return null;
		}
		
		public function getMaterialVO(name:String):MaterialVO
		{
			return _materials[name];			
		}
		
		protected function setupMaterials():void
		{
			addMaterial("napeGlass", Material.glass());
			addMaterial("napeIce", Material.ice());
			addMaterial("napeRubber", Material.rubber());
			addMaterial("napeSand", Material.sand());
			addMaterial("napeSteel", Material.steel());
			addMaterial("napeWood", Material.wood());
		}
		
		private var _materials:Dictionary = new Dictionary;
		private var _materialsDirty:Boolean;
		private var _cachedArray:Array;
	}
}