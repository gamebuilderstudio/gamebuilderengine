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
   import com.pblabs.engine.core.InputKey;
   import com.pblabs.engine.core.InputManager;
   import com.pblabs.engine.core.InputMap;
   
   import net.digitalprimates.fluint.tests.TestCase;

   /**
    * @private
    */
   public class InputTests extends TestCase
   {
      public function testInputMap():void
      {
         var inputMap:InputMap = new InputMap();
         inputMap.mapKeyToAction(InputKey.SPACE, "Space");
         inputMap.mapKeyToAction(InputKey.MOUSE_BUTTON, "MouseButton");
         inputMap.mapKeyToAction(InputKey.MOUSE_X, "MouseX");
         
         inputMap.mapActionToHandler("Space", onSpace);
         inputMap.mapActionToHandler("MouseButton", onMouseButton);
         inputMap.mapActionToHandler("MouseX", onMouseX);
         
         InputManager.instance.simulateKeyDown(InputKey.SPACE.keyCode);
         validateInputs(1, 0, false);
         InputManager.instance.simulateKeyUp(InputKey.SPACE.keyCode);
         validateInputs(0, 0, false);
         
         InputManager.instance.simulateMouseDown();
         InputManager.instance.simulateMouseMove();
         InputManager.instance.simulateMouseMove();
         validateInputs(0, 1, true);
         InputManager.instance.simulateMouseUp();
         validateInputs(0, 0, true);
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
      
      private function validateInputs(space:Number, mouseButton:Number, mouseX:Boolean):void
      {
         assertEquals(_spacePressed, space);
         assertEquals(_mousePressed, mouseButton);
         assertEquals(_mouseMoved, mouseX);
      }
      
      private var _spacePressed:Number = 0.0;
      private var _mousePressed:Number = 0.0;
      private var _mouseMoved:Boolean = false;
   }
}