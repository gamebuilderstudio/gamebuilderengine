package PBLabs.Components.Basic
{
   import PBLabs.Engine.Resource.*;
	import PBLabs.Engine.Entity.*;
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
      [TypeHint(type="PBLabs.Engine.Resource.MP3Resource")]
		public var Events:Array = new Array();
		
      /**
       * Play a sound when we are created?
       */
      public var StartSound:MP3Resource = null;
      
      private var DidSchedule:Boolean = false, FiredStartSound:Boolean = false
      
		protected override function _OnAdd():void
		{
			// Register events.
			var ed:IEventDispatcher = Owner.EventDispatcher;
			for(var key:String in Events)
				ed.addEventListener(key, soundEventHandler);
         
         if(!FiredStartSound && StartSound)
         {
            StartSound.SoundObject.play();
            FiredStartSound = true;
         }
         
         if(!DidSchedule)
         {
            setTimeout(_OnReset, 100);
            DidSchedule = true;
         }
		}
		
		protected override function _OnRemove():void
		{
			// Unregister events.
			var ed:IEventDispatcher = Owner.EventDispatcher;
			for(var key:String in Events)
				ed.removeEventListener(key, soundEventHandler);
		}
      
      protected override function _OnReset():void
      {
         // Since we get callbacks from setTimeout, we have to sanity check.
         if(!Owner)
            return;
         
         _OnRemove();
         _OnAdd();
      }

		private function soundEventHandler(e:Event):void
		{
         var sound:MP3Resource = Events[e.type];
         sound.SoundObject.play();
		}

	}
}