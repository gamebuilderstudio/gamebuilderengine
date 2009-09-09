/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.resource
{
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.serialization.TypeUtility;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.ByteArray;
   
   /**
    * The resource bundle handles automatic loading and registering of embedded resources.
    * To use, create a descendant class and embed resources as public variables, then
    *  instantiate your new class.  ResourceBundle will handle loading all of those resources
    *  into the ResourceManager. 
    * 
    * @see ../../../../../Reference/ResourceManager.html The Resource Manager
    * @see ../../../../../Examples/UsingResources.html Using Resources
    */
   public class ResourceBundle
   {
    
      /**
       * ExtensionTypes associates filename extensions with the resource type that they are to be loaded as.
       *  Each entry should be in the form of 'xml:"com.pblabs.engine.resource.XMLResource"'
       *  Where xml is the filename extension that should be associated with this type, and  
       *  where "com.pblabs.engine.resource.XMLResource" is the fully qualified resource class name string,
       *  and png is the (lower-case) extension.
       *
       * This array can be extended at runtime, such as:
       *  ResourceBundle.ExtensionTypes.mycustomext = "com.mydomain.customresource"
       */
      public static var ExtensionTypes:Object = {
                                                 png:"com.pblabs.rendering2D.ImageResource",
                                                 jpg:"com.pblabs.rendering2D.ImageResource",
                                                 gif:"com.pblabs.rendering2D.ImageResource",
                                                 bmp:"com.pblabs.rendering2D.ImageResource",
                                                 xml:"com.pblabs.engine.resource.XMLResource",
                                            pbelevel:"com.pblabs.engine.resource.XMLResource",
                                                 mp3:"com.pblabs.engine.resource.MP3Resource"
                                                };
                                                 
      /**
       * The constructor is where all of the magic happens.  
       * This is where the ResourceBundle loops through all of its public properties
       *  and registers any embedded resources with the ResourceManager.
       */
      public function ResourceBundle()
      {
         var desc:XML= describeType(this);
         var res:Class;
         var resIsEmbedded:Boolean;
         var resSource:String;
         var resMimeType:String;

         var resTypeName:String;

         new DataResource();

         
         // Loop through each public variable in this class
         for each (var v:XML in desc.variable){

            // Store a reference to the object
            res = this[v.@name];

            // Assume that it is not properly embedded, so that we can throw an error if needed.
            resIsEmbedded = false;
            resSource = "";
            resMimeType = "";
            resTypeName="";
                        
            // Loop through each metadata tag in the child variable
            for each (var meta:XML in v.children())
            {
               // If we've got an embedded metadata
               if (meta.@name == "Embed") 
               {
                  // If we've got a valid embed tag, then the resource embedded correctly.
                  resIsEmbedded = true;
                  
                  // Extract the source and MIME information from the embed tag.
                  for each (var arg:XML in meta.children())
                  {
                     if (arg.@key == "source") 
                     {
                        resSource = arg.@value;
                     } 
                     else if (arg.@key == "mimeType") 
                     {
                        resMimeType = arg.@value;
                     }
                  }
               }
               else if (meta.@name == "ResourceType")
               {
                  for each (arg in meta.children())
                  {
                     if (arg.@key == "className") 
                     {
                        resTypeName = arg.@value;
                     } 
                  }                  
               }
            }
            
            // Now that we've processed all of the metadata, it's time to see if it embedded properly.
            
            // Sanity check:
            if ( !resIsEmbedded || resSource == "" || res == null ) 
            {
               Logger.printError(this, "ResourceBundle", "A resource in the resource bundle with the name '" + v.@name + "' has failed to embed properly.  Please ensure that you have the command line option \"--keep-as3-metadata+=TypeHint,EditorData,Embed\" set properly.  Additionally, please check that the [embed] metadata syntax is correct."); 
               continue;
            }

            // If a metadata tag isn't specified with the resource type name explicitly,
            if (resTypeName == "")
            {
               // Then look up the class name by extension (this is the default behavior).
  
               // Get the extension of the source filename
               var extArray:Array = resSource.split(".");
               var ext:String = (extArray[extArray.length-1] as String).toLowerCase();

               // If the extension type is recognized or not...
               if ( !ExtensionTypes.hasOwnProperty(ext) )
               {
                  Logger.printWarning(this, "ResourceBundle", "No resource type specified for extension '." + ext + "'.  In the ExtensionTypes parameter, expected to see something like: ResourceBundle.ExtensionTypes.mycustomext = \"com.mydomain.customresource\" where mycustomext is the (lower-case) extension, and \"com.mydomain.customresource\" is a string of the fully qualified resource class name.  Defaulting to generic DataResource.");

                  // Default to a DataResource if no other name is specified.
                  resTypeName = "com.pblabs.engine.resource.DataResource";
               }
               else
               {
                  // And if the assigned value is a valid resource type, then take it from the array.
                  resTypeName = ExtensionTypes[ext] as String;
               }
            }
            
            // Now that we (hopefully) have our resource type name, we can try to instantiate it.
            
            
            var resType:Class;
            try {
               resType = getDefinitionByName( resTypeName ) as Class;
//            } catch ( err:ReferenceError ) {
            } catch ( err:Error ) {
               resType = null;
            }

            if (!resType)
            {
               Logger.printError(this, "ResourceBundle", "The resource type '" + resTypeName + "' specified for the embedded asset '" + resSource + "' could not be found.  Please ensure that the path name is correct, and that the class is explicity referenced somewhere in the project, so that it is available at runtime.  Did you properly reference this class in your References.as / References.mxml?");
               continue;
            }
            
            // The resource type is a class -- let's make sure it's a Resource
            
            var testResource:* = new resType();
            if (!(testResource is Resource))
            {
               Logger.printError(this, "ResourceBundle", "The resource type '" + resTypeName + "' specified for the embedded asset '" + resSource + "' is not a descendant from Resource.  Please ensure that the resource class descends properly from com.pblabs.engine.resource.Resource, and is defined correctly.");
               continue;
            }

            // Everything so far is hunky-dory -- go ahead and register the embedded resource!
            ResourceManager.instance.registerEmbeddedResource( resSource, resType, new res() );
         }
      }
   }
}
