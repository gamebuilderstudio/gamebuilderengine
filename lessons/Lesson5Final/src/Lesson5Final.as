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
    import com.pblabs.engine.core.*;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.PropertyReference;
    import com.pblabs.rendering2D.*;
    import com.pblabs.rendering2D.ui.*;
    
    import flash.display.Sprite;
    import flash.geom.Point;
   
   [SWF(width="800", height="600", frameRate="60")]
   public class Lesson5Final extends Sprite
   {
      public function Lesson5Final()
      {
         // Start up PBE
         PBE.startup(this);
         
         // Load up our embedded resources
         PBE.addResources(new MyResources());

         // Set up a simple scene entity
         createScene();
                  
         // Create an avatar entity
         createHero();
         
         // Create a simple background entity
         createBackground();
      }
      
      private function createScene():void 
      {
          var sceneView:SceneView = new SceneView();                        // Make the SceneView
          sceneView.width = 800;
          sceneView.height = 600;
          
          PBE.initializeScene(sceneView);                                   // This is just a helper function that will set up a basic scene for us          
      }

      private function createHero():void
      {
         // Allocate an entity for our hero avatar
         var hero:IEntity = PBE.allocateEntity();
                  
         // Add our spatial component to the Hero entity ...
         createSpatial( hero,
            // with location of 0,150...
            new Point(0, 150),
            // and with size of 60,53...
            new Point(60, 53)
         );
        
         // Create a simple render component to display our object

         // Here we've removed the reference to our simple shape renderer, and added a sprite render component.
         var render:SpriteRenderer = new SpriteRenderer();

         // Tell the Render component to use one of the images embedded by our ResourceBundle
         render.fileName = "../assets/fanship.png";
         
         // Add the renderer to the scene.
         render.scene = PBE.scene;
         
         // Set our hero to render above the background.
         render.layerIndex = 10;
         
         // Point the render component to this entity's Spatial component for position information
         render.positionProperty = new PropertyReference("@Spatial.position");
         // Point the render component to this entity's Spatial component for size information
         render.sizeProperty = new PropertyReference("@Spatial.size");
        
         // Add our render component to the Hero entity with the name "Render"
         hero.addComponent( render, "Render" );
         
         // Create an instance of our hero controller component
         var controller:HeroControllerComponent = new HeroControllerComponent();
         // Point the controller component to this entity's Spatial component for position information
         controller.positionReference = new PropertyReference("@Spatial.position");

         // Add the demo controller component to the Hero entity with the name "Controller"
         hero.addComponent( controller, "Controller" );

         // Register the entity with PBE under the name "Hero"
         hero.initialize("Hero");
      }
      
      private function createBackground():void
      {
         // Allocate an entity for our background sprite
         var bg:IEntity = PBE.allocateEntity();
         
         // Add our spatial component to the background entity ...
         createSpatial( bg, 
            // with location of 0,0...
            new Point(0, 0)
         );
            
         // Create a simple render component to display our object

         // Just like the hero, this also uses a SpriteRenderComponent
         var render:SpriteRenderer = new SpriteRenderer();
         
         // Tell the Render component to use one of the images embedded by our ResourceLinker
         render.fileName = "../assets/bg.jpg";
         
         // Set our background to render below the hero.
         render.layerIndex = 1;
         
         // Add the renderer to the scene.
         render.scene = PBE.scene;

         // Point the render component to this entity's Spatial component for position information
         render.positionProperty = new PropertyReference("@Spatial.position");
        
         // Add our render component to the BG entity with the name "Render"
         bg.addComponent( render, "Render" );

         // Register the entity with PBE under the name "BG"
         bg.initialize("BG");         
      }
      
      // This is a shortcut function to help simplify the creation of spatial components
      private function createSpatial( ent:IEntity, pos:Point, size:Point = null ):void
      {
          // Create our spatial component
          var spatial:SimpleSpatialComponent = new SimpleSpatialComponent();
          
          // Do a named lookup to register our background with the scene spatial database
          spatial.spatialManager = PBE.spatialManager;
          
          // Set our background position in space
          spatial.position = pos;
          
          if (size != null) 
              spatial.size = size;
          
          ent.addComponent(spatial, "Spatial");
      }
   }
}
