/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.components.basic
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.entity.EntityComponent;
    import com.pblabs.engine.resource.MP3Resource;
    
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    
    /**
     * Play sounds when events are triggered on an entity.
     */
    public class EventSoundTrigger extends EntityComponent
    {
        /**
         * Sounds indexed by event type to trigger them.
         */
        [TypeHint(type="com.pblabs.engine.resource.MP3Resource")]
        public var events:Array=new Array();
        
        /**
         * Play a sound when we are created?
         */
        public var startSound:MP3Resource=null;
        
        private var _didSchedule:Boolean=false
        private var _firedStartSound:Boolean=false
        
        override protected function onAdd():void
        {
            // Register events.
            var ed:IEventDispatcher=owner.eventDispatcher;
            for (var key:String in events)
                ed.addEventListener(key, soundEventHandler);
            
            if (!_firedStartSound && startSound)
            {
                startSound.soundObject.play();
                _firedStartSound=true;
            }
            
            if (!_didSchedule)
            {
                PBE.processManager.schedule(100, this, onReset);
                _didSchedule=true;
            }
        }
        
        override protected function onRemove():void
        {
            // Unregister events.
            var ed:IEventDispatcher=owner.eventDispatcher;
            for (var key:String in events)
                ed.removeEventListener(key, soundEventHandler);
        }
        
        override protected function onReset():void
        {
            // Since we get callbacks from schedule(), we have to sanity check.
            if (!owner)
                return;
            
            onRemove();
            onAdd();
        }
        
        private function soundEventHandler(event:Event):void
        {
            var sound:MP3Resource=events[event.type];
            sound.soundObject.play();
        }
        
    }
}