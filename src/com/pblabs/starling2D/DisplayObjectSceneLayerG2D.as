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
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.rendering2D.IDisplayObjectSceneLayer;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;

    /**
     * Layer within a DisplayObjectSceneG2D which manages a list of 
     * DisplayObjectRenderersG2D for rendering via Starling on the GPU. 
	 * The layer is responsible for keeping
     * itself sorted. This is also a good site for custom render
     * effects, parallaxing, etc.
     */
    public class DisplayObjectSceneLayerG2D extends Sprite implements IDisplayObjectSceneLayer
    {
        /**
         * Array.sort() compatible function used to determine draw order. 
         */
		private var _drawOrderFunction:Function;
        
        /**
         * All the renderers in this layer. 
         */
        public var rendererList:Vector.<DisplayObjectRendererG2D> = new Vector.<DisplayObjectRendererG2D>();
        
        /**
         * Set to true when we need to resort the layer. 
         */
        internal var needSort:Boolean = false;
        
        /**
         * Default sort function, which orders by zindex.
         */
        static public function defaultSortFunction(a:DisplayObjectRendererG2D, b:DisplayObjectRendererG2D):int
        {
            return a.zIndex - b.zIndex;
        }
        
        public function DisplayObjectSceneLayerG2D()
        {
            drawOrderFunction = defaultSortFunction;
            touchable = false;
        }
        
        /**
         * Indicates this layer is dirty and needs to resort.
         */
        public function markDirty():void
        {
            needSort = true;
        }
        
        public function onRender():void
        {
            if(needSort)
            {
                updateOrder();
                needSort = false;
            }
        }
        
        public function updateOrder():void
        {
            // Get our renderers in order.
            // TODO: A bubble sort might be more efficient in cases where
            // things don't change order much.
            rendererList.sort(drawOrderFunction);
            
            // Apply the order.
            var updated:int = 0;
            for(var i:int=0; i<rendererList.length; i++)
            {
                var d:DisplayObject = rendererList[i].displayObjectG2D;
                if(getChildAt(i) == d)
                    continue;
                
                updated++;
                setChildIndex(d, i);
            }
            
            // This is useful if you suspect you're changing order too much.
            //trace("Reordered " + updated + " items.");
        }
        
        public function add(dor:DisplayObjectRenderer):void
        {
            var idx:int = rendererList.indexOf(dor);
            if(idx != -1)
                throw new Error("Already added!");
            
            rendererList.push(dor as DisplayObjectRendererG2D);
            addChild((dor as DisplayObjectRendererG2D).displayObjectG2D);
            markDirty();
        }
        
        public function remove(dor:DisplayObjectRenderer):void
        {
            var idx:int = rendererList.indexOf(dor as DisplayObjectRendererG2D);
            if(idx == -1)
                return;
            rendererList.splice(idx, 1);
            removeChild((dor as DisplayObjectRendererG2D).displayObjectG2D);
        }
		
		public function get drawOrderFunction():Function
		{
			return _drawOrderFunction;
		}
		
		/**
		 * @private
		 */
		public function set drawOrderFunction(value:Function):void
		{
			_drawOrderFunction = value;
		}
    }
}