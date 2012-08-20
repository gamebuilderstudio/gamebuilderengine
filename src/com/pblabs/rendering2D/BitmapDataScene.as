/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.rendering2D.modifier.Modifier;
    import com.pblabs.rendering2D.ui.IUITarget;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Point;

    /**
     * A scene which draws to a BitmapData. Useful when you want to do
     * full screen pixel processing effects. 
     */
	public class BitmapDataScene extends DisplayObjectScene
	{
		[EditorData(ignore="true")]
        public var backbuffer:BitmapData;
		[EditorData(ignore="true")]
        public var bitmap:Bitmap = new Bitmap();
        
		/**
		 * Array with BitmapData modifiers that will be rendered 
		 */
		public function get modifiers():Array
		{
			return _modifiers;
		}
		
		public function set modifiers(value:Array):void
		{
			_modifiers = value;
		}
		
		[EditorData(ignore="true")]
        public override function set sceneView(value:IUITarget):void
        {
            if(_sceneView)
                _sceneView.removeDisplayObject(bitmap);
            
            super.sceneView = value;
            
            if(_sceneView)
            {
                _sceneView.removeDisplayObject(_rootSprite);
				_realRoot = new Sprite();
				_realRoot.addChild(_rootSprite);
				if (PBE.mainClass.parent!=PBE.mainStage)
				{
					_realRoot.x = PBE.mainClass.parent.x;
					_realRoot.y = PBE.mainClass.parent.y;
				}
				bitmap.pixelSnapping = PixelSnapping.NEVER;
                _sceneView.addDisplayObject(bitmap);
            }
        }
											
        public override function onFrame(elapsed:Number) : void
        {
            // Let things update.
            super.onFrame(elapsed);
						
            if(sceneView.width == 0 || sceneView.height == 0)
            {
                // Firefox 3 bug - we can get stageHeight/stageWidth of 0 which
                // trickles down and causes this problem. So if they are zero, 
                // just reassign to stageHeight/stageWidth.
                Logger.warn(this, "onFrame", "Zero size sceneView! Resetting to stage size (" + PBE.mainStage.stageWidth + "x" + PBE.mainStage.stageHeight + ")");
                
                if(PBE.mainStage.stageWidth == 0 || PBE.mainStage.stageHeight == 0)
                {
                    Logger.warn(this, "onFrame", "Stage is also zero size! This might be a Firefox bug (see http://bugs.adobe.com/jira/browse/FP-434).");
                    Logger.warn(this, "onFrame", "If it doesn't go away after a few frames, it is probably another issue.");
                } 
                
                sceneView.width = PBE.mainStage.stageWidth;
                sceneView.height = PBE.mainStage.stageHeight;
            }
            
            // Make sure back buffer is good.
            if(!backbuffer 
                || backbuffer.width != sceneView.width 
                || backbuffer.height != sceneView.height)
            {
                backbuffer = new BitmapData(sceneView.width, sceneView.height);
                bitmap.bitmapData = backbuffer;
                bitmap.x = bitmap.y = 0;
                bitmap.width = sceneView.width;
                bitmap.height = sceneView.height;
            }
            
            // Clear
            backbuffer.lock();
            backbuffer.fillRect(backbuffer.rect, 0);
            
            // Now traverse everything and draw it!
            // TODO: Be friendly towards caching layers.
            var m:Matrix = new Matrix();
            for(var i:int=0; i<_layers.length; i++)
            {
                var l:DisplayObjectSceneLayer = _layers[i];
                
                if(!l)
                    continue;
                
                for each(var d:DisplayObjectRenderer in l.rendererList)
                {
					d.updateTransform(false);
                    var localMat:Matrix = d.displayObject.transform.matrix;
                    m.a = localMat.a;
                    m.b = localMat.b;
                    m.c = localMat.c;
                    m.d = localMat.d;
                    m.tx = localMat.tx;
                    m.ty = localMat.ty;
                    m.concat(_rootSprite.transform.matrix);
                    
                    var dcp:ICopyPixelsRenderer = d as ICopyPixelsRenderer;
                    if(dcp && dcp.isPixelPathActive(m))
                        dcp.drawPixels(m, backbuffer);
                    else
						// Quoting docs regarding .draw(), the source display object does not use any of its applied transformations for this call. 
						// It is treated as it exists in the library or file, with no matrix transform, no color transform, and no blend mode. 
						backbuffer.draw(d.displayObject, m, d.displayObject.transform.colorTransform, d.displayObject.blendMode );
                }
            }

			if (modifiers.length>0)
			{
				for (var mo:int = 0; mo<modifiers.length; mo++)
					backbuffer = (modifiers[mo] as Modifier).modify(backbuffer);				
			}
			
            backbuffer.unlock();						
            bitmap.bitmapData = backbuffer;

        }
		
		public override function transformWorldToScreen(inPos:Point):Point
		{
			updateTransform();
			return _rootSprite.localToGlobal(inPos);            
		}
		

		public override function transformSceneToScreen(inPos:Point):Point
		{
			return transformWorldToScreen(inPos);            
		}
		
		public override function transformScreenToScene(inPos:Point):Point
		{
			return transformScreenToWorld(inPos);
		}
				
		public override function transformScreenToWorld(inPos:Point):Point
		{
			updateTransform();			
			return _rootSprite.globalToLocal(inPos);						
		}
						
		override protected function onRemove() : void
		{
			super.onRemove();
			
			// Make sure we don't leave any lingering content.
			if(_sceneView && (_sceneView as Sprite).contains(bitmap))
				_sceneView.removeDisplayObject(bitmap);
			if(backbuffer) backbuffer.dispose();
			bitmap = null;
			backbuffer = null;
			if(_realRoot && _realRoot.contains( _rootSprite ))
			{
				_realRoot.removeChild(_rootSprite);
				_realRoot = null;
			}
		}
		
		private var _modifiers:Array = new Array();
		private var _realRoot:Sprite;
	}
}