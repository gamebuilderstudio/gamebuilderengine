package com.pblabs.starling2D
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.Resource;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class ResourceTextureManagerG2D
	{
		private static var _originTexturesMap : Dictionary = new Dictionary();
		private static var _subTexturesMap : Dictionary = new Dictionary();
		private static var _textureAtlasMap : Dictionary = new Dictionary();
		private static var _textureReferenceCount : Dictionary = new Dictionary();
		
		public function ResourceTextureManagerG2D()
		{
		}
		
		public static function releaseTextures():void
		{
			//Release original parent texture if it is no longer referenced anywhere in the engine
			for(var key : * in _originTexturesMap)
			{
				var len : int = _originTexturesMap[key].length;
				for(var i : int = 0; i < len; i++)
				{
					var originObject : * = _originTexturesMap[key][i]
					_originTexturesMap[key].splice(i, 1);
					if(!_originTexturesMap[key] || _originTexturesMap[key].length < 1)
						delete _originTexturesMap[key];
					
					delete _textureReferenceCount[originObject];
					if(originObject["disposed"] && originObject["dispose"] != null )
					{
						originObject.disposed.remove(releaseTexture);
						originObject.dispose();
					}
				}
			}
			for(key in _subTexturesMap)
			{
				_subTexturesMap[key].disposed.remove(releaseTexture);
				_subTexturesMap[key].dispose();
				delete _subTexturesMap[key];
			}
			_originTexturesMap = new Dictionary();
			_subTexturesMap = new Dictionary();
			_textureAtlasMap = new Dictionary();
			_textureReferenceCount = new Dictionary();
		}
		
		public static function mapTextureToResource(texture : Texture, resource : Resource):void
		{
			if(!resource || !texture)
				return;
			
			texture.disposed.addOnce(releaseTexture);
			if(!_originTexturesMap[resource])
				_originTexturesMap[resource] = new Vector.<Texture>();
			_textureReferenceCount[texture] = 0;
			_originTexturesMap[resource].push( texture );
		}
		
		public static function mapTexturesToResource(textures : Vector.<Texture>, resource : Resource):void
		{
			if(!resource || !textures)
				return;
			
			var len : int = textures.length;
			for(var i : int = 0; i < len; i++)
			{
				_textureReferenceCount[textures[i]] = 0;
				textures[i].disposed.addOnce(releaseTexture);
			}
			_originTexturesMap[resource] = textures;
		}
		
		
		public static function mapTextureAtlasToResource(atlas : TextureAtlas, resource : Resource):void
		{
			if(!resource || !atlas)
				return;
			
			_textureReferenceCount[atlas] = 0;
			_originTexturesMap[resource] = [ atlas ];
		}
		
		public static function mapTextureWithKey(texture : Texture, key : String):void
		{
			if(!key || !texture)
				return;
			texture.disposed.addOnce(releaseTexture);
			if(!_originTexturesMap[key])
				_originTexturesMap[key] = new Vector.<Texture>();
			
			_textureReferenceCount[texture] = 0;
			_originTexturesMap[key].push( texture );
		}
		
		public static function getTextureForBitmapData(data : BitmapData, cacheKey : String = null):Texture
		{
			if(!data)
				return null;
			
			var key : * = cacheKey;
			if(!cacheKey)
				key = data;
			
			var subtexture : Texture;
			var texture : Texture;
			if(_originTexturesMap.hasOwnProperty(key) && _originTexturesMap[ key ] != null)
			{
				texture = _originTexturesMap[key][0] as Texture;
				_textureReferenceCount[texture]++;
				subtexture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTexturesMap[subtexture] = texture;
				return subtexture;
			}else{
				texture = Texture.fromBitmapData(data, false);
				texture.disposed.addOnce(releaseTexture);
				_originTexturesMap[key] = new Vector.<Texture>();
				_originTexturesMap[key].push( texture );
				_textureReferenceCount[texture] = 1;
				subtexture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTexturesMap[subtexture] = texture;
				return subtexture;
			}
		}
		
		public static function getTextureForResource(resource : Resource):Texture
		{
			if(!resource)
				return null;

			if(_originTexturesMap[ resource ])
			{
				var texture : Texture = _originTexturesMap[resource][0] as Texture;
				_textureReferenceCount[texture]++;
				var subtexture : Texture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTexturesMap[subtexture] = texture;
				return subtexture;
			}
			return null;
		}
		
		public static function getTexturesForResource(resource : Resource):Vector.<Texture>
		{
			if(!resource)
				return null;
			
			if(_originTexturesMap[resource])
			{
				var len : int = _originTexturesMap[resource].length;
				var newTextureList : Vector.<Texture> = new Vector.<Texture>();
				for(var i : int = 0; i < len; i++)
				{
					var texture : Texture = _originTexturesMap[resource][i] as Texture;
					_textureReferenceCount[texture]++;
					var subtexture : Texture = Texture.fromTexture(texture);
					subtexture.disposed.addOnce(releaseTexture);
					_subTexturesMap[subtexture] = texture;
					newTextureList.push(subtexture);
				}
				return newTextureList;
			}
			return null;
		}

		public static function getTextureAtlasForResource(resource : Resource):TextureAtlas
		{
			if(!resource)
				return null;
			
			if(_originTexturesMap[resource.filename])
			{
				var atlas : TextureAtlas = _originTexturesMap[resource][0] as TextureAtlas;
				//_textureReferenceCount[atlas]++;
				return atlas;
			}
			return null;
		}
		
		public static function getTextureForAtlasRegion(atlas : TextureAtlas, regionName : String, region : Rectangle, frame : Rectangle = null):Texture
		{
			var subtexture : Texture
			if(atlas.getRegion(regionName)){
				subtexture = atlas.getTexture(regionName);
			}else{
				atlas.addRegion(regionName, region, frame);
				subtexture = atlas.getTexture(regionName);
			}
			subtexture.disposed.addOnce(releaseTexture);
			_subTexturesMap[subtexture] = atlas;
			_textureReferenceCount[atlas]++;
			return subtexture;
		}
		
		public static function getTextureByKey(key : String):Texture
		{
			if(!key)
				return null;
			
			if(_originTexturesMap[ key ])
			{
				var texture : Texture = _originTexturesMap[key][0] as Texture;
				_textureReferenceCount[texture]++;
				var subtexture : Texture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTexturesMap[subtexture] = texture;
				return subtexture;
			}
			return null;
		}

		private static function releaseTexture(texture : Texture):void
		{
			try{
				var originObject : Object;
				if(_subTexturesMap[texture])
				{
					originObject = _subTexturesMap[texture];
					_textureReferenceCount[originObject]--;
					if(_textureReferenceCount[originObject] > 0){
						delete _subTexturesMap[texture];
						return;
					}
				}else if(!_originTexturesMap[texture]){
					return;
				}else{
					originObject = texture;
				}
				
				//Release original parent texture if it is no longer referenced anywhere in the engine
				for(var key : * in _originTexturesMap)
				{
					var len : int = _originTexturesMap[key].length;
					for(var i : int = 0; i < len; i++)
					{
						if(_originTexturesMap[key][i] == originObject){
							_originTexturesMap[key].splice(i, 1);
							if(!_originTexturesMap[key] || _originTexturesMap[key].length < 1)
								delete _originTexturesMap[key];
							
							delete _textureReferenceCount[originObject];
							if(originObject["disposed"] && originObject["dispose"] != null )
							{
								originObject.disposed.remove(releaseTexture);
								originObject.dispose();
							}
							return;
						}
					}
				}
			}catch(e : Error){
				Logger.error(null, "releaseTexture", "Error releasing texture");
			}
			
		}
	}
}