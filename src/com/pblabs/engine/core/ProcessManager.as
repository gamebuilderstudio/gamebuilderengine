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
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.debug.Profiler;
   import com.pblabs.engine.serialization.TypeUtility;
   
   import flash.events.Event;
   import flash.utils.getTimer;

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
    */
   public class ProcessManager
   {
      /**
       * The number of ticks that will happen every second.
       */
      public static const TICKS_PER_SECOND:int = 32;
      
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
      public static function get instance():ProcessManager
      {
         if (!_instance)
            _instance = new ProcessManager();
         
         return _instance;
      }
      
      private static var _instance:ProcessManager = null;
      
      /**
       * The scale at which time advances. If this is set to 2, the game
       * will essentially play twice as fast. A value of 0.5 will run the
       * game at half speed. A value of 1 is normal.
       */
      public function get timeScale():Number
      {
         return _timeScale;
      }
      
      /**
       * @private
       */
      public function set timeScale(value:Number):void
      {
          _timeScale = value;
      }

      /**
       * TweenMax uses timeScale as a config property, so now we haev a workaround.
       */
      public function set TimeScale(value:Number):void
      {
          timeScale = value;
      }

      /**
       * @private
       */ 
      public function get TimeScale():Number
      {
          return timeScale;
      }
      
      /**
       * Used to determine how far we are between ticks. 0.0 at the start of a tick, and
       * 1.0 at the end. Useful for smoothly interpolating visual elements.
       */
      public function get interpolationFactor():Number
      {
         return _interpolationFactor;
      }
      
      /**
       * The amount of time that has been processed by the process manager. This does
       * take the time scale into account. Time is in milliseconds.
       */
      public function get virtualTime():Number
      {
         return _virtualTime;
      }
      
      /**
       * Starts the process manager. This is automatically called when the first object
       * is added to the process manager. If the manager is stopped manually, then this
       * will have to be called to restart it.
       */
      public function start():void
      {
         if (started)
         {
            Logger.printWarning(this, "Start", "The ProcessManager is already started.");
            return;
         }
         
         lastTime = -1.0;
         elapsed = 0.0;
         Global.mainStage.addEventListener(Event.ENTER_FRAME, onFrame);
         started = true;
      }
      
      /**
       * Stops the process manager. This is automatically called when the last object
       * is removed from the process manager, but can also be called manually to, for
       * example, pause the game.
       */
      public function stop():void
      {
         if (!started)
         {
            Logger.printWarning(this, "Stop", "The ProcessManager isn't started.");
            return;
         }
         
         started = false;
         Global.mainStage.removeEventListener(Event.ENTER_FRAME, onFrame);
      }
      
      /**
       * Returns true if the process manager is advancing.
       */ 
      public function get isTicking():Boolean
      {
         return started;
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
      public function schedule(delay:Number, thisObject:Object, callback:Function, ...arguments):void
      {
         if (!started)
            start();
         
         var schedule:ScheduleObject = new ScheduleObject();
         schedule.dueTime = _virtualTime + delay;
         schedule.thisObject = thisObject;
         schedule.callback = callback;
         schedule.arguments = arguments;

         //find where to insert this item in the array.
         //we'll place it before the first item that is scheduled further out.
         //by keeping this array ordered we only have to iterate over schedules that are due at a given tick.
         var spliced:Boolean = false;
         for (var i:int = 0; i < scheduleEvents.length; i++)
         {
            var s:ScheduleObject = scheduleEvents[i];
            if (s.dueTime > schedule.dueTime)
            {
               scheduleEvents.splice(i, 0, schedule);
               spliced = true;
               break;
            }
         }
        
         //no schedules were found further out (or this is the first schedule). append to the end!
         if (!spliced)
            scheduleEvents.push(schedule);
      }
      
      /**
       * Registers an object to receive frame callbacks.
       * 
       * @param object The object to add.
       * @param priority The priority of the object. Objects added with higher priorities
       * will receive their callback before objects with lower priorities.
       */
      public function addAnimatedObject(object:IAnimatedObject, priority:Number = 0.0):void
      {
         addObject(object, priority, animatedObjects);
      }
      
      /**
       * Registers an object to receive tick callbacks.
       * 
       * @param object The object to add.
       * @param priority The priority of the object. Objects added with higher priorities
       * will receive their callback before objects with lower priorities.
       */
      public function addTickedObject(object:ITickedObject, priority:Number = 0.0):void
      {
         addObject(object, priority, tickedObjects);
      }
      
      /**
       * Unregisters an object from receiving frame callbacks.
       * 
       * @param object The object to remove.
       */
      public function removeAnimatedObject(object:IAnimatedObject):void
      {
         removeObject(object, animatedObjects);
      }
      
      /**
       * Unregisters an object from receiving tick callbacks.
       * 
       * @param object The object to remove.
       */
      public function removeTickedObject(object:ITickedObject):void
      {
         removeObject(object, tickedObjects);
      }
      
      /**
       * Forces the process manager to advance by the specified amount. This should
       * only be used for unit testing.
       * 
       * @param amount The amount of time to simulate.
       */
      public function testAdvance(amount:Number):void
      {
         advance(amount * _timeScale, true);
      }
      
      private function get listenerCount():int
      {
         return tickedObjects.length + animatedObjects.length;
      }
      
      private function addObject(object:*, priority:Number, list:Array):void
      {
         if (!started)
            start();
         
         var position:int = -1;
         for (var i:int = 0; i < list.length; i++)
         {
            if (list[i].listener == object)
            {
               Logger.printWarning(object, "AddProcessObject", "This object has already been added to the process manager.");
               return;
            }
            
            if (list[i].priority < priority)
            {
               position = i;
               break;
            }
         }
         
         var processObject:ProcessObject = new ProcessObject();
         processObject.listener = object;
         processObject.priority = priority;
         processObject.profilerKey = TypeUtility.getObjectClassName(object);
         
         if (position < 0 || position >= list.length)
            list.push(processObject);
         else
            list.splice(position, 0, processObject);
      }
      
      private function removeObject(object:*, list:Array):void
      {
         if (listenerCount == 1 && scheduleEvents.length == 0)
            stop();
         
         for (var i:int = 0; i < list.length; i++)
         {
            if (list[i].listener == object)
            {
               list.splice(i, 1);
               return;
            }
         }
         
         Logger.printWarning(object, "RemoveProcessObject", "This object has not been added to the process manager.");
      }
      
      private function onFrame(event:Event):void
      {
          var currentTime:Number = getTimer();
          if (lastTime < 0)
          {
              lastTime = currentTime;
              return;
          }
          
          var deltaTime:Number = (currentTime - lastTime) * _timeScale;
          advance(deltaTime);
          
          lastTime = currentTime;
      }
      
      private function advance(deltaTime:Number, suppressSafety:Boolean = false):void
      {
          elapsed += deltaTime;
          
          var startTime:Number = _virtualTime;
          
          Profiler.ensureAtRoot();
          
          // Process pending events.
          Profiler.enter("PendingEvents");
          for (var i:int = 0; i < scheduleEvents.length; i++)
          {
              var schedule:ScheduleObject = scheduleEvents[i];
              if (schedule.dueTime <= _virtualTime + deltaTime)
              {
                  schedule.callback.apply(schedule.thisObject, schedule.arguments);
                  scheduleEvents.splice(i, 1);
                  i--;
              }
              else
              {
                 //our scheduled event array is sorted by due time, 
                 //so once we hit one that isn't due we know we're done processing for this time.
                 break;
              }
          }
          Profiler.exit("PendingEvents");
          
          // Perform ticks.
          var tickCount:int = 0;
          while (elapsed >= TICK_RATE_MS && (suppressSafety || tickCount < MAX_TICKS_PER_FRAME))
          {
              _interpolationFactor = 0.0;
              
              Profiler.enter("Tick");
              
              for each (var object:ProcessObject in tickedObjects)
              {
                  Profiler.enter(object.profilerKey);
                  object.listener.onTick(TICK_RATE);
                  Profiler.exit(object.profilerKey);
              }
              
              Profiler.exit("Tick");
              
              _virtualTime += TICK_RATE_MS;
              elapsed -= TICK_RATE_MS;
              tickCount++;
          }
          
          // Safety net - don't do more than a few ticks per frame to avoid death spirals.
          if (tickCount >= MAX_TICKS_PER_FRAME && !suppressSafety)
          {
              elapsed = 0;
              Logger.printWarning(this, "Advance", "Exceeded maximum number of ticks for this frame.");
          }
          
          _virtualTime = startTime + deltaTime;
          
          // Update objects expecting interpolation between ticks.
          Profiler.enter("InterpolateTick");
          _interpolationFactor = elapsed / TICK_RATE_MS;
          for each (var tickedObject:ProcessObject in tickedObjects)
          {
              Profiler.enter(tickedObject.profilerKey);
              tickedObject.listener.onInterpolateTick(_interpolationFactor);
              Profiler.exit(tickedObject.profilerKey);
          }
          Profiler.exit("InterpolateTick");
          
          // Update objects wanting OnFrame callbacks.
          Profiler.enter("frame");
          for each (var animatedObject:ProcessObject in animatedObjects)
          {
              Profiler.enter(animatedObject.profilerKey);
              animatedObject.listener.onFrame(deltaTime / 1000);
              Profiler.exit(animatedObject.profilerKey);
          }
          Profiler.exit("frame");
          
          Profiler.ensureAtRoot();
      }
      
      private var started:Boolean = false;
      private var _virtualTime:Number = 0.0;
      private var _interpolationFactor:Number = 0.0;
      private var _timeScale:Number = 1.0;
      private var lastTime:Number = -1.0;
      private var elapsed:Number = 0.0;
      private var animatedObjects:Array = new Array();
      private var tickedObjects:Array = new Array();
      private var scheduleEvents:Array = new Array();
   }
}

class ScheduleObject
{
   public var dueTime:Number = 0.0;
   public var thisObject:Object = null;
   public var callback:Function = null;
   public var arguments:Array = null;
}

class ProcessObject
{
   public var profilerKey:String = null;
   public var listener:* = null;
   public var priority:Number = 0.0;
}