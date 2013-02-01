package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.DataResource;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.rendering2D.BitmapRenderer;
	import com.pblabs.rendering2D.fonts.BMFont;
	import com.pblabs.screens.ScreenManager;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import spark.primitives.Rect;
	
	public class UITextRendererComponent extends BitmapRenderer implements ITextRenderer
	{
		[EditorData(ignore="true")]
		public var textFormatter : TextFormat = new TextFormat("Arial", 30, 0xFFFFFF, true);
		public var autoResize : Boolean = true;
		
		protected var _bmFontObject : BMFont;
		protected var _textDisplay : TextField = new TextField();
		protected var _fontImage : ImageResource;
		protected var _fontData : DataResource;
		protected var _textDirty : Boolean = false;
		protected var _textInputType : String = TextFieldType.DYNAMIC;
		protected var _stagePoint : Point = new Point();
		protected var _previousAlpha : Number = 0;
		protected var _inputEnabled : Boolean = false;
		protected var _startMouseDownPos : Point = new Point();
		
		public function UITextRendererComponent()
		{
			super();
			//_displayObject = _textDisplay;
		}
		
		override public function onFrame(elapsed:Number):void
		{
			buildFontObject();
			
			if(_textDirty == true){
				paintTextToBitmap();
			}
			
			if(_inputEnabled && _transformDirty)
				hideInputField(null);
			if(_inputEnabled && this._alpha != 0)
				this.alpha = 0;
			super.onFrame(elapsed);
		}
		
		override protected function onAdd():void
		{
			/*if(!_textDisplay.text || _textDisplay.text == "") 
				text = "[EMPTY]";*/
			_textDisplay.defaultTextFormat = textFormatter;
			_textDisplay.autoSize = TextFieldAutoSize.LEFT;

			updateFontSize();
			paintTextToBitmap();
			
			PBE.mainStage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true);
			PBE.mainStage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);
			
			_textDisplay.addEventListener(Event.CHANGE, inputChanged);
			_textDisplay.addEventListener(FocusEvent.FOCUS_OUT, hideInputField);
			
			super.onAdd();
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true)
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);

			_textDisplay.removeEventListener(Event.CHANGE, inputChanged);
			_textDisplay.removeEventListener(FocusEvent.FOCUS_OUT, hideInputField);
			_textDisplay = null;
		}
		
		protected function inputChanged(event : Event):void
		{
			_textDisplay.setTextFormat(textFormatter);
			if(autoResize)
				_textDisplay.width += 25;
		}
		
		protected function onStageMouseDown(event : MouseEvent):void
		{
			_startMouseDownPos.setTo( event.stageX, event.stageY );
		}
		
		protected function onStageMouseUp(event : MouseEvent):void
		{
			_stagePoint.setTo( event.stageX, event.stageY );
			if(!_transformDirty && _startMouseDownPos.equals(_stagePoint))
				toggleInputDisplay();
		}
		
		protected function toggleInputDisplay():void
		{
			var localBounds : Rectangle = this.localBounds;
			localBounds.inflate( 10, 10 );
			localBounds.x -= 10;
			localBounds.y -= 10;
			var localTextPoint : Point = scene ? this.transformWorldToObject( scene.transformScreenToWorld(_stagePoint) ) : new Point();
			if( localBounds.containsPoint( localTextPoint ) && scene && _textDisplay.type == TextFieldType.INPUT && !_inputEnabled)
			{
				_textDisplay.selectable = true;
				var globalPoint : Point = scene.transformSceneToScreen( new Point(_transformMatrix.tx, _transformMatrix.ty) );
				PBE.mainStage.addChild(_textDisplay);
				_textDisplay.x = globalPoint.x;
				_textDisplay.y = globalPoint.y;
				_textDisplay.setTextFormat(textFormatter);
				var charIndex : int = _textDisplay.getCharIndexAtPoint(localTextPoint.x, localTextPoint.y);
				PBE.mainStage.focus = _textDisplay;
				_textDisplay.setSelection(charIndex, charIndex);
				if(autoResize)
					_textDisplay.width += 15;
				
				_previousAlpha = this._alpha;
				_inputEnabled = true;
			}else if(!localBounds.containsPoint( localTextPoint ) && _inputEnabled){
				hideInputField(null);
			}
		}
		
		protected function hideInputField(event : FocusEvent):void
		{
			_textDisplay.setSelection(0, 0);
			PBE.mainStage.focus = null;
			_textDisplay.selectable = false;
			if(PBE.mainStage.contains(_textDisplay))
				PBE.mainStage.removeChild(_textDisplay);

			this.alpha = _previousAlpha;
			_inputEnabled = false;
			text = _textDisplay.text;
		}
		
		protected function buildFontObject():void
		{
			if(!_bmFontObject && fontData && fontData.isLoaded && fontImage && fontImage.isLoaded)
			{
				var fontDataStr : String = fontData.data.readUTFBytes(fontData.data.length);
				_bmFontObject = new BMFont();
				_bmFontObject.parseFont(fontDataStr);
				
				_bmFontObject.addSheet(0, fontImage.bitmapData);
			}
		}
		
		protected function paintTextToBitmap():void
		{
			if(!size || size.x == 0 || size.y == 0) {
				this.bitmapData = new BitmapData(150,50);
				return;
			}
			if(!_bmFontObject)
				buildFontObject();
			//var bounds : Rectangle = _textDisplay.getBounds(_textDisplay);
			var textBitmapData:BitmapData = this.originalBitmapData;
			if(textBitmapData) 
				textBitmapData.fillRect(textBitmapData.rect, 0);
			if(!this.bitmapData || this.bitmapData.width != size.x || this.bitmapData.height != size.y || this.text == "")
			{
				if(textBitmapData)
					textBitmapData.dispose();
				textBitmapData = new BitmapData(size.x, size.y, true, 0x0);
			}
			textBitmapData.lock();
			if(_bmFontObject && fontData && fontData.isLoaded && fontData && fontData.isLoaded )
			{
				// OK, draw some fonts!
				_bmFontObject.drawString(textBitmapData, 0, 0, _textDisplay.text);
			}else{
				textBitmapData.draw(_textDisplay);
			}
			textBitmapData.unlock();
			this.bitmapData = textBitmapData;
			
			_textDirty = false;
		}
		
		protected var _newTextSize : Point = new Point();
		protected function updateFontSize():void
		{
			if(!_textDisplay || !autoResize) 
				return;
			
			var textSize : Rectangle = _textDisplay.getBounds(_textDisplay);
			_newTextSize.setTo( textSize.width+10, textSize.height+10);
			if(sizeProperty && sizeProperty.property != "")
			{
				size = _newTextSize;
				if(owner)
					this.owner.setProperty( sizeProperty, _newTextSize )
			}else{
				size = _newTextSize;
			}
		}

		public function get fontImage():ImageResource{ return _fontImage; }
		public function set fontImage(img : ImageResource):void{
			_fontImage = img;
		}

		public function get fontData():DataResource{ return _fontData; }
		public function set fontData(data : DataResource):void{
			_fontData = data;
		}

		public function get fontColor():uint{ return uint(textFormatter.color); }
		public function set fontColor(val : uint):void{
			textFormatter.color = val;
			_textDisplay.setTextFormat(textFormatter);
			_textDisplay.autoSize = TextFieldAutoSize.LEFT;
			_textDirty = true;
		}
		
		public function get fontSize():Number{ return int(textFormatter.size); }
		public function set fontSize(val : Number):void{
			textFormatter.size = val;
			_textDisplay.setTextFormat(textFormatter);
			_textDisplay.autoSize = TextFieldAutoSize.LEFT;
			
			updateFontSize();
			//Logger.print(this, "Text Size = W - "+_textDisplay.textWidth + ", H - "+_textDisplay.textHeight);
			_textDirty = true;
		}

		public function get text():String{ return _textDisplay.text; }
		public function set text(val : String):void{
			if(!val || val == ""){
				_textDisplay.text = "";
			}else{
				_textDisplay.text = val;
				_textDisplay.setTextFormat(textFormatter);
				_textDisplay.autoSize = TextFieldAutoSize.LEFT;
				updateFontSize();
			}
			_textDirty = true;
		}

		override public function set size(val : Point):void{
			if(!val.equals(this._size))
				_textDirty = true;
			super.size = val;
		}
		override public function set scale(val : Point):void{
			if(!val.equals(this._scale))
				_textDirty = true;
			super.scale = val;
		}

		public function get type():String{ return _textInputType; }
		public function set type(val : String):void{
			_textInputType = val;
			_textDirty = true;
			_textDisplay.type = _textInputType;
		}
	
		public function get nativeTextField():TextField{ return _textDisplay; }
	}
}