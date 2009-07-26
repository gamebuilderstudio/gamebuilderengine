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
		public var Events:Array = new Array();
		
      /**
       * Play a sound when we are created?
       */
      public var StartSound:MP3Resource = null;
      
      private var DidSchedule:Boolean = false, FiredStartSound:Boolean = false
      
		protected override function onAdd():void
		{
			// Register events.
			var ed:IEventDispatcher = owner.eventDispatcher;
			for(var key:String in Events)
				ed.addEventListener(key, soundEventHandler);
         
         if(!FiredStartSound && StartSound)
         {
            StartSound.SoundObject.play();
            FiredStartSound = true;
         }
         
         if(!DidSchedule)
         {
            setTimeout(onReset, 100);
            DidSchedule = true;
         }
		}
		
		protected override function onRemove():void
		{
			// Unregister events.
			var ed:IEventDispatcher = owner.eventDispatcher;
			for(var key:String in Events)
				ed.removeEventListener(key, soundEventHandler);
		}
      
      protected override function onReset():void
      {
         // Since we get callbacks from setTimeout, we have to sanity check.
         if(!owner)
            return;
         
         onRemove();
         onAdd();
      }

		private function soundEventHandler(e:Event):void
		{
         var sound:MP3Resource = Events[e.type];
         sound.SoundObject.play();
		}

	}
}