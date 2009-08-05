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
        public static function get instance():InputManager
        {
            if (!_instance)
                _instance = new InputManager();

            return _instance;
        }

        public static function isKeyDown(key:InputKey):Boolean
        {
            return instance.isKeyDown(key.keyCode);
        }

        private static var _instance:InputManager = null;

        public function InputManager()
        {
            Global.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            Global.mainStage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp);
            Global.mainStage.addEventListener(MouseEvent.MOUSE_DOWN,  onMouseDown);
            Global.mainStage.addEventListener(MouseEvent.MOUSE_UP,    onMouseUp);
            Global.mainStage.addEventListener(MouseEvent.MOUSE_MOVE,  onMouseMove);
            Global.mainStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            Global.mainStage.addEventListener(MouseEvent.MOUSE_OVER,  onMouseOver);
            Global.mainStage.addEventListener(MouseEvent.MOUSE_OUT,   onMouseOut);
        }

        /**
         * Returns whether or not a specific key is down.
         */
        public function isKeyDown(keyCode:int):Boolean
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
        public function simulateKeyDown(keyCode:int):void
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
        public function simulateKeyUp(keyCode:int):void
        {
            dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyCode));
        }

        /**
         * Simulates clicking the mouse button.
         */
        public function simulateMouseDown():void
        {
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
        }

        /**
         * Simulates releasing the mouse button.
         */
        public function simulateMouseUp():void
        {
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
        }

        /**
         * Simulates moving the mouse button. All this does is dispatch a mouse
         * move event since there is no way to change the current cursor position
         * of the mouse.
         */
        public function simulateMouseMove():void
        {
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
        }

        public function simulateMouseOver():void
        {
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
        }

        public function simulateMouseOut():void
        {
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
        }

        public function simulateMouseWheel():void
        {
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL));
        }

        private function onKeyDown(event:KeyboardEvent):void
        {
            if (_keyState[event.keyCode])
                return;

            _keyState[event.keyCode] = true;
            dispatchEvent(event);
        }

        private function onKeyUp(event:KeyboardEvent):void
        {
            _keyState[event.keyCode] = false;
            dispatchEvent(event);
        }

        private function onMouseDown(event:MouseEvent):void
        {
            dispatchEvent(event);
        }

        private function onMouseUp(event:MouseEvent):void
        {
            dispatchEvent(event);
        }

        private function onMouseMove(event:MouseEvent):void
        {
            dispatchEvent(event);
        }

        private function onMouseOver(event:MouseEvent):void
        {
            dispatchEvent(event);
        }

        private function onMouseOut(event:MouseEvent):void
        {
            dispatchEvent(event);
        }

        private function onMouseWheel(event:MouseEvent):void
        {
            dispatchEvent(event);
        }

        private var _keyState:Array = new Array();
    }
}

