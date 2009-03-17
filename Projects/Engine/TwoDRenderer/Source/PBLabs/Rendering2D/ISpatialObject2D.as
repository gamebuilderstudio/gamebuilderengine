package PBLabs.Rendering2D
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import PBLabs.Engine.Core.ObjectType;
   
   /**
    * Object with extents and ability to be ray-casted.
    * 
    * This is the basic interface for objects that support 2D spatial queries.
    * It is enough to do broad phase collision checks and ray casts.
    */ 
   public interface ISpatialObject2D
   {
      /**
       * Axis aligned object bounds in world space.
       */ 
      function get WorldExtents():Rectangle;
      
      /**
       * This object's collision flags.
       */ 
      function get QueryMask():ObjectType;
      
      /**
       * Perform a ray cast against this object.
       */ 
      function CastRay(start:Point, end:Point, info:RayHitInfo):Boolean;
   }
   
}