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
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    
    /**
     * Layer within a DisplayObjectScene which manages a list of 
     * DisplayObjectRenderers. The layer is responsible for keeping
     * itself sorted. This is also a good site for custom render
     * effects, parallaxing, etc.
     */
    public class DisplayObjectSceneLayer extends Sprite
    {
        /**
         * Array.sort() compatible function used to determine draw order. 
         */
        public var drawOrderFunction:Function;
        
        /**
         * All the renderers in this layer. 
         */
        public var rendererList:Array = new Array();
        
        /**
         * Set to true when we need to resort the layer. 
         */
        internal var needSort:Boolean = false;
        
        /**
         * Default sort function, which orders by zindex.
         */
        static public function defaultSortFunction(a:DisplayObjectRenderer, b:DisplayObjectRenderer):int
        {
            return a.zIndex - b.zIndex;
        }
        
        public function DisplayObjectSceneLayer()
        {
            drawOrderFunction = defaultSortFunction;
            mouseEnabled = false;
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
                var d:DisplayObject = rendererList[i].displayObject;
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
            
            rendererList.push(dor);
            addChild(dor.displayObject);
            markDirty();
        }
        
        public function remove(dor:DisplayObjectRenderer):void
        {
            var idx:int = rendererList.indexOf(dor);
            if(idx == -1)
                return;
            rendererList.splice(idx, 1);
            removeChild(dor.displayObject);
        }
    }
}