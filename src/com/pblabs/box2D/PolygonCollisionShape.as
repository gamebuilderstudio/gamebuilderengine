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
   import Box2DAS.Collision.Shapes.*;
   import Box2DAS.Common.V2;
   import Box2DAS.Dynamics.b2FixtureDef;
   
   import flash.geom.Point;
   
   public class PolygonCollisionShape extends CollisionShape
   {
      [TypeHint(type="flash.geom.Point")]
      public function get vertices():Array
      {
         return _vertices;
      }
      
      public function set vertices(value:Array):void
      {
         _vertices = value;
         
         if (_parent)
            _parent.buildCollisionShapes();
      }
      
	  override protected function doCreateShape():b2FixtureDef 
	  {
  			var halfSize:Point = new Point(_parent.size.x * 0.5, _parent.size.y * 0.5);
  			var scale:Number = (_parent.spatialManager as Box2DManagerComponent).inverseScale;
  			
			if(!_vertices) generateBox(10, 10);
  			var verticies:Array = new Array();
  			for (var i:int = 0; i < _vertices.length; i++)
	  				verticies.push(new V2(_vertices[i].x * halfSize.x * scale, _vertices[i].y * halfSize.y * scale));
  			
  			var shape:b2PolygonShape = new b2PolygonShape();
  			shape.SetAsArray(verticies);
  			
  			var fixtureDef:b2FixtureDef = new b2FixtureDef();
  			fixtureDef.shape = shape;
  			
  			return fixtureDef;
  	   }
	  		
	  	public function generateBox(halfWidth:Number, halfHeight:Number):void {
	  		_vertices = new Array();
		  	_vertices.push(new Point( -halfWidth, -halfHeight));
	  		_vertices.push(new Point( halfWidth, -halfHeight));
	 		_vertices.push(new Point( halfWidth, halfHeight));
			_vertices.push(new Point( -halfWidth, halfHeight));
	  }
      
      private var _vertices:Array = null;
   }
}