/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.tests
{
    import com.pblabs.engine.core.ProcessManager;
    import com.pblabs.engine.debug.Logger;
    
    import flexunit.framework.Assert;

    /**
     * @private
     */
    public class ProcessTests
    {
        private var _scheduleCount:int = 0;

        [Test]
        public function testAnimatedProcess():void
        {
            var animatedObject:AnimateTest = new AnimateTest();
            ProcessManager.instance.addAnimatedObject(animatedObject);

            ProcessManager.instance.testAdvance(200);
            Assert.assertEquals(200 / 1000, animatedObject.elapsed);

            ProcessManager.instance.timeScale = 0.5;
            ProcessManager.instance.testAdvance(200);
            Assert.assertEquals(100 / 1000, animatedObject.elapsed);
            ProcessManager.instance.timeScale = 1.0;

            ProcessManager.instance.removeAnimatedObject(animatedObject);
        }

        [Test]
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

        [Test]
        public function testTickRate():void
        {
            Logger.printHeader(null, "Running Process Tick Rate Test");

            var tickObject:TickTest = new TickTest(0);
            tickObject.testPriority = false;
            tickObject.testCount = true;
            ProcessManager.instance.addTickedObject(tickObject);

            ProcessManager.instance.testAdvance((ProcessManager.TICK_RATE_MS * 4) + 8);
            Assert.assertEquals(4, tickObject.tickCount);
            //Assert.assertTrue(Math.abs(tickObject.interpolationFactor - 8.0 / ProcessManager.TICK_RATE_MS) < 0.001);

            ProcessManager.instance.timeScale = 0.5;
            ProcessManager.instance.testAdvance((ProcessManager.TICK_RATE_MS * 4) + 8);
            Assert.assertEquals(6, tickObject.tickCount);
            //Assert.assertTrue(Math.abs(tickObject.interpolationFactor - 12.0 / ProcessManager.TICK_RATE_MS) < 0.001);
            ProcessManager.instance.timeScale = 1.0;

            ProcessManager.instance.removeTickedObject(tickObject);

            Logger.printFooter(null, "");
        }

        [Test]
        public function testSchedule():void
        {
            ProcessManager.instance.schedule(1000, this, onSchedule, 2, 7, 4, 3);
            ProcessManager.instance.testAdvance(999);
            Assert.assertEquals(0, _scheduleCount);
            ProcessManager.instance.testAdvance(1);
            Assert.assertEquals(1, _scheduleCount);
            ProcessManager.instance.testAdvance(1000);
            Assert.assertEquals(1, _scheduleCount);

            ProcessManager.instance.timeScale = 0.5;
            ProcessManager.instance.schedule(500, this, onSchedule, 2, 7, 4, 3);
            ProcessManager.instance.testAdvance(900);
            Assert.assertEquals(1, _scheduleCount);
            ProcessManager.instance.testAdvance(100);
            Assert.assertEquals(2, _scheduleCount);
            ProcessManager.instance.testAdvance(1000);
            Assert.assertEquals(2, _scheduleCount);
            ProcessManager.instance.timeScale = 1.0;
        }
        
        [Test]
        public function testScheduleVirtualTimeConsistency():void
        {
            var hits:int = 0;
            var wrongOrder:Boolean = false;
            var wrongTime:Boolean = false;
            
            var dueTime:Number = ProcessManager.instance.virtualTime + 1000;
            ProcessManager.instance.schedule(1000, this, 
                    function():void{
                    	if (hits == 0) wrongOrder = true;
                    	hits++;
                    	wrongTime = wrongTime || ProcessManager.instance.virtualTime < dueTime;
                    });

            ProcessManager.instance.testAdvance(100);

            var dueTime2:Number = ProcessManager.instance.virtualTime + 20;
            ProcessManager.instance.schedule(20, this, 
                    function():void{
                        if (hits > 0) wrongOrder = true;
                        hits++;
                        wrongTime = wrongTime || ProcessManager.instance.virtualTime < dueTime2;
                    });
                    
            ProcessManager.instance.testAdvance(2000);
            Assert.assertEquals(2, hits);
            Assert.assertFalse(wrongTime);
            Assert.assertFalse(wrongOrder);
        }

        private function onSchedule(two:int, seven:int, four:int, three:int):void
        {
            _scheduleCount++;

            Assert.assertEquals(two, 2);
            Assert.assertEquals(seven, 7);
            Assert.assertEquals(four, 4);
            Assert.assertEquals(three, 3);
        }

    }
}

import com.pblabs.engine.core.ITickedObject;
import com.pblabs.engine.core.IAnimatedObject;

class AnimateTest implements IAnimatedObject
{
    private var _elapsed:Number = 0.0;

    public function get elapsed():Number
    {
        return _elapsed;
    }

    public function onFrame(elapsed:Number):void
    {
        _elapsed = elapsed;
    }
}

class TickTest implements ITickedObject
{
    private var _tickCount:int = 0;
    private var _interpolationFactor:Number = 0.0;
    private var _priority:int = -1;

    public static var counter:int = 5;

    public var testPriority:Boolean = true;
    public var testCount:Boolean = false;

    public function get tickCount():int
    {
        return _tickCount;
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
}