package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.resource.DataResource;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.engine.resource.ResourceEvent;
	import com.pblabs.engine.resource.ResourceManager;
	import com.pblabs.rendering2D.BitmapRenderer;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import pxBitmapFont.PxBitmapFont;
	import pxBitmapFont.PxTextField;
	
	public class UITextRendererComponent extends BitmapRenderer implements ITextRenderer
	{
		[EditorData(ignore="true")]
		public var textFormatter : TextFormat = new TextFormat("Arial", 30, 0xFFFFFF, false);
		
		protected var _bmFontObject : PxTextField;
		protected var _textDisplay : TextField = new TextField();
		protected var _fontImage : ImageResource;
		protected var _fontData : DataResource;
		protected var _textDirty : Boolean = true;
		protected var _textSizeDirty : Boolean = true;
		protected var _textInputType : String = TextFieldType.DYNAMIC;
		protected var _stagePoint : Point = new Point();
		protected var _previousAlpha : Number = 0;
		protected var _inputEnabled : Boolean = false;
		protected var _startMouseDownPos : Point = new Point();
		protected var _wordWrap : Boolean = false; 
		protected var _autoResize : Boolean = true;
		protected var _worldScratchPoint : Point = new Point();

		private var _textSize : Point = new Point();
		
		public function UITextRendererComponent()
		{
			super();
			//_displayObject = _textDisplay;
		}
		
		override public function onFrame(elapsed:Number):void
		{
			updateTextImage();
			super.onFrame(elapsed);
		}
		
		override protected function onAdd():void
		{
			/*if(!_textDisplay.text || _textDisplay.text == "") 
				text = "[EMPTY]";*/
			if(!_textDisplay)
				_textDisplay = new TextField();
			_textDisplay.wordWrap = _wordWrap;
			_textDisplay.multiline = _wordWrap;
			_textDisplay.setTextFormat(textFormatter);
			_textDisplay.mouseEnabled = true;
			_textDisplay.autoSize = TextFieldAutoSize.LEFT;

			updateFontSize();
			paintTextToBitmap();
			
			super.onAdd();
		}
		
		override protected function onRemove():void
		{
			if(!isComposedTextData && this.bitmapData)
				this.bitmapData.dispose();

			super.onRemove();
			
			if(_fontData)
				_fontData.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			if(_fontImage)
				_fontImage.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);

			if(_bmFontObject)
				_bmFontObject.destroy();
			if(_textInputType == TextFieldType.INPUT){
				PBE.mainStage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true)
				PBE.mainStage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);

				_textDisplay.removeEventListener(Event.CHANGE, inputChanged);
				_textDisplay.removeEventListener(FocusEvent.FOCUS_OUT, hideInputField);
			}
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
			if(!_transformDirty && _startMouseDownPos.equals(_stagePoint) && !PBE.IN_EDITOR)
				toggleInputDisplay();
		}
		
		protected function toggleInputDisplay():void
		{
			var localBounds : Rectangle = this.localBounds;
			
			//Add padding to bounds
			localBounds.inflate( 10, 10 );
			
			var localTextPoint : Point = getLocalPointOfStage(_stagePoint);
			if( localBounds.containsPoint( localTextPoint ) && scene && _textDisplay.type == TextFieldType.INPUT && !_inputEnabled)
			{
				_textDisplay.selectable = true;
				_worldScratchPoint.setTo(_transformMatrix.tx, _transformMatrix.ty);
				var globalPoint : Point = scene.transformWorldToScreen( _worldScratchPoint );
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
				PBE.mainStage.focus = _textDisplay;
				_textDisplay.requestSoftKeyboard();
			}else if(!localBounds.containsPoint( localTextPoint ) && _inputEnabled){
				hideInputField(null);
				PBE.mainStage.focus = null;
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
		
		protected function updateTextImage():void
		{
			if(_inputEnabled && _transformDirty)
				hideInputField(null);

			if(_textSizeDirty)
			{
				updateFontSize();
			}
			if(_textDirty){
				paintTextToBitmap();
			}
			
			if(_inputEnabled && this._alpha != 0)
				this.alpha = 0;
		}
		
		protected function getLocalPointOfStage(stagePoint : Point):Point
		{
			var localTextPoint : Point = scene ? this.transformWorldToObject( scene.transformScreenToWorld(stagePoint) ) : new Point();
			return localTextPoint;
		}
		
		protected function buildFontObject():void
		{
			if(!_bmFontObject && isComposedTextData && _fontData.isLoaded && _fontImage.isLoaded)
			{
				_fontData.data.position = 0;
				var fontDataXMLStr : String = _fontData.data.readUTFBytes(_fontData.data.length);
				var fontXML : XML = XML(fontDataXMLStr);
				var fontName : String = fontXML.info.@face;
				
				var font : PxBitmapFont = PxBitmapFont.fetch(fontName);
				if(!font){
					font = new PxBitmapFont().loadAngelCode(_fontImage.bitmapData, fontXML);
					PxBitmapFont.store(fontName, font);
				}
				_bmFontObject = new PxTextField();
				_bmFontObject.text = _text;
				_bmFontObject.color = textFormatter.color as uint;
				_bmFontObject.fixedWidth = !_autoResize;
				_bmFontObject.wordWrap = _wordWrap;
				_bmFontObject.multiLine = _wordWrap;
				_bmFontObject.font = font;
				//_bmFontObject.lineSpacing = 2;
				this.fontName = fontName;
			}
		}
		
		protected function paintTextToBitmap(reuseBitmap : Boolean = true):void
		{
			var textBitmapData:BitmapData = bitmapData;
			var clearedBitmap : Boolean = false;
			
			if(!size || size.x < 1 || size.y < 1) {
				this.bitmapData = new BitmapData(150,50);
				return;
			}

			if(!_bmFontObject)
				buildFontObject();
			
			if(isComposedTextData && _bmFontObject)
			{
				_bmFontObject.update();
				textBitmapData = _bmFontObject.bitmapData;
			}else if(!isComposedTextData) {
				if(!textBitmapData || _textSizeDirty || this.text == "" || !reuseBitmap)
				{
					if(textBitmapData)
						textBitmapData.dispose();
					var bw : Number = this._size.x * (this._scale.x * ResourceManager.scaleFactor);
					var bh : Number = this._size.y * (this._scale.y * ResourceManager.scaleFactor);
					textBitmapData = new BitmapData(PBUtil.clamp(bw, 10, Number.MAX_VALUE), PBUtil.clamp(bh, 10, Number.MAX_VALUE), true, 0x0);
					clearedBitmap = true;
				}
				if(reuseBitmap && textBitmapData && !clearedBitmap){
					textBitmapData.fillRect(textBitmapData.rect, 0x0);
				}
				textBitmapData.lock();
				textBitmapData.draw(_textDisplay);
				textBitmapData.unlock();
			}
			if(!textBitmapData) return;
			
			this.bitmapData = textBitmapData;
			
			_textDirty = false;
			_textSizeDirty = false;
		}
		
		protected var _newTextSize : Point = new Point();
		protected function updateFontSize():void
		{
			if(!_bmFontObject)
				buildFontObject();

			if(autoResize){
				if(!isComposedTextData)
				{
					_textDisplay.width = this._size.x * this._scale.x;
					_textDisplay.height = this._size.y * this._scale.y;
					var textSize : Rectangle = _textDisplay.getBounds(_textDisplay);
					_newTextSize.setTo(textSize.width, textSize.height);
				}else if(isComposedTextData && _bmFontObject) {
					_bmFontObject.update();
					_newTextSize.setTo( _bmFontObject.width, _bmFontObject.height );
				}
				if(!this._size.equals(_newTextSize ))
					_transformDirty = true;
				
				if(sizeProperty && sizeProperty.property != "")
				{
					this._size = _newTextSize.clone();
					if(owner && sizeProperty)
						this.owner.setProperty( sizeProperty, _newTextSize.clone() )
				}else{
					this._size = _newTextSize.clone();
				}
			}
			if(!isComposedTextData && _textDisplay){
				_textDisplay.width = this._size.x * this._scale.x;
				_textDisplay.height = this._size.y * this._scale.y;
			}else if(!autoResize && isComposedTextData && _bmFontObject){
				_bmFontObject.width = this._size.x * this._scale.x;
				_bmFontObject.height = this._size.y * this._scale.y;
			}
		}
		
		protected function onResourceUpdated(event : ResourceEvent):void
		{
			if(_bmFontObject){
				_bmFontObject.destroy();
				_bmFontObject = null;
				PxBitmapFont.remove(fontName);
			}
			_textDirty = true;
			paintTextToBitmap();
			if(this.owner)
				this.owner.reset();
		}

		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!displayObject)
				return;
			
			if(updateProps)
				updateProperties();
			
			_transformMatrix.identity();
			_transformMatrix.translate(-_registrationPoint.x, -_registrationPoint.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation + _rotationOffset));
			_transformMatrix.translate((_position.x + _positionOffset.x), (_position.y + _positionOffset.y));
			
			displayObject.transform.matrix = _transformMatrix;
			displayObject.alpha = _alpha;
			displayObject.blendMode = (this._blendMode != "none" && this._blendMode != "shader") ? _blendMode : "normal";
			displayObject.visible = (alpha > 0);
			
			_transformDirty = false;
		}

		public function get isComposedTextData():Boolean {
			if(_fontImage && _fontData )
			{
				return true;
			}
			return false;
		}

		public function get fontImage():ImageResource{ return _fontImage; }
		public function set fontImage(img : ImageResource):void{
			if(_fontImage)
				_fontImage.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			_fontImage = img;
			if(_fontImage)
				_fontImage.addEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			
			_textDirty = true;
			_textSizeDirty = true;
			if(_bmFontObject){
				_bmFontObject.destroy();
				bitmap.bitmapData = null;
				originalBitmapData = null;
				_bmFontObject = null;
			}
		}

		public function get fontData():DataResource{ return _fontData; }
		public function set fontData(data : DataResource):void{
			if(_fontData)
				_fontData.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			_fontData = data;
			if(_fontData)
				_fontData.addEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			
			_textDirty = true;
			_textSizeDirty = true;
			if(_bmFontObject){
				_bmFontObject.destroy();
				bitmap.bitmapData = null;
				originalBitmapData = null;
				_bmFontObject = null;
			}
		}

		public function get fontColor():uint{ return uint(textFormatter.color); }
		public function set fontColor(val : uint):void{
			if(textFormatter.color != val)
				_textDirty = true;

			textFormatter.color = val;
			if(_textDisplay){
				_textDisplay.textColor = val;
				_textDisplay.setTextFormat(textFormatter);
			}
			if(_bmFontObject)
				_bmFontObject.color = val;
		}
		
		public function get fontBold():Boolean{ return textFormatter.bold; }
		public function set fontBold(val : Boolean):void{
			if(textFormatter.bold != val){
				_textDirty = true;
				_textSizeDirty = true;
			}

			textFormatter.bold = val;
			if(_textDisplay){
				_textDisplay.setTextFormat(textFormatter);
			}
		}

		public function get fontItalic():Boolean{ return textFormatter.italic; }
		public function set fontItalic(val : Boolean):void{
			if(textFormatter.italic != val){
				_textDirty = true;
				_textSizeDirty = true;
			}
			textFormatter.italic = val;
			if(_textDisplay){
				_textDisplay.setTextFormat(textFormatter);
			}
		}

		public function get fontSize():Number{ return int(textFormatter.size); }
		public function set fontSize(val : Number):void{
			if(textFormatter.size != val){
				_textDirty = true;
				_textSizeDirty = true;
			}
			textFormatter.size = val * ResourceManager.scaleFactor;
			if(_textDisplay){
				_textDisplay.setTextFormat(textFormatter);
			}
		}

		public function get fontName():String{ return textFormatter.font; }
		public function set fontName(val : String):void{
			if(textFormatter.font != val){
				_textDirty = true;
				_textSizeDirty = true;
			}
			textFormatter.font = val;
			if(_textDisplay){
				_textDisplay.setTextFormat(textFormatter);
			}
		}
		
		protected var _text : String;
		public function get text():String{ return _text; }
		public function set text(val : String):void{
			if(!val || val == ""){
				if(_textDisplay){
					_textDisplay.text = _text = "";
				}else{
					_text = "";
				}
				_textDirty = true;
			}else if(_text != val){
				if(_textDisplay){
					_textDisplay.text = _text = val;
					_textDisplay.setTextFormat(textFormatter);
				}else{
					_text = val;
				}
				_textSizeDirty = true;
				_textDirty = true;
			}
			if(_bmFontObject)
				_bmFontObject.text = _text;
		}

		override public function set size(val : Point):void{
			if(!val.equals(this._size)){
				_textDirty = true;
				_textSizeDirty = true;
			}
			super.size = val;
		}
		override public function set scale(val : Point):void{
			if(!val.equals(this._scale)){
				_textDirty = true;
				_textSizeDirty = true;
			}
			super.scale = val;
		}

		/**
		 * Uses one of the constants from the TextFieldType class
		 * i.e. TextFieldType.INPUT
		 * #see flash.text.TextFieldType
		 */
		public function get type():String{ return _textInputType; }
		public function set type(val : String):void{
			if(_textInputType == val)
				return;

			if(val != TextFieldType.INPUT && _textInputType == TextFieldType.INPUT){
				PBE.mainStage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true);
				PBE.mainStage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);
				_textDisplay.removeEventListener(Event.CHANGE, inputChanged);
				_textDisplay.removeEventListener(FocusEvent.FOCUS_OUT, hideInputField);
			}
			_textInputType = val;
			_textDirty = true;
			if(_textDisplay)
				_textDisplay.type = _textInputType;
			if(_textInputType == TextFieldType.INPUT){
				PBE.mainStage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true);
				PBE.mainStage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);
				_textDisplay.addEventListener(Event.CHANGE, inputChanged);
				_textDisplay.addEventListener(FocusEvent.FOCUS_OUT, hideInputField);
			}
		}
	
		public function get wordWrap():Boolean{ return _wordWrap; }
		public function set wordWrap(val : Boolean):void{
			if(_wordWrap == val)
				return;
			_wordWrap = val;
			if(_textDisplay){
				_textDisplay.wordWrap = _wordWrap;
				_textDisplay.multiline = _wordWrap;
			}
			if(_bmFontObject){
				_bmFontObject.wordWrap = _wordWrap;
				_bmFontObject.multiLine = _wordWrap;
			}
			_textDirty = true;
			_textSizeDirty = true;
		}

		public function get autoResize():Boolean{ return _autoResize; }
		public function set autoResize(val : Boolean):void{
			_autoResize = val;
			
			if(_bmFontObject)
				_bmFontObject.fixedWidth = !_autoResize;
			_textDirty = true;
			_textSizeDirty = true;
		}

		public function get nativeTextField():TextField{ return _textDisplay; }
		public function get bitmapTextField():PxTextField { return _bmFontObject; }
	}
}