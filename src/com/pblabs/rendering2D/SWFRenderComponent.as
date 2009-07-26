package com.pblabs.rendering2D
{
   import flash.display.*;
   import flash.geom.*;
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.debug.*;
   
   public class SWFRenderComponent extends BaseRenderComponent
   {
      public var FrameRate:Number = 25;
      public function set scaleFactor(value:Number):void
      {
         _Matrix = new Matrix();
         _Matrix.scale(value, value);
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
         if(!_Clip)
            _Clip = getClipInstance();
         
         // Position and draw.
         var screenPos:Point = manager.transformWorldToScreen(renderPosition);
         _Matrix.tx = screenPos.x;
         _Matrix.ty = screenPos.y;
         _Clip.transform.matrix = _Matrix;

         manager.drawDisplayObject(_Clip);
         
         // If we're on the last frame, self-destruct.
         if(_ClipFrame > _Clip.totalFrames)
         {
            //Logger.print(this, "Finished playback, destroying self.");
            owner.destroy();
            return;
         }

         // Update to next frame when appropriate.
         if(ProcessManager.instance.virtualTime - _ClipLastUpdate > 1000/FrameRate)
         {
            _ClipFrame++;
            _Clip.gotoAndStop(_ClipFrame);
            
            // Update child clips as well.
            updateChildClips(_Clip);
            
            _ClipLastUpdate = ProcessManager.instance.virtualTime;
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
      
      private var _Matrix:Matrix = new Matrix();
      private var _Clip:MovieClip;
      private var _ClipFrame:int;
      private var _ClipLastUpdate:int;
   }
}