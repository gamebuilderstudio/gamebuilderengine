package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.nape.INape2DSpatialComponent;
	import com.pblabs.nape.NapeManagerComponent;
	
	import flash.geom.Point;
	
	import nape.geom.Geom;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Circle;
	import nape.space.Space;
	
	public class GravitationalForceAction extends BaseAction implements ITickedObject
	{
		/**
		 * The reference to the physics spatial that will be affected.  
		 **/
		public var spatialReference : PropertyReference;
		/**
		 * The gravitational force applied to all surrounding bodies withing a certain distance/threshold 
		 **/
		public var gravitationalForceExp : ExpressionReference = new ExpressionReference("60");
		/**
		 * The maximum distance from the center of the gravitational force or spatial body center to apply forces to bodies
		 **/
		public var maxDistanceExp : ExpressionReference = new ExpressionReference("100");
		/**
		 * The power to raise the gravitational force to.
		 **/
		public var gravityPower : Number = 6;
		
		private var _spatial : INape2DSpatialComponent;
		private var _force : Vec2 = Vec2.get();
		private var _samplePoint : Body;
		private var _ignoreTimeScale : Boolean = false;
		private var _initialized : Boolean = false;
		
		public function GravitationalForceAction(){
			super();
		}
		
		override public function execute():*
		{
			if(!spatialReference || !gravitationalForceExp)
				return;
			
			if(!_initialized){
				
				if(!_samplePoint){
					_samplePoint = new Body();
					_samplePoint.shapes.add(new Circle(0.001));
				}
				
				if(!_spatial)
					_spatial = this.owner.owner.getProperty( spatialReference ) as INape2DSpatialComponent;
				
				PBE.processManager.addTickedObject(this);
				_initialized = true;
			}
			return;
		}
		
		public function onTick(deltaTime : Number):void
		{
			if(_spatial && _spatial.body && _spatial.spatialManager && (_spatial.spatialManager as NapeManagerComponent).space)
			{
				var physicsSpace : Space = (_spatial.spatialManager as NapeManagerComponent).space;
				
				var closestA:Vec2 = Vec2.get();
				var closestB:Vec2 = Vec2.get();
				
				for (var i:int = 0; i < physicsSpace.liveBodies.length; i++) {
					var body:Body = physicsSpace.liveBodies.at(i);
					// Find closest points between bodies.
					_samplePoint.position.set(body.position);
					var distance:Number = Geom.distanceBody(_spatial.body, _samplePoint, closestA, closestB);
					
					// Cut gravity off, well before distance threshold.
					if (distance > Number(getExpressionValue(maxDistanceExp))) {
						continue;
					}
					
					// Gravitational force.
					var force:Vec2 = closestA.sub(body.position, true);
					
					// We don't use a true description of gravity, as it doesn't 'play' as nice.
					force.length = body.mass * Math.pow(Number(getExpressionValue(gravitationalForceExp)), gravityPower) / (distance * distance);
					
					// Impulse to be applied = force * deltaTime
					body.applyImpulse(
						/*impulse*/ force.muleq(deltaTime),
						/*position*/ null, // implies body.position
						/*sleepable*/ true
					);
				}
				
				closestA.dispose();
				closestB.dispose();
			}
		}
		
		override public function stop():void
		{
			if(_initialized){
				PBE.processManager.removeTickedObject(this);
				_initialized = false;
			}
			super.stop();
		}
		override public function destroy():void
		{
			gravitationalForceExp.destroy();
			gravitationalForceExp = null;
			maxDistanceExp.destroy();
			maxDistanceExp = null;
			_spatial = null;
			
			if(_initialized)
			{
				PBE.processManager.removeTickedObject(this);
			}
			super.destroy();
		}

		/**
		 * @inheritDoc
		 */
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val:Boolean):void
		{
			_ignoreTimeScale = val;
		}
	}
}