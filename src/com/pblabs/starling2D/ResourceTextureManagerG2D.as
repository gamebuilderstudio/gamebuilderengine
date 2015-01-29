package com.pblabs.starling2D
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.engine.resource.Resource;
	import com.pblabs.engine.resource.ResourceManager;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class ResourceTextureManagerG2D
	{
		private static var _originTextureToBitmapDataMap : Dictionary = new Dictionary(true);
		private static var _originTexturesMap : Dictionary = new Dictionary();
		private static var _originAtlasMap : Dictionary = new Dictionary(true);
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
					var originTexture : Object = _originTexturesMap[key][i]
					_originTexturesMap[key].splice(i, 1);
					if(!_originTexturesMap[key] || _originTexturesMap[key].length < 1)
						delete _originTexturesMap[key];
					
					delete _textureReferenceCount[originTexture];
					if(originTexture is Texture && "root" in originTexture && originTexture.root in _originTextureToBitmapDataMap)
						delete _originTextureToBitmapDataMap[originTexture.root];
					if("disposed" in originTexture && originTexture.disposed && originTexture.disposed is Signal)
					{
						originTexture.disposed.remove(releaseTexture);
					}
					originTexture.dispose();
				}
			}
			for(key in _subTexturesMap)
			{
				if("disposed" in _subTexturesMap[key] && _subTexturesMap[key].disposed && _subTexturesMap[key].disposed is Signal)
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
			
			var sourceBitmapData : BitmapData = (overrideBitmapData ? overrideBitmapData : data);
			
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
				texture = Texture.fromBitmapData( sourceBitmapData, false, false, scaleFactor, "bgra", repeat);
				texture.disposed.addOnce(releaseTexture);
				texture.root.onRestore = onTextureRestored;
				_originTextureToBitmapDataMap[texture.root] = sourceBitmapData;
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
				if(resource.embeddedClass){
					texture = Texture.fromEmbeddedAsset(resource.embeddedClass, false, false, scaleFactor, "bgra", repeat);
					texture.disposed.addOnce(releaseTexture);
					resource.dispose();
				}else if(resource.isAtfImage && resource.atfData){
					texture = Texture.fromAtfData(resource.atfData, scaleFactor, false, true, repeat);
					texture.disposed.addOnce(releaseTexture);
					texture.root.onRestore = onTextureRestored;
					_originTextureToBitmapDataMap[texture.root] = resource.atfData;
				}else{
					texture = Texture.fromBitmapData(resource.bitmapData, false, false, scaleFactor, "bgra", repeat);
					texture.disposed.addOnce(releaseTexture);
					texture.root.onRestore = onTextureRestored;
					_originTextureToBitmapDataMap[texture.root] = resource.bitmapData;
				}
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
			if(resource in _originAtlasMap)
			{
				atlas = _originAtlasMap[resource][0] as TextureAtlas;
				//_textureReferenceCount[atlas]++;
			}else{
				var atlasTexture : Texture = getTextureForResource(resource);
				atlas = new TextureAtlas(atlasTexture);
				_originAtlasMap[resource] = new Vector.<TextureAtlas>();
				_originAtlasMap[resource].push( atlas );
			}
			return atlas;
		}
		
		public static function getTextureForAtlasRegion(atlas : TextureAtlas, regionName : String, region : Rectangle, frame : Rectangle = null, rotated : Boolean = false, trimmed : Boolean = false):Texture
		{
			var subtexture : Texture
			if(atlas.getRegion(regionName) == null){
				atlas.addRegion(regionName, region, frame, rotated);
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

		private static function onTextureRestored(texture : Texture):void
		{
			if(texture.root in _originTextureToBitmapDataMap && _originTextureToBitmapDataMap[texture.root] is BitmapData)
			{
				texture.root.uploadBitmapData( _originTextureToBitmapDataMap[texture.root] as BitmapData );
			}else if(texture.root in _originTextureToBitmapDataMap && _originTextureToBitmapDataMap[texture.root] is ByteArray){
				texture.root.uploadAtfData( _originTextureToBitmapDataMap[texture.root] as ByteArray );
			}
		}
		
		private static function releaseTexture(texture : Texture):void
		{
			try{
				var originTexture : Object;
				if(texture in _subTexturesMap)
				{
					originTexture = _subTexturesMap[texture];
					_textureReferenceCount[originTexture]--;
					if(_textureReferenceCount[originTexture] > 0){
						delete _subTexturesMap[texture];
						return;
					}
				}else if(!(texture in _originTexturesMap)){
					return;
				}else{
					originTexture = texture;
				}
				
				//Release original parent texture if it is no longer referenced anywhere in the engine
				/*
				for(var key : * in _originTexturesMap)
				{
					if(!(key is BitmapData)) continue;
					var len : int = _originTexturesMap[key].length;
					for(var i : int = 0; i < len; i++)
					{
						if(_originTexturesMap[key][i] == originTexture){
							_originTexturesMap[key].splice(i, 1);
							if(!_originTexturesMap[key] || _originTexturesMap[key].length < 1)
								delete _originTexturesMap[key];
							
							delete _textureReferenceCount[originTexture];
							if(originTexture is Texture && "root" in originTexture && originTexture.root in _originTextureToBitmapDataMap)
								delete _originTextureToBitmapDataMap[originTexture.root];
							if("disposed" in originTexture && originTexture["dispose"] != null )
							{
								originTexture.disposed.remove(releaseTexture);
							}
							originTexture.dispose();
							return;
						}
					}
				}
				*/
			}catch(e : Error){
				Logger.error(ResourceTextureManagerG2D, "releaseTexture", "Error releasing texture: " + e.getStackTrace());
			}
			
		}

		/** Textures that are created from Bitmaps or ATF files will have the scale factor 
		 *  assigned here. */
		public static function get scaleFactor():Number { return ResourceManager.scaleFactor; }
	}
}