package PBLabs.Box2D
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Dynamics.b2ContactFilter;

   public class ContactFilter extends b2ContactFilter
   {
      public override function ShouldCollide(shape1:b2Shape, shape2:b2Shape):Boolean
      {
         if (!super.ShouldCollide(shape1, shape2))
            return false;
         
         return true;
      }
   }
}