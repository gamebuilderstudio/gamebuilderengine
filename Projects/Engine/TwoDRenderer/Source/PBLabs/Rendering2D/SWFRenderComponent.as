package PBLabs.Rendering2D
{
   import flash.display.*;
   import flash.geom.*;
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Core.*;
   
   public class SWFRenderComponent extends BaseRenderComponent
   {
      public var FrameRate:Number = 25;

      /**
       * Subclasses must implement this method; it needs to return the embedded
       * SWF's class.
       */
      protected function _GetClipInstance():MovieClip
      {
         throw new Error("SWFRenderComponent must be subclassed and _GetClipInstance implemented to return a MovieClip from a SWF.");
      }
      
      public override function OnDraw(manager:IDrawManager2D):void
      {
         if(_Clip == null)
            _Clip = _GetClipInstance();
         
         // Position and draw.
         var m:Matrix = new Matrix();
         m.scale(RenderScale.x, RenderScale.y);
         m.translate(RenderPosition.x, RenderPosition.y);
         _Clip.transform.matrix = m;

         manager.DrawDisplayObject(_Clip);
         
         // If we're on the last frame, self-destruct.
         if(_ClipFrame > _Clip.totalFrames)
            Owner.Destroy();

         // Update to next frame when appropriate.
         if(ProcessManager.Instance.VirtualTime - _ClipLastUpdate > 1000/FrameRate)
         {
            _ClipFrame++;
            _Clip.gotoAndStop(_ClipFrame);
            
            // Update child clips as well.
            _UpdateChildClips(_Clip);
            
            _ClipLastUpdate = ProcessManager.Instance.VirtualTime;
         }
      }
      
      /**
       * Recursively advance a clip's children to the next frame.
       */
      protected function _UpdateChildClips(parent:MovieClip):void
      {
         for (var j:int=0; j<parent.numChildren; j++)
         {
            var mc:MovieClip = parent.getChildAt(j) as MovieClip;
            if(!mc)
               continue;
            
            mc.nextFrame();
            _UpdateChildClips(mc);
         }
      }
      
      private var _Clip:MovieClip;
      private var _ClipFrame:int;
      private var _ClipLastUpdate:int;
   }
}