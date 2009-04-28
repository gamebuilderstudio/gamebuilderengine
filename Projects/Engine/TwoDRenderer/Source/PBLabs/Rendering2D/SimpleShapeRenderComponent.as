package PBLabs.Rendering2D
{
   import flash.display.*;
   import flash.geom.*;
   
	/**
	 * Render simple shapes. For placeholder art, you often don't want or need to
	 * use sprites; this component will draw a circle or square of a specified
	 * size and color.
	 */
	public class SimpleShapeRenderComponent extends BaseRenderComponent
	{
	  public var ShowCircle:Boolean;
	  public var ShowSquare:Boolean;
	  public var Radius:Number;
	  
	  public var BorderThickness:Number = 2.0;
	  public var BorderColor:Number = 0x000000;
	  public var FillColor:Number = 0xFF00FF;
	
     public override function OnDraw(manager:IDrawManager2D):void
     {
        // Draw to the dummy sprite.
        _DummySprite.graphics.clear();
        _DummySprite.graphics.lineStyle(BorderThickness, BorderColor);
        _DummySprite.graphics.beginFill(FillColor);
        
        var rp:Point = RenderPosition;
        
        if(ShowSquare)
           _DummySprite.graphics.drawRect(rp.x - Radius, rp.y - Radius, Radius * 2, Radius * 2); 

        if(ShowCircle)
           _DummySprite.graphics.drawCircle(rp.x, rp.y, Radius);
           
        _DummySprite.graphics.endFill();

        // Submit to the draw manager.        
        manager.DrawDisplayObject(_DummySprite);
     }
	   
	   var _DummySprite:Sprite = new Sprite();
	}
}