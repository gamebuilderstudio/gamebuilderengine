package com.pblabs.engine.entity
{
    /**
     * Internal class used by Entity to service property lookups.
     */
    final internal class PropertyInfo
    {
        public var propertyParent:Object = null;
        public var propertyName:String = null;
        
        final public function getValue():*
        {
            try
            {         
                if(propertyName)
                    return propertyParent[propertyName];
                else
                    return propertyParent;
            }
            catch(e:Error)
            {
                return null;
            }
        }
        
        final public function setValue(value:*):void
        {
            propertyParent[propertyName] = value;
        }
        
        final public function clear():void
        {
            propertyParent = null;
            propertyName = null;
        }
    }
}