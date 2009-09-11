package com.pblabs.rendering2D
{
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * Render simple shapes. For placeholder art, you often don't want or need to
	 * use sprites; this component will draw a circle or square of a specified
	 * size and color.
	 */
	public class SimpleShapeRenderComponent extends BaseRenderComponent
	{
	  
		public var borderColor:uint = 0x000000;
	  
		[EditorData(defaultValue="2")]
		public var borderThickness:Number = 2.0;
		
		[EditorData(defaultValue="255")]
		public var fillColor:uint = 0x0000FF;
		  
		[EditorData(defaultValue="100")]
		public var radius:Number;
		
		public var showCircle:Boolean;
		  
		[EditorData(defaultValue="true")]
		public var showSquare:Boolean;
		
		protected var _dummySprite:Sprite=new Sprite();
	
		override public function onDraw(manager:IDrawManager2D):void
		{
			// Draw to the dummy sprite.
		    _dummySprite.graphics.clear();
		    _dummySprite.graphics.lineStyle(borderThickness, borderColor);
		    _dummySprite.graphics.beginFill(fillColor);
		    
		    var rp:Point = manager.transformWorldToScreen(renderPosition, 0, scrollFactor);
		    
		    if(showSquare)
		       _dummySprite.graphics.drawRect(rp.x - radius, rp.y - radius, radius * 2, radius * 2); 
		
		    if(showCircle)
		       _dummySprite.graphics.drawCircle(rp.x, rp.y, radius);
		       
		    _dummySprite.graphics.endFill();
		
		    // Submit to the draw manager.        
			manager.drawDisplayObject(_dummySprite);
		}
	}
}