/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2016 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.rendering2D.TiledMapRenderer;
	import com.pblabs.starling2D.spritesheet.SpriteContainerComponentG2D;
	import com.pblabs.tilemap.TiledLayer;
	import com.pblabs.tilemap.TiledTileLayer;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;

	public final class TiledMapRendererG2D extends TiledMapRenderer
	{
		protected var _tileTextures : Vector.<Texture> = new Vector.<Texture>();
		protected var _tileMatrix : Matrix = new Matrix();
		
		public function TiledMapRendererG2D()
		{
			// After most things, but before the scene.
			updatePriority = -1;
			super();
		}
		
		override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
		{
			if (!gpuObject || !scene)
				return false;
			
			var localPos:Point = transformWorldToObject(worldPosition);
			return gpuObject.hitTest(localPos) ? true : false;
		}
		
		override protected function onAdd():void
		{
			buildG2DObject();
			super.onAdd();
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			_tileTextures.length = 0;
		}
		
		override protected function buildG2DObject(skipCreation : Boolean = false):void
		{
			if(!Starling.context && !skipCreation){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}
			if(!skipCreation){
				if(!gpuObject){
					//Create GPU Renderer Object
					gpuObject = new Sprite();
				}
				smoothing = _smoothing;
				skipCreation = true;
			}
			super.buildG2DObject(skipCreation);
			_imageDataDirty = false;
		}
		
		override protected function paintTileMap():void
		{
			if(!scene || (_tiledMapResource && !_tiledMapResource.isLoaded) || !gpuObject) return;
			
			if ( clampCameraToSelf && !PBE.IN_EDITOR)
			{
				var cameraBounds : Rectangle = worldExtents.clone();
				cameraBounds.x = this.position.x;
				cameraBounds.y = this.position.y;
				scene.trackLimitRectangle = cameraBounds;
			}
			
			// If we don't have any tiles yet...
			if(_tileTextures.length == 0)
			{
				// ... check that the tilesheets are loaded.
				for each(var sheet:SpriteContainerComponentG2D in tileSheets)
				{
					if(sheet && !sheet.isLoaded)
					{
						// Make sure we will try to render again later.
						//invalidateRenderCache();
						return;
					}
				}
				
				// Great, set up the tile data then.
				for each(sheet in tileSheets)
				{
					if(!sheet) continue;
					for(var i:int=0; i<sheet.frameCount; i++){
						_tileTextures.push( sheet.getTexture(i) );
					}
				}
			}
			if((gpuObject as Sprite).numChildren > 0){
				(gpuObject as Sprite).removeChildren(0, -1, true);
			}
			
			var tiledLayers : Vector.<TiledLayer> = _tiledLayers.getTileLayers();
			for(var li : int = 0; li < tiledLayers.length; li++)
			{
				var tiledLayer : TiledTileLayer = tiledLayers[li] as TiledTileLayer;
					
				// Now, draw all our tiles.
				for(var curRow:int = 0; curRow < tiledLayer.data.length; curRow++)
				{
					for(var curX:int = 0; curX < tiledLayer.data[curRow].length; curX++)
					{
						var tileIndex:int = tiledLayer.data[curRow][curX];
						
						// Get position of the tile.
						_scratchCopyPoint.x = curX * _tileWidth;
						_scratchCopyPoint.y = curRow * _tileHeight;

						if (tileIndex > 0 && tileIndex <= _tileTextures.length)
						{
							var tileImageData : Image = new Image(_tileTextures[tileIndex-1]);
							tileImageData.alpha = tiledLayer.opacity;
							tileImageData.x = _scratchCopyPoint.x;
							tileImageData.y = _scratchCopyPoint.y;
							if(!_smoothing)
								tileImageData.smoothing = TextureSmoothing.NONE;
							else
								tileImageData.smoothing = TextureSmoothing.TRILINEAR;
							
							if(_tiledMap)
							{
								for(var ti : int = 0; ti < _tiledMap.tilesets.length; ti++)
								{
									if(tileIndex <= _tiledMap.tilesets[ti].firstGid)
									{
										tileImageData.pivotX = _tiledMap.tilesets[ti].tileOffset.x;
										tileImageData.pivotY = _tiledMap.tilesets[ti].tileOffset.y;
										break;
									}
								}
							}
							(gpuObject as Sprite).addChild(tileImageData);
						} 
					}
				}
			}
			_mapDirty = false;
			_transformDirty = true;
			updateTransform();
		}

		protected function modifyTexture(data:Texture):Texture
		{
			return data;            
		}
		
		override public function set tileSheets(data : Array):void
		{
			super.tileSheets = data;
			for(var i : int = 0; i < _tileTextures.length; i++)
			{
				_tileTextures[i].dispose();
			}
			_tileTextures.length = 0;
		}

		override public function set mouseEnabled(value:Boolean):void
		{
			_mouseEnabled = value;
			
			if(!gpuObject) return;
			gpuObject.touchable = _mouseEnabled;
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			//Not Supported
		}
		
		/**
		 * @see Bitmap.smoothing 
		 */
		[EditorData(ignore="true")]
		override public function set smoothing(value:Boolean):void
		{
			super.smoothing = value;
			_mapDirty = true;
		}
		
	}
}