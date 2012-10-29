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
		function get angularVelocity():Number;
		function set angularVelocity(val : Number):void;
		
		function get canMove():Boolean;
		function set canMove(val : Boolean):void;
		function get canRotate():Boolean;
		function set canRotate(val : Boolean):void;
		function get canSleep():Boolean;
		function set canSleep(val : Boolean):void;
		function get collidesContinuously():Boolean;
		function set collidesContinuously(val : Boolean):void;
		function get bodyType():uint; 
		function set bodyType(val : uint):void; 
	}
}