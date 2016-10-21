/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.screens
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.core.IAnimatedObject;
    import com.pblabs.engine.core.ITickedObject;
    import com.pblabs.engine.core.ScreenEvent;
    import com.pblabs.engine.debug.Logger;
    
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

	/**
	 * @eventType com.pblabs.engine.core.ScreenEvent.SCREEN_SHOW
	 */
	[Event(name="SCREEN_SHOW", type="com.pblabs.engine.core.ScreenEvent")]
	
	/**
	 * @eventType com.pblabs.engine.core.ScreenEvent.SCREEN_HIDE
	 */
	[Event(name="SCREEN_HIDE", type="com.pblabs.engine.core.ScreenEvent")]

	/**
	 * @eventType com.pblabs.engine.core.ScreenEvent.SCREEN_REMOVE
	 */
	[Event(name="SCREEN_REMOVE", type="com.pblabs.engine.core.ScreenEvent")]

	/**
     * A simple system for managing a game's UI.
     * 
     * <p>The ScreenManager lets you have a set of named screens. The
     * goto(), push(), and pop() methods let you move from screen
     * to screen in an easy to follow way. A screen is just a DisplayObject
     * which implements IScreen; the included classes are all AS, but if you
     * entirely use Flex, you can use .mxml, too.</p>
     * 
     * <p>To use, first register screen instances by calling registerScreen.
     * Each screen has a unique name. That is what you pass to goto() and 
     * push().</p>
     * 
     * <p>The ScreenManager maintains a stack of screens. Only the topmost 
     * screen is added to the display list, for efficiency. If you want a
     * dialog or another element which only partially covers the screen,
     * you will probably want to use a different system.</p>
     */
    public class ScreenManager extends EventDispatcher implements IAnimatedObject, ITickedObject
    {
        static private var _instance:ScreenManager;
        static public function get instance():ScreenManager
        {
            if(!_instance)
                _instance = new ScreenManager();
            return _instance;
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

		public function ScreenManager()
        {
            PBE.processManager.addTickedObject(this);
            PBE.processManager.addAnimatedObject(this);
            
            screenParent = PBE.mainClass;
        }
        
        /**
         * Associate a named screen with the ScreenManager.
         */
        public function registerScreen(name:String, instance:IScreen):void
        {
            screenDictionary[name] = instance;
        }
        
        /**
         * Get a screen by name. 
         * @param name Name of the string to get.
         * @return Requested screen.
         */
        public function get(name:String):IScreen
        {
            return screenDictionary[name];
        }
        
        /**
         * Go to a named screen.
         */
        private function set currentScreen(value:String):void
        {
            if(_currentScreen && screenStack.indexOf(getScreenName(_currentScreen)) == -1)
            {
				dispatchEvent(new ScreenEvent(ScreenEvent.SCREEN_HIDE, false, false, getScreenName(_currentScreen)));
                _currentScreen.onHide();

                _currentScreen = null;
            }
            
            if(value && _currentScreen != screenDictionary[value])
            {
                _currentScreen = screenDictionary[value];
                if(!_currentScreen)
                    throw new Error("No such screen '" + value + "'");
				
				dispatchEvent(new ScreenEvent(ScreenEvent.SCREEN_SHOW, false, false, value));
                _currentScreen.onShow();
            }
        }
		
		private function getScreenName(screen : IScreen):String
		{
			for each(var screeName : String in screenDictionary)
			{
				if(screenDictionary[screeName] == screen)
					return screeName;
			}
			return null;
		}
        
        /**
         * @returns The screen currently being displayed, if any.
         */
        public function getCurrentScreen():IScreen
        {
            return _currentScreen;
        }
        
		/**
		 * @returns The screen name of the screen currently being displayed, if any.
		 */
		public function getCurrentScreenName():String
		{
			return screenStack && screenStack.length > 0 ? screenStack[screenStack.length - 1] : null;
		}

		/**
         * Return true if a screen of given name exists. 
         * @param screenName Name of screen.
         * @return True if screen exists.
         * 
         */
        public function hasScreen(screenName:String):Boolean
        {
            return get(screenName) != null;
        }
        
        /**
         * Switch to the specified screen, altering the top of the stack.
         * @param screenName Name of the screen to switch to.
         */
        public function moveto(screenName:String):void
        {
            pop();
            push(screenName);
        }
        
        /**
         * Switch to the specified screen, saving the current screen in the 
         * stack so you can pop() and return to it later.  
         * @param screenName Name of the screen to switch to.
         */
        public function push(screenName:String):void
        {
			var currentScreenPos : int = screenStack.indexOf(screenName);
			if(currentScreenPos > -1)
				PBUtil.splice(screenStack, currentScreenPos, 1);
            screenStack.push(screenName);

			var screenContext : * = get(screenName);
            screenParent.addChildAt(screenContext, screenParent.numChildren);
			currentScreen = screenName;
        }
        
        /**
         * Pop the top of the stack and change to the new top element. Useful
         * for returning to the previous screen when it push()ed to the
         * current one.
         */ 
        public function pop():void
        {
            if(screenStack.length == 0)
            {
                Logger.warn(this, "pop", "Trying to pop empty ScreenManager.");
                return;
            }
            
			var oldScreenName : String = screenStack.pop();
            var oldScreen:Object = get(oldScreenName);
			currentScreen = screenStack[screenStack.length - 1];
            
			dispatchEvent(new ScreenEvent(ScreenEvent.SCREEN_REMOVE, false, false, oldScreenName));
			if(oldScreen && oldScreen.hasOwnProperty("parent") && oldScreen.parent)
                oldScreen.parent.removeChild(oldScreen);
        }
        
        /**
         * @private
         */  
        public function onFrame(elapsed:Number):void
        {
            if(_currentScreen)
                _currentScreen.onFrame(elapsed);
        }
        
        /**
         * @private
         */  
        public function onTick(tickRate:Number):void
        {
            if(_currentScreen)
                _currentScreen.onTick(tickRate);
        }
        
        /**
         * @private
         */  
        public function onInterpolateTick(i:Number):void
        {            
        }
        
        /**
         * This is where the screens are added and removed. Normally it is
         * set to Global.mainClass, but you may want to override it for
         * special cases.
         */ 
        public var screenParent:Object = null;

        private var _currentScreen:IScreen = null;
        private var screenStack:Array = [null];
        private var screenDictionary:Dictionary = new Dictionary();
    }
}