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
   import com.pblabs.engine.core.Global;
   import com.pblabs.engine.core.ObjectType;
   import com.pblabs.engine.core.NameManager;
   import com.pblabs.engine.entity.PropertyReference;
   import com.pblabs.engine.entity.allocateEntity;
   import com.pblabs.engine.entity.IEntity;
   import com.pblabs.rendering2D.BasicSpatialManager2D;
   import com.pblabs.rendering2D.ISpatialManager2D;
   import com.pblabs.rendering2D.Scene2DComponent;
   import com.pblabs.rendering2D.SimpleSpatialComponent;
   import com.pblabs.rendering2D.SimpleShapeRenderComponent;
   import com.pblabs.rendering2D.SpriteRenderComponent;
   import com.pblabs.rendering2D.ui.*;
   
   import flash.display.Sprite;
   import flash.geom.Point;
   
   [SWF(width="800", height="600", frameRate="60")]
   public class Lesson5Base extends Sprite
   {
      public function Lesson5Base()
      {
         // Start up PBE
         Global.startup(this);
         
         // Set up a simple scene entity
         createScene();
                  
         // Create an avatar entity
         createHero();
      }
      
      private function createScene():void 
      {
         // Allocate our Scene entity
         var scene:IEntity = allocateEntity();
         
         // Register with the name "Scene"
         scene.initialize("Scene");
         
         // Allocate our Spatial DB component
         var spatial:BasicSpatialManager2D = new BasicSpatialManager2D();
         
         // Add to Scene with name "Spatial"
         scene.addComponent( spatial, "Spatial" );

         // Allocate our renderering component 
         var renderer:Scene2DComponent = new Scene2DComponent();
        
         // Point renderer at Spatial (for object location information)
         renderer.spatialDatabase = spatial;
        
         // Create a view for our Renderer
         var view:SceneView = new SceneView();
         
         // Set the width of our Scene View
         view.width = 800;
         // Set the height of our Scene View
         view.height = 600;
         // Point the Renderer's SceneView at the view we just created.
         renderer.sceneView = view;
        
         // Point the camera (center of render view) at 0,0
         renderer.position = new Point(0,0);
        
         // Set the render mask to only draw objects explicitly marked as "Renderable"
         renderer.renderMask = new ObjectType("Renderable");
        
         // Add our Renderer component to the scene entity with the name "Renderer"
         scene.addComponent( renderer, "Renderer" );
      }

      private function createHero():void
      {
         // Allocate an entity for our hero avatar
         var hero:IEntity = allocateEntity();
         // Register the entity with PBE under the name "Hero"
         hero.initialize("Hero");
         
         // Add our spatial component to the Hero entity ...
         createSpatial( hero,
            // with location of 0,150...
            new Point(0, 150),
            // and with size of 60,53...
            new Point(60, 53)
         );
        
         // Create a simple render component to display our object
         var render:SimpleShapeRenderComponent = new SimpleShapeRenderComponent();
         // Specify to draw the object as a circle
         render.showCircle = true;
         // Mark the radius of the circle as 25
         render.radius = 25;
         
         // Point the render component to this entity's Spatial component for position information
         render.positionReference = new PropertyReference("@Spatial.position");
         // Point the render component to this entity's Spatial component for rotation information
         render.rotationReference = new PropertyReference("@Spatial.rotation");
        
         // Add our render component to the Hero entity with the name "Render"
         hero.addComponent( render, "Render" );
         
         // Create an instance of our hero controller component
         var controller:HeroControllerComponent = new HeroControllerComponent();
         // Point the controller component to this entity's Spatial component for position information
         controller.positionReference = new PropertyReference("@Spatial.position");

         // Add the demo controller component to the Hero entity with the name "Controller"
         hero.addComponent( controller, "Controller" );
      }
            
      // This is a shortcut function to help simplify the creation of spatial components
      private function createSpatial( ent:IEntity, pos:Point, size:Point = null ):void
      {
         // Create our spatial component
         var spatial:SimpleSpatialComponent = new SimpleSpatialComponent();
         
         // Do a named lookup to register our background with the scene spatial database
         spatial.spatialManager = NameManager.instance.lookupComponentByName("Scene", "Spatial") as ISpatialManager2D;
         
         // Set a mask flag for this object as "Renderable" to be seen by the scene Renderer
         spatial.objectMask = new ObjectType("Renderable");
         
         // Set our background position in space
         spatial.position = pos;

         if (size != null) 
         {
            spatial.size = size;
         }
         
         ent.addComponent(spatial, "Spatial");
      }
   }
}
