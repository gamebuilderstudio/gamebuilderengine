package com.pblabs.triggers.actions
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;
	
	public class PropertySetter extends BaseAction
	{
		public static const PROPERTYTYPES_POINT : String = "Point";
		public static const PROPERTYTYPES_PROPERTYREF : String = "Reference";
		public static const PROPERTYTYPES_EXPRESSIONREF : String = "Expression";
		public static const PROPERTYTYPES_COLOR : String = "Color";
		public static const PROPERTYTYPES_STRING : String = "String";
		public static const PROPERTYTYPES_INT : String = "int";
		public static const PROPERTYTYPES_NUMBER : String = "Number";
		public static const PROPERTYTYPES_UINT : String = "uint";
		
		//______________________________________ 
		//	Public Properties
		//______________________________________
		public var source:Object;

		[TypeHint(type="com.pblabs.engine.entity.PropertyReference")]
		public var property:PropertyReference;
		/**
		 * This is should be set to <code>false</code> if you wish to pass 
		 * actual PropertyReference objects for the source property.
		 * 
		 * @default true
		 */		
		public var passReferences:Boolean=true;
		public var propertyType : String = "int";
		
		//______________________________________ 
		//	Public Methods
		//______________________________________
		override public function execute():*
		{
			var newPropValue:*;
			
			// If our source is a properyreference
			if(source is ExpressionReference)
			{
				newPropValue = getExpressionValue((source as ExpressionReference));
				
			}else if(source is PropertyReference && passReferences) {
				
				newPropValue = _owner.owner.getProperty(source as PropertyReference);
			}
			// If our source is just a plain object
			else
			{
				newPropValue = source;
			}
			
			//Set property
			try
			{
				switch(propertyType){
					case PROPERTYTYPES_INT:
						newPropValue = int(newPropValue);
						break;
					case PROPERTYTYPES_NUMBER:
						newPropValue = Number(newPropValue);
						break;
					case PROPERTYTYPES_COLOR:
						newPropValue = uint(newPropValue);
						break;
					case PROPERTYTYPES_UINT:
						newPropValue = uint(newPropValue);
						break;
					case PROPERTYTYPES_STRING:
						newPropValue = String(newPropValue);
						break;
				}
				_owner.owner.setProperty(property, newPropValue);
			}
			catch(e:Error)
			{
				Logger.error(this,"execute","PropertySetter on component ["+this.owner.name+"] and entity ("+this.owner.owner.name+") Failed: " + e.message);
			}
			
			// Return a reference to the property
			return _owner.owner.getProperty(property);
		}
		
		override public function destroy():void
		{
			if(source is ExpressionReference) (source as ExpressionReference).destroy();
			source = null;
			property = null;
			super.destroy();
		}
	}
}