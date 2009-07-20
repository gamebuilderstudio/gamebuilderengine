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
   import PBLabs.Engine.Core.*;
   import PBLabs.Engine.Entity.*;
   import PBLabs.Rendering2D.*;
   import PBLabs.Rendering2D.UI.*;
   
   import flash.display.Sprite;
   import flash.geom.Point;
   
   [SWF(width="800", height="600", frameRate="60")]
   public class Lesson3Base extends Sprite
   {
      public function Lesson3Base()
      {
         Global.Startup(this);                                                // Start up PBE

         CreateScene();                                                       // Set up a simple scene entity
         
         CreateHero();                                                        // Create a simple avatar entity
      }
      
      private function CreateScene():void 
      {
         var Scene:IEntity = AllocateEntity();                                // Allocate our Scene entity
         Scene.Initialize("Scene");                                           // Register with the name "Scene"
         var Spatial:BasicSpatialManager2D = new BasicSpatialManager2D();     // Allocate our Spatial DB component
         Scene.AddComponent( Spatial, "Spatial" );                            // Add to Scene with name "Spatial"

         var Renderer:Scene2DComponent = new Scene2DComponent();              // Allocate our renderering component 
        
         Renderer.SpatialDatabase = Spatial;                                  // Point renderer at Spatial (for object location information)
        
         var View:SceneView = new SceneView();                                // Create a view for our Renderer
         View.width = 800;                                                    // Set the width of our Scene View
         View.height = 600;                                                   // Set the height of our Scene View
         Renderer.SceneView = View;                                           // Point the Renderer's SceneView at the view we just created.
        
         Renderer.Position = new Point(0,0);                                  // Point the camera (center of render view) at 0,0
        
         Renderer.RenderMask = new ObjectType("Renderable");                  // Set the render mask to only draw objects explicitly marked as "Renderable"
        
         Scene.AddComponent( Renderer, "Renderer" );                          // Add our Renderer component to the scene entity with the name "Renderer"
      }


      private function CreateHero():void
      {
         var Hero:IEntity = AllocateEntity();                                 // Allocate an entity for our hero avatar
         Hero.Initialize("Hero");                                             // Register the entity with PBE under the name "Hero"
         
         var Spatial:SimpleSpatialComponent = new SimpleSpatialComponent();   // Create our spatial component
         
         // Do a named lookup to register our hero with the scene spatial database
         Spatial.SpatialManager = NameManager.Instance.LookupComponentByName("Scene", "Spatial") as ISpatialManager2D;                            
         
         Spatial.ObjectMask = new ObjectType("Renderable");                   // Set a mask flag for this object as "Renderable" to be seen by the scene Renderer
         Spatial.Position = new Point(-375,-275);                             // Set our hero's position in space
         Spatial.Size = new Point(50,50);                                     // Set our hero's size as 50,50
        
         Hero.AddComponent( Spatial, "Spatial" );                             // Add our spatial component to the Hero entity with the name "Spatial"
        
         // Create a simple render component to display our object
         var Render:SimpleShapeRenderComponent = new SimpleShapeRenderComponent();
         Render.ShowCircle = true;                                            // Specify to draw the object as a circle
         Render.Radius = 25;                                                  // Mark the radius of the circle as 25
         
         // Point the render component to this entity's Spatial component for position information
         Render.PositionReference = new PropertyReference("@Spatial.Position");
         // Point the render component to this entity's Spatial component for rotation information
         Render.RotationReference = new PropertyReference("@Spatial.Rotation");
        
         Hero.AddComponent( Render, "Render" );                               // Add our render component to the Hero entity with the name "Render"
      }
   }
}
