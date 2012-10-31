package com.pblabs.nape
{
	import nape.phys.Material;

	public class MaterialVO
	{
		public var material:Material;
		public var name:String;
		
		public function MaterialVO(name:String, material:Material)
		{
			this.name = name;
			this.material = material;
		}
	}
}