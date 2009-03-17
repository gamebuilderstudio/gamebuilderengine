/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.UnitTests
{
   import PBLabs.Engine.Core.ProcessManager;
   import PBLabs.Engine.Debug.Logger;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class ProcessTests extends TestCase
   {
      public function testAnimatedProcess():void
      {
         var animatedObject:AnimateTest = new AnimateTest();
         ProcessManager.Instance.AddAnimatedObject(animatedObject);
         
         ProcessManager.Instance.TestAdvance(200);
         assertEquals(animatedObject.Elapsed, 200 / 1000);
         
         ProcessManager.Instance.TimeScale = 0.5;
         ProcessManager.Instance.TestAdvance(200);
         assertEquals(animatedObject.Elapsed, 100 / 1000);
         ProcessManager.Instance.TimeScale = 1.0;
         
         ProcessManager.Instance.RemoveAnimatedObject(animatedObject);
      }
      
      public function testPriority():void
      {
         Logger.PrintHeader(null, "Running Process Priority Test");
         
         var tickObject0:TickTest = new TickTest(0);
         var tickObject1:TickTest = new TickTest(1);
         var tickObject2:TickTest = new TickTest(2);
         var tickObject3:TickTest = new TickTest(3);
         var tickObject4:TickTest = new TickTest(4);
         var tickObject5:TickTest = new TickTest(5);
         ProcessManager.Instance.AddTickedObject(tickObject4, 4.0);
         ProcessManager.Instance.AddTickedObject(tickObject3, 3.0);
         ProcessManager.Instance.AddTickedObject(tickObject5, 5.0);
         ProcessManager.Instance.AddTickedObject(tickObject1, 1.0);
         ProcessManager.Instance.AddTickedObject(tickObject2, 2.0);
         ProcessManager.Instance.AddTickedObject(tickObject0, 0.0);
         
         ProcessManager.Instance.TestAdvance(ProcessManager.TICK_RATE_MS);
         
         ProcessManager.Instance.RemoveTickedObject(tickObject4);
         ProcessManager.Instance.RemoveTickedObject(tickObject3);
         ProcessManager.Instance.RemoveTickedObject(tickObject5);
         ProcessManager.Instance.RemoveTickedObject(tickObject1);
         ProcessManager.Instance.RemoveTickedObject(tickObject2);
         ProcessManager.Instance.RemoveTickedObject(tickObject0);
      }
      
      public function testTickRate():void
      {
         Logger.PrintHeader(null, "Running Process Tick Rate Test");
         
         var tickObject:TickTest = new TickTest(0);
         tickObject.TestPriority = false;
         tickObject.TestCount = true;
         ProcessManager.Instance.AddTickedObject(tickObject);
         
         ProcessManager.Instance.TestAdvance((ProcessManager.TICK_RATE_MS * 4) + 8);
         assertEquals(tickObject.TickCount, 4);
         assertTrue(Math.abs(tickObject.InterpolationFactor - 8.0 / ProcessManager.TICK_RATE_MS) < 0.001);
         
         ProcessManager.Instance.TimeScale = 0.5;
         ProcessManager.Instance.TestAdvance((ProcessManager.TICK_RATE_MS * 4) + 8);
         assertEquals(tickObject.TickCount, 6);
         assertTrue(Math.abs(tickObject.InterpolationFactor - 12.0 / ProcessManager.TICK_RATE_MS) < 0.001);
         ProcessManager.Instance.TimeScale = 1.0;
         
         ProcessManager.Instance.RemoveTickedObject(tickObject);
      }
      
      public function testSchedule():void
      {
         ProcessManager.Instance.Schedule(1000, this, _OnSchedule, 2, 7, 4, 3);
         ProcessManager.Instance.TestAdvance(999);
         assertEquals(_scheduleCount, 0);
         ProcessManager.Instance.TestAdvance(1);
         assertEquals(_scheduleCount, 1);
         ProcessManager.Instance.TestAdvance(1000);
         assertEquals(_scheduleCount, 1);
         
         ProcessManager.Instance.TimeScale = 0.5;
         ProcessManager.Instance.Schedule(500, this, _OnSchedule, 2, 7, 4, 3);
         ProcessManager.Instance.TestAdvance(900);
         assertEquals(_scheduleCount, 1);
         ProcessManager.Instance.TestAdvance(100);
         assertEquals(_scheduleCount, 2);
         ProcessManager.Instance.TestAdvance(1000);
         assertEquals(_scheduleCount, 2);
         ProcessManager.Instance.TimeScale = 1.0;
      }
      
      private function _OnSchedule(two:int, seven:int, four:int, three:int):void
      {
         _scheduleCount++;
         
         assertEquals(two, 2);
         assertEquals(seven, 7);
         assertEquals(four, 4);
         assertEquals(three, 3);
      }
      
      private var _scheduleCount:int = 0;
   }
}

import PBLabs.Engine.Core.ITickedObject;
import PBLabs.Engine.Core.IAnimatedObject;

class AnimateTest implements IAnimatedObject
{
   public function get Elapsed():Number
   {
      return _elapsed;
   }
   
   public function OnFrame(elapsed:Number):void
   {
      _elapsed = elapsed;
   }
   
   private var _elapsed:Number = 0.0;
}

class TickTest implements ITickedObject
{
   public static var Counter:int = 5;
   
   public var TestPriority:Boolean = true;
   public var TestCount:Boolean = false;
   
   public function get TickCount():int
   {
      return _tickCount;
   }
   
   public function get InterpolationFactor():Number
   {
      return _interpolationFactor;
   }
   
   public function TickTest(priority:int)
   {
      _priority = priority;
   }
   
   public function OnTick(tickRate:Number):void
   {
      if (TestPriority)
      {
         if (Counter == -1)
            throw new Error("Objects not removed from process list!");
         
         if (Counter != _priority)
            throw new Error("Incorrect tick order!");
      
         Counter--;
      }
      else if (TestCount)
      {
         _tickCount++;
      }
   }
   
   public function OnInterpolateTick(factor:Number):void
   {
      _interpolationFactor = factor;
   }
   
   private var _tickCount:int = 0;
   private var _interpolationFactor:Number = 0.0;
   private var _priority:int = -1;
}