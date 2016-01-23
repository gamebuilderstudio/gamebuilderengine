package com.pblabs.triggers.actions
{
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.rendering2D.TiledMapRenderer;
	
	public class ChangeTileIndexAction extends BaseAction
	{
		/**
		 * The reference to the tiled map renderer  
		 **/
		public var tiledMapRendererReference : PropertyReference;
		/**
		 * The X position of the tile in the grid map. 
		 **/
		public var tileX : ExpressionReference = new ExpressionReference("0");
		/**
		 * The Y position of the tile in the grid map. 
		 **/
		public var tileY : ExpressionReference = new ExpressionReference("0");
		/**
		 * The layer in which to change the tile index 
		 **/
		public var tiledLayerIndex : ExpressionReference = new ExpressionReference("0");
		
		private var _tiledMapRenderer : TiledMapRenderer;
		private var _tileX : int;
		private var _tileY : int;
		private var _tileLayerIndex : int;
		
		public function ChangeTileIndexAction(){
			super();
			_type = ActionType.ONETIME;
		}
		
		override public function execute():*
		{
			if(!tiledMapRendererReference || !tileX || !tileY || !tiledLayerIndex)
				return;
			
			if(!_tiledMapRenderer)
				_tiledMapRenderer = this.owner.owner.getProperty( tiledMapRendererReference ) as TiledMapRenderer;
			
			if(_tiledMapRenderer)
			{
				_tileX = !isNaN(int(tileX.expression)) ? int(tileX.expression) : int(getExpressionValue(tileX));
				_tileY = !isNaN(int(tileY.expression)) ? int(tileY.expression) : int(getExpressionValue(tileY));
				_tileLayerIndex = !isNaN(int(tiledLayerIndex.expression)) ? int(tiledLayerIndex.expression) : int(getExpressionValue(tiledLayerIndex));
				
				_tiledMapRenderer.setTile(_tileX, _tileY, _tileLayerIndex);
			}
			return;
		}
		
		override public function destroy():void
		{
			if(tileX) tileX.destroy();
			tileX = null;
			if(tileY) tileY.destroy();
			tileY = null;
			if(tiledLayerIndex) tiledLayerIndex.destroy();
			tiledLayerIndex = null;
			_tiledMapRenderer = null;
			super.destroy();
		}
	}
}