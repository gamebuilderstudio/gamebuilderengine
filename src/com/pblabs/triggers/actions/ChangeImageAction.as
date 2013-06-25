package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.rendering2D.SWFSpriteRenderer;
	import com.pblabs.rendering2D.SpriteRenderer;
	import com.pblabs.starling2D.SWFSpriteRendererG2D;
	import com.pblabs.starling2D.SpriteRendererG2D;
	
	import flash.geom.Point;
	
	public class ChangeImageAction extends BaseAction
	{
		/**
		 * The resource filename to load at runtime
		 **/
		public var resourceFileName : String;
		/**
		 * The class name of an embedded asset inside of a SWF perhaps
		 **/
		public var embeddedAssetName : String;
		/**
		 * The reference to the Renderer component
		 **/
		public var rendererComponentRef : PropertyReference = new PropertyReference();
		
		private var _renderer : DisplayObjectRenderer;
		
		public function ChangeImageAction(){
			super();
		}
		
		override public function execute():*
		{
			if(!resourceFileName || !rendererComponentRef)
				return;
			
			if(!_renderer)
				_renderer = this.owner.owner.getProperty( rendererComponentRef ) as DisplayObjectRenderer;
			if(_renderer)
			{
				if(_renderer is SpriteRenderer)
				{
					(_renderer as SpriteRenderer).fileName = resourceFileName;
				}else if(_renderer is SpriteRendererG2D){
					(_renderer as SpriteRendererG2D).fileName = resourceFileName;
				}else if(_renderer is SWFSpriteRenderer){
					(_renderer as SWFSpriteRenderer).fileName = resourceFileName;
					(_renderer as SWFSpriteRenderer).containingObjectName = embeddedAssetName;
				}else if(_renderer is SWFSpriteRendererG2D){
					(_renderer as SWFSpriteRendererG2D).fileName = resourceFileName;
					(_renderer as SWFSpriteRendererG2D).containingObjectName = embeddedAssetName;
				}
			}
			return;
		}
		
		override public function destroy():void
		{
			if(rendererComponentRef)
				rendererComponentRef.destroy();
			_renderer = null;
			super.destroy();
		}
	}
}