package com.pblabs.box2D
{
	import Box2DAS.Dynamics.b2Body;

	public class BodyType
	{
		public static const DYNAMIC:uint = b2Body.b2_dynamicBody;
		public static const KINEMATIC:uint = b2Body.b2_kinematicBody;
		public static const STATIC:uint = b2Body.b2_staticBody;
	}
}