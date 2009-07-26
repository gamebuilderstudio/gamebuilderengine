package com.pblabs.rendering2D
{
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.math.*;
   import com.pblabs.engine.entity.PropertyReference;
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
      public var RotationSpeed:Number = 0.2;
      
      public var FaceInMovementDirection:Boolean = false;
      
      [EditorData(defaultValue="1")]
      public var Nudge:Number = 1.0;
      
      public var AllowMovementProperty:PropertyReference = null;
      public var AllowMovementValue:String = null;
      
      public var MovementHeadingThreshold:Number = 100;
      
      public function set InitialPosition(value:Point):void
      {
         GoalPosition = value.clone();
         Position = value.clone();
      }
      
      public function set InitialRotation(value:Number):void
      {
         GoalRotation = value;
         Rotation = value;
      }
      
      public function get MoveDelta():Point
      {
         return GoalPosition.subtract(Position).clone();
      }
      
      private function get CheckMovementAllowed():Boolean
      {
         if(!AllowMovementProperty)
            return true;
         
         return Owner.GetProperty(AllowMovementProperty) == AllowMovementValue;
      }
      
      public override function OnTick(tickRate:Number):void
      {
         // Move towards our position goal.
         var moveDelta:Point = GoalPosition.subtract(Position);
         var moveAmount:Number = tickRate * TranslationSpeed * Nudge;
         
         if(moveDelta.length > moveAmount)
            moveDelta.normalize(moveAmount);
         
         var didMove:Boolean = false;
         var movementHeading:Number = Math.atan2(moveDelta.y, moveDelta.x);

         if(moveDelta.length > 0.001 && CheckMovementAllowed)
         {
            // Check our heading
            if(Math.abs(Utility.GetRadianShortDelta(movementHeading, Rotation)) <= MovementHeadingThreshold)
               Position = Position.add(moveDelta);
            
            // Only update position if we really need to move.
            didMove = true;
         }
         
         // Deal with facing-heading.
         if(didMove && FaceInMovementDirection)
            GoalRotation = movementHeading

         // Interpolate heading.
         var headingDelta:Number = Utility.GetRadianShortDelta(Rotation, GoalRotation);
         
         if(headingDelta < -RotationSpeed)
            headingDelta = -RotationSpeed;
         else if(headingDelta > RotationSpeed)
            headingDelta = RotationSpeed;

         if(Math.abs(headingDelta) > 0.01)
            Rotation += headingDelta;
      }
   }
}