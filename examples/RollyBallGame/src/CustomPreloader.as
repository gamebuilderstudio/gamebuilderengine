package
{
    import flash.display.*;
    import flash.events.*;
    
    import mx.controls.*;
    import mx.core.*;
    import mx.events.FlexEvent;
    import mx.preloaders.DownloadProgressBar;
 
    public class CustomPreloader extends DownloadProgressBar
    {
        [Embed(source="../assets/Preloader.swf")]
        private var FlashPreloader:Class;
        	
        public var wcs:MovieClip;
 
        private var _SetFrameListener:Boolean = false;
        private var _StopAtFrame:int = 20;
        private var _EndFrame:int = 195;
        private var _TransitionToMainMenu:Boolean = false, _FiredCompleteEvent:Boolean = false;
 
        public function SetFrameTarget(f:int):void
        {
        	var l:Loader = wcs.getChildAt(0) as Loader;
        	if(!l) return;
        	var mc:MovieClip = l.content as MovieClip;
        	if(!mc) return;
        	
        	if(!_SetFrameListener)
        	{
        		mc.addEventListener(Event.ENTER_FRAME, handleFrame, false, 0, true);
        		_SetFrameListener = true;
        	}
        	
        	if(mc.currentFrame < f)
        	   mc.play();
        	
        	_StopAtFrame = f;
        }
 
        public function CustomPreloader():void
        {
            wcs = new FlashPreloader();
            addChild(wcs);
            SetFrameTarget(20);
        }
 
        public override function set preloader(preloader:Sprite):void
        {
            preloader.addEventListener(ProgressEvent.PROGRESS, onSWFDownloadProgress);
            preloader.addEventListener(Event.COMPLETE, onSWFDownloadComplete);
            preloader.addEventListener(FlexEvent.INIT_PROGRESS, onFlexInitProgress);
            preloader.addEventListener(FlexEvent.INIT_COMPLETE, onFlexInitComplete);
 
            centerPreloader();
        }
 
        private function centerPreloader():void
        {
            x = (stageWidth / 2) - (wcs.width / 2);
            y = (stageHeight / 2) - (wcs.height / 2);
        }
 
        private function onSWFDownloadProgress(event:ProgressEvent):void
        {
            var t:Number = event.bytesTotal;
            var l:Number = event.bytesLoaded;
            var p:Number = Math.round((l/t) * 100) + 20;
            SetFrameTarget(p);
        }
 
        private function onSWFDownloadComplete(event:Event):void
        {
            //wcs.status.text = "DONE";
        }
 
        private function onFlexInitProgress(event:FlexEvent):void
        {
            //wcs.status.text = "Initializing...";
        }
 
        private function onFlexInitComplete(event:FlexEvent):void
        {
            //wcs.status.text = "Flex IS GO! PBEngine is great!";
            
            SetFrameTarget(_EndFrame);
        }
        
        private function handleFrame(e:Event):void
        {
        	var mc:MovieClip = e.target as MovieClip;
        	
        	if(mc.currentFrame >= _StopAtFrame)
        	{
        		mc.stop();
        	}
        	        	
        	if(mc.currentFrame == _EndFrame && !_TransitionToMainMenu)
        	{
        	   mc.stop();
        	   
        	   // Unload the preloader clip.
        	   (wcs.getChildAt(0) as Loader).unload();
        	   wcs.removeChildAt(0);
        	   wcs.parent.removeChild(wcs);
        	           	   
            // Kick over to the main menu, old school.
    	      _TransitionToMainMenu = true;
            dispatchEvent( new Event(Event.COMPLETE));
        	}  
        }
    }
}