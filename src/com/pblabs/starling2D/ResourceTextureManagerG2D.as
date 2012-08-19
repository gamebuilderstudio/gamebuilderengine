package com.pblabs.starling2D
{
	import com.pblabs.engine.resource.Resource;
	
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class ResourceTextureManagerG2D
	{
		private static var _texturesMap : Dictionary = new Dictionary();
		private static var _textureAtlasMap : Dictionary = new Dictionary();
		
		public function ResourceTextureManagerG2D()
		{
		}
		
		public static function mapTextureToResource(texture : Texture, resource : Resource):void
		{
			if(!resource || !texture)
				return;
			
			texture.disposed.addOnce(removeTexture);
			if(!_texturesMap[resource.filename])
				_texturesMap[resource.filename] = new Vector.<Texture>();
			
			_texturesMap[resource.filename].push( texture );
		}
		
		public static function getTextureForResource(resource : Resource):Texture
		{
			if(!resource)
				return null;

			if(_texturesMap.hasOwnProperty( resource.filename ))
			{
				return _texturesMap[resource.filename][0];
			}
			return null;
		}
		
		public static function mapTexturesToResource(textures : Vector.<Texture>, resource : Resource):void
		{
			if(!resource || !textures)
				return;
			
			var len : int = textures.length;
			for(var i : int = 0; i < len; i++)
			{
				textures[i].disposed.addOnce(removeTexture);
			}
			_texturesMap[resource.filename] = textures;
		}

		public static function getTexturesForResource(resource : Resource):Vector.<Texture>
		{
			if(!resource)
				return null;
			
			if(_texturesMap.hasOwnProperty( resource.filename ))
			{
				return _texturesMap[resource.filename] as Vector.<Texture>;
			}
			return null;
		}

		public static function mapTextureAtlasToResource(texture : TextureAtlas, resource : Resource):void
		{
			if(!resource || !texture)
				return;
			
			_textureAtlasMap[resource.filename] = texture;
		}
		
		public static function getTextureAtlasForResource(resource : Resource):TextureAtlas
		{
			if(!resource)
				return null;
			
			if(_textureAtlasMap.hasOwnProperty( resource.filename ))
			{
				return _textureAtlasMap[resource.filename];
			}
			return null;
		}
		
		public static function mapTextureWithKey(texture : Texture, key : String):void
		{
			if(!key || !texture)
				return;
			texture.disposed.addOnce(removeTexture);
			if(!_texturesMap[key])
				_texturesMap[key] = new Vector.<Texture>();
			
			_texturesMap[key].push( texture );
		}
		
		public static function getTextureByKey(key : String):Texture
		{
			if(!key)
				return null;
			
			if(_texturesMap.hasOwnProperty( key ))
			{
				return _texturesMap[key][0];
			}
			return null;
		}
		
		private static function removeTexture(texture : Texture):void
		{
			for(var key : * in _texturesMap)
			{
				var len : int = _texturesMap[key].length;
				for(var i : int = 0; i < len; i++)
				{
					if(_texturesMap[key][i] == texture)
						_texturesMap[key].splice(i, 1);
					
					if(!_texturesMap[key] || _texturesMap[key].length < 1)
						delete _texturesMap[key];
				}
			}
		}
	}
}