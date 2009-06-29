package PBLabs.Tweaker
{
   import PBLabs.Engine.Entity.*;
   
   /** 
    * Map a cell (specified in standard spreadsheet notation, ie E4) to
    * a PropertyReference.
    * <p>
    * Most of the time you will want to set a value in a template, which can
    * be done using a PropertyReference in the form of 
    * #TemplateName.ComponentName.PropertyName.
    */
   public class TweakerMapEntry
   {
      public var Cell:String;
      public var Property:PropertyReference;
   }
}