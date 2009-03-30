package PBLabs.Animation
{
   import flash.geom.Point;
   
   public class PointAnimator extends Animator
   {
      protected override function _Interpolate(start:*, end:*, time:Number):*
      {
         var result:Point = new Point();
         result.x = super._Interpolate(start.x, end.x, time);
         result.y = super._Interpolate(start.y, end.y, time);
         return result;
      }
   }
}