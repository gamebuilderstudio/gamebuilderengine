/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.ResourceEvent;
	import com.pblabs.rendering2D.UITextRendererComponent;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldType;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	
	public class UITextRendererComponentG2D extends UITextRendererComponent
	{
		private var _gpuTextField : TextField;
		private var _touchID : int = -1;
		private var _listeningToTouch : Boolean = false;
		
		public function UITextRendererComponentG2D()
		{
			super();
		}

		/**
		 * @inheritDoc
		 */
		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!gpuObject){
				super.updateTransform(updateProps);
				return;
			}
			
			if(updateProps)
				updateProperties();
			
			_transformMatrix.identity();
			//_transformMatrix.scale(combinedScale.x, combinedScale.y);
			_transformMatrix.translate(-_registrationPoint.x * combinedScale.x, -_registrationPoint.y * combinedScale.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset);
			_transformMatrix.translate((_position.x + _positionOffset.x), (_position.y + _positionOffset.y));
			
			gpuObject.transformationMatrix = _transformMatrix;
			gpuObject.alpha = this._alpha;
			gpuObject.blendMode = this._blendMode;
			gpuObject.visible = (alpha > 0);
			gpuObject.touchable = _mouseEnabled;
			
			_transformDirty = false;
		}

		override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
		{
			if (!gpuObject || !scene)
				return false;
			
			var localPos:Point = transformWorldToObject(worldPosition);
			return gpuObject.hitTest(localPos) ? true : false;
		}

		override protected function onRemove():void
		{
			super.onRemove();
			if(_textInputType == TextFieldType.INPUT && Starling.current != null && Starling.current.stage != null)
				Starling.current.stage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
		}

		override protected function buildG2DObject(skipCreation : Boolean = false):void
		{
			if(!Starling.context && !skipCreation){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}else if(!_listeningToTouch && _textInputType == TextFieldType.INPUT && type != TextFieldType.INPUT){
				if(Starling.current != null && Starling.current.stage != null){
					Starling.current.stage.addEventListener(TouchEvent.TOUCH, onStageTouch);
					_listeningToTouch = true;
					Logger.print(this, "Attaching Touch Listener");
				}
			}
			if(!skipCreation){
				if(!isComposedTextData && this.bitmap.bitmapData)
				{
				
					if(!gpuObject){
						//Create GPU Renderer Object
						gpuObject = new Image( ResourceTextureManagerG2D.getTextureForBitmapData( this.bitmap.bitmapData ) );
					}else{
						if(( gpuObject as Image).texture)
							( gpuObject as Image).texture.dispose();
						( gpuObject as Image).texture = ResourceTextureManagerG2D.getTextureForBitmapData( this.bitmap.bitmapData );
						( gpuObject as Image).readjustSize();
					}
				}
				smoothing = _smoothing;
				skipCreation = true;
			}
			super.buildG2DObject(skipCreation);
		}
		
		protected function onStageTouch(event : TouchEvent):void
		{
			var touch : Touch = event.getTouch(Starling.current.stage, TouchPhase.ENDED, _touchID);
			if(!touch || touch.phase != TouchPhase.ENDED)
				return;
			_touchID = touch.id;
			_stagePoint.setTo( touch.globalX, touch.globalY );
			toggleInputDisplay();
		}
		
		override protected function updateTextImage():void
		{
			if(!_fontData || !_fontImage){
				super.updateTextImage();
			}else{
				buildFontObject();
			}
		}
		
		override protected function getLocalPointOfStage(stagePoint : Point):Point
		{
			var localTextPoint : Point = this.gpuObject ? this.gpuObject.globalToLocal(stagePoint) : stagePoint;
			return localTextPoint;
		}
		
		override protected function buildFontObject():void
		{
			if(isComposedTextData && _fontData.isLoaded && _fontImage.isLoaded)
			{
				var currentFontName : String = fontName;
				if(currentFontName)
				{
					var bitmapFont : BitmapFont = TextField.getBitmapFont( currentFontName );
					if(!bitmapFont)
					{
						_fontData.data.position = 0;
						var fontDataXML : XML = XML(_fontData.data.readUTFBytes( _fontData.data.length ));
						var fontFace : String = String(fontDataXML.info.@face);
						if(fontFace != currentFontName)
						{
							this.fontName = currentFontName = fontFace;
						}
						var fontTexture : Texture = ResourceTextureManagerG2D.getTextureForResource(_fontImage);
						bitmapFont = new BitmapFont(fontTexture, fontDataXML);
						TextField.registerBitmapFont(bitmapFont, currentFontName);
					}
					if(!gpuObject){
						gpuObject = new TextField(_size.x, _size.y, _text, currentFontName, bitmapFont.size, this.fontColor, this.textFormatter.bold);
						(gpuObject as TextField).autoSize = _autoResize ? TextFieldAutoSize.BOTH_DIRECTIONS : TextFieldAutoSize.NONE;
					}
				}
			}
			if(!gpuObject)
			{
				buildG2DObject();
			}
		}
		
		override protected function updateFontSize():void
		{
			if(!_fontData || !_fontImage){
				super.updateFontSize();
			}else{
				if(autoResize && gpuObject){
					var textSize : Rectangle = _textDisplay.getBounds(_textDisplay);
					_newTextSize.setTo( (gpuObject as TextField).width, (gpuObject as TextField).height );

					if(!this._size.equals(_newTextSize ))
						_transformDirty = true;
					if(sizeProperty && sizeProperty.property != "")
					{
						this._size = _newTextSize;
						if(owner && sizeProperty)
							this.owner.setProperty( sizeProperty, _newTextSize.clone() )
					}else{
						this._size = _newTextSize;
					}
				}
			}
		}
		
		override protected function paintTextToBitmap():void
		{
			//Clear Functionality
			if(!_fontData || !_fontImage)
				super.paintTextToBitmap();
		}

		override protected function onResourceUpdated(event : ResourceEvent):void
		{
			var currentFontName : String = fontName;
			if(currentFontName && _bmFontObject && TextField.getBitmapFont(currentFontName))
			{
				TextField.unregisterBitmapFont(currentFontName, true);
			}
			if(gpuObject){
				_bmFontObject.destroy();
				_bmFontObject = null;
			}
			_textDirty = true;
			buildFontObject();
			if(this.owner)
				this.owner.reset();
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			if (value === bitmap.bitmapData){
				return;
			}
			// store orginal BitmapData so that modifiers can be re-implemented 
			// when assigned modifiers attribute later on.
			originalBitmapData = value;
			
			// check if we should do modification
			/*
			if (modifiers.length>0)
			{
			// apply all bitmapData modifiers
			bitmap.bitmapData = modify(originalBitmapData.clone());
			dataModified();			
			}	
			else	
			*/					
			bitmap.bitmapData = value;
			
			// Due to a bug, this has to be reset after setting bitmapData.
			smoothing = _smoothing;
			
			buildG2DObject();
			
			_transformDirty = true;
		}

		override public function get fontColor():uint{ 
			if(gpuObject && gpuObject is TextField)
				return (gpuObject as TextField).color;
			return uint(textFormatter.color);
		}
		override public function set fontColor(val : uint):void{
			super.fontColor = val;
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).color = val;
		}

		override public function get fontSize():Number{ 
			if(gpuObject && gpuObject is TextField)
				return (gpuObject as TextField).fontSize;
			return int(textFormatter.size); 
		}
		override public function set fontSize(val : Number):void{
			super.fontSize = val;
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).fontSize = val;
		}
		
		override public function get fontName():String{ 
			if(gpuObject && gpuObject is TextField)
				return (gpuObject as TextField).fontName;
			return textFormatter.font; 
		}
		override public function set fontName(val : String):void{
			super.fontName = val;
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).fontName = val;
		}
		
		override public function set text(val : String):void{
			super.text = val;	
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).text = _text;
		}
		
		override public function set autoResize(val : Boolean):void{
			super.autoResize = val;
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).autoSize = _autoResize ? TextFieldAutoSize.BOTH_DIRECTIONS : TextFieldAutoSize.NONE;
		}

		override public function set type(val : String):void{
			if(_textInputType == TextFieldType.INPUT && val != TextFieldType.INPUT && Starling.current != null && Starling.current.stage != null)
			{
				Starling.current.stage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
			}
			super.type = val;
			if(_textInputType == TextFieldType.INPUT && Starling.current != null && Starling.current.stage != null)
			{
				Starling.current.stage.addEventListener(TouchEvent.TOUCH, onStageTouch);
			}
		}
		/**
		 * @see Bitmap.smoothing 
		 */
		[EditorData(ignore="true")]
		override public function set smoothing(value:Boolean):void
		{
			
		}
	}
}