package com.pblabs.screens
{
    import flash.display.Sprite;

    /**
     * Most basic implementation of IScreen. You will probably want to use a
     * subclass.
     */
	public class BaseScreen extends Sprite implements IScreen
	{
		public function onShow():void
		{
		}
		
		public function onHide():void
		{
		}
		
		public function onFrame(delta:Number):void
		{
		}
		
		public function onTick(delta:Number):void
		{
		}
	}
}