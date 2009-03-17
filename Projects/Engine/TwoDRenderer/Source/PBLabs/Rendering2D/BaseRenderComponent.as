package PBLabs.Rendering2D
{
   import PBLabs.Engine.Entity.*;
   
   import flash.geom.Point;

   /**
    * Base implementation for a 2d renderable component. This contains some
    * convenient helper logic in order to simplify implementing your own renderable
    * component.
    */ 
   public class BaseRenderComponent extends EntityComponent implements IDrawable2D
   {
      public var PositionReference:PropertyReference;
      public var PositionOffset:Point = null;
      public var IsTracked:Boolean = false;
      
      public function get RenderSortKey():int
      {
         return _RenderSortKey;
      }
      
      public function set RenderSortKey(v:int):void
      {
         _RenderSortKey = v;
      }

      public function get LayerIndex():int
      {
         return _LayerIndex;
      }
      
      public function set LayerIndex(v:int):void
      {
         _LayerIndex = v;
      }

      public function get RenderPosition():Point
      {
         var res:Point = Owner.GetProperty(PositionReference);
         
         if(!res)
            return new Point(0,0);
         
         if(PositionOffset)
            return res.add(PositionOffset);
         else
            return res;
      }
      
      public function OnDraw(manager:IDrawManager2D):void
      {
      }
      
      private var _LayerIndex:int, _RenderSortKey:int;
   }
}