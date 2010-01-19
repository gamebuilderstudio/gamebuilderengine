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

    import com.pblabs.engine.PBE;

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
        public function InputManager()
        {
            PBE.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            PBE.mainStage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp);
            PBE.mainStage.addEventListener(MouseEvent.MOUSE_DOWN,  onMouseDown);
            PBE.mainStage.addEventListener(MouseEvent.MOUSE_UP,    onMouseUp);
            PBE.mainStage.addEventListener(MouseEvent.MOUSE_MOVE,  onMouseMove);
            PBE.mainStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            PBE.mainStage.addEventListener(MouseEvent.MOUSE_OVER,  onMouseOver);
            PBE.mainStage.addEventListener(MouseEvent.MOUSE_OUT,   onMouseOut);
        }

        /**
         * Returns whether or not a specific key is down.
         */
        public function isKeyDown(keyCode:int):Boolean
        {
            return _keyState[keyCode];
        }
        
        /**
         * Returns true if any key is down.
         */
        public function isAnyKeyDown():Boolean
        {
            for each(var b:Boolean in _keyState)
                if(b)
                    return true;
            return false;
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
            _keyState[keyCode] = true;
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
            _keyState[keyCode] = false;
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
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, Math.random() * 100, Math.random () * 100));
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

