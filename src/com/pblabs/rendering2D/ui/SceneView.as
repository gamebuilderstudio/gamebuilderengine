/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.ui
{
    import com.pblabs.engine.PBE;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    /**
     * This class can be set as the SceneView on the BaseSceneComponent class and is used
     * as the canvas to draw the objects that make up the scene. It defaults to the size
     * of the stage.
     * 
     * <p>Currently this is just a stub, and exists for clarity and potential expandability in
     * the future.</p>
     */
    public class SceneView extends Sprite implements IUITarget
    {
		
		public function SceneView()
		{
			if(PBE.mainClass)
			{
				if(!PBE.mainClass.contains(this))
					PBE.mainClass.addChildAt(this, 0);
				
				// Intelligent default size.
				width = PBE.mainStage.stage.stageWidth;
				height = PBE.mainStage.stage.stageHeight;
				name = "SceneView";
			}
		}
		
        override public function get width():Number
        {
            return _width;
        }
        
        override public function set width(value:Number):void
        {
            _width = value;
        }
        
        override public function get height():Number
        {
            return _height;
        }
        
        override public function set height(value:Number):void
        {
            _height = value;
        }
        
        public function addDisplayObject(dobj:Object):void
        {
            addChild(dobj as DisplayObject);
        }
        
        public function clearDisplayObjects():void
        {
            while(numChildren)
                removeChildAt(0);
        }
        
        public function removeDisplayObject(dObj:Object):void
        {
            removeChild(dObj as DisplayObject);
        }
        
        public function setDisplayObjectIndex(dObj:Object, index:int):void
        {
            setChildIndex(dObj as DisplayObject, index);
        }
        
        private var _width:Number = 0;
        private var _height:Number = 0;
    }
}
