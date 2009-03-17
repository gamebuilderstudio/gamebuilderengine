package PBLabs.Engine.UnitTests
{
   import PBLabs.Engine.Debug.Logger;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class ResourceTests extends TestCase
   {
      public function testResourceLoad():void
      {
         Logger.PrintHeader(null, "Running Resource Load Test");
         Logger.PrintFooter(null, "");
      }
      
      public function testReferenceCounting():void
      {
         Logger.PrintHeader(null, "Running Resource Reference Count Test");
         Logger.PrintFooter(null, "");
      }
   }
}