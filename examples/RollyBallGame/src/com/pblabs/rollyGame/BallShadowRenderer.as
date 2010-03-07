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
    import flash.utils.*;
    
    /**
     * Special effect renderer to give illusion of ball shadow.
     */
    public class BallShadowRenderer extends DisplayObjectRenderer
    {
        public var Map:NormalMap;
        
        public function BallShadowRenderer()
        {
            super();
            
            displayObject = new Sprite();
        }
        
        public override function onFrame(dt:Number):void
        {
			super.onFrame(dt);
			
            if(!Map)
                throw new Error("No normalmap specified!");
            
            // Calculate roller shadow.
            var lightPosX:Number = 320;
            var lightPosY:Number = -100;
            var lightPosZ:Number = 100;
            var silhouetteX:Number = 0, silhouetteY:Number = 0, silhouetteZ:Number = 8;
            var deltaX:Number, deltaY:Number, deltaZ:Number, deltaLen:Number;
            
            var graphics:Graphics = (displayObject as Sprite).graphics;
            
			// Get the ball.
            var ball:BallMover = owner.lookupComponentByName("Spatial") as BallMover;
            
            graphics.clear();
            graphics.beginFill(0x000000, 0.5);
            for(var i:int=0; i<24; i++)
            {
                var sinVal:Number = Math.sin((i/24) * Math.PI * 2);
                var cosVal:Number = Math.cos((i/24) * Math.PI * 2);
                
                // Determine point on the circle's silhouette.
                silhouetteX = sinVal * ball.Radius; 
                silhouetteY = cosVal * ball.Radius;
                silhouetteZ = ball.Height * 100 + 16;
                
                var normalX:Number = sinVal;
                var normalY:Number = cosVal;
                
                // Force light to be directional.
                deltaX = 1;
                deltaY = 5;
                deltaZ = -3;
                
                // If we face towards the light shift silhouette point down in Z
                if(deltaX * normalX + deltaY * normalY < 0)
                {
                    if(i==0)
                        graphics.moveTo(silhouetteX, silhouetteY);
                    else
                        graphics.lineTo(silhouetteX, silhouetteY);

                    continue;
                }
                
                // Normalize.
                deltaLen = Math.sqrt(deltaX*deltaX + deltaY*deltaY + deltaZ*deltaZ);
                deltaX /= deltaLen;
                deltaY /= deltaLen;
                deltaZ /= deltaLen;
                
                // Now march against the terrain until we hit it.
                for(var j:int=0; j<100; j++)
                {
                    silhouetteX += deltaX;
                    silhouetteY += deltaY;
                    silhouetteZ += deltaZ;
                    
                    if(silhouetteZ <= Map.getHeight(silhouetteX + ball.position.x, silhouetteY + ball.position.y) * 100)
                        break;
                }
                
                // draw shadow.
                if(i==0)
                    graphics.moveTo(silhouetteX, silhouetteY);
                else
                    graphics.lineTo(silhouetteX, silhouetteY);
            }
            
            graphics.endFill();
        }
    }
}