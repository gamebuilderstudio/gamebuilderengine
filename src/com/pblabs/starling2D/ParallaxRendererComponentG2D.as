/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import com.pblabs.engine.PBUtil;
	
	import flash.geom.Point;

	/**
	 * A Parallax effect renderer that tiles a texture and allows it to have a parallax factor which is multiplied by the 
	 * current scene position.
	 * 
	 * Multiple ParallaxRendererComponentG2D can be used to create a multi-layered parallaxed scene background effect.
	 **/
	public class ParallaxRendererComponentG2D extends ScrollingBitmapRendererG2D
	{
		[EditorData(inspectable="true")]
		public var parallaxFactor : Point = new Point(1, 1);
		
		public function ParallaxRendererComponentG2D()
		{
			super();
		}
	
		private var _lastPos : Point = new Point();
		override public function onFrame(deltaTime:Number):void
		{
			if(!displayObjectG2D || !scene || !(scene as DisplayObjectSceneG2D).trackObject || !scene.camera)
				return;

			var trackedObject : DisplayObjectRendererG2D = (scene as DisplayObjectSceneG2D).trackObject;
			var l : Number = trackedObject.x;
			var t : Number = trackedObject.y;
			if(_initialDraw){
				l += this.transformationMatrix.tx;
				t += this.transformationMatrix.ty;
				_lastPos.setTo(l, t);
			}
			var difX : Number = (_lastPos.x - l);
			var difY : Number = (_lastPos.y - t);
			var curPos : Point = this._position.clone();
			if(!_initialDraw){
				curPos.x -= difX;
				curPos.y -= difY;
			}

			var direction:Number = Math.atan2(difY, difX);
			var length:Number = PBUtil.xyLength(difX,difY);
			_scratchPoint.x -= (Math.cos(direction)*length) * (parallaxFactor.x);
			_scratchPoint.y -= (Math.sin(direction)*length) * (parallaxFactor.y);

			_lastPos.setTo( trackedObject.x , trackedObject.y );
			
			offsetTexture(_scratchPoint.x, _scratchPoint.y);

			updateProperties();
			
			if(!_initialDraw)
				position = curPos;
			
			// Now that we've read all our properties, apply them to our transform.
			if (_transformDirty)
				updateTransform();
			
		}
	}
}