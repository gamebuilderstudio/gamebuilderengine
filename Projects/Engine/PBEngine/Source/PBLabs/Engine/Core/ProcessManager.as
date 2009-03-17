package PBLabs.Engine.Core
{
   import PBLabs.Engine.Debug.Logger;
   
   import flash.events.Event;
   import flash.utils.getTimer;
   
   import mx.core.Application;
   
   /**
    * The process manager manages all time related functionality in the engine.
    * It provides mechanisms for performing actions every frame, every tick, or
    * at a specific time in the future.
    * 
    * <p>A tick happens at a set interval defined by the TICKS_PER_SECOND constant.
    * Using ticks for various tasks that need to happen repeatedly instead of
    * performing those tasks every frame results in much more consistent output.
    * However, for animation related tasks, frame events should be used so the
    * display remains smooth.</p>
    * 
    * @see ITickedObject
    * @see IAnimatedObject
    * @see ../../../../../Reference/ProcessManager.html The Process Manager
    */
   public class ProcessManager
   {
      /**
       * The number of ticks that will happen every second.
       */
      public static const TICKS_PER_SECOND:int = 30;
      
      /**
       * The rate at which ticks are fired, in seconds.
       */
      public static const TICK_RATE:Number = 1.0 / TICKS_PER_SECOND;
      
      /**
       * The rate at which ticks are fired, in milliseconds.
       */
      public static const TICK_RATE_MS:Number = TICK_RATE * 1000;
      
      /**
       * The maximum number of ticks that are fired every frame. In some cases,
       * if some process is eating up a whole bunch of time, a single frame
       * can take an extremely long amount of time. If several ticks then
       * need to be processed, the engine can quickly get in a state where
       * it is backlogged and unable to recover in a reasonable amount if
       * time. Only performing a certain number of ticks per frame will
       * alleviate that situation, but really, if this limit is ever reached,
       * there is probably a performance issue somewhere that needs to be resolved.
       */
      public static const MAX_TICKS_PER_FRAME:int = 10;
      
      /**
       * The singleton ProcessManager instance.
       */
      public static function get Instance():ProcessManager
      {
         if (_instance == null)
            _instance = new ProcessManager();
         
         return _instance;
      }
      
      private static var _instance:ProcessManager = null;
      
      /**
       * The scale at which time advances. If this is set to 2, the game
       * will essentially play twice as fast. A value of 0.5 will run the
       * game at half speed. A value of 1 is normal.
       */
      public function get TimeScale():Number
      {
         return _timeScale;
      }
      
      /**
       * @private
       */
      public function set TimeScale(value:Number):void
      {
         _timeScale = value;
      }
      
      /**
       * Used to determine how far we are between ticks. 0.0 at the start of a tick, and
       * 1.0 at the end. Useful for smoothly interpolating visual elements.
       */
      public function get InterpolationFactor():Number
      {
         return _interpolationFactor;
      }
      
      /**
       * The amount of time that has been processed by the process manager. This does
       * take the time scale into account. Time is in milliseconds.
       */
      public function get VirtualTime():Number
      {
         return _virtualTime;
      }
      
      /**
       * Starts the process manager. This is automatically called when the first object
       * is added to the process manager. If the manager is stopped manually, then this
       * will have to be called to restart it.
       */
      public function Start():void
      {
         if (_started)
         {
            Logger.PrintWarning(this, "Start", "The ProcessManager is already started.");
            return;
         }
         
         _lastTime = -1.0;
         _elapsed = 0.0;
         Application.application.stage.addEventListener(Event.ENTER_FRAME, _OnFrame);
         _started = true;
      }
      
      /**
       * Stops the process manager. This is automatically called when the last object
       * is removed from the process manager, but can also be called manually to, for
       * example, pause the game.
       */
      public function Stop():void
      {
         if (!_started)
         {
            Logger.PrintWarning(this, "Stop", "The ProcessManager isn't started.");
            return;
         }
         
         _started = false;
         Application.application.stage.removeEventListener(Event.ENTER_FRAME, _OnFrame);
      }
      
      /**
       * Schedules a function to be called at a specified time in the future.
       * 
       * @param delay The number of milliseconds in the future to call the function.
       * @param thisObject The object on which the function should be called. This
       * becomes the 'this' variable in the function.
       * @param callback The function to call.
       * @param arguments The arguments to pass to the function when it is called.
       */
      public function Schedule(delay:Number, thisObject:Object, callback:Function, ...arguments):void
      {
         if (!_started)
            Start();
         
         var schedule:ScheduleObject = new ScheduleObject();
         schedule.TimeRemaining = delay;
         schedule.ThisObject = thisObject;
         schedule.Callback = callback;
         schedule.Arguments = arguments;
         _scheduleEvents.push(schedule);
      }
      
      /**
       * Registers an object to receive frame callbacks.
       * 
       * @param object The object to add.
       * @param priority The priority of the object. Objects added with higher priorities
       * will receive their callback before objects with lower priorities.
       */
      public function AddAnimatedObject(object:IAnimatedObject, priority:Number = 0.0):void
      {
         _AddObject(object, priority, _animatedObjects);
      }
      
      /**
       * Registers an object to receive tick callbacks.
       * 
       * @param object The object to add.
       * @param priority The priority of the object. Objects added with higher priorities
       * will receive their callback before objects with lower priorities.
       */
      public function AddTickedObject(object:ITickedObject, priority:Number = 0.0):void
      {
         _AddObject(object, priority, _tickedObjects);
      }
      
      /**
       * Unregisters an object from receiving frame callbacks.
       * 
       * @param object The object to remove.
       */
      public function RemoveAnimatedObject(object:IAnimatedObject):void
      {
         _RemoveObject(object, _animatedObjects);
      }
      
      /**
       * Unregisters an object from receiving tick callbacks.
       * 
       * @param object The object to remove.
       */
      public function RemoveTickedObject(object:ITickedObject):void
      {
         _RemoveObject(object, _tickedObjects);
      }
      
      /**
       * Forces the process manager to advance by the specified amount. This should
       * only be used for unit testing.
       * 
       * @param amount The amount of time to simulate.
       */
      public function TestAdvance(amount:Number):void
      {
         _Advance(amount * _timeScale);
      }
      
      private function get _ListenerCount():int
      {
         return _tickedObjects.length + _animatedObjects.length;
      }
      
      private function _AddObject(object:*, priority:Number, list:Array):void
      {
         if (!_started)
            Start();
         
         var position:int = -1;
         for (var i:int = 0; i < list.length; i++)
         {
            if (list[i].Listener == object)
            {
               Logger.PrintWarning(object, "AddProcessObject", "This object has already been added to the process manager.");
               return;
            }
            
            if (list[i].Priority < priority)
            {
               position = i;
               break;
            }
         }
         
         var processObject:ProcessObject = new ProcessObject();
         processObject.Listener = object;
         processObject.Priority = priority;
         
         if ((position < 0) || (position >= list.length))
            list.push(processObject);
         else
            list.splice(position, 0, processObject);
      }
      
      private function _RemoveObject(object:*, list:Array):void
      {
         if ((_ListenerCount == 1) && (_scheduleEvents.length == 0))
            Stop();
         
         for (var i:int = 0; i < list.length; i++)
         {
            if (list[i].Listener == object)
            {
               list.splice(i, 1);
               return;
            }
         }
         
         Logger.PrintWarning(object, "RemoveProcessObject", "This object has not been added to the process manager.");
      }
      
      private function _OnFrame(event:Event):void
      {
         var currentTime:Number = getTimer();
         if (_lastTime < 0)
         {
            _lastTime = currentTime;
            return;
         }
         
         var elapsed:Number = (currentTime - _lastTime) * _timeScale;
         _Advance(elapsed);
         
         _lastTime = currentTime;
      }
      
      private function _Advance(elapsed:Number):void
      {
         _elapsed += elapsed;
         
         var startTime:Number = _virtualTime;
         
         // Process pending events.
         for (var i:int = 0; i < _scheduleEvents.length; i++)
         {
            var schedule:ScheduleObject = _scheduleEvents[i];
            schedule.TimeRemaining -= elapsed;
            if (schedule.TimeRemaining <= 0)
            {
               schedule.Callback.apply(schedule.ThisObject, schedule.Arguments);
               _scheduleEvents.splice(i, 1);
               i--;
            }
         }
         
         // Perform ticks.
         var tickCount:int = 0;
         while ((_elapsed >= TICK_RATE_MS) && (tickCount < MAX_TICKS_PER_FRAME))
         {
            _interpolationFactor = 0.0;
            
            for each (var object:ProcessObject in _tickedObjects)
               object.Listener.OnTick(TICK_RATE);
            
            _virtualTime += TICK_RATE_MS;
            _elapsed -= TICK_RATE_MS;
            tickCount++;
         }
         
         // Safety net - don't do more than a few ticks per frame to avoid death spirals.
         if (tickCount >= MAX_TICKS_PER_FRAME)
         {
            _elapsed = 0;
            Logger.PrintWarning(this, "Advance", "Exceeded maximum number of ticks for this frame.");
         }
         
         _virtualTime = startTime + elapsed;
         
         // Update objects expecting interpolation between ticks.
         _interpolationFactor = _elapsed / TICK_RATE_MS;
         for each (var tickedObject:ProcessObject in _tickedObjects)
            tickedObject.Listener.OnInterpolateTick(_interpolationFactor);
         
         // Update objects wanting OnFrame callbacks.
         for each (var animatedObject:ProcessObject in _animatedObjects)
            animatedObject.Listener.OnFrame(elapsed / 1000);
      }
      
      private var _started:Boolean = false;
      private var _virtualTime:Number = 0.0;
      private var _interpolationFactor:Number = 0.0;
      private var _timeScale:Number = 1.0;
      private var _lastTime:Number = -1.0;
      private var _elapsed:Number = 0.0;
      private var _animatedObjects:Array = new Array();
      private var _tickedObjects:Array = new Array();
      private var _scheduleEvents:Array = new Array();
   }
}

class ScheduleObject
{
   public var TimeRemaining:Number = 0.0;
   public var ThisObject:Object = null;
   public var Callback:Function = null;
   public var Arguments:Array = null;
}

class ProcessObject
{
   public var Listener:* = null;
   public var Priority:Number = 0.0;
}