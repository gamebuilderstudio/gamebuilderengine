package com.pblabs.physics
{
	import flash.geom.Point;

	public interface IPhysicsShape
	{
		function get name():String;
		function set name(value:String):void;
		function get density():Number;
		function set density(value:Number):void;
		function get friction():Number;
		function set friction(value:Number):void;
		function get restitution():Number;
		function set restitution(value:Number):void;
		function get isTrigger():Boolean;
		function set isTrigger(value:Boolean):void;
		function get shapeScale():Point;
		function set shapeScale(value:Point):void;
		function get containerSpatial():IPhysics2DSpatial;
	}
}