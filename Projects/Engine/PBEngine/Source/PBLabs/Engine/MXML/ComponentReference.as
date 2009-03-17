package PBLabs.Engine.MXML
{
   import mx.core.IMXMLObject;
   
   /**
    * The ComponentReference class is meant to be used as an MXML tag to force
    * inclusion of specific components in a project.
    * 
    * <p>This is necessary because the Flex compiler will only include definitions
    * of classes that are explicitly referenced somewhere in a project's codebase.
    * Since PBE is heavily data driven with most objects being instantiated from
    * XML, it is very likely that several components will not be compiled without
    * the use of this class.</p>
    * 
    * @see ../../../../../Examples/ComponentReferences.html Component References
    */
   public class ComponentReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The class of the component to force a reference to.
       */
      public var componentClass:Class; 
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
      }
   }
}