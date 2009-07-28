/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is property of PushButton Labs, LLC and NOT under the MIT license.
 ******************************************************************************/
package com.pblabs.rollyGame
{
    import com.pblabs.rendering2D.*;
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.*;
    
    public class BallSpriteRenderer extends SpriteRenderComponent
    {
        private var _BallChecker:BitmapData;
        private var _SphereFilter:DisplacementMapFilter;
        
        public function BallSpriteRenderer()
        {
            // This doesn't quite work and isn't used, but I'm keeping it around
            // because it is interesting.
            var sphereData:BitmapData = new BitmapData(32, 32, false, 0);
            for(var x:int=0; x<32; x++)
            {
                for(var y:int=0; y<32; y++)
                {
                    // Figure distance...
                    var offset:Point = new Point(x - 16, y - 16);
                    
                    // Stuff outside our radius.
                    if(offset.length > 16)
                    {
                        sphereData.setPixel(x, y, 127 << 8 | 127 << 16);
                        continue;
                    }
                    
                    // Figure the normal for a sphere at this position.
                    // 16 = sqrt( x^2 + y^2 + z^2)
                    // 16^2 = x^2 + y^2 + z^2
                    // 16^2 - (x^2 + y^2) = x^2
                    //var posZ:Number = Math.sqrt(16*16 - (offset.x * offset.x + offset.y * offset.y));
                    offset.normalize(Math.max(16.1 - offset.length, 0) / 2);
                    
                    var xOffset:int = -offset.x * 8 + 128;
                    var yOffset:int = -offset.y * 8 + 128;
                    
                    sphereData.setPixel(x, y, (xOffset << 8) | yOffset << 16);
                }
            }
            
            _SphereFilter = new DisplacementMapFilter(sphereData);
            _SphereFilter.scaleX = 4;
            _SphereFilter.scaleY = 4;
            _SphereFilter.componentX = BitmapDataChannel.GREEN;
            _SphereFilter.componentY = BitmapDataChannel.BLUE;
            _SphereFilter.mode = DisplacementMapFilterMode.CLAMP;
            
            // Generate the ball texture.
            _BallChecker = new BitmapData(64, 64, false);
            _BallChecker.perlinNoise(9, 10, 9, 0x48844, true, true);
        }
        
        public override function onDraw(manager:IDrawManager2D):void
        {
            var pos:Point = renderPosition;
            
            // Figure out scale factor.
            var size:Point = owner.getProperty(sizeReference) as Point;
            var scaleFactor:Number = size.x;
            
            // Make sure we have something valid to draw against.
            var spriteAsSprite:Sprite = _sprite as Sprite;
            if(!spriteAsSprite)
            {
                _sprite = new Sprite();
                spriteAsSprite = _sprite as Sprite;
            }
            
            // Draw the ball. We actually skip any distortion, panning is good 
            // enough to fool the eye at small size.            
            spriteAsSprite.graphics.clear();
            spriteAsSprite.graphics.beginBitmapFill(_BallChecker, new Matrix(32 / 32, 0, 0, 32 / 32, pos.x * 2, pos.y * 2 ), true, true);
            spriteAsSprite.graphics.drawCircle(pos.x, pos.y, scaleFactor / 2);
            spriteAsSprite.graphics.endFill();
            
            // Draw the ball.
            manager.drawDisplayObject(_sprite);        
        }
    }
}
