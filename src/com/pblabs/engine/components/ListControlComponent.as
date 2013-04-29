/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.components
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.components.ListDataComponent;
	import com.pblabs.engine.core.PBGroup;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.util.DynamicObjectUtil;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.rendering2D.IMobileSpatialObject2D;
	import com.pblabs.starling2D.DisplayObjectRendererG2D;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * This control will spawn entities into a scrollable list. Either
	 * horizontal or vertical scrolling.
	 * 
	 * @author lavonw
	 **/
	public class ListControlComponent extends AnimatedComponent 
	{
		public static const HORIZONTAL_LAYOUT : String = "Horizontal";
		public static const VERTICAL_LAYOUT : String = "Vertical";

		/**
		 * The data component on the entity that will be spawned. For each
		 * entry in the list an entity is spawned and the properties of the data object are saved to the Data Component.
		 * 
		 * If the data in the ListDataComponent is an object the public properties on that object will be copied
		 * over to the DataComponent on the new entity item in the list. If the data is a simple object like a string
		 * a the data will be assigned to a "data" property on the DataComponent.  
		 *
		 **/
		public var itemDataReference : PropertyReference;
		/**
		 * The main spatial component on the entity that will be spawned. This spatial will be used to position the entity.
		 **/
		public var itemSpatialReference : PropertyReference;
		
		public var layout : String = HORIZONTAL_LAYOUT;
		public var gap : int = 10;
		
		private var _listItems : Vector.<IEntity> = new Vector.<IEntity>();
		private var _listData : ListDataComponent;
		private var _itemEntityName : String;
		private var _listDataReference : PropertyReference;
		private var _horizontalScrollPosition : Number;
		private var _verticalScrollPosition : Number;
		
		public function ListControlComponent()
		{
			super();
		}
		
		override public function onFrame(deltaTime:Number):void
		{
			scrollList();
			super.onFrame(deltaTime);
		}
		
		override protected function onAdd():void
		{
			getListData();
			super.onAdd();
		}
		
		override protected function onReset():void
		{
			getListData();
			super.onReset();
		}

		override protected function onRemove():void
		{
			destroy();
			super.onRemove();
		}

		public function destroy():void
		{
			clearList();
			_listData.updated.remove(onDataSourceChanged);
		}
		
		public function getListData():void
		{
			if(!isRegistered || !this.owner)
				return;
			
			var listDataComp : ListDataComponent = this.owner.getProperty( listDataReference ) as ListDataComponent;
			if(!listDataComp)
				return;
			if(_listData){
				_listData.updated.remove(onDataSourceChanged);
				//TODO: Optimize the change in list data contents
				if(_listData != listDataComp || listDataComp.source.length != _listItems.length)
				{
					clearList();
				}
			}
			_listData = listDataComp;
			_listData.updated.add(onDataSourceChanged);
			buildList();
		}
		
		protected function clearList():void
		{
			if(_listItems)
			{
				var len : int = _listItems.length;
				for(var i : int = 0; i < len; i++)
				{
					var entity : IEntity = _listItems.shift();
					entity.destroy();
				}
			}
		}
		
		protected function buildList():void
		{
			if(!_listData)
				return;
			
			var listPos : Point = position;
			var len : int = _listData.source.length;
			for(var i : int = 0; i < len; i++)
			{
				var entity : IEntity;
				if(i >= _listItems.length){
					if(PBE.IS_SHIPPING_BUILD)
						entity = PBE.templateManager.instantiateEntityFromCallBack(itemEntityName, itemEntityName, false);
					else
						entity = PBE.templateManager.instantiateEntity(itemEntityName, true);
						
					if(!entity){
						Logger.error(this, 'execute', 'Error - The entity ['+itemEntityName+'] could not be spawned!');
						return;
					}
					entity.owningGroup = spawnedGroup;
					_listItems[i] = entity;
				}else{
					entity = _listItems[i];
				}
				entity.initialize(null, itemEntityName);
				
				var spatial : IMobileSpatialObject2D = entity.getProperty(itemSpatialReference) as IMobileSpatialObject2D;
				var currentPos : Point = spatial.position;
				if(layout == HORIZONTAL_LAYOUT){
					currentPos.setTo( listPos.x + ((spatial.size.x + gap) * i), listPos.y );
				}else if(layout == VERTICAL_LAYOUT){
					currentPos.setTo( listPos.x, listPos.y + ((spatial.size.y + gap) * i) );
				}
				spatial.position = currentPos;
				
				var dataComp : DataComponent = entity.getProperty(itemDataReference) as DataComponent;
				var data : * = _listData.source[i];
				if(data is String || data is Number || data is uint || data is int)
				{
					dataComp["data"] = data;
				}else if(data is Object){
					if(DynamicObjectUtil.isDynamic( data )){
						DynamicObjectUtil.copyDynamicObject( data, dataComp );
					}else{
						DynamicObjectUtil.copyData( data, dataComp );
					}
				}
				
			}
		}
		
		protected function onDataSourceChanged(dataComp : ListDataComponent):void
		{
			getListData();
		}
		
		/**
		 * Manages the scrolling behaviour of the entities in the list.
		 **/
		protected function scrollList():void
		{
			//TODO Add Scrolling functionality	
		}
		
		public function get scrollContentsBounds():Rectangle
		{
			var overalBounds : Rectangle = new Rectangle(position.x, position.y);
			var len : int = _listItems.length;
			for(var i : int = 0; i < len; i++)
			{
				var spatial : IMobileSpatialObject2D = _listItems[i].getProperty(itemSpatialReference) as IMobileSpatialObject2D;
				var objectBounds : Rectangle = spatial.worldExtents;
				if(layout == HORIZONTAL_LAYOUT){
					overalBounds.width += objectBounds.width;
				}else if(layout == VERTICAL_LAYOUT){
					overalBounds.height += objectBounds.height;
				}
			}
			return overalBounds;
		}
		
		private var _position : Point = new Point();
		public function get position():Point { return _listScroller ? _listScroller.position : _position; }
		public function set position(val : Point):void
		{
			_position = val;
		}

		private var _listScroller : DisplayObjectRenderer;
		public function get listScroller():DisplayObjectRenderer { return _listScroller; }
		public function set listScroller(val : DisplayObjectRenderer):void
		{
			_listScroller = val;
		}
		
		/**
		 * The list data that will be used to create the items in this list
		 **/
		public function get listDataReference():PropertyReference{ return _listDataReference; }
		public function set listDataReference(val : PropertyReference):void{
			_listDataReference = val;
			getListData();
		}

		/**
		 * The entity that will be used to spawn new list entries
		 **/
		public function get itemEntityName():String{ return _itemEntityName; }
		public function set itemEntityName(val : String):void{
			_itemEntityName = val;
			clearList();
			buildList();
		}
		
		public function get horizontalScrollPosition():Number{ return _horizontalScrollPosition; }
		public function set horizontalScrollPosition(val : Number):void{
			_horizontalScrollPosition = val;
			scrollList();
		}
		
		public function get verticalScrollPosition():Number{ return _verticalScrollPosition; }
		public function set verticalScrollPosition(val : Number):void{
			_verticalScrollPosition = val;
			scrollList();
		}

		private static var _spawnedGroup : PBGroup;
		public static function get spawnedGroup():PBGroup{ 
			if(!_spawnedGroup){
				_spawnedGroup = PBE.nameManager.lookup("SpawnedEntities") as PBGroup;
				if(!_spawnedGroup){
					_spawnedGroup = new PBGroup();
					_spawnedGroup.initialize("SpawnedEntities");
					_spawnedGroup.owningGroup = PBE.rootGroup;
				}
			}
			return _spawnedGroup; 
		}
		
	}
}