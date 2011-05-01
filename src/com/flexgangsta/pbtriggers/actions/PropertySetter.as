package com.flexgangsta.pbtriggers.actions
{
	import com.flexgangsta.pbtriggers.ITriggerComponent;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;
	
	public class PropertySetter implements IAction
	{
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
		
		public function set owner(value:ITriggerComponent):void
		{
			_owner=value;
		}

		//______________________________________ 
		//	Public Methods
		//______________________________________
		public function execute():*
		{
			var newPropValue:*;
			
			// If our source is a properyreference
			if(source is PropertyReference && passReferences)
			{
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
		
		public function destroy():void
		{
			source = null;
			property = null;
			_owner = null;
		}
		//______________________________________ 
		//	Private Properties
		//______________________________________
		private var _owner:ITriggerComponent;
	}
}