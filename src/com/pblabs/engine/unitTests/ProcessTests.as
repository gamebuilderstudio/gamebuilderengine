/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.unitTests
{
   import com.pblabs.engine.core.ProcessManager;
   import com.pblabs.engine.debug.Logger;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class ProcessTests extends TestCase
   {
      public function testAnimatedProcess():void
      {
         var animatedObject:AnimateTest = new AnimateTest();
         ProcessManager.instance.addAnimatedObject(animatedObject);
         
         ProcessManager.instance.testAdvance(200);
         assertEquals(animatedObject.elapsed, 200 / 1000);
         
         ProcessManager.instance.timeScale = 0.5;
         ProcessManager.instance.testAdvance(200);
         assertEquals(animatedObject.elapsed, 100 / 1000);
         ProcessManager.instance.timeScale = 1.0;
         
         ProcessManager.instance.removeAnimatedObject(animatedObject);
      }
      
      public function testPriority():void
      {
         Logger.printHeader(null, "Running Process Priority Test");
         
         var tickObject0:TickTest = new TickTest(0);
         var tickObject1:TickTest = new TickTest(1);
         var tickObject2:TickTest = new TickTest(2);
         var tickObject3:TickTest = new TickTest(3);
         var tickObject4:TickTest = new TickTest(4);
         var tickObject5:TickTest = new TickTest(5);
         ProcessManager.instance.addTickedObject(tickObject4, 4.0);
         ProcessManager.instance.addTickedObject(tickObject3, 3.0);
         ProcessManager.instance.addTickedObject(tickObject5, 5.0);
         ProcessManager.instance.addTickedObject(tickObject1, 1.0);
         ProcessManager.instance.addTickedObject(tickObject2, 2.0);
         ProcessManager.instance.addTickedObject(tickObject0, 0.0);
         
         ProcessManager.instance.testAdvance(ProcessManager.TICK_RATE_MS);
         
         ProcessManager.instance.removeTickedObject(tickObject4);
         ProcessManager.instance.removeTickedObject(tickObject3);
         ProcessManager.instance.removeTickedObject(tickObject5);
         ProcessManager.instance.removeTickedObject(tickObject1);
         ProcessManager.instance.removeTickedObject(tickObject2);
         ProcessManager.instance.removeTickedObject(tickObject0);
         
         Logger.printFooter(null, "");
      }
      
      public function testTickRate():void
      {
         Logger.printHeader(null, "Running Process Tick Rate Test");
         
         var tickObject:TickTest = new TickTest(0);
         tickObject.testPriority = false;
         tickObject.testCount = true;
         ProcessManager.instance.addTickedObject(tickObject);
         
         ProcessManager.instance.testAdvance((ProcessManager.TICK_RATE_MS * 4) + 8);
         assertEquals(tickObject.tickCount, 4);
         assertTrue(Math.abs(tickObject.interpolationFactor - 8.0 / ProcessManager.TICK_RATE_MS) < 0.001);
         
         ProcessManager.instance.timeScale = 0.5;
         ProcessManager.instance.testAdvance((ProcessManager.TICK_RATE_MS * 4) + 8);
         assertEquals(tickObject.tickCount, 6);
         assertTrue(Math.abs(tickObject.interpolationFactor - 12.0 / ProcessManager.TICK_RATE_MS) < 0.001);
         ProcessManager.instance.timeScale = 1.0;
         
         ProcessManager.instance.removeTickedObject(tickObject);
         
         Logger.printFooter(null, "");
      }
      
      public function testSchedule():void
      {
         ProcessManager.instance.schedule(1000, this, onSchedule, 2, 7, 4, 3);
         ProcessManager.instance.testAdvance(999);
         assertEquals(_scheduleCount, 0);
         ProcessManager.instance.testAdvance(1);
         assertEquals(_scheduleCount, 1);
         ProcessManager.instance.testAdvance(1000);
         assertEquals(_scheduleCount, 1);
         
         ProcessManager.instance.timeScale = 0.5;
         ProcessManager.instance.schedule(500, this, onSchedule, 2, 7, 4, 3);
         ProcessManager.instance.testAdvance(900);
         assertEquals(_scheduleCount, 1);
         ProcessManager.instance.testAdvance(100);
         assertEquals(_scheduleCount, 2);
         ProcessManager.instance.testAdvance(1000);
         assertEquals(_scheduleCount, 2);
         ProcessManager.instance.timeScale = 1.0;
      }
      
      private function onSchedule(two:int, seven:int, four:int, three:int):void
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

import com.pblabs.engine.core.ITickedObject;
import com.pblabs.engine.core.IAnimatedObject;

class AnimateTest implements IAnimatedObject
{
   public function get elapsed():Number
   {
      return _elapsed;
   }
   
   public function onFrame(elapsed:Number):void
   {
      _elapsed = elapsed;
   }
   
   private var _elapsed:Number = 0.0;
}

class TickTest implements ITickedObject
{
   public static var counter:int = 5;
   
   public var testPriority:Boolean = true;
   public var testCount:Boolean = false;
   
   public function get tickCount():int
   {
      return _tickCount;
   }
   
   public function get interpolationFactor():Number
   {
      return _interpolationFactor;
   }
   
   public function TickTest(priority:int)
   {
      _priority = priority;
   }
   
   public function onTick(tickRate:Number):void
   {
      if (testPriority)
      {
         if (counter == -1)
            throw new Error("Objects not removed from process list!");
         
         if (counter != _priority)
            throw new Error("Incorrect tick order!");
      
         counter--;
      }
      else if (testCount)
      {
         _tickCount++;
      }
   }
   
   public function onInterpolateTick(factor:Number):void
   {
      _interpolationFactor = factor;
   }
   
   private var _tickCount:int = 0;
   private var _interpolationFactor:Number = 0.0;
   private var _priority:int = -1;
}