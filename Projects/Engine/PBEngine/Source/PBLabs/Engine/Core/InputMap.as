/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Core
{
   import PBLabs.Engine.Serialization.ISerializable;
   
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   /**
    * This class wraps the InputManager to allow for better control over
    * input events. It also provides a mechanism for creating custom
    * keybindings and serializing those bindings.
    * 
    * <p>The way this is accomplished is by abstracting input events by giving
    * them names, and then mapping those names to specific keys. So, registering
    * a method to be called when a key is pressed is done by registering that
    * method with the name representing the event, then registering the specific
    * key with the name.</p>
    * 
    * @see InputKey
    * @see InputManager
    * @see ../../../../../Reference/Input.html Input
    */
   public class InputMap implements ISerializable
   {
      /**
       * Serializes the InputMap to a format containing just key value pairs with
       * the key representing the name of an input event and the value representing
       * the name of the key from the InputKey class.
       * 
       * @inheritDoc
       */
      public function Serialize(xml:XML):void
      {
         for (var keyCode:String in _keymap)
            xml.appendChild(new XML("<" + _keymap[keyCode] + ">" + InputKey.CodeToString(parseInt(keyCode)) + "</" + _keymap[keyCode] +">"));
      }
      
      /**
       * Deserializes the InputMap from the format described in the Serialize method.
       * 
       * @see #Serialize()
       * 
       * @inheritDoc
       */
      public function Deserialize(xml:XML):*
      {
         for each (var keyXML:XML in xml.children())
            SetKeyMapping(keyXML.name(), InputKey.StringToKey(keyXML.toString()));
         
         return this;
      }
      
      /**
       * Maps an input event registered with AddBinding to a specific key.
       * 
       * @param keyName The name of the binding to trigger when the key is pressed.
       * @param key The key that will trigger the binding. This should be one
       * of the constants defined in the InputKey class.
       * 
       * @see #AddBinding()
       */
      public function SetKeyMapping(keyName:String, key:InputKey):void
      {
         if (_keymap[key.KeyCode] == null)
         {
            if (key == InputKey.MOUSE_BUTTON)
            {
               InputManager.Instance.addEventListener(MouseEvent.MOUSE_DOWN, _OnMouseDown);
               InputManager.Instance.addEventListener(MouseEvent.MOUSE_UP, _OnMouseUp);
            }
            else if ((key == InputKey.MOUSE_X) && (_keymap[InputKey.MOUSE_Y] == null))
            {
               InputManager.Instance.addEventListener(MouseEvent.MOUSE_MOVE, _OnMouseMove);
            }
            else if ((key == InputKey.MOUSE_Y) && (_keymap[InputKey.MOUSE_X] == null))
            {
               InputManager.Instance.addEventListener(MouseEvent.MOUSE_MOVE, _OnMouseMove);
            }
            else if (!_registeredForKeyEvents)
            {
               InputManager.Instance.addEventListener(KeyboardEvent.KEY_DOWN, _OnKeyDown);
               InputManager.Instance.addEventListener(KeyboardEvent.KEY_UP, _OnKeyUp);
               _registeredForKeyEvents = true;
            }
         }
         
         _keymap[key.KeyCode] = keyName;
      }
      
      /**
       * Binds a function to an input event. When the specified input event is
       * triggered, the function will be called. If it is a press event, the function
       * will be passed 1 as its only parameter. If it is a release event, the
       * function will be passed 0 as its only parameter. If it is an analog event
       * then the analog value will be passed. In the case of mouse movement (currently
       * the only analog event) the value will be the amount the mouse moved on the
       * specific axis.
       * 
       * @param keyName The name to give this binding.
       * @param callback The function to call when the input event defined by keyName
       * is triggered.
       */
      public function AddBinding(keyName:String, callback:Function):void
      {
         _bindings[keyName] = callback;
      }
      
      private function _OnKeyDown(event:KeyboardEvent):void
      {
         _OnInputEvent(event.keyCode, 1.0);
      }
      
      private function _OnKeyUp(event:KeyboardEvent):void
      {
         _OnInputEvent(event.keyCode, 0.0);
      }
      
      private function _OnMouseDown(event:MouseEvent):void
      {
         _OnInputEvent(InputKey.MOUSE_BUTTON.KeyCode, 1.0);
      }
      
      private function _OnMouseUp(event:MouseEvent):void
      {
         _OnInputEvent(InputKey.MOUSE_BUTTON.KeyCode, 0.0);
      }
      
      private function _OnMouseMove(event:MouseEvent):void
      {
         if (_lastMouseX == Number.NEGATIVE_INFINITY)
         {
            _lastMouseX = event.stageX;
            _lastMouseY = event.stageY;
            return;
         }
         
         if (event.stageX != _lastMouseX)
            _OnInputEvent(InputKey.MOUSE_X.KeyCode, event.stageX - _lastMouseX);
         
         if (event.stageY != _lastMouseY)
            _OnInputEvent(InputKey.MOUSE_Y.KeyCode, event.stageY - _lastMouseY);
         
         _lastMouseX = event.stageX;
         _lastMouseY = event.stageY;
      }
      
      private function _OnInputEvent(keyCode:int, value:Number):void
      {
         var key:String = _keymap[keyCode];
         if (key == null)
            return;
         
         var callback:Function = _bindings[key];
         if (callback == null)
            return;
         
         callback(value);
      }
      
      private var _lastMouseX:Number = Number.NEGATIVE_INFINITY;
      private var _lastMouseY:Number = Number.NEGATIVE_INFINITY;
      private var _keymap:Dictionary = new Dictionary();
      private var _bindings:Dictionary = new Dictionary();
      private var _registeredForKeyEvents:Boolean = false;
   }
}