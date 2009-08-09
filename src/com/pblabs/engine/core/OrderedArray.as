/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
    import flash.utils.Dictionary;
    
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;
    
    [EditorData(editAs="flash.utils.Dictionary")]
    
    /**
     * An ordered associative array with a working length property. No other members
     * of Array are implemented despite its suggestive name.
     * 
     * Got this from http://www.senocular.com/flash/actionscript.php?file=ActionScript_3.0/AssociativeArray.as
     * All rights remain with the original author of this file.
     */
    dynamic public class OrderedArray extends Proxy 
    {
        
        private var memberValueHash:Object = {};
        private var memberIndexHash:Object = {};
        private var memberNameArray:Array = [];
        
        public function get length():uint 
        {
            return memberNameArray.length;
        }
        
        override flash_proxy function setProperty(name:*, value:*):void 
        {
            if (name in memberValueHash == false) 
            {
                var last:uint = memberNameArray.length;
                memberIndexHash[name] = last;
                memberNameArray[last] = name;
            }
            memberValueHash[name] = value;
        }
        
        override flash_proxy function getProperty(name:*):* 
        {
            return memberValueHash[name];
        }
        
        override flash_proxy function callProperty(name:*, ...rest):* 
        {
            if (memberValueHash[name] is Function)
            {
                return memberValueHash[name].apply(null, rest);
            }
            return null;
        }
        
        override flash_proxy function hasProperty(name:*):Boolean 
        {
            return name in memberValueHash;
        }
        
        override flash_proxy function deleteProperty(name:*):Boolean 
        {
            if (name in memberValueHash)
            {
                var index:int = memberIndexHash[name];
                memberNameArray.splice(index, 1);
                var last:uint = memberNameArray.length;
                
                while(index < last)
                {
                    memberIndexHash[memberNameArray[index]]--;
                    index++;
                }
                
                delete memberValueHash[name];
                delete memberIndexHash[name];
                
                return true;
            }
            return false;
        }
        
        override flash_proxy function nextNameIndex(index:int):int 
        {
            return (index < memberNameArray.length) ? index + 1 : 0;
        }
        
        override flash_proxy function nextName(index:int):String 
        {
            return memberNameArray[index - 1];
        }
        
        override flash_proxy function nextValue(index:int):* 
        {
            return memberValueHash[memberNameArray[index - 1]];
        }
        
        override flash_proxy function getDescendants(name:*):* 
        {
            return null;
        }
        
        override flash_proxy function isAttribute(name:*):Boolean 
        {
            return false;
        }
    }
}