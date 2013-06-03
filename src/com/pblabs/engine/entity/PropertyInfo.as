/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.entity
{
	import com.pblabs.engine.debug.Logger;

    /**
     * Internal class used by Entity to service property lookups.
     */
    final internal class PropertyInfo
    {
        public var propertyParent:Object = null;
        public var propertyName:String = null;
        
        final public function getValue():*
        {
            if(propertyParent && propertyName && propertyParent.hasOwnProperty(propertyName))
                return propertyParent[propertyName];
            else if(propertyParent)
                return propertyParent;
			return null;
        }
        
        final public function setValue(value:*):void
        {
			if(!propertyParent.hasOwnProperty(propertyName)) {
				Logger.warn(this, 'setValue', 'Setting property on parent object failed. Property ['+propertyName+'] not found on ['+propertyParent+']!');
				return;
			}
            propertyParent[propertyName] = value;
        }
        
        final public function clear():void
        {
            propertyParent = null;
            propertyName = null;
			if(_infoObjectsPool.indexOf(this) == -1)
				_infoObjectsPool.push(this);
        }
		
		public static function getInstance():PropertyInfo
		{
			if(_infoObjectsPool.length < 1){
				var info : PropertyInfo = new PropertyInfo();
				return info;
			}
			return _infoObjectsPool.shift();
		}
		private static var _infoObjectsPool : Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
    }
}