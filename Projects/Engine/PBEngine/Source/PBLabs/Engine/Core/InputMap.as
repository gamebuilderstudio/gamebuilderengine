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
    * <p>Additionally, here are several contsants defined by this class that map a fairly
    * human readable name to the key code value used by Flash.</p>
    * 
    * @see InputManager
    * @see ../../../../../Reference/Input.html Input
    */
   public class InputMap implements ISerializable
   {
      public static const BACKSPACE:int = 8;
      public static const TAB:int = 9;
      public static const ENTER:int = 13;
      public static const SHIFT:int = 16;
      public static const CONTROL:int = 17;
      public static const PAUSE:int = 19;
      public static const CAPSLOCK:int = 20;
      public static const ESCAPE:int = 27;
      
      public static const SPACE:int = 32;
      public static const PAGEUP:int = 33;
      public static const PAGEDOWN:int = 34;
      public static const END:int = 35;
      public static const HOME:int = 36;
      public static const LEFT:int = 37;
      public static const UP:int = 38;
      public static const RIGHT:int = 39;
      public static const DOWN:int = 40;
      
      public static const INSERT:int = 45;
      public static const DELETE:int = 46;
      
      public static const ZERO:int = 48;
      public static const ONE:int = 49;
      public static const TWO:int = 50;
      public static const THREE:int = 51;
      public static const FOUR:int = 52;
      public static const FIVE:int = 53;
      public static const SIX:int = 54;
      public static const SEVEN:int = 55;
      public static const EIGHT:int = 56;
      public static const NINE:int = 57;

      public static const A:int = 65;
      public static const B:int = 66;
      public static const C:int = 67;
      public static const D:int = 68;
      public static const E:int = 69;
      public static const F:int = 70;
      public static const G:int = 71;
      public static const H:int = 72;
      public static const I:int = 73;
      public static const J:int = 74;
      public static const K:int = 75;
      public static const L:int = 76;
      public static const M:int = 77;
      public static const N:int = 78;
      public static const O:int = 79;
      public static const P:int = 80;
      public static const Q:int = 81;
      public static const R:int = 82;
      public static const S:int = 83;
      public static const T:int = 84;
      public static const U:int = 85;
      public static const V:int = 86;
      public static const W:int = 87;
      public static const X:int = 88;
      public static const Y:int = 89;
      public static const Z:int = 90;
      
      public static const NUM0:int = 96;
      public static const NUM1:int = 97;
      public static const NUM2:int = 98;
      public static const NUM3:int = 99;
      public static const NUM4:int = 100;
      public static const NUM5:int = 101;
      public static const NUM6:int = 102;
      public static const NUM7:int = 103;
      public static const NUM8:int = 104;
      public static const NUM9:int = 105;
      
      public static const MULTIPLY:int = 106;
      public static const ADD:int = 107;
      public static const SUBTRACT:int = 109;
      public static const DECIMAL:int = 110;
      public static const DIVIDE:int = 111;
      
      public static const F1:int = 112;
      public static const F2:int = 113;
      public static const F3:int = 114;
      public static const F4:int = 115;
      public static const F5:int = 116;
      public static const F6:int = 117;
      public static const F7:int = 118;
      public static const F8:int = 119;
      public static const F9:int = 120;
      // F10 is considered 'reserved' by Flash
      public static const F11:int = 122;
      public static const F12:int = 123;
      
      public static const NUMLOCK:int = 144;
      public static const SCROLLLOCK:int = 145;
      
      public static const COLON:int = 186;
      public static const PLUS:int = 187;
      public static const COMMA:int = 188;
      public static const MINUS:int = 189;
      public static const PERIOD:int = 190
      public static const BACKSLASH:int = 191;
      public static const TILDE:int = 192;
      
      public static const LEFT_BRACKET:int = 219;
      public static const SLASH:int = 220;
      public static const RIGHT_BRACKET:int = 221;
      public static const QUOTE:int = 222;
      
      public static const MOUSE_BUTTON:int = 253;
      public static const MOUSE_X:int = 254;
      public static const MOUSE_Y:int = 255;
      
      /**
       * Serializes the InputMap to a format containing just key value pairs with
       * the key representing the name of an input event and the value representing
       * the keyCode.
       * 
       * @inheritDoc
       */
      public function Serialize(xml:XML):void
      {
         for (var keyCode:String in _keymap)
            xml.appendChild(new XML("<" + _keymap[keyCode] + ">" + keyCode + "</" + _keymap[keyCode] +">"));
      }
      
      /**
       * Deserializes the InputMap from the format described in the Serialize method.
       * 
       * @see #Serialize()
       * 
       * @inheritDoc
       */
      public function Deserialize(xml:XML):void
      {
         for each (var keyXML:XML in xml.children())
            SetKeyMapping(keyXML.name(), parseInt(keyXML.toString()));
      }
      
      /**
       * Maps an input event registered with AddBinding to a specific key.
       * 
       * @param keyName The name of the binding to trigger when the key is pressed.
       * @param keyCode The key that will trigger the binding. This should be one
       * of the constants defined in this class.
       * 
       * @see #AddBinding()
       */
      public function SetKeyMapping(keyName:String, keyCode:int):void
      {
         if (_keymap[keyCode] == null)
         {
            if (keyCode == MOUSE_BUTTON)
            {
               InputManager.Instance.addEventListener(MouseEvent.MOUSE_DOWN, _OnMouseDown);
               InputManager.Instance.addEventListener(MouseEvent.MOUSE_UP, _OnMouseUp);
            }
            else if ((keyCode == MOUSE_X) && (_keymap[MOUSE_Y] == null))
            {
               InputManager.Instance.addEventListener(MouseEvent.MOUSE_MOVE, _OnMouseMove);
            }
            else if ((keyCode == MOUSE_Y) && (_keymap[MOUSE_X] == null))
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
         
         _keymap[keyCode] = keyName;
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
         _OnInputEvent(MOUSE_BUTTON, 1.0);
      }
      
      private function _OnMouseUp(event:MouseEvent):void
      {
         _OnInputEvent(MOUSE_BUTTON, 0.0);
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
            _OnInputEvent(MOUSE_X, event.stageX - _lastMouseX);
         
         if (event.stageY != _lastMouseY)
            _OnInputEvent(MOUSE_Y, event.stageY - _lastMouseY);
         
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