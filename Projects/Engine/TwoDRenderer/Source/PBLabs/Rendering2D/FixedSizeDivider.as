package PBLabs.Rendering2D
{
   import flash.geom.Rectangle;
   
  /**
   * Divide a sprite sheet into fixed-size cells.
   */
   public class FixedSizeDivider implements ISpriteSheetDivider
   {
      public var Width:int = 30, Height:int = 16;

      public function set OwningSheet(v:SpriteSheetComponent):void
      {
         _OwningSheet = v;
      }

      public function get FrameCount():int
      {
         if(!_OwningSheet) throw new Error("Must have a valid sheet!");
         
         return Math.floor(_OwningSheet.ImageData.width / Width) * Math.floor(_OwningSheet.ImageData.height / Height);
      }
      
      public function GetFrameArea(index:int):Rectangle
      {
         if(!_OwningSheet) throw new Error("Must have a valid sheet!");

         var x:int = index % Math.floor(_OwningSheet.ImageData.width / Width);
         var y:int = Math.floor(index / Math.floor(_OwningSheet.ImageData.width / Width));
         
         return new Rectangle(x * Width, y * Height, Width, Height);
      }

      private var _OwningSheet:SpriteSheetComponent;
   }
}