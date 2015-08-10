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
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.core.GlobalExpressionManager;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.ResourceEvent;
	import com.pblabs.engine.resource.ResourceManager;
	import com.pblabs.rendering2D.UITextRendererComponent;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldType;
	
	import starling.core.Starling;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
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
			_transformMatrix.translate(-_registrationPoint.x, -_registrationPoint.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation + _rotationOffset));
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
				}
			}
			if(!skipCreation){
				if(!gpuObject && !isComposedTextData)
				{
					gpuObject = new TextField(_size.x * _scale.x, _size.y * _scale.y, _text, textFormatter.font, fontSize, uint(textFormatter.color), Boolean(textFormatter.bold));
					(gpuObject as TextField).customScaleFactor = ResourceTextureManagerG2D.actualScaleFactor;
					(gpuObject as TextField).italic = Boolean(textFormatter.italic);
					(gpuObject as TextField).autoSize = _autoResize ? _autoResizeDirection : "none";
					(gpuObject as TextField).wordWrap = _wordWrap;
					(gpuObject as TextField).hAlign = HAlign.LEFT;
					(gpuObject as TextField).vAlign = VAlign.TOP;
					
					_textDirty = false;
					_textSizeDirty = false;
				}else if(!gpuObject && isComposedTextData && _fontData.isLoaded && _fontImage.isLoaded) {
					var currentFontName : String = fontName;
					if(currentFontName)
					{
						var bitmapFont : BitmapFont = TextField.getBitmapFont( currentFontName );
						if(!bitmapFont || (bitmapFont && bitmapFont.texture.isDisposed))
						{
							if(bitmapFont && bitmapFont.texture.isDisposed){
								ResourceTextureManagerG2D.releaseTexture(bitmapFont.texture);
								TextField.unregisterBitmapFont(currentFontName);
							}
							
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
						gpuObject = new TextField(_size.x * _scale.x, _size.y * _scale.y, _text, currentFontName, bitmapFont.size, uint(textFormatter.color));
						(gpuObject as TextField).autoSize = _autoResize ? _autoResizeDirection : "none";
						(gpuObject as TextField).autoScale = _autoResize;
						(gpuObject as TextField).wordWrap = _wordWrap;
						(gpuObject as TextField).hAlign = HAlign.LEFT;
						(gpuObject as TextField).vAlign = VAlign.TOP;
						
						_textDirty = false;
						_textSizeDirty = false;
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
			_worldScratchPoint.setTo(_transformMatrix.tx, _transformMatrix.ty);
			toggleInputDisplay();
			
			if(_inputEnabled && gpuObject)
				gpuObject.visible = false;
		}
		
		override protected function paintTextToBitmap(reuseBitmap:Boolean=true):void
		{
			if(!gpuObject)
				buildFontObject();
		}
		
		override protected function getStagePointOfInputControl(localPoint : Point):Point
		{
			var actualStageScaleFactorX : Number = PBE.mainStage.stageWidth / GlobalExpressionManager.instance.baseScreenSize.x;
			var actualStageScaleFactorY : Number = PBE.mainStage.stageHeight / GlobalExpressionManager.instance.baseScreenSize.y;

			if(gpuObject) (gpuObject as TextField).customScaleFactor = actualStageScaleFactorX;
			_textDisplay.scaleX = actualStageScaleFactorX;
			_textDisplay.scaleY = actualStageScaleFactorY;

			localPoint = this.scene.transformWorldToScreen(localPoint);
			localPoint.x *= actualStageScaleFactorX; 
			localPoint.y *= actualStageScaleFactorY; 
			//localPoint.x -= (this.scene.sceneView as SceneViewG2D).starlingInstance.viewPort.topLeft.x;
			//localPoint.y -= (this.scene.sceneView as SceneViewG2D).starlingInstance.viewPort.topLeft.y;
			return localPoint;
		}

		override protected function getLocalPointOfStage(stagePoint : Point):Point
		{
			return this.gpuObject ? this.gpuObject.globalToLocal(stagePoint) : stagePoint;
		}
		
		override protected function buildFontObject():void
		{
			buildG2DObject();
		}
		
		override protected function updateFontSize():void
		{
			if(!gpuObject)
				buildFontObject();

			if(autoResize && gpuObject){
				var textSize : Rectangle = (gpuObject as TextField).getBounds(gpuObject);
				_newTextSize.setTo(textSize.width, textSize.height);
				
				if(_newTextSize.x == 0 || _newTextSize.y == 0) 
					return;

				//Passing changed size through instead of auto size changes
				if(_transformDirty){
					_newTextSize.x = this._size.x;
					_newTextSize.y = this._size.y;
					(gpuObject as TextField).width = this._size.x * _scale.x;					
					(gpuObject as TextField).height = this._size.y * _scale.y;					
				}
				
				if(isComposedTextData)
					_scale.x = _scale.y = 1;

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
			}else if(gpuObject){
				(gpuObject as TextField).width = this._size.x * _scale.x;					
				(gpuObject as TextField).height = this._size.y * _scale.y;					
			}
		}
		
		override protected function onResourceUpdated(event : ResourceEvent):void
		{
			var currentFontName : String = fontName;
			if(currentFontName && _bmFontObject && TextField.getBitmapFont(currentFontName))
			{
				TextField.unregisterBitmapFont(currentFontName, true);
			}
			if(gpuObject && _bmFontObject){
				_bmFontObject.destroy();
				_bmFontObject = null;
			}
			if(gpuObject){
				removeFromScene();
				gpuObject.dispose();
				gpuObject = null;
			}
			_textDirty = true;
			_textSizeDirty = true;
			if(this.owner)
				this.owner.reset();
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

		override public function get fontBold():Boolean{ 
			if(gpuObject && gpuObject is TextField)
				return (gpuObject as TextField).bold;
			return Boolean(textFormatter.bold);
		}
		override public function set fontBold(val : Boolean):void{
			super.fontBold = val;
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).bold = val;
		}

		override public function get fontItalic():Boolean{ 
			if(gpuObject && gpuObject is TextField)
				return (gpuObject as TextField).italic;
			return Boolean(textFormatter.italic);
		}
		override public function set fontItalic(val : Boolean):void{
			super.fontItalic = val;
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).italic = val;
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
				(gpuObject as TextField).autoSize = (_autoResize ? _autoResizeDirection : TextFieldAutoSize.NONE);
		}

		override public function set wordWrap(val : Boolean):void{
			super.wordWrap = val;
			if(gpuObject && gpuObject is TextField)
				(gpuObject as TextField).wordWrap = _wordWrap;
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