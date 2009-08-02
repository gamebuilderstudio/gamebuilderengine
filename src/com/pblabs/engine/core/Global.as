/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
   import com.pblabs.engine.debug.log4PBE.LogManager;
   
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.display.Stage;
   
   /**
    * This exists as a helper for retrieving the global application object.
    */
   public class Global
   {
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
      
      public static function startup(mainClass:Sprite):void
      {
         _main = mainClass;
         LogManager.instance.loadDefaultConfiguration();
         
         if (!IS_SHIPPING_BUILD && (_main.loaderInfo && _main.loaderInfo.parameters && _main.loaderInfo.parameters["generateSchema"] == "1"))
            SchemaGenerator.instance.generateSchema();
      }
      
      public static function gethostingDomain():String
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
       * Recursively searches for an object with the specified name that has been added to the
       * display hierarchy.
       * 
       * @param name The name of the object to find.
       * 
       * @return The display object with the specified name, or null if it wasn't found.
       */
      public static function findChild(name:String):DisplayObject
      {
         return _FindChild(name, _main);
      }
      
      private static function _FindChild(name:String, parent:DisplayObjectContainer):DisplayObject
      {
         if (!parent)
            return null;
         
         if (parent.name == name)
            return parent;
         
         for (var i:int = 0; i < parent.numChildren; i++)
         {
            var child:DisplayObject = _FindChild(name, parent.getChildAt(i) as DisplayObjectContainer);
            if (child)
               return child;
         }
         
         return null;
      }
      
      private static var _main:Sprite = null;
   }
}