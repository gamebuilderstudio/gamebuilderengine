package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	
	import cmodule.Box2D.*;
	
	import flash.geom.Point;
	
	public class b2Vec2 extends b2Base {
		
		public function b2Vec2(p:int = -1) {
			if(p == -1)
				_ptr = int(lib.b2Vec2Array_new(this))+8;
			else
				_ptr = p;
		}
		
		public static function Make(x : Number, y : Number):b2Vec2 {
			var bV : b2Vec2 = new b2Vec2(-1);
			bV.x = x;
			bV.x = y;
			return bV;
		}
		
		public function SetZero() : void { x = 0.0; y = 0.0; }
		public function SetV(v:V2) : void { x=v.x; y=v.y; }
		
		public function get v2():V2 {
			return new V2(x, y);
		}
		
		public function set v2(v:V2):void {
			x = v.x;
			y = v.y;
		}
		
		public function get x():Number { return mem._mrf(_ptr + 0); }
		public function set x(v:Number):void { mem._mwf(_ptr + 0, v); }
		public function get y():Number { return mem._mrf(_ptr + 4); }
		public function set y(v:Number):void { mem._mwf(_ptr + 4, v); }
	
	}
}