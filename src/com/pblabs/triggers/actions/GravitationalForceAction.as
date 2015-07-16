package com.pblabs.triggers.actions
{
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	import com.pblabs.nape.INape2DSpatialComponent;
	import com.pblabs.nape.NapeManagerComponent;
	
	import nape.geom.Geom;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Circle;
	import nape.space.Space;
	
	public class GravitationalForceAction extends BaseAction
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
		
		public function GravitationalForceAction(){
			super();
			_type = ActionType.PERSISTANT;
		}
		
		override public function onTick(deltaTime:Number):void
		{
			execute();
			
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
		
		override public function execute():*
		{
			if(!spatialReference || !gravitationalForceExp)
				return;
			
			if(!_samplePoint){
				_samplePoint = new Body();
				_samplePoint.shapes.add(new Circle(0.001));
			}
			
			if(!_spatial)
				_spatial = this.owner.owner.getProperty( spatialReference ) as INape2DSpatialComponent;

			super.execute();
		}
		
		override public function stop():void
		{
			_spatial = null;
			super.stop();
		}
		
		override public function destroy():void
		{
			if(gravitationalForceExp)
				gravitationalForceExp.destroy();
			gravitationalForceExp = null;
			if(maxDistanceExp)
				maxDistanceExp.destroy();
			maxDistanceExp = null;
			if(spatialReference)
				spatialReference.destroy();
			spatialReference = null;
			_spatial = null;
			
			super.destroy();
		}
	}
}