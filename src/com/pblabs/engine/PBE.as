package com.pblabs.engine
{
	import com.pblabs.engine.core.*;
	import com.pblabs.engine.debug.*;
	import com.pblabs.engine.entity.*;
	import com.pblabs.engine.resource.ResourceManager;
	import com.pblabs.engine.version.VersionDetails;
	import com.pblabs.engine.version.VersionUtil;
	import com.pblabs.rendering2D.*;
	import com.pblabs.rendering2D.ui.*;
	import com.pblabs.screens.ScreenManager;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.*;
	import flash.system.Security;

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
		public static const REVISION:uint = 625;
		
		private static var _main:Sprite = null;	
		private static var _versionDetails:VersionDetails;
		
		private static var _spatialManager:ISpatialManager2D;
		private static var _scene:DisplayObjectScene;
		
        private static var _stageQualityStack:Array = [];
        private static var _started:Boolean = false;
        
		/**
		 * Register a type with PushButton Engine so that it can be deserialized,
		 * even if no code directly uses it.
		 */
		public static function registerType(type:Class):void
		{
			// Do nothing - the compiler will include the class by virtue of it
			// having been used.
		}
		
		/**
		 * Allocates an instance of the hidden Entity class. This should be
		 * used anytime an IEntity object needs to be created. Encapsulating
		 * the Entity class forces code to use IEntity rather than Entity when
		 * dealing with entity references. This will ensure that code is future
		 * proof as well as allow the Entity class to be pooled in the future.
		 * 
		 * @return A new IEntity.
		 */
		public static function allocateEntity():IEntity
		{
			return com.pblabs.engine.entity.allocateEntity();
		}
		
		/**
		 * Define an entity using a function callback.
		 * 
		 * @param name The name of the entity; used to identify it for creation
		 *             later.
		 * @param definition The function, taking no arguments and returning IEntity,
		 * 					 which creates an instance of that entity.
		 */
		public static function defineEntityByFunction(name:String, definition:Function):void
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
		public static function defineWithXML(xml:XML):void
		{
			throw new Error("Not implemented.");
		}
		
		/**
		 * Start the engine by giving it a reference to the root of the display hierarchy.
		 */
		public static function startup(mainClass:Sprite):void
		{
            if(_started)
                throw new Error("You can only call PBE.startup once.");

            _main = mainClass;
			_versionDetails = VersionUtil.checkVersion(mainClass);
			
			// Set the stage alignment and scalemode
			// We do this to be consistent between CS4/Flex apps, if you want stage alignment
			// and scale mode to be different just set these values after you call PBE.startup.
			mainClass.stage.align = StageAlign.TOP_LEFT;
			mainClass.stage.scaleMode = StageScaleMode.NO_SCALE;

			Logger.print(PBE, "PushButton Engine - r"+ REVISION +" - "+_versionDetails + " - " + Security.sandboxType);
			
			if (!IS_SHIPPING_BUILD && (_main.loaderInfo && _main.loaderInfo.parameters && _main.loaderInfo.parameters["generateSchema"] == "1"))
				SchemaGenerator.instance.generateSchema();

            Logger.startup();
            
            _started = true;
		}

		/**
		 * Helper function to set up a basic scene using default Rendering2D
		 * classes. Very useful for getting started quickly.
		 */
		public static function initializeScene(view:IUITarget, sceneName:String = "SceneDB", sceneClass:Class = null, spatialManagerClass:Class = null):IEntity
		{
			// You will notice this is almost straight out of lesson #2.
			var scene:IEntity = allocateEntity();                                // Allocate our Scene entity
			scene.initialize(sceneName);                                         // Register with the name "Scene"

			if(!spatialManagerClass)
				spatialManagerClass = BasicSpatialManager2D;
			
			var spatial:ISpatialManager2D = new spatialManagerClass();           // Allocate our Spatial DB component
			_spatialManager = spatial;
			scene.addComponent( spatial as IEntityComponent, "Spatial" );        // Add to Scene with name "Spatial"
			
			if(!sceneClass)
				sceneClass = DisplayObjectScene;
			
			_scene = new sceneClass();               // Allocate our renderering component
            _scene.sceneView = view;                 // Point the Renderer's SceneView at the view we just created.
			scene.addComponent( _scene, "Scene" );   // Add our Renderer component to the scene entity with the name "Renderer"
			
			return scene;
		}
		
		public static function getSpatialManager():ISpatialManager2D
		{
			return _spatialManager;
		}
		
		public static function getScene():IScene2D
		{
			return _scene;
		}
        
        public static function getFlashVars():Object
        {
            return LoaderInfo(mainStage.loaderInfo).parameters;
        }
        
        /**
         * True if PBE.startup has been called.
         */
        public static function get started():Boolean
        {
            return _started;
        }
		
		/**
		 * Return true if the specified key is down.
		 */
		public static function isKeyDown(key:InputKey):Boolean
		{
			return InputManager.instance.isKeyDown(key.keyCode);
		}
		
        /**
         * Return true if any key is down.
         */
        public static function isAnyKeyDown():Boolean
        {
            return InputManager.instance.isAnyKeyDown();
        }

        /**
		 * Locate an entity by its name.
		 */
		public static function lookup(entityName:String):IEntity
		{
			return NameManager.instance.lookup(entityName);
		}
        
        /**
         * Locate a named component on a named entity.
         */
        public static function lookupComponentByName(entityName:String, componentName:String):IEntityComponent
        {
            return NameManager.instance.lookupComponentByName(entityName, componentName);
        }

        /**
         * Locate the first component of a type on a named entity.
         */
        public static function lookupComponentByType(entityName:String, componentType:Class):IEntityComponent
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
		public static function makeEntity(entityName:String, params:Object = null):IEntity
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
					// Special case to allow "@foo": to assign foo as a new component... named foo.
					if(String(key).charAt(0) == "@" && String(key).indexOf(".") == -1)
					{
						entity.addComponent(IEntityComponent(params[key]), String(key).substring(1));
					}
					else
					{
						entity.setProperty(new PropertyReference(key), params[key]);
					}
				}
				else
				{
					// Error case.
					Logger.error(PBE, "MakeEntity", "Unexpected key '" + key + "'; can only handle String or PropertyReference.");
				}
			}
			
			// Give it to the user.
			return entity;
		}
        
        /**
         * Print a message to the log. 
         * @param reporter Usually 'this'; the class initiating the logging.
         * @param message The message to log.
         * 
         */
        public static function log(reporter:*, message:String):void
        {
            Logger.print(reporter, message);
        }

		/**
		 * Set this to true to get rid of a bunch of development related functionality that isn't
		 * needed in a final release build.
		 */
		public static const IS_SHIPPING_BUILD:Boolean = false;
		
		/**
		 * The stage. This is the root of the display heirarchy and is automatically created by
		 * flash when the application starts up.
		 */
		public static function get mainStage():Stage
		{
			if (!_main)
				throw new Error("Cannot retrieve the global stage instance until mainClass has been set to the startup class!");
			
			return _main.stage;
		}
		
		/**
		 * A reference to the main class of the application. This must be set when the application
		 * first loads as several core subsystems rely on it's presence.
		 */
		public static function get mainClass():Sprite
		{
			return _main;
		}
		
		/**
		 * Returns information about the current running swf.
		 * @return VersionDetails Object
		 */		
		public static function get versionDetails():VersionDetails
		{
			return _versionDetails;
		}
		
		/**
		 * Returns the LevelManager instance
		 * @return LevelManager instance
		 */		
		public static function get levelManager():LevelManager
		{
			return LevelManager.instance;
		}
		
		/**
		 * Returns the ScreenManager instance
		 * @return ScreenManager
		 */		
		public static function get screenManager():ScreenManager
		{
			return ScreenManager.instance;
		}
		
		/**
		 * Returns the NameManager instance 
		 * @return NameManager instance
		 */		
		public static function get nameManager():NameManager
		{
			return NameManager.instance;
		}
		
		/**
		 * Returns the ProcessManager instance 
		 * @return ProcessManager instance
		 */		
		public static function get processManager():ProcessManager
		{
			return ProcessManager.instance;
		}
		
		/**
		 * Returns the TemplateManager instance.
		 * @return TemplateManager instance 
		 */		
		public static function get templateManager():TemplateManager
		{
			return TemplateManager.instance;
		}
		
		/**
		 * Returns the InputManager instance. 
		 * @return InputManager instance.
		 * 
		 */		
		public static function get inputManager():InputManager
		{
			return InputManager.instance;
		}
		
		/**
		 * Returns the ObjectTypeManager instance. 
		 * @return ObjectTypeManager instance.
		 * 
		 */		
		public static function get objectTypeManager():ObjectTypeManager
		{
			return ObjectTypeManager.instance;
		}
		
		/**
		 * Returns the ResourceManager instance. 
		 * @return ResourceManager instance.
		 */		
		public static function get resourceManager():ResourceManager
		{
			return ResourceManager.instance;
		}
		
		public static function getHostingDomain():String
		{
			// Get at the hosting domain.
			var urlString:String = _main.stage.loaderInfo.url;
			var urlParts:Array = urlString.split("://");
			var wwwPart:Array = urlParts[1].split("/");
			if(wwwPart.length)
				return wwwPart[0];
			else
				return "[unknown]";
		}
        
        /**
         * Set stage quality to a new value, and store the old value so we
         * can restore it later. Useful if you want to temporarily toggle
         * render quality.
         *  
         * @param newQuality From StafeQuality, new quality level to use. 
         */
        public static function pushStageQuality(newQuality:String):void
        {
            _stageQualityStack.push(mainStage.quality);
            mainStage.quality = newQuality;
        }
        
        /**
         * Restore stage quality to previous value.
         * 
         * @see pushStageQuality
         */
        public static function popStageQuality():void
        {
            if(_stageQualityStack.length == 0)
                throw new Error("Bottomed out in stage quality stack! You have mismatched push/pop calls!");
            
            mainStage.quality = _stageQualityStack.pop();
        }
		
		/**
		 * Loads a resource from a file. If the resource has already been loaded or is embedded, a
		 * reference to the existing resource will be given. The resource is not returned directly
		 * since loading is asynchronous. Instead, it will be passed to the function specified in
		 * the onLoaded parameter. Even if the resource has already been loaded, it cannot be
		 * assumed that the callback will happen synchronously.
		 * 
		 * <p>This will not attempt to load resources that have previously failed to load. Instead,
		 * the load will fail instantly.</p>
		 * 
		 * @param filename The url of the file to load.
		 * @param resourceType The Resource subclass specifying the type of resource that is being
		 * requested.
		 * @param onLoaded A function that will be called on successful load of the resource. The
		 * function should take a single parameter of the type specified in the resourceType
		 * parameter.
		 * @param onFailed A function that will be called if loading of the resource fails. The
		 * function should take a single parameter of the type specified in the resourceType
		 * parameter. The resource passed to the function will be invalid, but the filename
		 * property will be correct.
		 * @param forceReload Always reload the resource, even if it has already been loaded.
		 * 
		 * @see Resource
		 */
		public static function loadResource(filename:String, resourceType:Class, 
											onLoaded:Function = null, onFailed:Function = null, 
											forceReload:Boolean = false):void
		{
			resourceManager.load(filename, resourceType, onLoaded, onFailed, forceReload);
		}
		
        /**
         * Defer a call until the start of the next tick or frame. 
         * @param method Method to call.
         * @param args Arguments, if any.
         */
        public static function callLater(method:Function, args:Array = null):void
        {
            ProcessManager.instance.callLater(method, args);
        }
		
		/**
		 * Recursively searches for an object with the specified name that has been added to the
		 * display hierarchy.
		 * 
		 * @param name The name of the object to find.
		 * 
		 * @return The display object with the specified name, or null if it wasn't found.
		 */
		public static function findChild(name:String, displayObjectToSearch:DisplayObject = null):DisplayObject
		{
			return _findChild(name, displayObjectToSearch ? displayObjectToSearch : _main);
		}
		
		private static function _findChild(name:String, current:DisplayObject):DisplayObject
		{
			if (!current)
				return null;
			
			if (current.name == name)
				return current;
			
			var parent:DisplayObjectContainer = current as DisplayObjectContainer;
			
			if (!parent)
			    return null;
			     
			for (var i:int = 0; i < parent.numChildren; i++)
			{
				var child:DisplayObject = _findChild(name, parent.getChildAt(i));
				if (child)
					return child;
			}
			
			return null;
		}
		
	}
}