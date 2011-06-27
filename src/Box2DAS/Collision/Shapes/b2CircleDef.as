package Box2DAS.Collision.Shapes
{
	import Box2DAS.Common.V2;
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Dynamics.b2FixtureDef;
	
	public class b2CircleDef extends b2FixtureDef
	{
		public function b2CircleDef()
		{
			localPosition = new b2Vec2(_ptr + 16);
			localPosition.v2 = new V2(0.0, 0.0);
			
			type = b2Shape.e_circle;
			radius = 1.0;
			
			super();
		}
		
		public var localPosition:b2Vec2;
		public var radius:Number;
	}
}