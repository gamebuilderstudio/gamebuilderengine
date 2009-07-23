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
   import Box2D.Collision.Shapes.b2PolygonDef;
   import Box2D.Collision.Shapes.b2ShapeDef;
   
   import flash.geom.Point;
   
   public class PolygonCollisionShape extends CollisionShape
   {
      [TypeHint(type="flash.geom.Point")]
      public function get Vertices():Array
      {
         return _vertices;
      }
      
      public function set Vertices(value:Array):void
      {
         _vertices = value;
         
         if (_parent != null)
            _parent.BuildCollisionShapes();
      }
      
      protected override function _CreateShape():b2ShapeDef
      {
         var halfSize:Point = new Point(_parent.Size.x * 0.5, _parent.Size.y * 0.5);
         var scale:Number = _parent.Manager.InverseScale;
         
         var shape:b2PolygonDef = new b2PolygonDef();
         
         shape.vertexCount = _vertices.length;
         for (var i:int = 0; i < shape.vertexCount; i++)
            shape.vertices[i].Set(_vertices[i].x * halfSize.x * scale, _vertices[i].y * halfSize.y * scale);
         
         return shape;
      }
      
      private var _vertices:Array = null;
   }
}