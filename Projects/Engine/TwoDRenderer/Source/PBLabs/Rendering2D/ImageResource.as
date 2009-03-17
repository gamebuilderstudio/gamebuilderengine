package PBLabs.Rendering2D
{
   import PBLabs.Engine.Resource.Resource;
   
   import flash.display.Bitmap;
   
   /**
    * This is a Resource subclass for image data.
    */
   public class ImageResource extends Resource
   {
      /**
       * Once the resource has succesfully loaded, this contains a bitmap representing
       * the loaded image.
       */
      public function get Image():Bitmap
      {
         return _image;
      }
      
      /**
       * @inheritDoc
       */
      override protected function _OnContentReady(content:*):Boolean 
      {
         _image = content as Bitmap;
         return _image != null;
      }
      
      private var _image:Bitmap = null;
   }
}