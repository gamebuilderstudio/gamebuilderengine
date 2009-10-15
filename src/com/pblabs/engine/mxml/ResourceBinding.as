/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.mxml
{
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.resource.Resource;
   import com.pblabs.engine.resource.provider.EmbeddedResourceProvider;
   
   import mx.core.IMXMLObject;
   
   /**
    * The ResourceBinding class is meant to be used as an MXML tag to embed resources
    * in the project's resulting .swf file. Embedded resources provide several benefits,
    * the most useful of which is that the loading time of the swf will be less due to
    * a decreased download time.
    * 
    * <p>Embedded resources can be accessed just like any other resource with the resource
    * manager's Load method. The only difference is that a reference to embedded resources
    * will always exist, and therefore they will never be unloaded.</p>
    * 
    * @see com.pblabs.engine.core.ResourceManager
    * @see ../../../../../Examples/EmbeddingResources.html Embedding Resources
    */
   public class ResourceBinding implements IMXMLObject
   {
      [Bindable] 
      [Inspectable(category="General", defaultValue="", format="File")]
      /**
       * The embed statement for the asset that is to be embedded.
       */
      public var resourceClass:Class;
      
      [Bindable]
      /**
       * The string by which the resource can be looked up in the resource manager.
       * It should usually match the filename of the asset for clarity.
       */
      public var filename:String;
      
      [Bindable]
      /**
       * The Resource subclass that should be created for this asset.
       * 
       * @see com.pblabs.engine.core.Resource
       */
      public var resourceType:Class;
      
      /**
       * The static array that will hold all bindings so the EmbeddedResourceProvider
       * can retrive it
       * 
       * @see com.pblabs.engine.core.Resource
       */
             
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {      	
         if (!resourceClass)
         {
            Logger.error("ResourceBinding", "", "Invalid resourceClass specified for binding of " + filename + ".");
            return;
         }
         
         var resource:* = new resourceType();
         if (!(resource is Resource))
         {
            Logger.error("ResourceBinding", "", "Invalid resourceType specified for binding of " + filename + ".");
            return;
         }
         
         var item:* = new resourceClass();
                          
         /*if (!(item is ByteArray))
         {
            //Logger.error("ResourceBinding", "", "The loaded resourceClass for binding of " + filename + " is not a ByteArray.");
            //return;
         } */
         
         EmbeddedResourceProvider.instance.registerResource(filename, resourceType, item);
      }
   }
}