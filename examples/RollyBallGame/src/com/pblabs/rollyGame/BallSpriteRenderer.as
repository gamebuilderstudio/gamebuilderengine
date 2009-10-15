/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is property of PushButton Labs, LLC and NOT under the MIT license.
 ******************************************************************************/
package com.pblabs.rollyGame
{
    import com.pblabs.engine.entity.PropertyReference;
    import com.pblabs.rendering2D.*;
    
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.*;
    
    public class BallSpriteRenderer extends DisplayObjectRenderer
    {
        private var _BallChecker:BitmapData;
        private var _SphereFilter:DisplacementMapFilter;
        public var sizeReference:PropertyReference;
        
        public function BallSpriteRenderer()
        {
            // Generate the ball texture.
            _BallChecker = new BitmapData(64, 64, false);
            _BallChecker.perlinNoise(9, 10, 9, 0x48844, true, true);
            
            displayObject = new Sprite();
        }
        
        public override function onFrame(dt:Number):void
        {
            super.onFrame(dt);

            var pos:Point = renderPosition;
            
            // Figure out scale factor.
            var size:Point = owner.getProperty(sizeReference) as Point;
            var scaleFactor:Number = size.x;
            
            // Make sure we have something valid to draw against.
            var spriteAsSprite:Sprite = displayObject as Sprite;
            if(!spriteAsSprite)
            {
                displayObject = new Sprite();
                spriteAsSprite = displayObject as Sprite;
            }
            
            // Draw the ball. We actually skip any distortion, panning is good 
            // enough to fool the eye at small size.            
            spriteAsSprite.graphics.clear();
            spriteAsSprite.graphics.beginBitmapFill(_BallChecker, new Matrix(32 / 32, 0, 0, 32 / 32, pos.x, pos.y), true, true);
            spriteAsSprite.graphics.drawCircle(0, 0, scaleFactor / 2);
            spriteAsSprite.graphics.endFill();
        }
    }
}
