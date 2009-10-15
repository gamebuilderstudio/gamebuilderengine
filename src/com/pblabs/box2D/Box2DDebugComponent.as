/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.box2D
{
    import Box2D.Dynamics.b2DebugDraw;
    
    import com.pblabs.rendering2D.DisplayObjectRenderer;
    
    import flash.display.Sprite;
    import flash.geom.Point;
    
    public class Box2DDebugComponent extends DisplayObjectRenderer
    {
        public var manager:Box2DManagerComponent;
        
        override public function get layerIndex():int
        {
            // Always draw last.
            if(scene && scene.layerCount)
                return scene.layerCount - 1;
            else
                return 0;
        }
        
        override protected function onAdd():void
        {
            displayObject = new Sprite();
            _drawer.m_sprite = displayObject as Sprite;
            _drawer.m_fillAlpha = 0.3;
            _drawer.m_lineThickness = 1.0;
            _drawer.m_drawFlags = b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit;
        }
        
        override protected function onReset():void 
        {
            if (manager)
                manager.setDebugDrawer(_drawer);
        }

        protected var _drawer:b2DebugDraw = new b2DebugDraw();
    }
}