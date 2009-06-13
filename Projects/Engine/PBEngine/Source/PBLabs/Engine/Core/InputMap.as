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
   
   [EditorData(editAs="flash.utils.Dictionary", typeHint="PBLabs.Engine.Core.InputKey")]
   
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
            MapKeyToHandler(InputKey.StringToKey(keyXML.toString()), keyXML.name());
         
         return this;
      }
      
      /**
       * Maps a specific key to an input action (registered with MapActionToHandler).
       * 
       * Note: If you are just binding a specific key directly to a specific handler
       *  function (with no special key remapping options), then using 
       *  MapKeyToHandler() will save you a step. Use the MapKeyToAction() and
       *  MapActionToHandler() pair if you want the flexibility of an abstracted 
       *  re-usable component or easier key re-binding.
       *
       * @param key The key that will trigger the action. This should be one
       * of the constants defined in the InputKey class.
       * @param actionName The name of the action to trigger when the key is pressed.
       * 
       * @see #MapActionToHandler()
       * @see #MapKeyToHandler()
       */
      public function MapKeyToAction(key:InputKey, actionName:String):void
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
         
         _keymap[key.KeyCode] = actionName;
      }
      
      /**
       * Binds an input action to a handler callback. When the specified input action
       * is triggered, the handler function will be called. If it is a press event, the 
       * function will be passed 1 as its only parameter. If it is a release event, the
       * function will be passed 0 as its only parameter. If it is an analog event
       * then the analog value will be passed. In the case of mouse movement (currently
       * the only analog event) the value will be the amount the mouse moved on the
       * specific axis.
       *
       * Input actions are mapped to specific key or mouse inputs in SetKeyMapping().
       *
       * Note: If you are just binding a specific key directly to a specific handler
       *  function (with no special key remapping options), then using 
       *  MapKeyToHandler() will save you a step. Use the MapKeyToAction() and
       *  MapActionToHandler() pair if you want the flexibility of an abstracted 
       *  re-usable component or easier key re-binding.
       * 
       * @param actionName The name to give this binding.
       * @param handler The function to call when the input event defined by actionName
       * is triggered.
       *
       * @see #MapKeyToAction()
       * @see #MapKeyToHandler()
       */
      public function MapActionToHandler(actionName:String, handler:Function):void
      {
         _bindings[actionName] = handler;
      }
      
      /**
       * Maps a specific key to a handler callback. When the specified key or mouse 
       * input is triggered, the handler function will be called. If it is a press 
       * event, the function will be passed 1 as its only parameter. If it is a 
       * release event, the function will be passed 0 as its only parameter. If it 
       * is an analog event then the analog value will be passed. In the case of 
       * mouse movement (currently the only analog event) the value will be the 
       * amount the mouse moved on the specific axis.
       *
       * Note: If you need special key remapping options, or are building an
       *  abstracted re-usable component, you may want the flexibilty offered by 
       *  using MapKeyToAction() and MapKeyToHandler(), as this lets you separate 
       *  specific keys from specific callbacks, as they can be bound later in game
       *  configuration files (such as .pbelevel files). 
       *
       * @param key The key that will trigger the handler. This should be one
       * of the constants defined in the InputKey class.
       * @param handler The function to call when the input event is triggered.
       * 
       * @see #MapActionToHandler()
       * @see #MapKeyToHandler()
       */
      public function MapKeyToHandler(key:InputKey, handler:Function):void
      {
         // Use the key name as an intermediate unique action name
         var action:String = InputKey.CodeToString(key.KeyCode); 
         
         MapKeyToAction(key, action);
         MapActionToHandler(action, handler);
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
         var action:String = _keymap[keyCode];
         if (action == null)
            return;
         
         var callback:Function = _bindings[action];
         if (callback == null)
            return;
         
         callback(value);
      }
      
      private var _lastMouseX:Number = Number.NEGATIVE_INFINITY;
      private var _lastMouseY:Number = Number.NEGATIVE_INFINITY;
      /** _keymap links an key input or mouse input to an action name */
      private var _keymap:Dictionary = new Dictionary();
      /** _bindings links an action name to a function callback */
      private var _bindings:Dictionary = new Dictionary();
      private var _registeredForKeyEvents:Boolean = false;
   }
}