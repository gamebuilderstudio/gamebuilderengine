package PBLabs.Engine.UnitTestHelper
{
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Entity.PropertyReference;
   
   import flash.geom.Point;
   
   /**
    * @private
    */
   public class TestComponentB extends EntityComponent
   {
      public var TestComplex:Point = null;
      
      public var ATestValueReference:PropertyReference = new PropertyReference();
      
      public function GetTestValueFromA():int
      {
         return Owner.GetProperty(ATestValueReference);
      }
   }
}