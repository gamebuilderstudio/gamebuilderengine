package com.pblabs.engine.scripting
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.serialization.ISerializable;
	import com.pblabs.engine.util.DynamicObjectUtil;
	
	import flash.geom.Point;
	
	import scripting.Parser;
	import scripting.Scanner;
	import scripting.VirtualMachine;
	
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
		public static var GlobalExpEntities : Object = {};
		
		private var _value:*;
		private var _dynamicThisObject : Object = new Object();
		private var _cachedProgram : *;
		private var _byteCode : Array;
		
		private static var _scriptScanner : Scanner = new Scanner();
		private static var _scriptParser : Parser = new Parser();
		private static var _initialized : Boolean = false;
		private static var _evm : VirtualMachine = new VirtualMachine();
		private static var _globalGameObject : Object;
		private static var _expressionCache : Vector.<ExpressionByteCode>;
		private var _fatalError : Boolean = false;
		
		public function ExpressionReference(expression:Object="", selfContext : Object = null)
		{
			if(!_initialized)
				initialize();	

			this.expression = String(expression);
			
			this.selfContext = selfContext;
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
			xml.appendChild(expressionXML);
		}
		
		/**
		 * @inheritDoc
		 */
		public function deserialize(xml:XML):*
		{
			expression = String(xml);
			return this;
		}
		
		public function destroy():void
		{
			DynamicObjectUtil.clearDynamicObject(_dynamicThisObject);
			_dynamicThisObject = null;
			_value = null;
			_expression = null;
			_cachedProgram = null;
			var cachedExp : ExpressionByteCode = findCachedExpressionCode(_expression);
			if(cachedExp)
				cachedExp.referenceCount--;
		}
		
		public static function getExpressionValue(expression : ExpressionReference, owner : IEntity):*
		{
			var value : *;
			if(expression){
				if(!expression.selfContext)
					expression.selfContext = owner.Self;
				value = expression.value;
				if(value == null || value == "null" || value == "undefined")
					value = null;
			}
			return value;
		}
		/*-----------------------------------------------------------------------------------------------------------
		*                                          Private Method
		-------------------------------------------------------------------------------------------------------------*/
		private function evaluateExpression(context : Object = null, thisObject : * = null):void
		{
			if(PBE.IN_EDITOR)
				return;
			if(thisObject == null){
				thisObject = _dynamicThisObject;
				
				if(context)
				{
					thisObject.Self = context;
				}
			}
			if(_byteCode){
				_globalGameObject.Self = thisObject.Self;
				_evm.rewind();
				_evm.setByteCode(_byteCode);
				if(!_evm.execute())
				{
					_value = _evm.getGlobalObject().returnVal;
				}
			}
		}
		
		private function initialize():void
		{
			if(!_globalGameObject){
				_globalGameObject = _evm.getGlobalObject();
				_globalGameObject.Entity = ExpressionReference.GlobalExpEntities;
				_globalGameObject.Point = Point;
				_globalGameObject.PBE = PBE;
				ExpressionUtils.importStaticMethods( _globalGameObject, Math );
				//Override slow math functions with faster bitwise versions
				ExpressionUtils.importFunction(_globalGameObject, "abs", ExpressionUtils.fastAbs);
				ExpressionUtils.importFunction(_globalGameObject, "floor", ExpressionUtils.fastFloor);
				ExpressionUtils.importFunction(_globalGameObject, "setPoint", ExpressionUtils.setPoint);
				//ExpressionUtils.importFunction(_globalGameObject, "Entity", ExpressionUtils.getEntity);
				ExpressionUtils.importFunction(_globalGameObject, "magnitudeOfPoint", ExpressionUtils.magnitudeOfPoint);
				ExpressionUtils.importFunction(_globalGameObject, "magnitude", ExpressionUtils.magnitude);
				ExpressionUtils.importFunction(_globalGameObject, "rotationOfAngle", ExpressionUtils.rotationOfAngle);
				ExpressionUtils.importFunction(_globalGameObject, "distance", ExpressionUtils.distance);
				ExpressionUtils.importFunction(_globalGameObject, "distanceOfPoint", ExpressionUtils.distanceOfPoint);
				ExpressionUtils.importFunction(_globalGameObject, "randomRange", ExpressionUtils.randomRange);
				ExpressionUtils.importFunction(_globalGameObject, "clampToRange", ExpressionUtils.clampToRange);
				ExpressionUtils.importFunction(_globalGameObject, "percentOfRange", ExpressionUtils.percentOfRange);
				ExpressionUtils.importFunction(_globalGameObject, "valueOfRangePercent", ExpressionUtils.valueOfRangePercent);
				ExpressionUtils.importFunction(_globalGameObject, "roundTo", ExpressionUtils.roundTo);
				ExpressionUtils.importFunction(_globalGameObject, "inchesToPixels", ExpressionUtils.inchesToPixels);
				ExpressionUtils.importFunction(_globalGameObject, "mmToPixels", ExpressionUtils.mmToPixels);
				
				DynamicObjectUtil.copyDynamicObject(PBE.GLOBAL_DYNAMIC_OBJECT, _globalGameObject);
			}
			if(!_expressionCache)
				_expressionCache = new Vector.<ExpressionByteCode>();
			_initialized = true;
		}
		
		private function findCachedExpressionCode(expression : String):ExpressionByteCode
		{
			var len : int = _expressionCache.length;
			for(var i : int = 0; i < len; i++)
			{
				if(_expressionCache[i].expression == expression){
					return _expressionCache[i];
				}
			}
			return null;
		}

		private function parseExpression(rawExpression : String):String
		{
			if(rawExpression.substr(0, 1) == ".")
				rawExpression = "0" + rawExpression;
			if(rawExpression.indexOf(" .") > -1)
				rawExpression = rawExpression.split(" .").join(" 0.");
			return rawExpression;
		}
		
		/*-----------------------------------------------------------------------------------------------------------
		*                                          Getter & Setters
		-------------------------------------------------------------------------------------------------------------*/
		/**
		 * The evaluated value of the expression 
		 */
		public function get value():*
		{
			if(_fatalError)
				return null;
			
			if(!PBE.IS_SHIPPING_BUILD){
				try{
					evaluateExpression();
				}catch(e : Error){
					_fatalError = true;
					Logger.error(this, "ExpressionValue", "Expression Fatal Error: [ "+_expression+" ] exiting...");
				}
			}else{
				evaluateExpression();
			}
			return _value;
		}
		
		private var _expression:String = null;
		/**
		 * The string to the expression that this evaluates.
		 */
		public function get expression():String { return _expression; }
		public function set expression(str:String):void
		{
			if(str == null || _expression == str) 
				return;
			if(str == ""){ _expression = ""; return; }
			
			_expression = parseExpression(str);
			if(!PBE.IN_EDITOR){
				var cachedExp : ExpressionByteCode = findCachedExpressionCode(_expression);
				if(cachedExp){
					_byteCode = cachedExp.byteCode;
					cachedExp.referenceCount++;
				}else{
					var tmpExp : String = "var returnVal = " +_expression;
					if(tmpExp.substr(-1, 1) != ";")
						tmpExp += ";";
					
					_scriptScanner.source = tmpExp;
					_scriptParser.scanner = _scriptScanner;
					
					_byteCode = _scriptParser.parse(_evm);
					var expCacheEntry : ExpressionByteCode = new ExpressionByteCode();
					expCacheEntry.byteCode = _byteCode;
					expCacheEntry.expression = _expression;
					expCacheEntry.referenceCount++;
					_expressionCache.push( expCacheEntry );
				}
			}
		}
		
		public function get selfContext():Object{ return _dynamicThisObject.Self; }
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
import flash.utils.describeType;

class ExpressionUtils{
	public static function importStaticMethods(globalObject : Object, staticClass : Class):void
	{
		var classDesc : XML = describeType(staticClass);
		var curName : String;
		for each(var constant : XML in classDesc.constant)
		{
			curName = String(constant.@name);
			globalObject[curName] = staticClass[curName];
		}
		for each(var method : XML in classDesc.method)
		{
			curName = String(method.@name);
			globalObject[curName] = staticClass[curName];
		}
	}
	
	public static function importFunction(globalObject : Object, funcName : String, func : Function):void
	{
		globalObject[funcName] = func;
	}
	
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
	
	public static function randomRange(min : Number, max : Number):Number
	{
		return (int(Math.random() * (max - min + 1)) + min);
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

	public static function fastAbs(v:int) : int {
		return (v ^ (v >> 31)) - (v >> 31);
	}
	
	public static function fastFloor(v:Number) : int {
		return int(v);
	}
}

class ExpressionByteCode
{
	public var expression : String;
	public var byteCode : Array;
	public var referenceCount : int = 0;
}