package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Mat22 extends b2Base {
	
		public function b2Mat22(p:int) {
			_ptr = p;
			col1 = new b2Vec2(_ptr + 0);
			col2 = new b2Vec2(_ptr + 8);
		}
		
		public function get m22():M22 {
			return new M22(col1.v2, col2.v2);
		}
		
		public function set m22(v:M22):void {
			col1.v2 = v.c1;
			col2.v2 = v.c2;
		}
		
		//Added: @lavonw
		public function SetM(m:b2Mat22) : void
		{
			col1.SetV(m.col1.v2);
			col2.SetV(m.col2.v2);
		}
		
		public function AddM(m:b2Mat22) : void
		{
			col1.x += m.col1.x;
			col1.y += m.col1.y;
			col2.x += m.col2.x;
			col2.y += m.col2.y;
		}
		
		public function SetIdentity() : void
		{
			col1.x = 1.0; col2.x = 0.0;
			col1.y = 0.0; col2.y = 1.0;
		}
		
		public function SetZero() : void
		{
			col1.x = 0.0; col2.x = 0.0;
			col1.y = 0.0; col2.y = 0.0;
		}
		
		public var col1:b2Vec2; // col1 = new b2Vec2(_ptr + 0);
		public var col2:b2Vec2; // col2 = new b2Vec2(_ptr + 8);
	
	}
}