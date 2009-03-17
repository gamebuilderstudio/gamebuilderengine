package PBLabs.Box2D
{
   import Box2D.Collision.b2ContactPoint;
   
   import flash.events.Event;
   import flash.geom.Point;

   public class CollisionEvent extends Event
   {
      public static const COLLISION_EVENT:String = "COLLISION_EVENT";
      public static const COLLISION_STOPPED_EVENT:String = "COLLISION_STOPPED_EVENT";
      
      public var Collider:Box2DSpatialComponent = null;
      public var Collidee:Box2DSpatialComponent = null;
      public var Normal:Point = null;
      
      public function CollisionEvent(type:String, point:b2ContactPoint, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         Collider = point.shape1.m_userData as Box2DSpatialComponent;
         Collidee = point.shape2.m_userData as Box2DSpatialComponent;
         Normal = new Point(point.normal.x, point.normal.y);
         
         super(type, bubbles, cancelable);
      }
   }
}