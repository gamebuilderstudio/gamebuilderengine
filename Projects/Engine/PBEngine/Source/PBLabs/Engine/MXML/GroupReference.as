package PBLabs.Engine.MXML
{
   import PBLabs.Engine.Core.LevelManager;
   
   import mx.core.IMXMLObject;
   
   /**
    * The GroupReference class is meant to be used as an MXML tag to associate groups
    * with level numbers in the LevelManager.
    * 
    * @see PBLabs.Engine.Core.LevelManager
    */
   public class GroupReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The name of the group to instantiate with this reference.
       */
      public var name:String = "";
      
      [Bindable]
      /**
       * The level at which the group will be instantiated. A level of 0 means the group
       * will be instantiated at startup. Otherwise, the group will be instantiated when the
       * specified level is reached. Negative numbers can be used to initialize the group
       * with the level manager but instantiate it manually.
       */
      public var level:int = -1;
      
      [Bindable]
      /**
       * Setting this to true will keep the level manager from unloading this group
       * when advancing to the next level.
       */
      public var persist:Boolean = false;
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         LevelManager.Instance.AddGroupReference(name, level, persist);
      }
   }
}