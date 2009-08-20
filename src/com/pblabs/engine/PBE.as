package com.pblabs.engine
{
	import com.pblabs.engine.core.*;
	import com.pblabs.engine.debug.*;
	import com.pblabs.engine.entity.*;
	import com.pblabs.rendering2D.*;
	import com.pblabs.rendering2D.ui.*;
	
	import flash.display.Sprite;
	import flash.geom.*;
	

	/**
	 * Utility class to simplify working with PushButton Engine.
	 * 
	 * This class makes some assumptions about what components and modules
	 * are present. If you are doing strange things, then you may need to
	 * directly access things this class does for you. However if you are
	 * just getting started this is likely to be a useful toolkit.
	 */
	public class PBE
	{
		/**
		 * Register a type with PushButton Engine so that it can be deserialized,
		 * even if no code directly uses it.
		 */
		static public function registerType(type:Class):void
		{
			// Do nothing - the compiler will include the class by virtue of it
			// having been used.
		}
		
		/**
		 * Define an entity using a function callback.
		 * 
		 * @param name The name of the entity; used to identify it for creation
		 *             later.
		 * @param definition The function, taking no arguments and returning IEntity,
		 * 					 which creates an instance of that entity.
		 */
		static public function defineEntityByFunction(name:String, definition:Function):void
		{
			TemplateManager.instance.registerEntityCallback(name, definition);
		}
		
		/**
		 * Define one or more entities using PBE level XML.
		 * 
		 * This function will do its best to cope with what you give it. It can
		 * accept either a things tag containing several entities/templates/groups,
		 * or a template or entity tag defining a single item.
		 */
		static public function defineWithXML(xml:XML):void
		{
			throw new Error("Not implemented.");
		}
		
		/**
		 * Start the engine by giving it a reference to the root of the display hierarchy.
		 */
		static public function startup(mainClass:Sprite):void
		{
			Global.startup(mainClass);
		}
		
		static private var spatialManager:ISpatialManager2D;
		static private var theScene:Scene2DComponent;

		/**
		 * Helper function to set up a basic scene using default Rendering2D
		 * classes. Very useful for getting started quickly.
		 */
		static public function initializeScene(theView:IUITarget, sceneName:String = "SceneDB"):void
		{
			// You will notice this is straight out of lesson #2.
			var scene:IEntity = allocateEntity();                                // Allocate our Scene entity
			scene.initialize(sceneName);                                         // Register with the name "Scene"

			var spatial:BasicSpatialManager2D = new BasicSpatialManager2D();     // Allocate our Spatial DB component
			spatialManager = spatial;
			scene.addComponent( spatial, "Spatial" );                            // Add to Scene with name "Spatial"
			
			var renderer:Scene2DComponent = new Scene2DComponent();               // Allocate our renderering component
			theScene = renderer;
			renderer.spatialDatabase = spatial;                                   // Point renderer at Spatial (for entity location information)
			renderer.sceneView = theView;                                         // Point the Renderer's SceneView at the view we just created.
			renderer.position = new Point(theView.width / 2, theView.height / 2); // Point the camera (center of render view) at 0,0
			renderer.renderMask = new ObjectType("Renderable");                   // Set the render mask to only draw entities explicitly marked as "Renderable"
			scene.addComponent( renderer, "Renderer" );                           // Add our Renderer component to the scene entity with the name "Renderer"			
		}
		
		static public function getSpatialManager():ISpatialManager2D
		{
			return spatialManager;
		}
		
		static public function getScene():Scene2DComponent
		{
			return theScene;
		}
		
		/**
		 * Return true if the specified key is down.
		 */
		static public function isKeyDown(key:InputKey):Boolean
		{
			return InputManager.instance.isKeyDown(key.keyCode);
		}
		
		/**
		 * Locate an entity by its name.
		 */
		static public function lookup(entityName:String):IEntity
		{
			return NameManager.instance.lookup(entityName);
		}
        
        /**
         * Locate a named component on a named entity.
         */
        static public function lookupComponentByName(entityName:String, componentName:String):IEntityComponent
        {
            return NameManager.instance.lookupComponentByName(entityName, componentName);
        }

        /**
         * Locate the first component of a type on a named entity.
         */
        static public function lookupComponentByType(entityName:String, componentType:Class):IEntityComponent
        {
            return NameManager.instance.lookupComponentByType(entityName, componentType);
        }

        /**
		 * Make a new instance of an entity, setting appropriate fields based
		 * on the parameters passed.
		 * 
		 * @param entityName Identifier by which to look up the entity on the 
		 * 					 TemplateManager.
		 * @param params     Properties to assign, by key/value. Keys can be
		 * 					 strings or PropertyReferences. Values can be any
		 * 					 type.
		 */
		static public function makeEntity(entityName:String, params:Object = null):IEntity
		{
			// Create the entity.
			var entity:IEntity = TemplateManager.instance.instantiateEntity(entityName);
			if(!entity)
				return null;
			
			if(!params)
				return entity;
			
			// Set all the properties.
			for(var key:* in params)
			{
				if(key is PropertyReference)
				{
					// Fast case.
					entity.setProperty(key, params[key]);
				}
				else if(key is String)
				{
					// Slow case.
					entity.setProperty(new PropertyReference(key), params[key]);
				}
				else
				{
					// Error case.
					Logger.printError(PBE, "MakeEntity", "Unexpected key '" + key + "'; can only handle String or PropertyReference.");
				}
			}
			
			// Give it to the user.
			return entity;
		}
	}
}