package com.pblabs.triggers.actions
{
	import avmplus.getQualifiedClassName;
	
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.components.DataComponent;
	import com.pblabs.engine.components.ListDataComponent;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.triggers.actions.BaseAction;
	import com.pblabs.triggers.actions.IAction;
	
	import flash.events.Event;
	
	public class ListAction extends BaseAction
	{
		public static var ACTIONTYPE_CLEAR : String = "clearList";
		public static var ACTIONTYPE_INSERT : String = "inserIntoList";
		public static var ACTIONTYPE_REMOVE : String = "removeFromList";
		public static var ACTIONTYPE_REPLACE : String = "replaceListItem";
		
		/**
		 * The type of sub action to execute. This action performs a number of
		 * sub operations.
		 **/
		public var actionType : String = ACTIONTYPE_INSERT;
		
		/**
		 * The data to insert into the list
		 **/
		public var dataReference : ExpressionReference;

		/**
		 * The property reference of the List Data object to store the task data on
		 **/
		public var listDataReference : PropertyReference;
		
		public var itemIndex : int = 0;
		
		private var _data : *;
		private var _listData : ListDataComponent;
		
		public function ListAction()
		{
		}
		
		override public function execute():*
		{
			_listData = this.owner.owner.getProperty( listDataReference ) as ListDataComponent;
			if(!_listData || !(_listData is ListDataComponent)){
				Logger.error(this, "execute", "The list data component you specified either can not be found or is not a ListDataComponent. Exiting action...");
				return;
			}
			
			if(actionType == ACTIONTYPE_INSERT)
			{
				_data = getExpressionValue(dataReference);
				_listData.addItemAt(_data, itemIndex);
			}else if(actionType == ACTIONTYPE_REPLACE){
				_data = getExpressionValue(dataReference);
				_listData.replaceItemAt(_data, itemIndex);
			}else if(actionType == ACTIONTYPE_REMOVE){
				_listData.removeItemAt(itemIndex);
			}else if(actionType == ACTIONTYPE_CLEAR){
				_listData.clearAll();
			}
		}
		
		override public function destroy():void
		{
			if(dataReference)
				dataReference.destroy();
			dataReference = null;
			
			super.destroy();
		}
	}
}