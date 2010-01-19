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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.InputKey;
    import com.pblabs.engine.core.InputManager;
    import com.pblabs.engine.core.InputMap;

    import flexunit.framework.Assert;

    /**
     * @private
     */
    public class InputTests
    {
        private var _spacePressed:Number = 0.0;
        private var _mousePressed:Number = 0.0;
        private var _mouseMoved:Boolean = false;

        [Test]
        public function testInputMap():void
        {
            var inputMap:InputMap = new InputMap();
            inputMap.mapKeyToAction(InputKey.SPACE, "Space");
            inputMap.mapKeyToAction(InputKey.MOUSE_BUTTON, "MouseButton");
            inputMap.mapKeyToAction(InputKey.MOUSE_X, "MouseX");

            inputMap.mapActionToHandler("Space", onSpace);
            inputMap.mapActionToHandler("MouseButton", onMouseButton);
            inputMap.mapActionToHandler("MouseX", onMouseX);

            PBE.inputManager.simulateKeyDown(InputKey.SPACE.keyCode);
            validateInputs(1, 0, false);
            PBE.inputManager.simulateKeyUp(InputKey.SPACE.keyCode);
            validateInputs(0, 0, false);

            PBE.inputManager.simulateMouseDown();
            PBE.inputManager.simulateMouseMove();
            PBE.inputManager.simulateMouseMove();
            validateInputs(0, 1, true);
            PBE.inputManager.simulateMouseUp();
            validateInputs(0, 0, true);
            
            inputMap.destroy();
        }

        private function onSpace(value:Number):void
        {
            _spacePressed = value;
        }

        private function onMouseButton(value:Number):void
        {
            _mousePressed = value;
        }

        private function onMouseX(value:Number):void
        {
            _mouseMoved = true;
        }

        private function validateInputs(space:Number, mouseButton:Number, didMouseMove:Boolean):void
        {
            Assert.assertEquals("Space wasn't as expected.", _spacePressed, space);
            Assert.assertEquals("Mouse button wasn't as expected.", _mousePressed, mouseButton);
            Assert.assertEquals("Mouse wasn't moved as expected.", _mouseMoved, didMouseMove);
        }
    }
}