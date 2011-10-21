package com.pblabs.rendering2D
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.rendering2D.SpriteRenderer;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ParallaxRepeatRendererComponent extends SpriteRenderer
	{
		[Inspectable(name="Parallax Factor", type="flash.geom.Point", defaultValue="1,1")]
		public var parallaxFactor:Point = new Point(1,1);
		
		[Inspectable(name="Scroll Position", type="flash.geom.Point", defaultValue="0,0")]
		public var scrollPosition:Point = new Point(0,0);
		
		[Inspectable(name="Repeat-X", enumeration="true,false", defaultValue="true")]

		public var repeatX : Boolean = true;
		[Inspectable(name="Repeat-Y", enumeration="true,false", defaultValue="false")]
		public var repeatY : Boolean = false;
		
		public var backgroundFill : uint = 0xFFFFFF;
		
		public var bindScrollPositionToScene : Boolean = false;
		
		protected var canvasBitmapData : BitmapData;
		
		private var _repeatPosition : Point = new Point();

		public function ParallaxRepeatRendererComponent()
		{
			super();
		}

		override public function isPixelPathActive(objectToScreen:Matrix):Boolean
		{
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function drawPixels(objectToScreen:Matrix, renderTarget:BitmapData):void
		{
			// Draw to the target.
			if (bitmap.bitmapData!=null)
				renderTarget.copyPixels(bitmap.bitmapData, new Rectangle(0,0, scene.sceneViewBounds.width, scene.sceneViewBounds.height), objectToScreen.transformPoint(zeroPoint), null, null, true);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set scene(value:IScene2D):void
		{
			super.scene = value;
			paintRenderer();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set bitmapData(value:BitmapData):void
		{
			if (value === bitmap.bitmapData)
				return;
			
			// store orginal BitmapData so that modifiers can be re-implemented 
			// when assigned modifiers attribute later on.
			if(value != canvasBitmapData){ 
				originalBitmapData = value;
				paintRenderer();
			}
			
			// check if we should do modification
			if (modifiers.length>0)
			{
				// apply all bitmapData modifiers
				bitmap.bitmapData = modify(originalBitmapData.clone());
				dataModified();			
			}	
			else						
				bitmap.bitmapData = value;
			
			if (displayObject==null)
			{
				_displayObject = new Sprite();
				(_displayObject as Sprite).addChild(bitmap);				
				_displayObject.visible = false;
				(_displayObject as Sprite).mouseEnabled = _mouseEnabled;
			}
			
			// Due to a bug, this has to be reset after setting bitmapData.
			smoothing = _smoothing;
			_transformDirty = true;
		}

		/**
		 * @inheritDoc
		 */
		override public function onFrame(elapsed:Number):void
		{
			super.onFrame(elapsed);
			paintRenderer();
		}
		
		override public function set position(value:Point):void
		{
			if(!bindScrollPositionToScene)
			{
				super.position = value;
			}
			//Position Is being constrained to SceneView 0,0
		}
		
		private var _zeroPoint : Point = new Point();
		
		protected function paintRenderer():void
		{
			if(!scene || !bitmapData) return;
			
			if(bindScrollPositionToScene)
			{
				var sceneBoundsInViewSpace : Rectangle = scene.sceneContainer.getBounds( scene.sceneView as DisplayObject );
				var globalZero : Point = (scene.sceneView as DisplayObject).localToGlobal(_zeroPoint);
				var localZero : Point = scene.transformScreenToWorld(globalZero);
				scrollPosition.x = scene.sceneViewBounds.left;
				scrollPosition.y = scene.sceneViewBounds.top;
				//Logger.print(this, "Local Scene Zero - "+localZero.toString());
				if(localZero.x != _position.x || localZero.y != _position.y)
				{
					_position = localZero;
					_transformDirty = true;
				}
				_repeatPosition.x = scrollPosition.x * (1 - parallaxFactor.x);
				_repeatPosition.y = scrollPosition.y * (1 - parallaxFactor.y);
			}else{
				_repeatPosition.x = scrollPosition.x * ((1 - parallaxFactor.x) == 0 ? 1 : (1 - parallaxFactor.x) );
				_repeatPosition.y = scrollPosition.y * ((1 - parallaxFactor.y) == 0 ? 1 : (1 - parallaxFactor.y) );
			}
			

			if(!canvasBitmapData || canvasBitmapData.width != size.x || canvasBitmapData.height != size.y)
			{
				canvasBitmapData = new BitmapData(size.x, size.y, true, backgroundFill);
			}
			canvasBitmapData.fillRect(canvasBitmapData.rect, 0);
			canvasBitmapData.lock();
			
			//Fill Remaining X
			var remainingFillX : Number = (size.x - _repeatPosition.x);
			var remainingFillY : Number = (size.y - _repeatPosition.y);
			if(originalBitmapData.rect.width < remainingFillX || originalBitmapData.rect.height < remainingFillY)
			{
				var copyIterationsX : Number = Math.ceil(remainingFillX / originalBitmapData.width);
				var fillX : Number = _repeatPosition.x;
				var fillY : Number = _repeatPosition.y;
				if(!repeatX) copyIterationsX = 1;
				
				for (var i:int = 0; i < copyIterationsX; i++)
				{
					canvasBitmapData.copyPixels(originalBitmapData, originalBitmapData.rect, new Point(fillX, fillY));
					
					//Fill Vertically If repeatY
					if(repeatY){
						fillY += originalBitmapData.height;
						var copyIterationsY : Number = Math.ceil(remainingFillY / originalBitmapData.rect.height);
						//copyIterationsY = 1;
						for (var j:int = 0; j < copyIterationsY; j++)
						{
							canvasBitmapData.copyPixels(originalBitmapData, originalBitmapData.rect, new Point(fillX, fillY));
							fillY += originalBitmapData.height;
						}
						fillY = _repeatPosition.y;
					}
					fillX += originalBitmapData.width;
				}
			}else{
				canvasBitmapData.copyPixels(originalBitmapData, originalBitmapData.rect, new Point(_repeatPosition.x, _repeatPosition.y));
			}
			
			canvasBitmapData.unlock();
			this.bitmapData = canvasBitmapData;
		}
	}
}