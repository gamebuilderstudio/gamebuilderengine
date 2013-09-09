package com.pblabs.physics
{
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.rendering2D.IMobileSpatialObject2D;
	
	import flash.geom.Point;

	public interface IPhysics2DSpatial extends IMobileSpatialObject2D
	{
		function buildCollisionShapes():void;
		
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
		function get bodyType():*; 
		function set bodyType(val : *):void;
		function get gravity():Point; 
		function set gravity(val : Point):void;
		
	}
}