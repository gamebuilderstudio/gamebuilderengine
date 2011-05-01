package com.flexgangsta.pbtriggers.actions
{
	import com.flexgangsta.pbtriggers.ITriggerComponent;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;

	public class MethodInvoker implements IAction
	{
		//______________________________________ 
		//	Public Properties
		//______________________________________
		
		/**
		 * A PropertyReference of the method to call.
		 */		
		[TypeHint(type="com.pblabs.engine.entity.PropertyReference")]
		public var methodReference:PropertyReference;
		
		/**
		 * An Array of arguments to pass to the method
		 * when it is called
		 */		
		public var args:Array = new Array();
		
		/**
		 * This is should be set to <code>false</code> if you wish to pass 
		 * actual PropertyReference objects as parameters.
		 * 
		 * @default true
		 */		
		public var passReferences:Boolean=true;
		
		public function set owner(value:ITriggerComponent):void
		{
			_owner = value;
		}
		
		//______________________________________ 
		//	Public Methods
		//______________________________________
		public function execute():*
		{
			var processedArguments:Array = new Array();
			
			//process the arguments
			for(var i:int=0; i<args.length; i++)
			{
				var arg:* = args[i];
				// If we get a property reference and it's okay to convert them to objects
				if(arg is PropertyReference && passReferences)
					processedArguments.push(_owner.owner.getProperty(arg as PropertyReference));
				else
					processedArguments.push(arg);
			}
			
			// Create the method and execute
			try
			{
				var method:Function = _owner.owner.getProperty(methodReference);
				return method.apply(null,processedArguments);
			}
			catch(e:Error)
			{
				if(e is ArgumentError)
					Logger.error(this,"execute","MethodInvoker Failed:" + ArgumentError(e).message);
				else
					Logger.error(this,"execute","MethodInvoker Failed: Method reference " + methodReference.property + " does not exist");
				return;
			}
		}
		
		public function destroy():void
		{
			var len : int = args.length;
			for(var i : int = 0; i < len; i++)
			{
				args.pop();
			}
			methodReference = null;
			_owner = null;
		}
		//______________________________________ 
		//	Private Properties
		//______________________________________
		private var _owner:ITriggerComponent;
	}
}