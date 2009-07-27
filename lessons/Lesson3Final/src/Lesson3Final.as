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
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.entity.*;
   import com.pblabs.rendering2D.*;
   import com.pblabs.rendering2D.UI.*;
   
   import flash.display.Sprite;
   import flash.geom.Point;
   
   [SWF(width="800", height="600", frameRate="60")]
   public class Lesson3Final extends Sprite
   {
      public function Lesson3Final()
      {
         Global.startup(this);                                                // Start up PBE

         createScene();                                                       // Set up a simple scene entity
         
         createHero();                                                        // Create a simple avatar entity
      }
      
      private function createScene():void 
      {
         var Scene:IEntity = allocateEntity();                                // Allocate our Scene entity
         Scene.initialize("Scene");                                           // Register with the name "Scene"
         var Spatial:BasicSpatialManager2D = new BasicSpatialManager2D();     // Allocate our Spatial DB component
         Scene.addComponent( Spatial, "Spatial" );                            // Add to Scene with name "Spatial"

         var Renderer:Scene2DComponent = new Scene2DComponent();              // Allocate our renderering component 
        
         Renderer.spatialDatabase = Spatial;                                  // Point renderer at Spatial (for object location information)
        
         var View:SceneView = new SceneView();                                // Create a view for our Renderer
         View.width = 800;                                                    // Set the width of our Scene View
         View.height = 600;                                                   // Set the height of our Scene View
         Renderer.sceneView = View;                                           // Point the Renderer's SceneView at the view we just created.
        
         Renderer.position = new Point(0,0);                                  // Point the camera (center of render view) at 0,0
        
         Renderer.renderMask = new ObjectType("Renderable");                  // Set the render mask to only draw objects explicitly marked as "Renderable"
        
         Scene.addComponent( Renderer, "Renderer" );                          // Add our Renderer component to the scene entity with the name "Renderer"
      }


      private function createHero():void
      {
         var Hero:IEntity = allocateEntity();                                 // Allocate an entity for our hero avatar
         Hero.initialize("Hero");                                             // Register the entity with PBE under the name "Hero"
         
         var Spatial:SimpleSpatialComponent = new SimpleSpatialComponent();   // Create our spatial component
         
         // Do a named lookup to register our hero with the scene spatial database
         Spatial.spatialManager = NameManager.instance.lookupComponentByName("Scene", "Spatial") as ISpatialManager2D;                            
         
         Spatial.objectMask = new ObjectType("Renderable");                   // Set a mask flag for this object as "Renderable" to be seen by the scene Renderer
         Spatial.position = new Point(-375,-275);                             // Set our hero's position in space
         Spatial.size = new Point(50,50);                                     // Set our hero's size as 50,50
        
         Hero.addComponent( Spatial, "Spatial" );                             // Add our spatial component to the Hero entity with the name "Spatial"
        
         // Create a simple render component to display our object
         var Render:SimpleShapeRenderComponent = new SimpleShapeRenderComponent();
         Render.showCircle = true;                                            // Specify to draw the object as a circle
         Render.radius = 25;                                                  // Mark the radius of the circle as 25
         
         // Point the render component to this entity's Spatial component for position information
         Render.positionReference = new PropertyReference("@Spatial.position");
         // Point the render component to this entity's Spatial component for rotation information
         Render.rotationReference = new PropertyReference("@Spatial.rotation");
        
         Hero.addComponent( Render, "Render" );                               // Add our render component to the Hero entity with the name "Render"
         
         var Controller:DemoControllerComponent = new DemoControllerComponent();
         // Point the controller component to this entity's Spatial component for position information
         Controller.positionReference = new PropertyReference("@Spatial.position");
         // Add the demo controller component to the Hero entity with the name "Controller"
         Hero.addComponent( Controller, "Controller" );
      }
   }
}
