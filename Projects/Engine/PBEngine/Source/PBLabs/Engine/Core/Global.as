/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Core
{
   import flash.display.Stage;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   /**
    * This exists as a helper for retrieving the global Stage object.
    */
   public class Global
   {
      public static function get MainStage():Stage
      {
         if (_main == null)
            throw new Error("Cannot retrieve the global stage instance until MainClass has been set to the startup class!");
         
         return _main.stage;
      }
      
      public static function get MainClass():Sprite
      {
         return _main;
      }
      
      public static function set MainClass(value:Sprite):void
      {
         _main = value;
      }
      
      public static function FindChild(name:String):DisplayObject
      {
         return _FindChild(name, _main);
      }
      
      private static function _FindChild(name:String, parent:DisplayObjectContainer):DisplayObject
      {
         if (parent == null)
            return null;
         
         if (parent.name == name)
            return parent;
         
         for (var i:int = 0; i < parent.numChildren; i++)
         {
            var child:DisplayObject = _FindChild(name, parent.getChildAt(i) as DisplayObjectContainer);
            if (child != null)
               return child;
         }
         
         return null;
      }
      
      private static var _main:Sprite = null;
   }
}