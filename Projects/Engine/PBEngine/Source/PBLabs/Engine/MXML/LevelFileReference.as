package PBLabs.Engine.MXML
{
   import PBLabs.Engine.Core.LevelManager;
   
   import mx.core.IMXMLObject;
   
   /**
    * The LevelFileReference class is meant to be used as an MXML tag to associate level
    * files with level numbers in the LevelManager.
    * 
    * @see PBLabs.Engine.Core.LevelManager
    */
   public class LevelFileReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The filename of the level file to load with this reference.
       */
      public var filename:String = "";
      
      [Bindable]
      /**
       * The level at which the level file will be loaded. A level of 0 means the level
       * file will be loaded at startup. Otherwise, the level file will be loaded when the
       * specified level is reached. Negative numbers can be used to initialize the level
       * file with the level manager but load it manually.
       */
      public var level:int = -1;
      
      [Bindable]
      /**
       * Setting this to true will keep the level manager from unloading this level file
       * when advancing to the next level.
       */
      public var persist:Boolean = false;
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         LevelManager.Instance.AddLevelFileReference(filename, level, persist);
      }
   }
}