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
    import com.pblabs.engine.core.IPBObject;
    import com.pblabs.engine.core.PBGroup;
    import com.pblabs.engine.core.PBObject;
    import com.pblabs.engine.core.PBSet;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.IEntityComponent;
    import com.pblabs.engine.serialization.TypeUtility;
    
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
                Logger.print(Console, PBE.versionDetails.toString());
            }, "Echo PushButton Engine version information.");
            
            registerCommand("fps", function():void
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
                var sum:int = Console._listDisplayObjects(PBE.mainStage, 0);
                Logger.print(Console, " " + sum + " total display objects.");
            }, "Outputs the display list.");
            
            registerCommand("tree", function():void
            {
                var sum:int = Console._listPBObjects(PBE.rootGroup, 0);
                Logger.print(Console, " " + sum + " total PBObjects.");
            }, "List all the PBObjects in the game.");
        }
        
        protected static function _listDisplayObjects(current:DisplayObject, indent:int):int
        {
            if (!current)
                return 0;
            
            Logger.print(Console, 
                Console.generateIndent(indent) + 
                current.name + 
                " ("+ current.x + ","+ current.y+") visible=" +
                current.visible);
            
            var parent:DisplayObjectContainer = current as DisplayObjectContainer;
            if (!parent)
                return 1;
            
            var sum:int = 1;
            for (var i:int = 0; i < parent.numChildren; i++)
                sum += _listDisplayObjects(parent.getChildAt(i), indent+1);
            return sum;
        }

        protected static function _listPBObjects(current:IPBObject, indent:int):int
        {
            if (!current)
                return 0;
            
            var type:String = " ("+ TypeUtility.getObjectClassName(current) +")";
            if(current.name || current.alias)
            {
                Logger.print(Console, 
                    Console.generateIndent(indent) + 
                    current.name + type + " alias = " + current.alias);
            }
            else
            {
                Logger.print(Console, 
                    Console.generateIndent(indent) + 
                    "[anonymous]" + type);                
            }
            
            // Recurse if it's a known type.
            var parentSet:PBSet = current as PBSet;
            var parentGroup:PBGroup = current as PBGroup;
            var parentEntity:IEntity = current as IEntity;
            
            var sum:int = 1;
			var i:int = 0;

            if(parentSet)
            {
                for(i=0; i<parentSet.length; i++)
                    sum += _listPBObjects(parentSet.getItem(i), indent+1);
            }
            else if(parentGroup)
            {
                for(i=0; i<parentGroup.length; i++)
                    sum += _listPBObjects(parentGroup.getItem(i), indent+1);
            }
            else if(parentEntity)
            {
                // Get all the components. Components don't count for the sum.
                var c:Array = parentEntity.lookupComponentsByType(IEntityComponent);
                for(i=0; i<c.length; i++)
                {
                    var iec:IEntityComponent = c[i] as IEntityComponent;
                    type = " ("+ TypeUtility.getObjectClassName(iec) +")";
                    Logger.print(Console, Console.generateIndent(indent + 1) + iec.name + type);
                }
            }
            
            return sum;
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