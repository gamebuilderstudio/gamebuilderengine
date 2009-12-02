/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/

package
{
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.entity.*;
   import com.pblabs.rendering2D.*;
   import com.pblabs.rendering2D.ui.*;
   
   import flash.display.Sprite;
   import flash.geom.Point;
   
   [SWF(width="800", height="600", frameRate="60")]
   public class Lesson2Final extends Sprite
   {
      public function Lesson2Final()
      {
         PBE.startup(this);                                                   // Start PBE.

         CreateScene();                                                       // Set up a simple scene entity

         CreateHero();                                                        // Create a simple avatar entity
      }
      
      private function CreateScene():void 
      {
         var sceneView:SceneView = new SceneView();                           // Make the SceneView
         sceneView.width = 800;
         sceneView.height = 600;
	     
         PBE.initializeScene(sceneView);                                      // This is just a helper function that will set up a basic scene for us
      }


      private function CreateHero():void
      {
         var Hero:IEntity = allocateEntity();                                 // Allocate an entity for our hero avatar
         Hero.initialize("Hero");                                             // Register the entity with PBE under the name "Hero"
         
         var Spatial:SimpleSpatialComponent = new SimpleSpatialComponent();   // Create our spatial component
         
         Spatial.position = new Point(0,0);                                   // Set our hero's spatial position as 0,0
         Spatial.size = new Point(50,50);                                     // Set our hero's size as 50,50
        
         Hero.addComponent( Spatial, "Spatial" );                             // Add our spatial component to the Hero entity with the name "Spatial"
        
         var circleSprite:Sprite = new Sprite();                              // Make the sprite that will be rendered
         circleSprite.graphics.lineStyle(2, 0x000000);
         circleSprite.graphics.beginFill(0x0000FF0);
         circleSprite.graphics.drawCircle(0, 0, 25);
         circleSprite.graphics.endFill();
         
         var Render:DisplayObjectRenderer = new DisplayObjectRenderer();      // Create a DisplayObjectRenderer to display our object
         Render.displayObject = circleSprite;                                 // Specify the display object to use
         Render.scene = PBE.getScene();                                       // Set which scene this is apart of
         
         // Point the render component to this entity's Spatial component for position information
         Render.positionProperty = new PropertyReference("@Spatial.position");
         // Point the render component to this entity's Spatial component for rotation information
         Render.rotationProperty = new PropertyReference("@Spatial.rotation");
        
         Hero.addComponent( Render, "Render" );                               // Add our render component to the Hero entity with the name "Render"
      }
   }
}
