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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
   
   /**
    * Component to manage rendering a 2d scene to BitmapData. 
    */ 
   public class Scene2DBitmapDataComponent extends Scene2DComponent
   {   	   	   		

	    /**
	    *  get BitmapData of renderTarget
	    */    	   	
   		public function get bitmapData():BitmapData
   		{
   			return _currentRenderTarget;
   		}

	    /**
	    *  get BitmaData of clearRenderTarget
	    */    	   	
   		public function get clearBitmapData():BitmapData
   		{
   			return _clearRenderTarget;
   		}

	    /**
	    *  get Bitmap of renderTarget
	    */    	   	
   		public function get bitmap():Bitmap
   		{
   			return _bitmap;
   		}

	    /**
	    *  False if Bitmap should not be automaticly added to the sceneView 
	    */    	   	
   		public function get addToView():Boolean
   		{
   			return _addToView;
   		}
   		public function set addToView(value:Boolean):void
   		{
   			_addToView = value;
   		}


	    /**
	    *  BitmapData supports per-pixel transparency.
	    */    	   	
   		public function get transparent():Boolean
   		{
   			return _transparent;
   		}
   		public function set transparent(value:Boolean):void
   		{
   			if (value!=_transparent)
   			{
   			   _transparent = value;
   			   invalidateRenderTarget();
   			}
   		}

	    /**
	    *  Background color of the BitmapData on each render 
	    */    	   	
   		public function get fillColor():uint
   		{
   			return _fillColor;
   		}
   		public function set fillColor(value:uint):void
   		{
   			if (value!=_fillColor)
   			{
   			   _fillColor = value;
   			   invalidateRenderTarget();
   			}	   			
   		}

	    /**
	    *  Specifies if the background has to be cleared on each render  
	    */    	   	
   		public var doClear:Boolean = true;
   		
   		   		      		   		   		   		   		
	    /**
	    *  the function render() will handle rendering of the scene 
	    */    	   	
      	override protected function render():void
        {    
        	// if renderTarget is not defined yet or sceneView dimensions have changed (re)create the renderTarget    	
        	if (_currentRenderTarget==null || _currentRenderTarget.width!=sceneView.width || _currentRenderTarget.height!=sceneView.height)
        		createRenderTarget();

			// if we want to clear the _renderTarget we will do that using the copyPixels method using the prepared _clearRenderTarget
			// BitmapData. This is a faster way to clear than using FillRect.
        	if (doClear)
        		_currentRenderTarget.copyPixels(_clearRenderTarget,_clearRenderTarget.rect,new Point(0,0));

			// call the super.render() method to render all elements onto the renderTarget
			super.render();
			
			// add the _bitmap linked to renderTarget BitmapData to the sceneView - each call to super.render() will clear all sceneView objects						
			if (_addToView)
			  sceneView.addDisplayObject(_bitmap);
		}
		
		
	    /**
	    *  When this class is added to the system 
	    *  the renderTarget has to be created. 
	    */    	   	
		override protected function onAdd():void
		{
			super.onAdd();
			createRenderTarget();
		}
        
	    /**
	    *  The function will create the renderTarget, create a bitmap that links to the 
	    *  renderTarget BitmapData and creates and fills a BitmapData that will be used 
	    *  for clearing purposes.
	    */    	   	
        private function createRenderTarget():void
        {
        	// if there is a renderTarget invalidate it first
        	if (_currentRenderTarget!=null) invalidateRenderTarget();
        	// create the renderTarget BitmapData
        	_currentRenderTarget = new BitmapData(sceneView.width,sceneView.height,_transparent);
        	// create bitmap that will be added to the sceneView
        	_bitmap = new Bitmap(_currentRenderTarget);
        	// create the clearRenderTarget BitmapData and fill it with the _fillColor
        	_clearRenderTarget = new BitmapData(sceneView.width,sceneView.height,false,_fillColor);        	
        }
                      
	    /**
	    *  The function invalidateRenderTarget will invalidate the 
	    *  renderTarget so it is recreated in render() 
	    */    	   	
        private function invalidateRenderTarget():void
        {
        	// dispose of the renderTarget
			_currentRenderTarget.dispose();
			_currentRenderTarget = null;   			           	
        	// dispose of the bitmap
        	_bitmap = null;
        	// dispose of the renderTarget used for clearing
			_clearRenderTarget.dispose();
			_clearRenderTarget = null;   			           	
        }

		// private variable declarations	

        private var _clearRenderTarget:BitmapData;
        private var _transparent:Boolean = false;
        private var _fillColor:uint = 0x000000;
        private var _bitmap:Bitmap = null;
        private var _addToView:Boolean = true;   		
   		   		   		   		
   }
}