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
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.core.SchemaGenerator;
   
   import flash.utils.getQualifiedClassName;
   
   import mx.core.IMXMLObject;

   /**
    * The TypeReference class is meant to be used as an MXML tag to force
    * inclusion of specific types in a project.
    * 
    * <p>This is necessary because the Flex compiler will only include definitions
    * of classes that are explicitly referenced somewhere in a project's codebase.
    * Since PBE is heavily data driven with most objects being instantiated from
    * XML, it is very likely that several components will not be compiled without
    * the use of this class.</p>
    */
   public class TypeReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The class of the type to force a reference to.
       */
      public var type:Class; 
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         if (!PBE.IS_SHIPPING_BUILD)
         {
            var name:String = getQualifiedClassName(type);
            SchemaGenerator.instance.addClass(name, type);
         }
      }
   }
}