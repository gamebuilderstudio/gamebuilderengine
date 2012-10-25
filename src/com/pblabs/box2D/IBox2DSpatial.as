package com.pblabs.box2D
{
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.rendering2D.IMobileSpatialObject2D;

	public interface IBox2DSpatial extends IMobileSpatialObject2D
	{
		function get collisionType():ObjectType;
		function set collisionType(type : ObjectType):void;
		function get collidesWithTypes():ObjectType;
		function set collidesWithTypes(type : ObjectType):void;
		function get collisionShapes():Array;
		function set collisionShapes(shapes : Array):void;
		
	}
}