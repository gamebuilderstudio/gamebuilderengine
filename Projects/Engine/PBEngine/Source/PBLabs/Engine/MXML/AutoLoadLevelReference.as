package PBLabs.Engine.MXML
{
   import PBLabs.Engine.Core.LevelManager;
   
   import mx.core.IMXMLObject;
   
   /**
    * The AutoLoadLevelReference class is meant to be used as an MXML tag to inform
    * the LevelManager that a specific level should be automatically loaded.
    * 
    * @see PBLabs.Engine.Core.LevelManager
    */
   public class AutoLoadLevelReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The level to load automatically.
       */
      public var level:int = -1;
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         LevelManager.Instance.AddAutoLoadLevel(level);
      }
   }
}