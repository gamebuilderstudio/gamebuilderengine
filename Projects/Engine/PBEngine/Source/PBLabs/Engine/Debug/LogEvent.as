package PBLabs.Engine.Debug
{
   import flash.events.Event;
   
   /**
    * A LogEvent is an event used by the Logger to dispatch log related information.
    */
   public class LogEvent extends Event
   {
      /**
       * The entry added event is dispatched by the Logger whenever a new
       * message is printed to the log.
       * 
       * @eventType ENTRY_ADDED_EVENT
       */
      public static const ENTRY_ADDED_EVENT:String = "ENTRY_ADDED_EVENT";
      
      /**
       * The LogEntry associated with this event.
       */
      public var Entry:LogEntry = null;
      
      public function LogEvent(type:String, entry:LogEntry, bubbles:Boolean=false, cancelable:Boolean=false) 
      {
         Entry = entry;
         super(type, bubbles, cancelable);
      }
   }
}