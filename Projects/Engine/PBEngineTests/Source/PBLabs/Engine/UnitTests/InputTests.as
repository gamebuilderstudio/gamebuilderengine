package PBLabs.Engine.UnitTests
{
   import PBLabs.Engine.Core.InputManager;
   import PBLabs.Engine.Core.InputMap;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class InputTests extends TestCase
   {
      public function testInputMap():void
      {
         var inputMap:InputMap = new InputMap();
         inputMap.SetKeyMapping("Space", InputMap.SPACE);
         inputMap.SetKeyMapping("MouseButton", InputMap.MOUSE_BUTTON);
         inputMap.SetKeyMapping("MouseX", InputMap.MOUSE_X);
         
         inputMap.AddBinding("Space", _OnSpace);
         inputMap.AddBinding("MouseButton", _OnMouseButton);
         inputMap.AddBinding("MouseX", _OnMouseX);
         
         InputManager.Instance.SimulateKeyDown(InputMap.SPACE);
         _ValidateInputs(1, 0, false);
         InputManager.Instance.SimulateKeyUp(InputMap.SPACE);
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