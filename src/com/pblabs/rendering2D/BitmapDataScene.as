package com.pblabs.rendering2D
{
    import com.pblabs.rendering2D.ui.IUITarget;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Matrix;

    /**
     * A scene which draws to a BitmapData. Useful when you want to do
     * full screen pixel processing effects. 
     */
	public class BitmapDataScene extends DisplayObjectScene
	{
        public var backbuffer:BitmapData = new BitmapData(640, 480);
        public var bitmap:Bitmap = new Bitmap();
        
        public override function set sceneView(value:IUITarget):void
        {
            if(_sceneView)
                _sceneView.removeDisplayObject(bitmap);
            
            super.sceneView = value;
            
            if(_sceneView)
            {
                _sceneView.removeDisplayObject(_rootSprite);
                var realRoot:Sprite = new Sprite();
                realRoot.addChild(_rootSprite);
                _sceneView.addDisplayObject(bitmap);
            }
        }
        
        public override function onFrame(elapsed:Number) : void
        {
            // Let things update.
            super.onFrame(elapsed);

            // Make sure back buffer is good.
            if(backbuffer.width != sceneView.width 
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
            for each(var l:DisplayObjectSceneLayer in _layers)
            {
                for each(var d:DisplayObjectRenderer in l.rendererList)
                {
                    var localMat:Matrix = d.displayObject.transform.matrix;
                    m.a = localMat.a;
                    m.b = localMat.b;
                    m.c = localMat.c;
                    m.d = localMat.d;
                    m.tx = localMat.tx;
                    m.ty = localMat.ty;
                    m.concat(_rootSprite.transform.matrix);
                    
                    backbuffer.draw(d.displayObject, m);
                }
            }
            
            backbuffer.unlock();
            bitmap.bitmapData = backbuffer;
        }
	}
}