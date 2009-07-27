package com.pblabs.components.basic
{
   import com.pblabs.engine.resource.*;
	import com.pblabs.engine.entity.*;
	import flash.events.*;
   import flash.utils.*;

   /**
    * Play sounds when events are triggered on an entity.
    */
	public class EventSoundTrigger extends EntityComponent
	{
      /**
       * Sounds indexed by event type to trigger them.
       */
      [TypeHint(type="com.pblabs.engine.resource.MP3Resource")]
		public var events:Array = new Array();
		
      /**
       * Play a sound when we are created?
       */
      public var startSound:MP3Resource = null;
      
      private var DidSchedule:Boolean = false, FiredStartSound:Boolean = false
      
		override protected function onAdd():void
		{
			// Register events.
			var ed:IEventDispatcher = owner.eventDispatcher;
			for(var key:String in events)
				ed.addEventListener(key, soundEventHandler);
         
         if(!FiredStartSound && startSound)
         {
            startSound.soundObject.play();
            FiredStartSound = true;
         }
         
         if(!DidSchedule)
         {
            setTimeout(onReset, 100);
            DidSchedule = true;
         }
		}
		
		override protected function onRemove():void
		{
			// Unregister events.
			var ed:IEventDispatcher = owner.eventDispatcher;
			for(var key:String in events)
				ed.removeEventListener(key, soundEventHandler);
		}
      
      override protected function onReset():void
      {
         // Since we get callbacks from setTimeout, we have to sanity check.
         if(!owner)
            return;
         
         onRemove();
         onAdd();
      }

		private function soundEventHandler(event:Event):void
		{
         var sound:MP3Resource = events[event.type];
         sound.soundObject.play();
		}

	}
}