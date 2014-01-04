package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	
	import flash.geom.Point;

	/**
	 * A Parallax effect renderer that tiles a texture and allows it to have a parallax factor which is multiplied by the 
	 * current scene position.
	 * 
	 * Multiple ParallaxRendererComponent can be used to create a multi-layered parallaxed scene background effect.
	 **/
	public class ParallaxRendererComponent extends ScrollingBitmapRenderer
	{
		[EditorData(inspectable="true")]
		public var parallaxFactor : Point = new Point(1, 1);

		public function ParallaxRendererComponent()
		{
			super();
		}

		private var _lastPos : Point = new Point();
		override public function onFrame(deltaTime:Number):void
		{
			if(!_displayObject || !_scene)
				return;

			var l : Number = scene.sceneViewBounds.left;
			var t : Number = scene.sceneViewBounds.top;
			if(!_painted && !PBE.IN_EDITOR){
				l += ((_position.x + _positionOffset.x) - registrationPoint.x);
				t += ((_position.y + _positionOffset.y) - registrationPoint.y);
				_lastPos.setTo(l, t);
			}
			var difX : Number = _lastPos.x - l;
			var difY : Number = _lastPos.y - t;
			var curPos : Point = this._position.clone();
			curPos.x -= difX;
			curPos.y -= difY;
			
			var direction:Number = Math.atan2(difY, difX);
			var length:Number = PBUtil.xyLength(difX,difY);
			difX = (Math.cos(direction)*length);
			difY = (Math.sin(direction)*length);
			_scratchPosition.x += difX * (parallaxFactor.x);
			_scratchPosition.y += difY * (parallaxFactor.y);
			
			_lastPos.setTo( scene.sceneViewBounds.left , scene.sceneViewBounds.top );
			
			if(PBE.processManager.timeScale <= 0){
				_scratchPosition.x = _scratchPosition.y = 0;
			}

			offsetImage(_scratchPosition.x, _scratchPosition.y);
			
			updateProperties();
			
			if(!PBE.IN_EDITOR)
				position = curPos;
			
			// Now that we've read all our properties, apply them to our transform.
			if (_transformDirty)
				updateTransform();
			
		}
	}
}