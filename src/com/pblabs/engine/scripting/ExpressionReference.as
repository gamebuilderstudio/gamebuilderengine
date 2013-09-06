package com.pblabs.engine.scripting
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.serialization.ISerializable;
	import com.pblabs.engine.util.DynamicObjectUtil;
	
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	import r1.deval.D;
	
	/**
	 * ExpressionReference is the wrapper for the D.eval class to run expressions in PBE.
	 * This is a very powerful class because you can access components on the entity that 
	 * this reference belongs to by passing the Self property from an IEntity to this class.
	 * 
	 * An expression that is run by an ExpressionReference instance also has access to the global references in a game 
	 * that can be found on the PBE.GLOBAL_DYNAMIC_OBJECT object such as the Game object or Accelerometer, etc.
	 * 
	 * #see com.pblabs.engine.core.GlobalExpressionManager
	 * 
	 * Expressions also have access to all the static methods on the Math class such as cos(), sin(), random(), etc...
	 * 
	 * <listing version="1.0">
	 * 	var expression : ExpressionReference = new ExpressionReference("(Self.Spatial.position.x * 10) - Game.Mouse.stageX", entity.Self);
	 * 	var val : Number = expression.value;
	 * 
	 * 	//OR concatenate an evaluation
	 * 	var newVal : Number = expression.eval( "cos( (Self.Spatial.position.y * 10) )" ).value;
	 * 
 	 * 	//VERY IMPORTANT
	 * 	//Destory all expression references when finished using it.
	 * 	expression.destroy();
	 * </listing>
	 **/
	public class ExpressionReference implements ISerializable
	{
		public var cacheExpression : Boolean = false;
		
		private var _value:*;
		private var _dynamicThisObject : Object = new Object();
		private var _thisObjectName : String;
		private var _cachedProgram : *;
		
		private static var _initialized : Boolean = false;

		public function ExpressionReference(expression:Object="", selfContext : Object = null)
		{
			this.expression = String(expression);

			DynamicObjectUtil.copyDynamicObject(PBE.GLOBAL_DYNAMIC_OBJECT, _dynamicThisObject);
			
			this.selfContext = selfContext;
			if(!_initialized)
				initialize();	
		}
		
		public function eval(str : String, context : Object = null, thisObject : * = null):ExpressionReference
		{
			this.expression = str;
			evaluateExpression(context, thisObject);
			return this;
		}
		
		
		/*--Serialization-----------------------------------------------------------------------------------------------*/
		/**
		 * @inheritDoc
		 */
		public function serialize(xml:XML):void
		{
			var expressionXML : XML = new XML("<![CDATA["+ _expression +"]]>");
			if(_dynamicThisObject && _dynamicThisObject.Self && _dynamicThisObject.Self["name"])
			{
				xml.@thisObjectName = _dynamicThisObject.Self.name;
			}
			xml.appendChild(expressionXML);
		}
		
		/**
		 * @inheritDoc
		 */
		public function deserialize(xml:XML):*
		{
			/*if(_expression && _expression !== xml.toString())
				Logger.warn(this, "deserialize", "Overwriting property; was '" + _property + "', new value is '" + xml.toString() + "'");*/
			_expression = xml.toString();
			_thisObjectName = String(xml.@thisObjectName);
			if(_dynamicThisObject && _expression.indexOf(_thisObjectName) != -1)
			{
				var entity : IEntity = PBE.lookupEntity(_thisObjectName);
				if(!entity){
					PBE.callLater(deserialize, [xml]);
					return this;
				}
				_dynamicThisObject.selfContext = entity.Self;
			//}else{
				//Logger.error(this, "deserialize", "Fatal Error deserializing Expression Reference. The @thisObjectName property is missing from the xml node tag");
			}
			return this;
		}
		
		public function destroy():void
		{
			DynamicObjectUtil.clearDynamicObject(_dynamicThisObject);
			_dynamicThisObject = null;
			_value = null;
			_expression = null;
			_cachedProgram = null;
		}

		public static function getExpressionValue(expression : ExpressionReference, owner : IEntity):*
		{
			var value : *;
			if(expression){
				expression.selfContext = owner.Self;
				value = expression.value;
				if(value == null || value == "null" || value == "undefined")
					value = expression.expression;
			}
			return value;
		}
		/*-----------------------------------------------------------------------------------------------------------
		*                                          Private Method
		-------------------------------------------------------------------------------------------------------------*/
		private function evaluateExpression(context : Object = null, thisObject : * = null):void
		{
			if(thisObject == null){
				thisObject = _dynamicThisObject;

				if(context)
				{
					thisObject.Self = context;
				}
			}
			try{
				if(cacheExpression){
					_value = D.eval(_cachedProgram, context, thisObject);
				}else{
					_value = D.eval(_expression, context, thisObject);
				}
			}catch(e : Error){
				Logger.error(this, 'evaluateExpression', 'Failed expression ['+_expression+'] Msg = '+e.message);
			}
		}
		
		private function parseExpression():void
		{
			//TODO Pull Out PropertyReferences
		}
		
		private function initialize():void
		{
			if(_initialized) return;
			
			D.importStaticMethods( Math );
			D.importClass( Point );
			D.importClass( PBE );
			D.importFunction("setPoint", ExpressionUtils.setPoint);
			D.importFunction("Entity", ExpressionUtils.getEntity);
			D.importFunction("magnitudeOfPoint", ExpressionUtils.magnitudeOfPoint);
			D.importFunction("magnitude", ExpressionUtils.magnitude);
			D.importFunction("rotationOfAngle", ExpressionUtils.rotationOfAngle);
			D.importFunction("distance", ExpressionUtils.distance);
			D.importFunction("distanceOfPoint", ExpressionUtils.distanceOfPoint);
			D.importFunction("clampToRange", ExpressionUtils.clampToRange);
			D.importFunction("percentOfRange", ExpressionUtils.percentOfRange);
			D.importFunction("valueOfRangePercent", ExpressionUtils.valueOfRangePercent);
			D.importFunction("roundTo", ExpressionUtils.roundTo);
			D.importFunction("inchesToPixels", ExpressionUtils.inchesToPixels);
			D.importFunction("mmToPixels", ExpressionUtils.mmToPixels);
			
			_initialized = true;
		}
		/*-----------------------------------------------------------------------------------------------------------
		*                                          Getter & Setters
		-------------------------------------------------------------------------------------------------------------*/
		/**
		 * The evaluated value of the expression 
		 */
		public function get value():*
		{
			evaluateExpression();
			return _value;
		}
		
		private var _expression:String = null;
		/**
		 * The string to the expression that this evaluates.
		 */
		public function get expression():String { return _expression; }
		public function set expression(str:String):void
		{
			if(str == null || _expression == str) return;
			
			_expression = str;
			if(cacheExpression){
				_cachedProgram = D.parseProgram(_expression);
			}else{
				_cachedProgram = null;
			}
				
			parseExpression();
		}
		
		public function set selfContext(obj : Object):void
		{
			if(!obj) return;
			//Copy Data to internal Object
			_dynamicThisObject.Self = obj;
		}
		
		public function get dynamicThisObject():Object{ return _dynamicThisObject; }
	}
}
import com.pblabs.engine.PBE;
import com.pblabs.engine.entity.IEntity;

