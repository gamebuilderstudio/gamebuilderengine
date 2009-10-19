package com.pblabs.engine.debug
{
    /**
     * Process simple text commands from the user.
     */ 
	public class Console
	{
        /**
         * The commands. 
         */
        protected static var commands:Object = {};
        
        public static function registerCommand(name:String, callback:Function, docs:String = null):void
        {
            // Sanity checks.
            if(callback == null)
                Logger.error(Console, "registerCommand", "Command '" + name + "' has no callback!");

            if(!name || name.length == 0)
                Logger.error(Console, "registerCommand", "Command has no name!");

            if(name.indexOf(" ") != -1)
                Logger.error(Console, "registerCommand", "Command '" + name + "' has a space in it, it will not work.");
            
            // Fill in description.
            var c:ConsoleCommand = new ConsoleCommand();
            c.name = name;
            c.callback = callback;
            c.docs = docs;
            
            if(commands[name])
                Logger.warn(Console, "registerCommand", "Replacing existing command '" + name + "'.");
            
            // Set it.
            commands[name] = c;
        }
        
        public static function processLine(line:String):void
        {
            // Register default commands.
            if(commands.help == null)
                init();
            
            // Split it by spaces.
            var args:Array = line.split(" ");
            
            // Look up the command.
            if(args.length == 0)
                return;
            var potentialCommand:ConsoleCommand = commands[args[0].toString()]; 
            
            if(!potentialCommand)
            {
                Logger.warn(Console, "processLine", "No such command '" + args[0].toString() + "'!");
                return;
            }

            // Now call the command.
            potentialCommand.callback.apply(null, args.slice(1));
        }
        
        public static function init():void
        {
            registerCommand("help", function():void
            {
                // Get commands in alphabetical order.
                var tempList:Array = [];
                for(var cmd:String in commands)
                    tempList.push(cmd);
                tempList.sort();
                
                // Display results.
                Logger.print(Console, "Commands:");
                for(var i:int=0; i<tempList.length; i++)
                {
                    var cc:ConsoleCommand = commands[tempList[i]] as ConsoleCommand;
                    Logger.print(Console, "   " + cc.name + " - " + (cc.docs ? cc.docs : ""));
                }
            }, "List known commands.");
        }
	}
}

final class ConsoleCommand
{
    public var name:String;
    public var callback:Function;
    public var docs:String;
}