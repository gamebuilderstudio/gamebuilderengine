package com.pblabs.nape
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.rendering2D.IScene2D;
	
	import nape.util.ShapeDebug;
	
	public class NapeDebugRenderer extends DisplayObjectRenderer
	{
		private var _shapeDebug:ShapeDebug;
		private var _spatialManager:NapeManagerComponent;
		private var _enabled:Boolean;
		
		public function NapeDebugRenderer()
		{
			super();
			enabled = true;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			if ( value != _enabled )
			{
				_enabled = value;
				if (!_enabled &&  _shapeDebug )
					_shapeDebug.clear();
			}
		}

		public function get spatialManager():NapeManagerComponent
		{
			return _spatialManager;
		}

		public function set spatialManager(value:NapeManagerComponent):void
		{
			_spatialManager = value;
		}

		override public function onFrame(elapsed:Number):void
		{
			var scale:Number = _spatialManager.scale;
			if ( _enabled && _shapeDebug)
			{
				_shapeDebug.clear();
				_shapeDebug.transform.setAs(scale, 0, 0, scale, 0, 0);
				_shapeDebug.draw(_spatialManager.space);
				_shapeDebug.flush();
			}
		}
		
		override protected function onAdd():void
		{
			if (!scene)
			{
				Logger.warn(this, "onAdd", "Debug renderer scene is not set!");
				scene = PBE.lookupComponentByType("Scene", IScene2D) as IScene2D;
			}
			super.onAdd();
			_shapeDebug = new ShapeDebug(scene.sceneViewBounds.width, scene.sceneViewBounds.height );
			//_shapeDebug.drawConstraints = true;
			displayObject =  _shapeDebug.display;
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			displayObject = null;
		}
	}
}