import flash.geom.Point;
import flash.system.Capabilities;

class ExpressionUtils{
	public static function inchesToPixels(inches:Number):Number
	{
		return Math.round(Capabilities.screenDPI * inches);
	}
	
	public static function mmToPixels(mm:Number):Number
	{
		return Math.round(Capabilities.screenDPI * (mm / 25.4));
	}

	public static function roundTo(value:Number, decimals:int = 1):Number
	{
		var m:int = Math.pow(10, decimals);
		return Math.round(value * m) / m;
	}
	
	public static function percentOfRange(currentValue : Number, min : Number, max : Number, decimal : Boolean = true):Number
	{
		if(decimal)
			return ((( currentValue - min ) / ( max - min )) / 1 );
		return ((( currentValue - min ) / ( max - min )) * 100 );
	}

	public static function valueOfRangePercent(percentage : Number, min : Number, max : Number):Number
	{
		return ((( max - min ) / 100 ) * percentage ) + min;
	}

	public static function clampToRange(value : Number, min : Number, max : Number):Number
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function distanceOfPoint(pointA : Point, pointB : Point):Number
	{
		return distance(pointA.x, pointA.y, pointB.x, pointB.y);
	}

	public static function distance(x1 : Number, y1 : Number, x2 : Number, y2 : Number):Number
	{
		var dx:Number = x1-x2;
		var dy:Number = y1-y2;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public static function magnitudeOfPoint(point : Point):Number
	{
		return magnitude(point.x, point.y);
	}

	/**
	 * Returns the distance/magnitude between two values
	 **/
	public static function magnitude(valA : Number, valB : Number):Number
	{
		return Math.sqrt( ((valA) * (valA)) + ((valB) * (valB)) );
	}

	/**
	 * Returns the rotation angle of two points in degress
	 **/
	public static function rotationOfAngle(ptA : Point, ptB : Point):Number
	{
		return Math.atan2((ptA.y - ptB.y), (ptA.x - ptB.x)) / Math.PI * 180;
	}

	public static function setPoint(x : Number, y : Number):Point
	{
		return new Point(x,y);
	}

	public static function getEntity(name : String):Object
	{
		var entity : Object = PBE.lookupEntity(name);
		return entity ? entity.Self : null;
	}
}