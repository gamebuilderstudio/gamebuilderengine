package com.pblabs.nape
{
	import com.pblabs.engine.serialization.ISerializable;
	
	import nape.phys.Material;

	public class MaterialVO implements ISerializable
	{
		public var material:Material;
		public var name:String;
		
		public function MaterialVO(name:String = null, material:Material = null)
		{
			this.name = name;
			this.material = material;
		}
		
		public function serialize(xml:XML):void
		{
			if(!material)
				return;
			xml.elasticity = material.elasticity;
			xml.staticFriction = material.staticFriction;
			xml.dynamicFriction = material.dynamicFriction;
			xml.rollingFriction = material.rollingFriction;
			xml.density = material.density;
			xml.@name = name;
		}
		
		public function deserialize(xml:XML):*
		{
			if(!material)
				material = new Material();
			material.elasticity = Number(xml.elasticity);
			material.staticFriction = Number(xml.staticFriction);
			material.dynamicFriction = Number(xml.dynamicFriction);
			material.rollingFriction = Number(xml.rollingFriction);
			material.density = Number(xml.density);
			name = String(xml.@name);
			return this;
		}
	}
}