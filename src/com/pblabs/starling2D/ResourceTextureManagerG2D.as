package com.pblabs.starling2D
{
	import com.pblabs.engine.PBUtil;
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
		private static var _subTextureToOriginTextureMap : Dictionary = new Dictionary();
		private static var _textureReferenceCount : Dictionary = new Dictionary();
		
		public function ResourceTextureManagerG2D()
		{
		}
		
		public static function releaseTextures():void
		{
			//Release original parent texture if it is no longer referenced anywhere in the engine
			for(var subTexture : * in _subTextureToOriginTextureMap)
			{
				if("disposed" in subTexture && subTexture.disposed && subTexture.disposed is Signal)
				{
					subTexture.disposed.remove(releaseTexture);
				}
				if(subTexture is Texture)
					(subTexture as Texture).dispose();
				delete _subTextureToOriginTextureMap[subTexture];
			}

			for(var key : * in _originTexturesMap)
			{
				var deletedOriginTexture : Boolean = false;
				var len : int = _originTexturesMap[key].length;
				for(var i : int = 0; i < len; i++)
				{
					var originTexture : Object = _originTexturesMap[key][i]
					if(_originTexturesMap[key][i] == originTexture){
						
						PBUtil.splice(_originTexturesMap[key], i, 1);
						
						if(!_originTexturesMap[key] || _originTexturesMap[key].length < 1){
							delete _originTexturesMap[key];
							deletedOriginTexture = true;
						}
						if(originTexture in _textureReferenceCount){
							delete _textureReferenceCount[originTexture];
						}
							
						if(originTexture is Texture && "root" in originTexture && originTexture.root in _originTextureToBitmapDataMap)
							delete _originTextureToBitmapDataMap[originTexture.root];
						if("disposed" in originTexture && originTexture.disposed && originTexture.disposed is Signal)
						{
							originTexture.disposed.remove(releaseTexture);
						}
						originTexture.dispose();
					}
				}
				if(deletedOriginTexture && key in _originAtlasMap)
					delete _originAtlasMap[key];
			}
			_originTexturesMap = new Dictionary();
			_subTextureToOriginTextureMap = new Dictionary();
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
				_subTextureToOriginTextureMap[subtexture] = texture;
				return subtexture;
			}else{
				texture = Texture.fromBitmapData( sourceBitmapData, false, false, scaleFactor, "bgra", repeat);
				texture.disposed.addOnce(releaseTexture);
				texture.root.onRestore = onTextureRestored;
				_originTextureToBitmapDataMap[texture.root] = sourceBitmapData;
				_originTexturesMap[key] = new Vector.<Texture>();
				_originTexturesMap[key][_originTexturesMap[key].length] = texture;
				_textureReferenceCount[texture] = 1;
				subtexture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTextureToOriginTextureMap[subtexture] = texture;
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
				_subTextureToOriginTextureMap[subtexture] = texture;
				return subtexture;
			}else{
				//TODO: Add support for ATFImageResources in the future
				if(resource.embeddedClass){
					texture = Texture.fromEmbeddedAsset(resource.embeddedClass, false, false, scaleFactor, "bgra", repeat);
					texture.disposed.addOnce(releaseTexture);
					resource.dispose();
				}else if(resource.isAtfImage && resource.atfData){
					texture = Texture.fromAtfData(resource.atfData, scaleFactor, false, false, repeat, onTextureRestored);
					texture.disposed.addOnce(releaseTexture);
					_originTextureToBitmapDataMap[texture.root] = resource.atfData;
				}else{
					texture = Texture.fromBitmapData(resource.bitmapData, false, false, scaleFactor, "bgra", repeat, onTextureRestored);
					texture.disposed.addOnce(releaseTexture);
					_originTextureToBitmapDataMap[texture.root] = resource.bitmapData;
				}
				_originTexturesMap[resource] = new Vector.<Texture>();
				_originTexturesMap[resource][_originTexturesMap[resource].length] = texture;
				_textureReferenceCount[texture] = 1;
				subtexture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTextureToOriginTextureMap[subtexture] = texture;
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
					_subTextureToOriginTextureMap[subtexture] = texture;
					newTextureList[newTextureList.length] = subtexture;
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
				_originAtlasMap[resource][_originAtlasMap[resource].length] = atlas;
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
			//subtexture.disposed.addOnce(releaseTexture);
			//_subTextureToOriginTextureMap[subtexture] = atlas.texture.root;
			//_textureReferenceCount[atlas.texture.root]++;
			return subtexture;
		}
		
		public static function isATextureCachedWithKey(key : *):Boolean
		{
			return key in _originTexturesMap;
		}
		
		public static function getTextureByKey(key : String):Texture
		{
			if(!key)
				return null;
			
			if(key in _originTexturesMap)
			{
				var texture : Texture = _originTexturesMap[key][0] as Texture;
				_textureReferenceCount[texture]++;
				var subtexture : Texture = Texture.fromTexture(texture);
				subtexture.disposed.addOnce(releaseTexture);
				_subTextureToOriginTextureMap[subtexture] = texture;
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
		
		public static function releaseTexture(subTexture : Texture):void
		{
			try{
				var originTexture : Object;
				if(subTexture in _subTextureToOriginTextureMap)
				{
					if("disposed" in subTexture && subTexture.disposed && subTexture.disposed is Signal)
					{
						subTexture.disposed.remove(releaseTexture);
					}
					subTexture.dispose();
					originTexture = _subTextureToOriginTextureMap[subTexture];
					delete _subTextureToOriginTextureMap[subTexture];

					//Reduce Count on Origin Texture
					if(originTexture in _textureReferenceCount){
						_textureReferenceCount[originTexture] =  _textureReferenceCount[originTexture] - 1;
					}
					
				}else if(!(subTexture in _originTexturesMap)){
					return;
				}else{
					originTexture = subTexture;
				}
				
				//Release original parent texture if it is no longer referenced anywhere in the engine
				///*
				for(var key : * in _originTexturesMap)
				{
					var deletedOriginTexture : Boolean = false;
					var len : int = _originTexturesMap[key].length;
					for(var i : int = 0; i < len; i++)
					{
						if(_originTexturesMap[key][i] == originTexture && originTexture in _textureReferenceCount && _textureReferenceCount[originTexture] < 1){
							
							PBUtil.splice(_originTexturesMap[key], i, 1);
							if(!_originTexturesMap[key] || _originTexturesMap[key].length < 1){
								delete _originTexturesMap[key];
								deletedOriginTexture = true;
							}

							if(originTexture in _textureReferenceCount)
								delete _textureReferenceCount[originTexture];
							
							if(originTexture is Texture && "root" in originTexture && originTexture.root in _originTextureToBitmapDataMap)
								delete _originTextureToBitmapDataMap[originTexture.root];
							if("disposed" in originTexture && originTexture.disposed && originTexture.disposed is Signal)
							{
								originTexture.disposed.remove(releaseTexture);
							}
							originTexture.dispose();
							if(deletedOriginTexture && key in _originAtlasMap)
								delete _originAtlasMap[key];
							return;
						}
					}
				}
				//*/
			}catch(e : Error){
				Logger.error(ResourceTextureManagerG2D, "releaseTexture", "Error releasing texture: " + e.getStackTrace());
			}
			
		}

		/** Textures that are created from Bitmaps or ATF files will have the scale factor 
		 *  assigned here. */
		public static function get scaleFactor():Number { return ResourceManager.scaleFactor; }

		/**
		 * The actual scaleFactor not just the currently supported scaleFactor which could be different if all assets do not support the actual scaleFactor.
		 */
		public static function get actualScaleFactor():Number { return ResourceManager.actualScaleFactor; }
	}
}