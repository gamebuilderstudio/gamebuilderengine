/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.debug
{
    import com.pblabs.engine.PBE;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.system.Security;
    
    /**
     * Process simple text commands from the user. Useful for debugging.
     */ 
    public class Console
    {
        /**
         * The commands, indexed by name. 
         */
        protected static var commands:Object = {};
        protected static var _stats:Stats;
        
        public static var verbosity:int = 0;
        
        
        /**
         * Register a command which the user can execute via the console.
         * 
         * <p>Arguments are parsed and cast to match the arguments in the user's
         * function. Command names must be alphanumeric plus underscore with no
         * spaces.</p>
         *  
         * @param name The name of the command as it will be typed by the user. No spaces.
         * @param callback The function that will be called. Can be anonymous.
         * @param docs A description of what the command does, its arguments, etc.
         * 
         */
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
            
            if(commands[name.toLowerCase()])
                Logger.warn(Console, "registerCommand", "Replacing existing command '" + name + "'.");
            
            // Set it.
            commands[name.toLowerCase()] = c;
        }
        
        /**
         * Take a line of console input and process it, executing any command.
         * @param line String to parse for command.
         */
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
            var potentialCommand:ConsoleCommand = commands[args[0].toString().toLowerCase()]; 
            
            if(!potentialCommand)
            {
                Logger.warn(Console, "processLine", "No such command '" + args[0].toString() + "'!");
                return;
            }
            
            // Now call the command.
            try
            {
                potentialCommand.callback.apply(null, args.slice(1));                
            }
            catch(e:Error)
            {
                Logger.error(Console, args[0], "Error: " + e.toString() + " - " + e.getStackTrace());
            }
        }
        
        /**
         * Internal initialization, this will get called on its own. 
         */
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
            
            registerCommand("version", function():void
            {
                Logger.print(Console, "PushButton Engine - r"+ PBE.REVISION +" - "+
                    PBE.versionDetails +" - "+Security.sandboxType);
            }, "Echo PushButton Engine version information.");
            
            // NB - Do we want to rename this to "toggleFps"?
            registerCommand("showFps", function():void
            {
                if(!_stats)
                {
                    _stats = new Stats();
                    PBE.mainStage.addChild(_stats);
                    Logger.print(Console, "Enabled FPS display.");
                }
                else
                {
                    PBE.mainStage.removeChild(_stats);
                    _stats = null;
                }
            }, "Toggle an FPS/Memory usage indicator.");
            
            registerCommand("verbose", function(level:int):void
            {
                Console.verbosity = level;
                Logger.print(Console, "Verbosity set to " + level);
            }, "Set verbosity level of console output.");
            
            registerCommand("listDisplayObjects", function():void
            {
                Console._listDisplayObjects(PBE.mainStage, 0);
            }, "Outputs the display list.");
        }
        
        protected static function _listDisplayObjects(current:DisplayObject, indent:int):void
        {
            if (!current)
                return;
            
            Logger.print(Console, 
                Console.generateIndent(indent) + 
                current.name + 
                " ("+ current.x + ","+ current.y+") visible=" +
                current.visible);
            
            var parent:DisplayObjectContainer = current as DisplayObjectContainer;
            if (!parent)
                return;
            
            for (var i:int = 0; i < parent.numChildren; i++)
                _listDisplayObjects(parent.getChildAt(i), indent+1);
        }
        
        protected static function generateIndent(indent:int):String
        {
            var str:String = "";
            for(var i:int=0; i<indent; i++)
            {
                // Add 2 spaces for indent
                str += "  ";
            }
            
            return str;
        }
    }
}

final class ConsoleCommand
{
    public var name:String;
    public var callback:Function;
    public var docs:String;
}