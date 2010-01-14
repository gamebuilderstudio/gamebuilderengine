package com.pblabs.engine.core
{
    public class PBObject
    {
        protected var _name:String;
        protected var _owningGroup:PBGroup;

        public function get owningGroup():PBGroup
        {
            return _owningGroup;
        }

        public function set owningGroup(value:PBGroup):void
        {
            if(!value)
                throw new Error("Must always be in a group - cannot set owningGroup to null!");
            
            if(_owningGroup)
                _owningGroup.removeFromGroup(this);
            
            _owningGroup = value;
            _owningGroup.addToGroup(this);
        }

        public function get name():String
        {
            return _name;
        }

        public function set name(value:String):void
        {
            _name = value;
        }

        public function destroy():void
        {
            // Remove from our owning group.
            if(_owningGroup)
            {
                _owningGroup.removeFromGroup(this);
                _owningGroup = null;                
            }
        }
    }
}