package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.resource.DataResource;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.rendering2D.BitmapRenderer;
	import com.pblabs.rendering2D.fonts.BMFont;
	import com.pblabs.screens.ScreenManager;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import spark.primitives.Rect;
	
	public class UITextRendererComponent extends BitmapRenderer
	{
		public var fontImage : ImageResource;
		public var fontData : DataResource;
		
		public var textFormatter : TextFormat = new TextFormat("Arial", 30, 0xFFFFFF, true);
		
		private var bmFontObject : BMFont;
		private var textDisplay : TextField = new TextField();
		
		public function UITextRendererComponent()
		{
			super();
			//_displayObject = textDisplay;
		}
		
		override public function onFrame(elapsed:Number):void
		{
			buildFontOBject();
			super.onFrame(elapsed);
		}
		
		override protected function onAdd():void
		{
			if(!textDisplay.text || textDisplay.text == "") 
				text = "NEW TEXT";
			textDisplay.selectable = false;
			
			/*if(_displayObject == textDisplay && useBitmapFont && fontImage && fontData)
				_displayObject = null;*/

			super.onAdd();
		}
		
		private function buildFontOBject():void
		{
			if(!bmFontObject && fontData && fontData.isLoaded && fontImage && fontImage.isLoaded)
			{
				var fontData : String = fontData.data.readUTFBytes(fontData.data.length);
				bmFontObject = new BMFont();
				bmFontObject.parseFont(fontData);
				
				bmFontObject.addSheet(0, fontImage.bitmapData);
				
				paintTextToBitmap();
			}
		}
		
		private function paintTextToBitmap():void
		{
			if(!size || size.x == 0 || size.y == 0) {
				this.bitmapData = new BitmapData(100,100);
				return;
			}
			if(!bmFontObject)
				buildFontOBject();
			//var bounds : Rectangle = textDisplay.getBounds(textDisplay);
			var textBitmapData:BitmapData = this.originalBitmapData;
			textBitmapData.fillRect(textBitmapData.rect, 0);
			if(!this.bitmapData || this.bitmapData.width != size.x || this.bitmapData.height != size.y)
			{
				textBitmapData = new BitmapData(size.x, size.y, true, 0x0);
			}
			textBitmapData.lock();
			if(bmFontObject && fontData && fontData.isLoaded && fontData && fontData.isLoaded )
			{
				// OK, draw some fonts!
				bmFontObject.drawString(textBitmapData, 0, 0, textDisplay.text);
			}else{
				textBitmapData.draw(textDisplay);
			}
			textBitmapData.unlock();
			this.bitmapData = textBitmapData;
		}

		public function get fontColor():uint{ return uint(textFormatter.color); }
		public function set fontColor(val : uint):void{
			textFormatter.color = val;
			textDisplay.setTextFormat(textFormatter);
			textDisplay.autoSize = TextFieldAutoSize.LEFT;
			paintTextToBitmap();
		}
		
		public function get fontSize():int{ return int(textFormatter.size); }
		public function set fontSize(val : int):void{
			textFormatter.size = val;
			textDisplay.setTextFormat(textFormatter);
			textDisplay.autoSize = TextFieldAutoSize.LEFT;
			paintTextToBitmap();
		}

		public function get text():String{ return textDisplay.text; }
		public function set text(val : String):void{
			textDisplay.text = val;
			textDisplay.setTextFormat(textFormatter);
			textDisplay.autoSize = TextFieldAutoSize.LEFT;
			paintTextToBitmap();
		}

		override public function set size(val : Point):void{
			super.size = val;
			paintTextToBitmap();
		}
		override public function set scale(val : Point):void{
			super.scale = val;
			paintTextToBitmap();
		}
	}
}