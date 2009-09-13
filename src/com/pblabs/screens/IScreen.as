package com.pblabs.screens
{
    /**
     * Interface for a screen which can be managed by the ScreenManager.
     * 
     * <p>Because we may wish to use DisplayObject subclasses for which we cannot
     * control the inheritance hierarchy, the ScreenManager requires that screens
     * be both a DisplayObject and also that they inherit IScreen. BaseScreen is
     * a simple (and usually sufficient) example of this.</p>
     */ 
    public interface IScreen
    {
        /**
         * Called when the screen becomes visible.
         * 
         * <p>Note that the ScreenManager is responsible for adding/removing
         * the screen from the display list, but you may wish to turn things
         * on or off as a result.</p>
         */ 
        function onShow():void;

        /**
         * Called when the screen is no longer visible.
         * 
         * <p>Note that the ScreenManager is responsible for adding/removing
         * the screen from the display list, but you may wish to turn things
         * on or off as a result.</p>
         */ 
        function onHide():void;
        
        /**
         * While the screen is visible, this is called every frame to allow
         * it to easily update itself.
         */
        function onFrame(delta:Number):void;
        
        /**
         * While the screen is visible, this is called every tick to allow
         * it to update based on per-tick activities like gameplay.
         */
        function onTick(delta:Number):void;
    }
}