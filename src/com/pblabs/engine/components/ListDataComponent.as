/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.components
{
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.serialization.ISerializable;
   import com.pblabs.engine.serialization.Serializer;
   
   import org.osflash.signals.Signal;
   
   /**
    * A List Container for storing data into an array. As it is dynamic, you can set whatever
    * fields you want. Useful for storing sequential data.
	* 
	* All entries to the array will be stored on the class with the syntax itemX
	* with the X being the index of the entry in the array. This is being done so that objects can be referenced via expressions
	* with the syntax of Self.ListData.item0, Self.ListData.item1, etc...
	* 
	* This class will be used with the ListRenderer Component to render dynamic lists
    */
   public dynamic class ListDataComponent extends EntityComponent implements ISerializable
   {
	   [EditorData(ignore="true")]
	   public var updated : Signal = new Signal(ListDataComponent);
	   
	   private var _data : Array = new Array(); 
	   
	   public function serialize(xml:XML):void
	   {
		   var sourceXML : XML = new XML('<source type="Array" />');
		   Serializer.instance.serialize(_data, sourceXML);
		   xml.appendChild(sourceXML);
	   }
	   
	   public function deserialize(xml:XML):*
	   {
		   source = Serializer.instance.deserialize( [], xml.source[0]);
		   return this;
	   }
	   
	   public function replaceItemAt(item : Object, index : int):void
	   {
		   this["item"+index] = item;
		   _data[index] = item;
		   refresh();
	   }
	   
	   public function addItemAt(item : Object, index : int):void
	   {
		   var len : int = _data.length;
		   for(var i : int = index; i < len; i++)
		   {
			   this["item"+(i+1)] = this["item"+i];
			   _data[(i+1)] = _data[i];
		   }
		   this["item"+index] = _data[index] = item;
		   refresh();
	   }

	   public function removeItemAt(index : int):void
	   {
		   delete this["item"+index];
		   var len : int = _data.length;
		   for(var i : int = index+1; i < len; i++)
		   {
			   this["item"+(i-1)] = this["item"+i];
		   }
		   _data.splice(index, 1);
		   delete this["item"+_data.length];
		   refresh();
	   }

	   public function push(item : Object):void
	   {
		   this["item"+_data.length] = item;
		   _data.push(item);
		   refresh();
	   }
	   
	   public function clearAll(callRefresh : Boolean = true):void
	   {
		   var len : int = _data.length;
		   for(var i : int = 0; i < len; i++)
		   {
			   delete this["item"+i];
		   }
		   if(callRefresh)
		       refresh();
	   }
	   
	   /**
	   * Notify listeners on the entity that the List Data has changed
	   **/
	   public function refresh():void
	   {
		   updated.dispatch(this);
	   }
	   
	   public function get source():Array { return _data; }
	   public function set source(data : Array):void{
		   clearAll();
		   _data = data;
		   var len : int = _data.length;
		   for(var i : int = 0; i < len; i++)
		   {
			   this["item"+i] = _data[i];
		   }
	   }
	   
	   public function get count():int { return _data.length; }
	   public function set count(val : int):void{}

	   private var _tempEmptyObject : Object = {};
	   public function get lastEntry():Object { return _data && _data.length > 0 ? _data[_data.length-1] : _tempEmptyObject; }
	   public function set lastEntry(val : Object):void{}

	   override protected function onAdd():void
	   {
		   super.onAdd();
		   
		   if(!_data){
		     _data = new Array(); 
		   }
		   if(!updated){
			   updated = new Signal(ListDataComponent); 
		   }
	   }
	   
	   override protected function onRemove():void
	   {
		   clearAll();
		   _data = null;
		   
		   updated.removeAll();
		   updated = null;
		   super.onRemove();
	   }
   }
}