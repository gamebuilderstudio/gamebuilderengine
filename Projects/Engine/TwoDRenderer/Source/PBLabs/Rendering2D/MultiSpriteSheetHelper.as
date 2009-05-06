package PBLabs.Rendering2D
{
   import PBLabs.Engine.Entity.*;
   
   import flash.geom.Point;
   import flash.utils.Dictionary;

   /**
    * Helper to manage many similar sprite sheets (for instance, multiple sheets
    * for the same character). You can specify a divider and directions-per-frame
    * count, then a dictionary where the keys are the names of the sheets (for 
    * instance "Run") and the file to load from (for instance 
    * "../Assets/Images/MyCharacterRun.gif"). New SpriteSheetComponents are
    * created by this component and added to the owning Entity. Then you can get
    * at the sheets by referencing this component's owning entity and the name
    * of the sheet you specified in the Sheets dictionary.
    */ 
	public class MultiSpriteSheetHelper extends EntityComponent
	{
	   public var Divider:ISpriteSheetDivider;
	   public var DirectionsPerFrame:int;
	   public var Center:Point = new Point();
	   public var Sheets:Dictionary = new Dictionary();
	   
	   protected override function _OnAdd():void
	   {
	      // Create the sheets.
	      for(var key:String in Sheets)
	      {
	         var file:String = Sheets[key];
	         
	         var newSheet:SpriteSheetComponent = new SpriteSheetComponent();
	         newSheet.DirectionsPerFrame = DirectionsPerFrame;
	         newSheet.Divider = Divider;
	         newSheet.ImageFilename = file;
	         newSheet.Center = Center;
	         
	         Owner.AddComponent(newSheet, key);
	      }
	   }
	}
}
