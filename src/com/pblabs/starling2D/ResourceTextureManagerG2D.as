package com.pblabs.starling2D
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.engine.resource.Resource;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
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
					var originObject : Object = _originTexturesMap[key][i]
					_originTexturesMap[key].splice(i, 1);
					if(!_originTexturesMap[key] || _originTexturesMap[key].length < 1)
						delete _originTexturesMap[key];
					
					delete _textureReferenceCount[originObject];
					if(originObject.hasOwnProperty("disposed") && originObject.disposed && originObject.disposed is Signal)
					{
						originObject.disposed.remove(releaseTexture);
					}
					originObject.dispose();
				}
			}
			for(key in _subTexturesMap)
			{
				if(_subTexturesMap[key].hasOwnProperty("disposed") && _subTexturesMap[key].disposed && _subTexturesMap[key].disposed is Signal)
				{
					_subTexturesMap[key].disposed.remove(releaseTexture);
				}
				_subTexturesMap[key].dispose();
				delete _subTexturesMap[key];
			}
			_originTexturesMap = new Dictionary();
			_subTexturesMap = new Dictionary();
			_textureAtlasMap = new Dictionary();
			_textureReferenceCount = new Dictionary();
		}
		
		public static function getTextureForBitmapData(data : BitmapData, cacheKey : String = null, overrideBitmapData : BitmapData = null, repeat : Boolean = false):Texture
		{
			if(!data)
				return null;
			
			var key : * = cacheKey;
			if(!cacheKey)
				key = data;
			
			var subtexture : Texture;
			var texture : Texture;
			if(key in _originTexturesMap && _originTexturesMap[ key ] != null)
			{
				texture = _originTexturesMap[key][0] as Texture;
				_textureReferenceCount[texture]++;
				subtexture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTexturesMap[subtexture] = texture;
				return subtexture;
			}else{
				texture = Texture.fromBitmapData( (overrideBitmapData ? overrideBitmapData : data), false, false, _scaleFactor, "bgra", repeat);
				texture.disposed.addOnce(releaseTexture);
				_originTexturesMap[key] = new Vector.<Texture>();
				_originTexturesMap[key].push( texture );
				_textureReferenceCount[texture] = 1;
				subtexture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTexturesMap[subtexture] = texture;
				return subtexture;
			}
			return null;
		}
		
		public static function getTextureForResource(resource : ImageResource, repeat : Boolean = false):Texture
		{
			if(!resource)
				return null;

			var subtexture : Texture;
			var texture : Texture;
			if(resource in _originTexturesMap && _originTexturesMap[ resource ] != null)
			{
				texture = _originTexturesMap[resource][0] as Texture;
				_textureReferenceCount[texture]++;
				subtexture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTexturesMap[subtexture] = texture;
				return subtexture;
			}else{
				//TODO: Add support for ATFImageResources in the future
				texture = Texture.fromBitmapData(resource.bitmapData, false, false, _scaleFactor, "bgra", repeat);
				texture.disposed.addOnce(releaseTexture);
				_originTexturesMap[resource] = new Vector.<Texture>();
				_originTexturesMap[resource].push( texture );
				_textureReferenceCount[texture] = 1;
				subtexture = Texture.fromTexture(texture);
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

		public static function getTextureAtlasForResource(resource : ImageResource):TextureAtlas
		{
			if(!resource)
				return null;
			var atlas : TextureAtlas;
			if(resource in _originTexturesMap)
			{
				atlas = _originTexturesMap[resource][0] as TextureAtlas;
				//_textureReferenceCount[atlas]++;
			}else{
				var atlasTexture : Texture = getTextureForResource(resource);
				atlas = new TextureAtlas(atlasTexture);
				_originTexturesMap[resource] = new Vector.<TextureAtlas>();
				_originTexturesMap[resource].push( atlas );
			}
			return atlas;
		}
		
		public static function getTextureForAtlasRegion(atlas : TextureAtlas, regionName : String, region : Rectangle, frame : Rectangle = null):Texture
		{
			var subtexture : Texture
			if(atlas.getRegion(regionName) == null){
				atlas.addRegion(regionName, region, frame);
			}
			subtexture = atlas.getTexture(regionName);
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
				if(texture in _subTexturesMap)
				{
					originObject = _subTexturesMap[texture];
					_textureReferenceCount[originObject]--;
					if(_textureReferenceCount[originObject] > 0){
						delete _subTexturesMap[texture];
						return;
					}
				}else if(!(texture in _originTexturesMap)){
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

		/** Textures that are created from Bitmaps or ATF files will have the scale factor 
		 *  assigned here. */
		private static var _scaleFactor : Number = 1;
		public static function get scaleFactor():Number { return _scaleFactor; }
		public static function set scaleFactor(value:Number):void { _scaleFactor = value; }
	}
}