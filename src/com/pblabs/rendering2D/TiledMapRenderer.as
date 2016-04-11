/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2016 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.resource.ResourceEvent;
	import com.pblabs.engine.resource.XMLResource;
	import com.pblabs.nape.CircleCollisionShape;
	import com.pblabs.nape.CollisionShape;
	import com.pblabs.nape.PolygonCollisionShape;
	import com.pblabs.physics.IPhysics2DSpatial;
	import com.pblabs.rendering2D.BitmapRenderer;
	import com.pblabs.rendering2D.spritesheet.SpriteContainerComponent;
	import com.pblabs.tilemap.TiledLayer;
	import com.pblabs.tilemap.TiledLayers;
	import com.pblabs.tilemap.TiledMap;
	import com.pblabs.tilemap.TiledObject;
	import com.pblabs.tilemap.TiledObjectLayer;
	import com.pblabs.tilemap.TiledTileLayer;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Handles rendering a TileMap object to the screen.  
	 * Requires a reference to the same tile sheet that was used when creating the tile map.
	 */
	public class TiledMapRenderer extends BitmapRenderer
	{
		public var clampCameraToSelf:Boolean = false;
		
		/**
		 * Add tile sheets to this array in the order that they were used in the tile map.
		 */ 
		protected var _tileSheets:Array = new Array();
		protected var _tiledMapResource : XMLResource;
		protected var _tiledMap : TiledMap;
		protected var _tileBitmapDatas : Vector.<BitmapData> = new Vector.<BitmapData>();
		protected var _scratchCopyPoint : Point = new Point();
		protected var _mapDirty : Boolean = true;
		protected var _worldExtents : Rectangle;
		protected var _tiledLayers : TiledLayers;
		protected var _tiledMapSize:Point = new Point(10,10);
		protected var _tileWidth:int = 32;
		protected var _tileHeight:int = 32;
		
		// We render tiles here before displaying them.
		private var _frameCache:BitmapData;
		private var _alphaBitmap:BitmapData;
		private var _tileRect : Rectangle = new Rectangle();
		private var _collisionShapes : Array = [];
		
		public function TiledMapRenderer()
		{
			// After most things, but before the scene.
			updatePriority = -1;
			super();
		}
		
		public function get layerCount():int { return _tiledLayers ? _tiledLayers.length : 0; }

		public function get tileWidth():int { return _tileWidth; }
		public function set tileWidth(val : int):void
		{
			_tileWidth = val;
			_mapDirty = true;
		}
		
		public function get tileHeight():int { return _tileHeight; }
		public function set tileHeight(val : int):void
		{
			_tileHeight = val;
			_mapDirty = true;
		}

		public function get tiledMapSize():Point { return _tiledMapSize; }
		public function set tiledMapSize(val : Point):void
		{
			_tiledMapSize = val;
			if(!_tiledMapResource)
				setupDefaultTileLayer();
			_mapDirty = true;
		}

		[TypeHint(type="com.pblabs.rendering2D.spritesheet.SpriteSheetComponent")]
		public function get tileSheets():Array { return _tileSheets; }
		public function set tileSheets(data : Array):void
		{
			_tileSheets = data;
			_tileBitmapDatas.length = 0;
			_mapDirty = true;
		}

		public function get tiledMap():TiledMap{ return _tiledMap; }
		public function get tiledMapResource():XMLResource { return _tiledMapResource; }
		public function set tiledMapResource(data : XMLResource):void
		{
			if(_tiledMapResource){
				_tiledMapResource.removeEventListener(ResourceEvent.LOADED_EVENT, parseTileMapData);
				_tiledMapResource.removeEventListener(ResourceEvent.UPDATED_EVENT, onTiledMapDataUpdated);
			}

			_tiledMapResource = data;
			if(isRegistered && owner && _tiledMapResource && _tiledMapResource.isLoaded)
				parseTileMapData();
			else if(_tiledMapResource)
				_tiledMapResource.addEventListener(ResourceEvent.LOADED_EVENT, parseTileMapData);
			
			if(_tiledMapResource) _tiledMapResource.addEventListener(ResourceEvent.UPDATED_EVENT, onTiledMapDataUpdated);

			if(!_tiledMapResource){
				_tiledMap = null;
				setupDefaultTileLayer();
			}
			_mapDirty = true;
		}
		
		public function get worldExtents():Rectangle
		{
			if(!_worldExtents){
				_worldExtents = new Rectangle(0, 0, _tiledMapSize.x * _tileWidth, _tiledMapSize.y * _tileHeight);
			}else{
				_worldExtents.x = _worldExtents.y = 0;
				_worldExtents.width = _tiledMapSize.x * _tileWidth;
				_worldExtents.height = _tiledMapSize.y * _tileHeight;
			}
			return _worldExtents;
		}
		
		public function setTile(x : int, y : int, layerIndex : int = 0, tileIndex : int = 0):void{
			if(!_tiledLayers || x > _tiledMapSize.x || y > _tiledMapSize.y || layerIndex >= _tiledLayers.length) return;

			(_tiledLayers[layerIndex] as TiledTileLayer).data[y][x] = tileIndex;
			_mapDirty = true;
		}

		override public function onFrame(elapsed:Number) : void
		{
			if(_mapDirty)
				paintTileMap();
			super.onFrame(elapsed);
		}
		
		override protected function onAdd():void
		{
			if(!_tiledLayers)
			{
				setupDefaultTileLayer();
			}
			super.onAdd();
			
			if(!_tiledMap && isRegistered && owner && _tiledMapResource && _tiledMapResource.isLoaded)
				parseTileMapData();
			
			if(_mapDirty)
				paintTileMap();
			
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			
			_tileBitmapDatas.length = 0;
			if(_alphaBitmap) _alphaBitmap.dispose();
			_tiledLayers = null;
			
			if(!PBE.IN_EDITOR)
				cleanUpCollisionShapes();
		}
		
		protected function setupDefaultTileLayer():void
		{
			_tiledLayers = new TiledLayers();
			var defaultLayer : TiledTileLayer = new TiledTileLayer(null);
			defaultLayer.data = [];
			for(var row : int = 0; row < _tiledMapSize.y; row++)
			{
				for(var col : int = 0; col < _tiledMapSize.x; col++)
				{
					if(!defaultLayer.data[row])
					{
						defaultLayer.data[row] = [];
					}
					defaultLayer.data[row][col] = 0;
				}
			}
			_tiledLayers.addLayer( defaultLayer );
			if(sizeProperty != null){
				var mapSize : Point = new Point(worldExtents.width, worldExtents.height);
				this.owner.setProperty(sizeProperty, mapSize.clone());
			}
		}
		
		protected function onTiledMapDataUpdated(event : Event):void
		{
			parseTileMapData();
			paintTileMap();
		}
		
		protected function parseTileMapData(event : Event = null):void
		{
			_worldExtents = null;
			
			_tiledMap = new TiledMap(_tiledMapResource.XMLData);
			_tiledLayers = _tiledMap.layers;
			_tileWidth = _tiledMap.tileWidth;
			_tileHeight = _tiledMap.tileHeight;
			_tiledMapSize.x = _tiledMap.width;
			_tiledMapSize.y = _tiledMap.height;
			if(sizeProperty != null){
				var mapSize : Point = new Point(worldExtents.width, worldExtents.height);
				this.owner.setProperty(sizeProperty, mapSize.clone());
			}
			
			if(!PBE.IN_EDITOR && positionProperty)
			{
				cleanUpCollisionShapes();
				
				var collisionSpatial : IPhysics2DSpatial;
				var spatialParts : Array = positionProperty.property.split(".");
				spatialParts.pop();
				var spatialName : String = spatialParts.join(".");
				collisionSpatial = this.owner.getProperty( new PropertyReference(spatialName) ) as IPhysics2DSpatial;
				if(collisionSpatial && collisionSpatial is IPhysics2DSpatial)
				{
					var tiledLayers : Vector.<TiledLayer> = _tiledLayers.getObjectLayers();
					for(var li : int = 0; li < tiledLayers.length; li++)
					{
						if(tiledLayers[li] is TiledObjectLayer)
						{
							var tiledObjectsLayer : TiledObjectLayer = tiledLayers[li] as TiledObjectLayer;
							for(var oi : int = 0; oi < tiledObjectsLayer.objects.length; oi++)
							{
								var tiledObject : TiledObject = tiledObjectsLayer.objects[oi] as TiledObject;
								
								if(tiledObject.type == "shape")
								{ 
									var collisionShape : CollisionShape;
									var vertices : Array;
									switch(tiledObject.shape){
										case TiledObject.POLYGON:
											collisionShape = new PolygonCollisionShape();
											vertices = [];
											tiledObject.points.filter(function(pt:Point, i:int, list:Vector.<Point>):Boolean { 
												vertices[i] = new Point(tiledObject.x + pt.x, tiledObject.y + pt.y) ; return true; 
											});
											(collisionShape as PolygonCollisionShape).vertices = vertices;
											break;
										case TiledObject.RECTANGLE:
											collisionShape = new PolygonCollisionShape();
											vertices = [];
											vertices.push(new Point(tiledObject.x, tiledObject.y));
											vertices.push(new Point(tiledObject.x + tiledObject.width, tiledObject.y));
											vertices.push(new Point(tiledObject.x + tiledObject.width, tiledObject.y + tiledObject.height));
											vertices.push(new Point(tiledObject.x, tiledObject.y + tiledObject.height));
											(collisionShape as PolygonCollisionShape).vertices = vertices;
											break;
										case TiledObject.ELLIPSE:
											collisionShape = new CircleCollisionShape();
											(collisionShape as CircleCollisionShape).radius = ((tiledObject.width + tiledObject.height) / 2)/2;
											(collisionShape as CircleCollisionShape).position = new Point( tiledObject.x + (collisionShape as CircleCollisionShape).radius, tiledObject.y + (collisionShape as CircleCollisionShape).radius);
											break;
									}
									for(var key : * in tiledObject.properties.properties)
									{
										if(key in (collisionShape as PolygonCollisionShape))
											(collisionShape as PolygonCollisionShape)[key] = tiledObject.properties.properties[key];
									}
									if(collisionShape)
									{
										if("name" in tiledObject.properties.properties)
											collisionShape.name = tiledObject.properties.properties.name;
										_collisionShapes.push( collisionShape );
									}
								}
							}
						}
					}
					if(_collisionShapes.length > 0)
					{
						collisionSpatial.collisionShapes = collisionSpatial.collisionShapes.concat(_collisionShapes);
					}
				}
			}
			
			_mapDirty = true;
		}
		
		protected function cleanUpCollisionShapes():void
		{
			var collisionSpatial : IPhysics2DSpatial;
			var len : int = _collisionShapes.length;
			if(_collisionShapes && len > 0)
			{
				for(var ci : int = 0; ci < len; ci++)
				{
					collisionSpatial = _collisionShapes[ci].containerSpatial;
					var shapeIndex : int = collisionSpatial.collisionShapes.indexOf(_collisionShapes[ci]);
					if(shapeIndex > -1)
					{
						collisionSpatial.collisionShapes.splice(shapeIndex, 1);
					}
				}
				collisionSpatial.collisionShapes = collisionSpatial.collisionShapes;
			}
			if(_collisionShapes) _collisionShapes.length = 0;
		}
		
		protected function paintTileMap():void
		{
			if(!scene || (_tiledMapResource && !_tiledMapResource.isLoaded)) return;
				
			if ( clampCameraToSelf && !PBE.IN_EDITOR)
			{
				var cameraBounds : Rectangle = worldExtents.clone();
				cameraBounds.x = this.position.x;
				cameraBounds.y = this.position.y;
				scene.trackLimitRectangle = cameraBounds;
			}
			
			// If we don't have any tiles yet...
			if(_tileBitmapDatas.length == 0)
			{
				// ... check that the tilesheets are loaded.
				for each(var sheet:SpriteContainerComponent in tileSheets)
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
					for(var i:int=0; i<sheet.frameCount; i++)
						_tileBitmapDatas.push(sheet.getFrame(i));
				}
			}
			
			if (!_frameCache || 
				_frameCache.width  != worldExtents.width ||
				_frameCache.height != worldExtents.height)
			{
				if(_frameCache)
					_frameCache.dispose();
				_frameCache = new BitmapData(worldExtents.width, worldExtents.height, true, 0x0);
			}
			
			
			_tileRect.x = _tileRect.y = 0;
			_tileRect.width = _tileWidth;
			_tileRect.height = _tileHeight;
			
			// Clear the bitmap!
			_frameCache.lock();
			_frameCache.fillRect(_frameCache.rect, 0x0);
			
			var tiledLayers : Vector.<TiledLayer> = _tiledLayers.getTileLayers();
			for(var li : int = 0; li < tiledLayers.length; li++)
			{
				if(tiledLayers[li] is TiledTileLayer)
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
							
							if (tileIndex > 0 && tileIndex <= _tileBitmapDatas.length)
							{
								var tileBitmapData : BitmapData = _tileBitmapDatas[tileIndex-1];
								
								if(_tiledMap)
								{
									for(var ti : int = 0; ti < _tiledMap.tilesets.length; ti++)
									{
										if(tileIndex <= _tiledMap.tilesets[ti].firstGid)
										{
											_tileRect.x = _tiledMap.tilesets[ti].tileOffset.x;
											_tileRect.y = _tiledMap.tilesets[ti].tileOffset.y;
											break;
										}
									}
								}
								if(tiledLayer.opacity < 1)
								{
									if(!_alphaBitmap)
										_alphaBitmap = new BitmapData(_tileRect.width, _tileRect.height, true, toARGB(0x0, (tiledLayer.opacity*255)));
									_frameCache.copyPixels(tileBitmapData, _tileRect, _scratchCopyPoint, _alphaBitmap, null, true);
								}else{
									_frameCache.copyPixels(tileBitmapData, _tileRect, _scratchCopyPoint, null, null, true);
								}
							} 
						}
					}
				}
			}
			
			_frameCache.unlock();
			_mapDirty = false;
			bitmapData = _frameCache;
		}
		
		protected static function toARGB(rgb:uint, newAlpha:uint):uint{
			var argb:uint = 0;
			argb = (rgb);
			argb += (newAlpha<<24);
			return argb;
		}		
	}
}