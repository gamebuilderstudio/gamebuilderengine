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
		public var source:*;

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
				(source as ExpressionReference).selfContext = _owner.owner.Self;
				newPropValue = (source as ExpressionReference).value;
				
			}else if(source is PropertyReference && passReferences) {
				
				newPropValue = _owner.owner.getProperty(source);
			}
			// If our source is just a plain object
			else
			{
				newPropValue = source;
			}
			
			//Set property
			try
			{
				_owner.owner.setProperty(property,newPropValue);
			}
			catch(e:Error)
			{
				Logger.error(this,"execute","PropertySetter Failed: " + e.message);
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