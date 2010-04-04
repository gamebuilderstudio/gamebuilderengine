/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
   import com.pblabs.engine.entity.PropertyReference;
   import com.pblabs.engine.PBUtil;
   
   import flash.geom.Point;

   /**
    * A simple spatial component which moves towards a goal point and heading. 
    * Useful as a building block for more complex movement behaviors.
    */
   public class Interpolated2DMoverComponent extends SimpleSpatialComponent
   {
      private var _goalPosition:Point = new Point();

      [EditorData(ignore="true")]
      /**
       * The goal to which we want to move.
       */
      public function set goalPosition(value:Point):void
      {
          if(lockGoal)
              return;
          
          _goalPosition = value;
      }
      
      public function get goalPosition():Point
      {
          return _goalPosition;
      }
      
      [EditorData(ignore="true")]
      /**
       * The direction in which we want to face. 
       * @see faceInMovementDirection
       */
      public var goalRotation:Number = 0;

      [EditorData(defaultValue="5")]
      /**
       * How fast will we move towards our goal position? 
       */
      public var translationSpeed:Number = 5.0;

      [EditorData(defaultValue="1")]
      /**
       * How quickly will we turn towards our goal heading? 
       */
      public var rotationSpeed:Number = 20;

      /**
       * When true, we turn to face the goal position before moving towards it. 
       */
      public var faceInMovementDirection:Boolean = false;

      [EditorData(defaultValue="1")]
      /**
       * Coefficient which allows the movement speed to be fudged.
       */
      public var nudge:Number = 1.0;

      /**
       * Property to check to see if we can move. 
       */
      public var allowMovementProperty:PropertyReference = null;

      /**
       * If the allowMovementProperty is equal to this value, allow movement. 
       */
      public var allowMovementValue:String = null;

      /**
       * Within how many degrees must we be of our goal heading before we
       * will start moving towards the goal position? 
       */
      public var movementHeadingThreshold:Number = 100;
      
      /**
       * If true, the goal position cannot be changed. Useful for when you have
       * many other components trying to set the goal.
       */
      public var lockGoal:Boolean = false;

      /**
       * Sets our position and goalPosition to the same value, useful for
       * setting up initial state.
       */
      public function set initialPosition(value:Point):void
      {
         goalPosition = value.clone();
         position = value.clone();
      }

      /**
       * Sets our rotation and goalRotation to the same value, useful for
       * setting up initial state.
       */
      public function set initialRotation(value:Number):void
      {
         goalRotation = value;
         rotation = value;
      }

      /**
       * How far are we from our goal position?
       */
      public function get moveDelta():Point
      {
         return goalPosition.subtract(position).clone();
      }

      /**
       * Can we currently move (as determined by allowMovementProperty and allowMovementValue)? 
       */
      private function get checkMovementAllowed():Boolean
      {
         if(!allowMovementProperty)
            return true;

         return owner.getProperty(allowMovementProperty) == allowMovementValue;
      }

      override public function onTick(tickRate:Number):void
      {
         // Move towards our position goal.
         var moveDelta:Point = goalPosition.subtract(position);
         var moveAmount:Number = tickRate * translationSpeed * nudge;
         
         if(moveDelta.length > moveAmount)
            moveDelta.normalize(moveAmount);

         var didMove:Boolean = false;
         var movementHeading:Number = PBUtil.getDegreesFromRadians(Math.atan2(moveDelta.y, moveDelta.x));

         if(moveDelta.length > 0.001 && checkMovementAllowed)
         {
            // Check our heading
            if(Math.abs(PBUtil.getDegreesShortDelta(movementHeading, rotation)) <= movementHeadingThreshold)
               position = position.add(moveDelta);

            // Only update position if we really need to move.
            didMove = true;
         }

         // Deal with facing-heading.
         if(didMove && faceInMovementDirection)
            goalRotation = movementHeading

         // Interpolate heading.
         var headingDelta:Number = PBUtil.getDegreesShortDelta(rotation, goalRotation);

         if(headingDelta < -rotationSpeed)
            headingDelta = -rotationSpeed;
         else if(headingDelta > rotationSpeed)
            headingDelta = rotationSpeed;

         if(Math.abs(headingDelta) > 0.01)
            rotation += headingDelta;
      }
   }
}