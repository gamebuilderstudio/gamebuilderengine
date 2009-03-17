package PBLabs.Engine.Components
{
   import PBLabs.Engine.Core.IAnimatedObject;
   import PBLabs.Engine.Core.ProcessManager;
   import PBLabs.Engine.Entity.EntityComponent;
   
   /**
    * Base class for components that need to perform actions every frame. This
    * needs to be subclassed to be useful.
    */
   public class AnimatedComponent extends EntityComponent implements IAnimatedObject
   {
      /**
       * The update priority for this component. Higher numbered priorities have
       * OnFrame called before lower priorities.
       */
      public var UpdatePriority:Number = 0.0;
      
      /**
       * @inheritDoc
       */
      public function OnFrame(elapsed:Number):void
      {
      }
      
      protected override function _OnAdd():void
      {
         ProcessManager.Instance.AddAnimatedObject(this, UpdatePriority);
      }
      
      protected override function _OnRemove():void
      {
         ProcessManager.Instance.RemoveAnimatedObject(this);
      }
   }
}