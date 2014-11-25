package com.pblabs.engine.resource
{
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.resource.provider.EmbeddedResourceProvider;
   
   import flash.display.DisplayObject;
   import flash.system.ApplicationDomain;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   
   /**
    * The external resource bundle handles automatic loading and registering of external embedded resources.
    * To use, create a descendant class and embed resources as public variables, then
    * instantiate the class inside a module that will be later loaded using the ExternalResourceManager.  
    * ExternalResourceBundle will handle loading all of those resources into the ResourceManager and
    * the ExternalResourceManager.
    * 
    */
   public class ExternalResourceBundle
   {
      
      /**
       * ExtensionTypes associates filename extensions with the resource type that they are to be loaded as.
       *  Each entry should be in the form of 'xml:"com.pblabs.engine.resource.XMLResource"'
       *  Where xml is the filename extension that should be associated with this type, and  
       *  where "com.pblabs.engine.resource.XMLResource" is the fully qualified resource class name string.
       *
       * This array can be extended at runtime, such as:
       *  ExternalResourceBundle.ExtensionTypes.mycustomext = "com.mydomain.customresource"
       */
      
      public static var ExtensionTypes:Object = ResourceBundle.ExtensionTypes;
      
      /**
       * The constructor is where all of the magic happens.  
       * This is where the ExternalResourceBundle loops through all of its public properties
       *  and registers any embedded resources with the ResourceManager.
       */
      public function ExternalResourceBundle(rootSwf : DisplayObject)
      {
         // Make sure PBE is initialized - no resource manager, no love.
         try
         {
            // I search for the corresponding classes this way so the modules
            // containing the assets do not depend on the PBE classes.
            // This way we avoid including redundant classes and keep file size to its minimum.
            if (!PBE.resourceManager)
            {
               throw new Error("Cannot instantiate a ExternalResourceBundle until you have called PBE.startup(this);. Load the external resource module AFTER the call to PBE.startup().");
            }
         }
         catch (e:Error){}
         
         // Get information about our members (which will be external embedded resources)
         var desc:XML = describeType(rootSwf);
         var res:*;
         var resIsEmbedded:Boolean;
         var resSource:String;
         var resMimeType:String;
         var resTypeName:String;
         
         // Loop through each public variable in this class
         for each (var v:XML in desc.variable)
         {
            // Store a reference to the object
            res = rootSwf[v.@name];
            
            // Assume that it is not properly embedded, so that we can throw an error if needed.
            resIsEmbedded = false;
            resSource = "";
            resMimeType = "";
            resTypeName="";
            
			if(v.@type != 'Class' && res == null){
				res = rootSwf.loaderInfo.applicationDomain.getDefinition( String(v.@type) ) as Class;
			}
			
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
				   resIsEmbedded = true;
				   
				   for each (arg in meta.children())
				   {
					   if (arg.@key == "name") 
					   {
						   resSource = arg.@value;
					   } 
					   //Override to allow you to specify the resource type that should be used.
					   if (arg.@key == "className") 
					   {
						   resTypeName = arg.@value;
					   }
				   }                  
               }
            }
            
            // Now that we've processed all of the metadata, it's time to see if it embedded properly.
            // Sanity check:
            if (!resIsEmbedded || resSource == "" || res == null) 
            {
			   Logger.error(this, "ExternalResourceBundle", "A resource in the resource bundle with the name '" + v.@name + "' has failed to embed properly.  Please ensure that you have the command line option \"--keep-as3-metadata+=TypeHint,EditorData,Embed\" set properly.  Additionally, please check that the [Embed] metadata syntax is correct.");
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
				  Logger.warn(this, "ExternalResourceBundle", "No resource type specified for extension '." + ext + "'.  In the ExtensionTypes parameter, expected to see something like: ResourceBundle.ExtensionTypes.mycustomext = \"com.mydomain.customresource\" where mycustomext is the (lower-case) extension, and \"com.mydomain.customresource\" is a string of the fully qualified resource class name.  Defaulting to generic DataResource.");
                  
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
            try 
            {
               // Look up the class!
               resType = ApplicationDomain.currentDomain.getDefinition( resTypeName ) as Class;
            } 
            catch ( err:Error ) 
            {
               // Failed, so make sure it's null.
               resType = null;
            }
            
            if (!resType)
            {
			   Logger.error(this, "ResourceBundle", "The external resource type '" + resTypeName + "' specified for the embedded asset '" + resSource + "' could not be found.  Please ensure that the path name is correct, and that the class is explicity referenced somewhere in the project, so that it is available at runtime.  Do you call PBE.registerType(" + resTypeName + "); somewhere?");
               continue;
            }
            
            // Everything so far is hunky-dory -- go ahead and register the embedded resource with
            // the embedded resource provider!
            try 
            {
               // Registers the resource normally into the PBE EmbeddedResourceProvider
				var resource:*;
				if(res is Class)
					resource = new res();
				else 
					resource = res;
			   EmbeddedResourceProvider.instance.registerResource(resSource, resType, resource);
               
               // Registers the resource into ExternalResourceManager.
               // This will allow us to unload the resources when the module is unloaded.
			   ExternalResourceManager.instance.registerResource({source:resSource, resType:resType, cls:res});
            }
            catch(e:Error){}
         }
      }                  
   }
}