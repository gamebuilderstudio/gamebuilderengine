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
   import PBLabs.Engine.Core.*;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class InputTests extends TestCase
   {
      public function testInputMap():void
      {
         var inputMap:InputMap = new InputMap();
         inputMap.MapKeyToAction(InputKey.SPACE, "Space");
         inputMap.MapKeyToAction(InputKey.MOUSE_BUTTON, "MouseButton");
         inputMap.MapKeyToAction(InputKey.MOUSE_X, "MouseX");
         
         inputMap.MapActionToHandler("Space", _OnSpace);
         inputMap.MapActionToHandler("MouseButton", _OnMouseButton);
         inputMap.MapActionToHandler("MouseX", _OnMouseX);
         
         InputManager.Instance.SimulateKeyDown(InputKey.SPACE.KeyCode);
         _ValidateInputs(1, 0, false);
         InputManager.Instance.SimulateKeyUp(InputKey.SPACE.KeyCode);
         _ValidateInputs(0, 0, false);
         
         InputManager.Instance.SimulateMouseDown();
         InputManager.Instance.SimulateMouseMove();
         InputManager.Instance.SimulateMouseMove();
         _ValidateInputs(0, 1, true);
         InputManager.Instance.SimulateMouseUp();
         _ValidateInputs(0, 0, true);
      }
      
      private function _OnSpace(value:Number):void
      {
         _spacePressed = value;
      }
      
      private function _OnMouseButton(value:Number):void
      {
         _mousePressed = value;
      }
      
      private function _OnMouseX(value:Number):void
      {
         _mouseMoved = true;
      }
      
      private function _ValidateInputs(space:Number, mouseButton:Number, mouseX:Boolean):void
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