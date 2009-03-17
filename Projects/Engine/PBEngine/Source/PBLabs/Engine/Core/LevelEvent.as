package PBLabs.Engine.Core
{
   import flash.events.Event;
   
   /**
    * The LevelEvent is used by the LevelManager to dispatch information about the loaded
    * status of levels.
    * 
    * @see PBLabs.Engine.Core.LevelManager
    */
   public class LevelEvent extends Event
   {
      /**
       * This event is dispatched by the LevelManager upon loading of a level's data.
       * 
       * @eventType LOADED_EVENT
       */
      public static const LOADED_EVENT:String = "LOADED_EVENT";
      
      /**
       * The level associated with this event.
       */
      public var Level:int = -1;
      
      public function LevelEvent(type:String, level:int, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         Level = level;
         super(type, bubbles, cancelable);
      }
   }
}