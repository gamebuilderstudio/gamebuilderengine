package PBLabs.Engine.Core
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   import mx.core.Application;
   
   /**
    * The input manager wraps the default input events produced by flash to make
    * them more game friendly. For instance, by default, flash will dispatch a
    * key down event when a key is pressed, and at a consistent interval while it
    * is still held down. For games, this is not very useful.
    * 
    * <p>The InputMap class contains several constants that represent the keyboard
    * and mouse. It can also be used to facilitate responding to specific key events
    * (OnSpacePressed) rather than generic key events (OnKeyDown).</p>
    * 
    * @see InputMap
    * @see ../../../../../Reference/Input.html Input
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
      
      private static var _instance:InputManager = null;
      
      public function InputManager()
      {
         if (Application.application.stage != null)
            _SetupEvents();
         else
            Application.application.addEventListener(Event.ADDED_TO_STAGE, _SetupEvents);
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
      
      private function _SetupEvents(event:Event = null):void
      {
         Application.application.stage.addEventListener(KeyboardEvent.KEY_DOWN, _OnKeyDown);
         Application.application.stage.addEventListener(KeyboardEvent.KEY_UP, _OnKeyUp);
         Application.application.stage.addEventListener(MouseEvent.MOUSE_DOWN, _OnMouseDown);
         Application.application.stage.addEventListener(MouseEvent.MOUSE_UP, _OnMouseUp);
         Application.application.stage.addEventListener(MouseEvent.MOUSE_MOVE, _OnMouseMove);
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