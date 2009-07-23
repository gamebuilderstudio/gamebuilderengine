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
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   import com.pblabs.engine.core.Global;
   
   /**
    * The input manager wraps the default input events produced by Flash to make
    * them more game friendly. For instance, by default, Flash will dispatch a
    * key down event when a key is pressed, and at a consistent interval while it
    * is still held down. For games, this is not very useful.
    * 
    * <p>The InputMap class contains several constants that represent the keyboard
    * and mouse. It can also be used to facilitate responding to specific key events
    * (OnSpacePressed) rather than generic key events (OnKeyDown).</p>
    * 
    * @see InputMap
    */
   public class InputManager extends EventDispatcher
   {
      /**
       * The singleton InputManager instance.
       */
      public static function get Instance():InputManager
      {
         if (_instance == null)
            _instance = new InputManager();
         
         return _instance;
      }

      public static function IsKeyDown(key:InputKey):Boolean
      {
         return Instance.IsKeyDown(key.KeyCode);
      }
      
      private static var _instance:InputManager = null;
      
      public function InputManager()
      {
         Global.MainStage.addEventListener(KeyboardEvent.KEY_DOWN, _OnKeyDown);
         Global.MainStage.addEventListener(KeyboardEvent.KEY_UP,   _OnKeyUp);
         Global.MainStage.addEventListener(MouseEvent.MOUSE_DOWN,  _OnMouseDown);
         Global.MainStage.addEventListener(MouseEvent.MOUSE_UP,    _OnMouseUp);
         Global.MainStage.addEventListener(MouseEvent.MOUSE_MOVE,  _OnMouseMove);
      }
      
      /**
       * Returns whether or not a specific key is down.
       */
      public function IsKeyDown(keyCode:int):Boolean
      {
         return _keyState[keyCode];
      }
      
      /**
       * Simulates a key press. The key will remain 'down' until SimulateKeyUp is called
       * with the same keyCode.
       * 
       * @param keyCode The key to simulate. This should be one of the constants defined in
       * InputMap
       * 
       * @see InputMap
       */
      public function SimulateKeyDown(keyCode:int):void
      {
         dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyCode));
      }
      
      /**
       * Simulates a key release.
       * 
       * @param keyCode The key to simulate. This should be one of the constants defined in
       * InputMap
       * 
       * @see InputMap
       */
      public function SimulateKeyUp(keyCode:int):void
      {
         dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyCode));
      }
      
      /**
       * Simulates clicking the mouse button.
       */
      public function SimulateMouseDown():void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
      }
      
      /**
       * Simulates releasing the mouse button.
       */
      public function SimulateMouseUp():void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
      }
      
      /**
       * Simulates moving the mouse button. All this does is dispatch a mouse
       * move event since there is no way to change the current cursor position
       * of the mouse.
       */
      public function SimulateMouseMove():void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
      }
      
      private function _OnKeyDown(event:KeyboardEvent):void
      {
         if (_keyState[event.keyCode])
            return;
         
         _keyState[event.keyCode] = true;
         dispatchEvent(event);
      }
      
      private function _OnKeyUp(event:KeyboardEvent):void
      {
         _keyState[event.keyCode] = false;
         dispatchEvent(event);
      }
      
      private function _OnMouseDown(event:MouseEvent):void
      {
         dispatchEvent(event);
      }
      
      private function _OnMouseUp(event:MouseEvent):void
      {
         dispatchEvent(event);
      }
      
      private function _OnMouseMove(event:MouseEvent):void
      {
         dispatchEvent(event);
      }
      
      private var _keyState:Array = new Array();
   }
}