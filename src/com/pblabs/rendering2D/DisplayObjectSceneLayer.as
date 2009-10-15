package com.pblabs.rendering2D
{
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    
    public class DisplayObjectSceneLayer extends Sprite
    {
        public var drawOrderFunction:Function;
        public var rendererList:Array = new Array();
        public var needSort:Boolean = false;
        
        static public function defaultSortFunction(a:DisplayObjectRenderer, b:DisplayObjectRenderer):int
        {
            return a.zIndex - b.zIndex;
        }
        
        public function DisplayObjectSceneLayer()
        {
            drawOrderFunction = defaultSortFunction;
        }
        
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