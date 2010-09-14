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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.serialization.ISerializable;
    
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;

    [EditorData(editAs="flash.utils.Dictionary", typeHint="com.pblabs.engine.core.InputKey")]

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
         * serializes the InputMap to a format containing just key value pairs with
         * the key representing the name of an input event and the value representing
         * the name of the key from the InputKey class.
         *
         * @inheritDoc
         */
        public function serialize(xml:XML):void
        {
            for (var keyCode:String in _keymap)
                xml.appendChild(new XML("<" + _keymap[keyCode] + ">" + InputKey.codeToString(parseInt(keyCode)) + "</" + _keymap[keyCode] +">"));
        }

        /**
         * deserializes the InputMap from the format described in the serialize method.
         *
         * @see #serialize()
         *
         * @inheritDoc
         */
        public function deserialize(xml:XML):*
        {
            for each (var keyXML:XML in xml.children())
                mapKeyToAction(InputKey.stringToKey(keyXML.toString()), keyXML.name());

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
        public function mapKeyToAction(key:InputKey, actionName:String):void
        {
            if(!key)
                throw new Error("Got a null key in mapKeyToAction; you probably have a typo in a key name.");

            if (_keymap[key.keyCode] == null)
            {
                if (key == InputKey.MOUSE_BUTTON)
                {
                    PBE.inputManager.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
                    PBE.inputManager.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
                }
                else if ((key == InputKey.MOUSE_X) && !(_keymap[InputKey.MOUSE_Y]))
                {
                    PBE.inputManager.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                }
                else if ((key == InputKey.MOUSE_Y) && !(_keymap[InputKey.MOUSE_X]))
                {
                    PBE.inputManager.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                }
                else if (key == InputKey.MOUSE_WHEEL)
                {
                    PBE.inputManager.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
                }
                else if (key == InputKey.MOUSE_HOVER)
                {
                    PBE.inputManager.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
                    PBE.inputManager.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);            	
                }
                else if (!_registeredForKeyEvents)
                {
                    PBE.inputManager.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                    PBE.inputManager.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
                    _registeredForKeyEvents = true;
                }
            }

            _keymap[key.keyCode] = actionName;
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
        public function mapActionToHandler(actionName:String, handler:Function):void
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
        public function mapKeyToHandler(key:InputKey, handler:Function):void
        {
            // Use the key name as an intermediate unique action name
            var action:String = InputKey.codeToString(key.keyCode); 

            mapKeyToAction(key, action);
            mapActionToHandler(action, handler);
        }      


        public function destroy():void
        {
            PBE.inputManager.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            PBE.inputManager.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            PBE.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            PBE.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            PBE.inputManager.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            PBE.inputManager.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

        private function onKeyDown(event:KeyboardEvent):void
        {
            onInputEvent(event.keyCode, 1.0);
        }

        private function onKeyUp(event:KeyboardEvent):void
        {
            onInputEvent(event.keyCode, 0.0);
        }

        private function onMouseDown(event:MouseEvent):void
        {
            onInputEvent(InputKey.MOUSE_BUTTON.keyCode, 1.0);
        }

        private function onMouseUp(event:MouseEvent):void
        {
            onInputEvent(InputKey.MOUSE_BUTTON.keyCode, 0.0);
        }

        private function onMouseMove(event:MouseEvent):void
        {
            // The mouse position on the mainStage is used instead of the event's stageX/stageY.
            // stageX/stageY get reset to 0 on the event dispatch from the InputManager.
            if (_lastMouseX == Number.NEGATIVE_INFINITY)
            {
                _lastMouseX = PBE.mainClass.parent.mouseX;
                _lastMouseY = PBE.mainClass.parent.mouseY;
                _suppressDeltaNextTime = true;
                return;
            }

            if (event.stageX != _lastMouseX || _suppressDeltaNextTime)
                onInputEvent(InputKey.MOUSE_X.keyCode, _suppressDeltaNextTime ? 0 : PBE.mainClass.parent.mouseX - _lastMouseX);

            if (event.stageY != _lastMouseY || _suppressDeltaNextTime)
                onInputEvent(InputKey.MOUSE_Y.keyCode, _suppressDeltaNextTime ? 0 : PBE.mainClass.parent.mouseY - _lastMouseY);

            _lastMouseX = event.stageX;
            _lastMouseY = event.stageY;
            _suppressDeltaNextTime = false;
        }

        private function onMouseOver(event:MouseEvent):void
        {
            onInputEvent(InputKey.MOUSE_HOVER.keyCode, 1.0);
        }

        private function onMouseOut(event:MouseEvent):void
        {
            onInputEvent(InputKey.MOUSE_HOVER.keyCode, 0.0);
        }

        private function onMouseWheel(event:MouseEvent):void
        {
            onInputEvent(InputKey.MOUSE_WHEEL.keyCode, event.delta);
        }

        private function onInputEvent(keyCode:int, value:Number):void
        {
            var action:String = _keymap[keyCode];
            if (action == null)
                return;

            var callback:Function = _bindings[action];
            if (callback == null)
            {
                Logger.print(this, "Got an action for '" + action + "' but no registered callback; ignoring."); 
                return;
            }

            callback(value);
        }

        private var _lastMouseX:Number = Number.NEGATIVE_INFINITY;
        private var _lastMouseY:Number = Number.NEGATIVE_INFINITY;
        private var _suppressDeltaNextTime:Boolean = false;
        
        /** _keymap links an key input or mouse input to an action name */
        private var _keymap:Dictionary = new Dictionary();
        /** _bindings links an action name to a function callback */
        private var _bindings:Dictionary = new Dictionary();
        private var _registeredForKeyEvents:Boolean = false;
    }
}

