package com.pblabs.rendering2D
{
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.math.*;
   import com.pblabs.engine.entity.PropertyReference;
   import flash.geom.Point;

   public class Interpolated2DMoverComponent extends SimpleSpatialComponent
   {
      [EditorData(ignore="true")]
      public var goalPosition:Point = new Point();
      
      [EditorData(ignore="true")]
      public var goalRotation:Number = 0;
      
      [EditorData(defaultValue="5")]
      public var translationSpeed:Number = 5.0;
      
      [EditorData(defaultValue="1")]
      public var rotationSpeed:Number = 0.2;
      
      public var faceInMovementDirection:Boolean = false;
      
      [EditorData(defaultValue="1")]
      public var nudge:Number = 1.0;
      
      public var allowMovementProperty:PropertyReference = null;
      public var allowMovementValue:String = null;
      
      public var movementHeadingThreshold:Number = 100;
      
      public function set initialPosition(value:Point):void
      {
         goalPosition = value.clone();
         position = value.clone();
      }
      
      public function set initialRotation(value:Number):void
      {
         goalRotation = value;
         rotation = value;
      }
      
      public function get moveDelta():Point
      {
         return goalPosition.subtract(position).clone();
      }
      
      private function get checkMovementAllowed():Boolean
      {
         if(!allowMovementProperty)
            return true;
         
         return owner.getProperty(allowMovementProperty) == allowMovementValue;
      }
      
      public override function onTick(tickRate:Number):void
      {
         // Move towards our position goal.
         var moveDelta:Point = goalPosition.subtract(position);
         var moveAmount:Number = tickRate * translationSpeed * nudge;
         
         if(moveDelta.length > moveAmount)
            moveDelta.normalize(moveAmount);
         
         var didMove:Boolean = false;
         var movementHeading:Number = Math.atan2(moveDelta.y, moveDelta.x);

         if(moveDelta.length > 0.001 && checkMovementAllowed)
         {
            // Check our heading
            if(Math.abs(Utility.getRadianShortDelta(movementHeading, rotation)) <= movementHeadingThreshold)
               position = position.add(moveDelta);
            
            // Only update position if we really need to move.
            didMove = true;
         }
         
         // Deal with facing-heading.
         if(didMove && faceInMovementDirection)
            goalRotation = movementHeading

         // Interpolate heading.
         var headingDelta:Number = Utility.getRadianShortDelta(rotation, goalRotation);
         
         if(headingDelta < -rotationSpeed)
            headingDelta = -rotationSpeed;
         else if(headingDelta > rotationSpeed)
            headingDelta = rotationSpeed;

         if(Math.abs(headingDelta) > 0.01)
            rotation += headingDelta;
      }
   }
}