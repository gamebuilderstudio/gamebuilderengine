package com.pblabs.rendering2D
{
   import flash.display.*;
   import flash.geom.*;
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.debug.*;
   
   public class SWFRenderComponent extends BaseRenderComponent
   {
      public var frameRate:Number = 25;
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
      
      public override function onDraw(manager:IDrawManager2D):void
      {
         if(!_clip)
            _clip = getClipInstance();
         
         // Position and draw.
         var screenPos:Point = manager.transformWorldToScreen(renderPosition);
         _matrix.tx = screenPos.x;
         _matrix.ty = screenPos.y;
         _clip.transform.matrix = _matrix;

         manager.drawDisplayObject(_clip);
         
         // If we're on the last frame, self-destruct.
         if(_clipFrame > _clip.totalFrames)
         {
            //Logger.print(this, "Finished playback, destroying self.");
            owner.destroy();
            return;
         }

         // Update to next frame when appropriate.
         if(ProcessManager.instance.virtualTime - _clipLastUpdate > 1000/frameRate)
         {
            _clipFrame++;
            _clip.gotoAndStop(_clipFrame);
            
            // Update child clips as well.
            updateChildClips(_clip);
            
            _clipLastUpdate = ProcessManager.instance.virtualTime;
         }
      }
      
      /**
       * Recursively advance a clip's children to the next frame.
       */
      protected function updateChildClips(parent:MovieClip):void
      {
         for (var j:int=0; j<parent.numChildren; j++)
         {
            var mc:MovieClip = parent.getChildAt(j) as MovieClip;
            if(!mc)
               continue;
            
            mc.nextFrame();
            updateChildClips(mc);
         }
      }
      
      private var _matrix:Matrix = new Matrix();
      private var _clip:MovieClip;
      private var _clipFrame:int;
      private var _clipLastUpdate:int;
   }
}