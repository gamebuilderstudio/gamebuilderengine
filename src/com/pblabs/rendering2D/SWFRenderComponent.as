package com.pblabs.rendering2D
{
    import com.pblabs.engine.core.ProcessManager;
    
    import flash.display.MovieClip;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    public class SWFRenderComponent extends BaseRenderComponent
    {
        public var frameRate:Number = 25;
        public var screenOffset:Point = new Point();
        public var loop:Boolean = false;

        protected var _matrix:Matrix = new Matrix();
        protected var _clip:MovieClip;
        protected var _clipFrame:int;
        protected var _clipLastUpdate:int;
        protected var _clipDirty:Boolean = true;
        protected var _maxFrames:int;
        
        public function set scaleFactor(value:Number):void
        {
            _matrix = new Matrix();
            _matrix.scale(value, value);
        }
        
        /**
         * Subclasses must implement this method; it needs to return the embedded
         * SWF's class.
         */
        protected function getClipInstance():MovieClip
        {
            throw new Error("SWFRenderComponent must be subclassed and getClipInstance implemented to return a MovieClip from a SWF.");
        }
        
        override public function onDraw(manager:IDrawManager2D):void
        {
            if(!owner)
                return;
            
            if(!_clip || _clipDirty)
            {
                _clip = getClipInstance();
                _clipFrame = 0;
                
                // Gracefully exit when the clip isn't available. It might still be loading.
                if (_clip)
                {
                    _maxFrames = findMaxFrames(_clip, _clip.totalFrames);
                    _clipDirty = false;
                }
                else
                {
                    return;
                }
            }
            
            // Position and draw.
            var screenPos:Point = manager.transformWorldToScreen(renderPosition);
            _matrix.tx = screenPos.x + screenOffset.x;
            _matrix.ty = screenPos.y + screenOffset.y;
            _clip.transform.matrix = _matrix;
            
            //trace("Drawing at " + screenPos.toString() + " with width=" + _Clip.width + ", height=" + _Clip.height);
            
            manager.drawDisplayObject(_clip);
            
            // Update to next frame when appropriate.
            if(ProcessManager.instance.virtualTime - _clipLastUpdate > 1000/frameRate)
            {
                // If we're on the last frame, loop or self-destruct.
                if(++_clipFrame > _maxFrames)
                {
                    if (loop) 
                    {
                        _clipFrame = 1;
                    }
                    else 
                    {
                        //Logger.Print(this, "Finished playback, destroying self.");
                        owner.destroy();
                        return;
                    }
                }
                
                if(_clip.totalFrames >= _clipFrame)
                    _clip.gotoAndStop(_clipFrame);
                
                // Update child clips as well.
                updateChildClips(_clip, _clipFrame);
                
                _clipLastUpdate = ProcessManager.instance.virtualTime;
            }
        }
        
        /**
         * Find the child clip with the largest number of frames. 
         * This will be used as our target for the end of the animation. 
         */
        protected function findMaxFrames(parent:MovieClip, currentMax:int):int
        {
            for (var j:int=0; j<parent.numChildren; j++)
            {
                var mc:MovieClip = parent.getChildAt(j) as MovieClip;
                if(!mc)
                    continue;
                
                currentMax = Math.max(currentMax, mc.totalFrames);            
                
                findMaxFrames(mc, currentMax);
            }
            
            return currentMax;
        }
        
        /**
         * Recursively advance a clip's children to the current frame.
         * This takes into account children with varying frame counts.
         */
        protected function updateChildClips(parent:MovieClip, currentFrame:int):void
        {
            for (var j:int=0; j<parent.numChildren; j++)
            {
                var mc:MovieClip = parent.getChildAt(j) as MovieClip;
                if(!mc)
                    continue;
                
                if (mc.totalFrames >= currentFrame)
                    mc.gotoAndStop(currentFrame);
                
                updateChildClips(mc, currentFrame);
            }
        }
        
        
    }
}