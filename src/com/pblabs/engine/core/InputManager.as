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
    
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import starling.events.Touch;
    import starling.events.TouchPhase;

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
    public class InputManager extends EventDispatcher implements ITickedObject
    {
		public var stageMouseX : Number = 0;
		public var stageMouseY : Number = 0;
		
        public function InputManager()
        {
            PBE.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            PBE.mainStage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp);
            PBE.mainClass.parent.addEventListener(MouseEvent.MOUSE_DOWN,  onMouseDown, true);
            PBE.mainClass.parent.addEventListener(MouseEvent.MOUSE_UP,    onMouseUp, true);
            PBE.mainClass.parent.addEventListener(MouseEvent.MOUSE_MOVE,  onMouseMove);
            PBE.mainClass.parent.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            PBE.mainClass.parent.addEventListener(MouseEvent.MOUSE_OVER,  onMouseOver);
            PBE.mainClass.parent.addEventListener(MouseEvent.MOUSE_OUT,   onMouseOut);
            
            // Add ourselves with the highest priority, so that our update happens at the beginning of the next tick.
            // This will keep objects processing afterwards as up-to-date as possible when using keyJustPressed() or keyJustReleased()
            PBE.processManager.addTickedObject( this, Number.MAX_VALUE );
        }
        
		private var _ignoreTimeScale : Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val:Boolean):void
		{
			_ignoreTimeScale = val;
		}

		/**
         * @inheritDoc
         */
        public function onTick(deltaTime:Number):void
        {
            // This function tracks which keys were just pressed (or released) within the last tick.
            // It should be called at the beginning of the tick to give the most accurate responses possible.
            
            var cnt:int;
            var len : int = _keyState.length;
            for (cnt = 0; cnt < len; cnt++)
            {
				var curKeyState : InputState = _keyState[cnt];
				
				var oldKeyIndex : int = findKeyStateIndex(curKeyState.keyCode, _keyStateOld);
				var oldKeyState : InputState = _keyStateOld[oldKeyIndex];
				
				if (curKeyState.value && !oldKeyState.value)
					findKeyState(curKeyState.keyCode, _justPressed).value = true;
                else
					findKeyState(curKeyState.keyCode, _justPressed).value = false;
                
                if (!curKeyState.value && oldKeyState.value)
					findKeyState(curKeyState.keyCode, _justReleased).value = true;
                else
					findKeyState(curKeyState.keyCode, _justReleased).value = false;
                
				oldKeyState.value = curKeyState.value;
            }
        }
        
        /**
         * Returns whether or not a key was pressed since the last tick.
         */
        public function keyJustPressed(keyCode:int):Boolean
        {
			return findKeyState(keyCode, _justPressed).value;
        }
        
        /**
         * Returns whether or not a key was released since the last tick.
         */
        public function keyJustReleased(keyCode:int):Boolean
        {
            return findKeyState(keyCode, _justReleased).value;
        }

        /**
         * Returns whether or not a specific key is down.
         */
        public function isKeyDown(keyCode:int):Boolean
        {
            return findKeyState(keyCode, _keyState).value;
        }
        
        /**
         * Returns true if any key is down.
         */
        public function isAnyKeyDown():Boolean
        {
			var len : int = _keyState.length;
			for(var i : int = 0; i < len; i++)
			{
				if(_keyState[i].value)
					return true;
			}
            return false;
        }

		/**
		 * Returns true if any touch events have been received. Can also check for a specific key code.
		 */
		public function isTouching(keyCode : int = -1):Boolean
		{
			var len : int = _keyState.length;
			for(var i : int = 1; i < 11; i++)
			{
				var inputState : InputState = findKeyState(InputKey["TOUCH_"+i].keyCode, _keyState);
				if(inputState.phase != TouchPhase.HOVER && inputState.value && (keyCode == -1 || (keyCode != -1 && inputState.keyCode == keyCode)))
				{
					return true;
				}
			}
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
			findKeyState(keyCode, _keyState).value = true;
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
			findKeyState(keyCode, _keyState).value = false;
        }

        /**
         * Simulates clicking the mouse button.
         */
        public function simulateMouseDown():void
        {
			onMouseDown(new MouseEvent(MouseEvent.MOUSE_DOWN));
        }

        /**
         * Simulates releasing the mouse button.
         */
        public function simulateMouseUp():void
        {
			onMouseUp(new MouseEvent(MouseEvent.MOUSE_UP));
        }

        /**
         * Simulates moving the mouse button. All this does is dispatch a mouse
         * move event since there is no way to change the current cursor position
         * of the mouse.
         */
        public function simulateMouseMove():void
        {
			onMouseMove(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, Math.random() * 100, Math.random () * 100));
        }

        public function simulateMouseOver():void
        {
			onMouseOver(new MouseEvent(MouseEvent.MOUSE_OVER));
        }

        public function simulateMouseOut():void
        {
			onMouseOut(new MouseEvent(MouseEvent.MOUSE_OUT));
        }

        public function simulateMouseWheel():void
        {
			onMouseWheel(new MouseEvent(MouseEvent.MOUSE_WHEEL));
        }

		/**
		 * Simulates clicking the mouse button.
		 */
		public function simulateTouch(touches : Vector.<Touch>):void
		{
			//Only supporting 10 touch inputs
			var len : int = touches.length > 10 ? 10 : touches.length;
			for(var i : int = 0; i < len; i++)
			{
				var touch : Touch = touches[i];
				var inputData : InputState;
				for(var x : int = 1; x < 11; x++)
				{
					var tmpInputData : InputState = findKeyState(InputKey["TOUCH_"+x].keyCode, _keyState);
					if(tmpInputData.id == touch.id){
						inputData = tmpInputData;
						tmpInputData = null;
						break;
					}
				}
				if(!inputData){
					inputData = findKeyState(InputKey["TOUCH_"+(i+1)].keyCode, _keyState);
				}
				
				if(inputData){
					if(touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.STATIONARY || touch.phase == TouchPhase.MOVED){
						if(i == 0 && touch.phase == TouchPhase.BEGAN)
							simulateMouseDown();
	
						inputData.value = true;
						inputData.stageX = touch.globalX;
						inputData.stageY = touch.globalY;

						if(touch.phase == TouchPhase.BEGAN){
							inputData.id = touch.id;					
						}
						
					}else if(touch.phase == TouchPhase.ENDED){// || touch.phase == TouchPhase.STATIONARY
						if(i == 0)
							simulateMouseUp();
						inputData.value = false;
					}
					inputData.touchCount = touch.tapCount;
					inputData.phase = touch.phase;
				}
				inputData = null;
				touch = null;
			}
		}
		
		public function getKeyData(keyCode : int):InputState
		{
			var len : int = _keyState.length;
			for(var i : int = 0; i < len; i++)
			{
				if(_keyState[i].keyCode == keyCode)
					return _keyState[i];
			}
			var keyState : InputState = InputState.getInstance(keyCode);
			_keyState.push( keyState );
			return keyState;
		}

		private function onKeyDown(event:KeyboardEvent):void
        {
			var state : InputState = findKeyState(event.keyCode, _keyState);
			state.value = true;
			if(state.preventDefaultBehaviour)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
			}
			dispatchEvent(event);
        }

        private function onKeyUp(event:KeyboardEvent):void
        {
			var state : InputState = findKeyState(event.keyCode, _keyState);
			state.value = false;
			if(state.preventDefaultBehaviour)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
			}
            dispatchEvent(event);
        }

        private function onMouseDown(event:MouseEvent):void
        {
			var keyData : InputState = findKeyState(InputKey.MOUSE_BUTTON.keyCode, _keyState);
			keyData.value = true;
			keyData.stageX = PBE.mainStage.mouseX;
			keyData.stageY = PBE.mainStage.mouseY;
			if(event.hasOwnProperty("clickCount"))
				keyData.touchCount = event.clickCount;
			if(keyData.preventDefaultBehaviour)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
			}
            dispatchEvent(event);
        }

        private function onMouseUp(event:MouseEvent):void
        {
			var keyData : InputState = findKeyState(InputKey.MOUSE_BUTTON.keyCode, _keyState);
			keyData.value = false;
			keyData.stageX = PBE.mainStage.mouseX;
			keyData.stageY = PBE.mainStage.mouseY;
			if(event.hasOwnProperty("clickCount"))
				keyData.touchCount = event.clickCount;
			if(keyData.preventDefaultBehaviour)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
			}
            dispatchEvent(event);
        }

        private function onMouseMove(event:MouseEvent):void
        {
            dispatchEvent(event);
			stageMouseX = event.stageX;
			stageMouseY = event.stageY;
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
		
		private function findKeyState(keyCode : int, stateMap : Vector.<InputState>):InputState
		{
			var len : int = stateMap.length;
			for(var i : int = 0; i < len; i++)
			{
				if(stateMap[i].keyCode == keyCode)
					return stateMap[i];
			}
			var inputState : InputState = InputState.getInstance(keyCode);
			stateMap.push( inputState );
			return inputState;
		}

		private function findKeyStateIndex(keyCode : int, stateMap : Vector.<InputState>):int
		{
			var len : int = stateMap.length;
			for(var i : int = 0; i < len; i++)
			{
				if(stateMap[i].keyCode == keyCode)
					return i;
			}
			stateMap.push( InputState.getInstance(keyCode) );
			return len;
		}

		private var _keyState:Vector.<InputState> = new Vector.<InputState>();     // The most recent information on key states
        private var _keyStateOld:Vector.<InputState> = new Vector.<InputState>();  // The state of the keys on the previous tick
        private var _justPressed:Vector.<InputState> = new Vector.<InputState>();  // An array of keys that were just pressed within the last tick.
        private var _justReleased:Vector.<InputState> = new Vector.<InputState>(); // An array of keys that were just released within the last tick.
    }
}

