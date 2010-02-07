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
    
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.rendering2D.DisplayObjectRenderer;
    
    import flash.display.Sprite;
    import flash.geom.Point;
    
    /**
     * Helper component to visualize Box2D debug state. Properties let you
     * toggle what is drawn.
     */
    public class Box2DDebugComponent extends DisplayObjectRenderer
    {
        public function get spatialManager():Box2DManagerComponent
        {
            return _manager;
        }
        
        public function set spatialManager(value:Box2DManagerComponent):void
        {
            _manager = value;
        }
        
        public function get manager():Box2DManagerComponent
        {
            Logger.warn(this, "get manager", "manager is deprecated; switch to spatialManager.");
            return spatialManager;
        }
        
        public function set manager(value:Box2DManagerComponent):void
        {
            spatialManager = value;
            Logger.warn(this, "set manager", "manager is deprecated; switch to spatialManager.");
        }
                
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
			super.onAdd();
            displayObject = new Sprite();
			_zIndex = 30000;
            _drawer.m_sprite = displayObject as Sprite;
            _drawer.m_fillAlpha = 0.3;
            _drawer.m_lineThickness = 1.0;
            applyDebugFlags();
        }

        override protected function onRemove():void
        {
	        // Suppress auto-registration behavior. 
			super.onRemove();
        }
        
        override protected function onReset():void 
        {
            if (spatialManager)
                spatialManager.setDebugDrawer(_drawer);
        }

        public function get drawShapes():Boolean
        {
            return _drawShapes;
        }
        
        public function set drawShapes(value:Boolean):void
        {
            _drawShapes = value;
            applyDebugFlags();
        }
        
        public function get drawJoints():Boolean
        {
            return _drawJoints;
        }
        
        public function set drawJoints(value:Boolean):void
        {
            _drawJoints = value;
            applyDebugFlags();
        }
        
        public function get drawCoreShapes():Boolean
        {
            return _drawCoreShapes;
        }
        
        public function set drawCoreShapes(value:Boolean):void
        {
            _drawCoreShapes = value;
            applyDebugFlags();
        }
        
        public function get drawAABB():Boolean
        {
            return _drawAABB;
        }
        
        public function set drawAABB(value:Boolean):void
        {
            _drawAABB = value;
            applyDebugFlags();
        }
        
        public function get drawOBB():Boolean
        {
            return _drawOBB;
        }
        
        public function set drawOBB(value:Boolean):void
        {
            _drawOBB = value; 
            applyDebugFlags();        
        }
        
        public function get drawPairs():Boolean
        {
            return _drawPairs;
        }
        
        public function set drawPairs(value:Boolean):void
        {
            _drawPairs = value;
            applyDebugFlags();
        }
        
        public function get drawCenterOfMass():Boolean
        {
            return _drawCenterOfMass;
        }
        
        public function set drawCenterOfMass(value:Boolean):void
        {
            _drawCenterOfMass = value;
            applyDebugFlags();
        }
        
        public function applyDebugFlags():void
        {
            if (_drawShapes) 
                _drawer.AppendFlags(b2DebugDraw.e_shapeBit);
            else 
                _drawer.ClearFlags(b2DebugDraw.e_shapeBit);
            
            if (_drawJoints) 
                _drawer.AppendFlags(b2DebugDraw.e_jointBit);
            else 
                _drawer.ClearFlags(b2DebugDraw.e_jointBit);
            
            if (_drawCoreShapes) 
                _drawer.AppendFlags(b2DebugDraw.e_coreShapeBit);
            else 
                _drawer.ClearFlags(b2DebugDraw.e_coreShapeBit);
            
            if (_drawAABB) 
                _drawer.AppendFlags(b2DebugDraw.e_aabbBit);
            else 
                _drawer.ClearFlags(b2DebugDraw.e_aabbBit);
            
            if (_drawOBB) 
                _drawer.AppendFlags(b2DebugDraw.e_obbBit);
            else 
                _drawer.ClearFlags(b2DebugDraw.e_obbBit);
            
            if (_drawPairs)
                _drawer.AppendFlags(b2DebugDraw.e_pairBit);
            else 
                _drawer.ClearFlags(b2DebugDraw.e_pairBit);
            
            if (_drawCenterOfMass) 
                _drawer.AppendFlags(b2DebugDraw.e_centerOfMassBit);
            else 
                _drawer.ClearFlags(b2DebugDraw.e_centerOfMassBit);
        }        
        
        private var _manager:Box2DManagerComponent = null;
        protected var _drawer:b2DebugDraw = new b2DebugDraw();
        protected var _drawShapes:Boolean = true; 
        protected var _drawJoints:Boolean = true;      
        protected var _drawCoreShapes:Boolean = false;
        protected var _drawAABB:Boolean = false;
        protected var _drawOBB:Boolean = false;
        protected var _drawPairs:Boolean = false;
        protected var _drawCenterOfMass:Boolean = false;
    }
}