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
   public class Lesson4Final extends Sprite
   {
      public function Lesson4Final()
      {
         // Start up PBE
         Global.Startup(this);

         // Set up a simple scene entity
         CreateScene();
         
         // Create a simple avatar entity
         CreateHero();
      }
      
      private function CreateScene():void 
      {
         // Allocate our Scene entity
         var Scene:IEntity = AllocateEntity();
         
         // Register with the name "Scene"
         Scene.Initialize("Scene");
         
         // Allocate our Spatial DB component
         var Spatial:BasicSpatialManager2D = new BasicSpatialManager2D();
         
         // Add to Scene with name "Spatial"
         Scene.AddComponent( Spatial, "Spatial" );

         // Allocate our renderering component 
         var Renderer:Scene2DComponent = new Scene2DComponent();
        
         // Point renderer at Spatial (for object location information)
         Renderer.SpatialDatabase = Spatial;
        
         // Create a view for our Renderer
         var View:SceneView = new SceneView();
         
         // Set the width of our Scene View
         View.width = 800;
         // Set the height of our Scene View
         View.height = 600;
         // Point the Renderer's SceneView at the view we just created.
         Renderer.SceneView = View;
        
         // Point the camera (center of render view) at 0,0
         Renderer.Position = new Point(0,0);
        
         // Set the render mask to only draw objects explicitly marked as "Renderable"
         Renderer.RenderMask = new ObjectType("Renderable");
        
         // Add our Renderer component to the scene entity with the name "Renderer"
         Scene.AddComponent( Renderer, "Renderer" );
      }


      private function CreateHero():void
      {
         // Allocate an entity for our hero avatar
         var Hero:IEntity = AllocateEntity();
         // Register the entity with PBE under the name "Hero"
         Hero.Initialize("Hero");
         
         // Create our spatial component
         var Spatial:SimpleSpatialComponent = new SimpleSpatialComponent();
         
         // Do a named lookup to register our hero with the scene spatial database
         Spatial.SpatialManager = NameManager.Instance.LookupComponentByName("Scene", "Spatial") as ISpatialManager2D;                            
         
         // Set a mask flag for this object as "Renderable" to be seen by the scene Renderer
         Spatial.ObjectMask = new ObjectType("Renderable");
         // Set our hero's position in space
         Spatial.Position = new Point(0,0);
         // Set our hero's size as 50,50
         Spatial.Size = new Point(50,50);
        
         // Add our spatial component to the Hero entity with the name "Spatial"
         Hero.AddComponent( Spatial, "Spatial" );
        
         // Create a simple render component to display our object
         var Render:SimpleShapeRenderComponent = new SimpleShapeRenderComponent();
         // Specify to draw the object as a circle
         Render.ShowCircle = true;
         // Mark the radius of the circle as 25
         Render.Radius = 25;
         
         // Point the render component to this entity's Spatial component for position information
         Render.PositionReference = new PropertyReference("@Spatial.Position");
         // Point the render component to this entity's Spatial component for rotation information
         Render.RotationReference = new PropertyReference("@Spatial.Rotation");
        
         // Add our render component to the Hero entity with the name "Render"
         Hero.AddComponent( Render, "Render" );
         
         // Create an instance of our hero controller component
         var Controller:HeroControllerComponent = new HeroControllerComponent();
         // Point the controller component to this entity's Spatial component for position information
         Controller.PositionReference = new PropertyReference("@Spatial.Position");

         // Add the demo controller component to the Hero entity with the name "Controller"
         Hero.AddComponent( Controller, "Controller" );
      }
   }
}
