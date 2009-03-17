package PBLabs.Rendering2D
{
   import flash.geom.Rectangle;
   
   /**
    * Base interface for descriptions about how frames are laid out in a sprite sheet.
    */
   public interface ISpriteSheetDivider
   {
      /**
       * How many frames are in this sprite sheet?
       */ 
      function get FrameCount():int;
      
      /**
       * Return the size of a frame, given the desired index and the source
       * image's dimensions.
       */
      function GetFrameArea(index:int):Rectangle;
      
      /**
       * Many times you want to infer information about frames based on data
       * from the sprite sheet. When the divider is assigned to a sprite sheet,
       * the sprite sheet passes itself to OwningSheet so you can store it and
       * get information from it.
       */
      function set OwningSheet(v:SpriteSheetComponent):void;
   }
}