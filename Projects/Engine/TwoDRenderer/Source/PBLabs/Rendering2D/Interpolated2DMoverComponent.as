package PBLabs.Rendering2D
{
   import PBLabs.Engine.Core.*;
   import flash.geom.Point;

   public class Interpolated2DMoverComponent extends SimpleSpatialComponent
   {
      [EditorData(ignore="true")]
      public var GoalPosition:Point = new Point();
      
      [EditorData(ignore="true")]
      public var GoalRotation:Number = 0;
      
      [EditorData(defaultValue="5")]
      public var TranslationSpeed:Number = 5.0;
      
      [EditorData(defaultValue="1")]
      public var RotationSpeed:Number = 1.0;
      
      public var FaceInMovementDirection:Boolean = false;
      
      [EditorData(defaultValue="1")]
      public var Nudge:Number = 1.0;
      
      public function set InitialPosition(v:Point):void
      {
         GoalPosition = v.clone();
         Position = v.clone();
      }
      
      public function set InitialRotation(v:Number):void
      {
         GoalRotation = v;
         Rotation = v;
      }
      
      public override function OnTick(tickRate:Number):void
      {
         // Move towards our position goal.
         var moveDelta:Point = GoalPosition.subtract(Position);
         var moveAmount:Number = tickRate * TranslationSpeed * Nudge;
         
         if(moveDelta.length > moveAmount)
            moveDelta.normalize(moveAmount);
         
         var didMove:Boolean = false;
         if(moveDelta.length > 0.001)
         {
            // Only update position if we really need to move.
            Position = Position.add(moveDelta);
            didMove = true;
         }
         
         // Deal with facing-heading.
         if(didMove && FaceInMovementDirection)
            GoalRotation = Math.atan2(moveDelta.y, moveDelta.x);

         // Interpolate heading.
         var headingDelta:Number = GoalRotation - Rotation;
         
         if(headingDelta < -RotationSpeed)
            headingDelta = -RotationSpeed;
         else if(headingDelta > RotationSpeed)
            headingDelta = RotationSpeed;

         if(Math.abs(headingDelta) > 0.01)
            Rotation += headingDelta;
      }
   }
}