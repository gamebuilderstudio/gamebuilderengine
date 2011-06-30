package com.pblabs.box2D.controllers
{
	import Box2DAS.Common.V2;
	import Box2DAS.Controllers.*;
	
	import com.pblabs.box2D.Box2DManagerComponent;
	import com.pblabs.box2D.Box2DSpatialComponent;
	import com.pblabs.engine.entity.EntityComponent;
	
	import flash.geom.Point;
	
	/**
	 * A PBE implementation of the box2D controller that can be used with a Box2DManagerComponent.
	 * This is an implementation that can be re-used multiple times by just adding different effects to 
	 * each one.
	 * 
	 * <listing version="3.0">
	 * var box2DController : Box2DControllerComponent = new Box2DControllerComponent();
	 * box2DController.effect = new box2DSpringEffect();
	 * gameEntity.addComponent(box2DController, "BuoyancyEffect");
	 * </listing>
	 * @author Lavon Woods
	 */
	public class Box2DControllerComponent extends EntityComponent 
	{
			
		//-----------------------------------------------------------------------------
		//
		//  Properties
		//
		//-----------------------------------------------------------------------------
		
		protected var b2dController:b2Controller;
		
		protected var b2dEffect : b2Effect;
		public function get():b2Effect { return b2dEffect; }
		public function set(effect : b2Effect):void { 
			b2dEffect = effect; 
		}
		
		//-----------------------------------------------------------------------------
		//
		//  Constructor
		//
		//-----------------------------------------------------------------------------
		
		public function Box2DControllerComponent() {
			super();
			initialize();
		}

		//-------------------------------------
		//  spatialManager
		//-------------------------------------
		
		private var _spatialManager:Box2DManagerComponent;
		
		public function get spatialManager():Box2DManagerComponent {
				return _spatialManager;
		}
		
		public function set spatialManager(value:Box2DManagerComponent):void {
			if (value == _spatialManager)
				return;
			
			if (b2dController) {
				disposeController();
				
				_spatialManager = value;
				
				setupController();
			} else {
				_spatialManager = value;
			}
		}
		
		
		//-------------------------------------
		//  spatials
		//-------------------------------------
		
		private var _spatials:Array;
		
		public function get spatials():Array {
				return _spatials;
		}
		
		public function set spatials(value:Array):void {
				disposeSpatials();
				
				_spatials = value;
				
				setupSpatials();
		}
		
		
		//-----------------------------------------------------------------------------
		//
		//  Methods
		//
		//-----------------------------------------------------------------------------
		
		override protected function onAdd():void {
				super.onAdd();
				
				setup();
		}
		
		override protected function onReset():void {
				super.onReset();
				
				setup();
		}
		
		override protected function onRemove():void {
				dispose();
				
				super.onRemove();
		}
		
		
		//--------------------------------------
		//
		//  Initialize
		//
		//-------------------------------------
		
		private function initialize():void {
				_spatials = new Array();
		}
		
		
		//-------------------------------------
		//
		//  Setup
		//
		//-------------------------------------
		
		private function setup():void {
				if (_spatialManager == null) throw new Error("spatialManager was not assigned");
				
				setupController();
		}
		
		private function dispose():void {
				disposeController();
		}
		
		
		//-------------------------------------
		//  b2dController
		//-------------------------------------
		
		private function setupController():void {
				if(b2dController)
					return;
				
				disposeController();
				
				b2dController = new b2Controller(null, b2dEffect);
				
				_spatialManager.addController(b2dController);
				
				setupSpatials();
		}
		
		private function disposeController():void {
				disposeSpatials();
				
				_spatialManager.removeController(b2dController);
				
				b2dController = null;
		}
		
		
		//-------------------------------------
		//  spatials
		//-------------------------------------
		
		private function setupSpatials():void {
				if (b2dController == null)
						return;
				
				for each (var spatial:Box2DSpatialComponent in _spatials) {
						b2dController.AddBody(spatial.body);
				}
		}
		
		private function disposeSpatials():void {
				if (_spatials == null)
						return;
				
				for each (var spatial:Box2DSpatialComponent in _spatials) {
						b2dController.RemoveBody(spatial.body);
				}
		}
		
		
		//-------------------------------------
		//
		//  Adding Spatials
		//
		//-------------------------------------
		
		public function addSpatial(spatial:Box2DSpatialComponent):void {
				_spatials.push(spatial);
				
				if (spatial.body == null)
						return;
				
				if (b2dController)
						b2dController.AddBody(spatial.body);
		}
		
		public function removeSpatial(spatial:Box2DSpatialComponent):void {
				var index:int = _spatials.indexOf(spatial);
				if (index == -1)
						return;
				
				_spatials.splice(index, 1);
				
				if (b2dController)
						b2dController.RemoveBody(spatial.body);
		}
	}
}