package com.pblabs.triggers.actions
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.scripting.ExpressionReference;

	public class MethodInvoker extends BaseAction
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
		public var args:Array = [];
		
		/**
		 * This is should be set to <code>false</code> if you wish to pass 
		 * actual PropertyReference objects as parameters.
		 * 
		 * @default true
		 */		
		public var passReferences:Boolean=true;
		
		//______________________________________ 
		//	Public Methods
		//______________________________________
		override public function execute():*
		{
			var processedArguments:Array = [];
			
			//process the arguments
			for(var i:int=0; i<args.length; i++)
			{
				var arg:* = args[i];
				// If we get a property reference and it's okay to convert them to objects
				if(arg is PropertyReference && passReferences){
					processedArguments.push(_owner.owner.getProperty(arg as PropertyReference));
				}else if(arg is ExpressionReference){
					(arg as ExpressionReference).selfContext = _owner.owner.Self;
					processedArguments.push((arg as ExpressionReference).value);
				}else{
					processedArguments.push(arg);
				}
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
		
		override public function destroy():void
		{
			var len : int = args.length;
			for(var i : int = 0; i < len; i++)
			{
				if(args[i] is ExpressionReference) (args[i] as ExpressionReference).destroy();
				args.pop();
			}
			methodReference = null;
			super.destroy();
		}
	}
}