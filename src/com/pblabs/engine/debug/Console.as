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
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.core.IPBObject;
    import com.pblabs.engine.core.InputKey;
    import com.pblabs.engine.core.PBGroup;
    import com.pblabs.engine.core.PBObject;
    import com.pblabs.engine.core.PBSet;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.IEntityComponent;
    import com.pblabs.engine.entity.PropertyReference;
    import com.pblabs.engine.serialization.TypeUtility;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
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
        
        /**
         * Alphabetically ordered list of commands.
         */
        protected static var commandList:Array = [];
        protected static var commandListOrdered:Boolean = false;

		protected static var _hotKeyCode:uint = InputKey.TILDE.keyCode;
        
        protected static var _stats:Stats;
        
        public static var verbosity:int = 0;
		public static var showStackTrace:Boolean = false;
		
        
        
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
            
            // Update the list.
            commandList.push(c);
            commandListOrdered = false;
        }
        
        /**
         * @return An alphabetically sorted list of all the console commands.
         */
        public static function getCommandList():Array
        {
            ensureCommandsOrdered();
            
            return commandList;
        }
        
        /**
         * Take a line of console input and process it, executing any command.
         * @param line String to parse for command.
         */
        public static function processLine(line:String):void
        {
            // Make sure everything is in order.
            ensureCommandsOrdered();
			
			// Match Tokens, this allows for text to be split by spaces excluding spaces between quotes.
			// TODO Allow escaping of quotes
			var pattern:RegExp = /[^\s"']+|"[^"]*"|'[^']*'/g;
			var args:Array = [];
			var test:Object = {};
			while (test)
			{
				test = pattern.exec(line);
				if(test)
				{
					var str:String = test[0];
					str = PBUtil.trim(str, "'");
					str = PBUtil.trim(str, "\"");
					args.push(str);	// If no more matches can be found, test will be null	
				}
			}
			
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
				var errorStr:String = "Error: " + e.toString();
				if(showStackTrace)
				{
					errorStr += " - " + e.getStackTrace();
				}
                Logger.error(Console, args[0], errorStr);
            }
        }
        
        /**
         * Internal initialization, this will get called on its own. 
         */
        public static function init():void
        {
			/*** THESE ARE THE DEFAULT CONSOLE COMMANDS ***/
            registerCommand("help", function(prefix:String = null):void
            {
                // Get commands in alphabetical order.
                ensureCommandsOrdered();
                
                Logger.print(Console, "Keyboard shortcuts: ");
                Logger.print(Console, "[SHIFT]-TAB - Cycle through autocompleted commands.");
                Logger.print(Console, "PGUP/PGDN   - Page log view up/down a page.");
                Logger.print(Console, "");
                
                // Display results.
                Logger.print(Console, "Commands:");
                for(var i:int=0; i<commandList.length; i++)
                {
                    var cc:ConsoleCommand = commandList[i] as ConsoleCommand;
                    
                    // Do prefix filtering.
                    if(prefix && prefix.length > 0 && cc.name.substr(0, prefix.length) != prefix)
                        continue;
                    
                    Logger.print(Console, "   " + cc.name + " - " + (cc.docs ? cc.docs : ""));
                }
                
                // List input options.
            }, "[prefix] - List known commands, optionally filtering by prefix.");
            
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
					Logger.print(Console, "Disabled FPS display.");
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
			
			/*** Commands for Property References ***/ 
			// Create dummy entity to make these propertyReferences work
			var dummyEntity:IEntity = PBE.allocateEntity();
			dummyEntity.initialize("console");
			
			registerCommand("set", _setProperty, 
				"Sets a property reference. usage: set #entity.component.property false");
			
			registerCommand("get", _getProperty,
				"Gets a property reference. usage: get #entity.component.property");
			
			registerCommand("call", _callMethod,
				"Calls a method on a component. usage: call #entity.component.function param1 param2");
			
			registerCommand("dispatch", _dispatchEvent,
				"Dispatches an event on an entity's event bus. usage: dispatch #entity eventType");
        }
		
		protected static function _setProperty(reference:String, value:*):void
		{
			if(reference.substr(0,1) != "#" && reference.substr(0,1) != "!")
			{
				Logger.warn(Console, "set", "set can only be used on named entites or templates. " +
					"The PropertyReference must start with # or !.");
				return;
			}
			
			var entity:IEntity = PBE.lookupEntity("console");
			var pr:PropertyReference = new PropertyReference(reference);
			
			var downcase:String = String(value).toLowerCase();
			if(downcase == "true" || downcase == "false")
			{
				value = PBUtil.stringToBoolean(downcase);
			}
			
			entity.setProperty(pr, value);
		}
		
		protected static function _getProperty(reference:String):void
		{
			if(reference.substr(0,1) != "#" && reference.substr(0,1) != "!")
			{
				Logger.warn(Console, "get", "get can only be used on named entites or templates. " +
					"The PropertyReference must start with # or !.");
				return;
			}
			
			var entity:IEntity = PBE.lookupEntity("console");
			var pr:PropertyReference = new PropertyReference(reference);
			
			Logger.print(Console, entity.getProperty(pr));
		}
		
		protected static function _callMethod(reference:String, ... args):void
		{
			if(reference.substr(0,1) != "#")
			{
				Logger.warn(Console, "call", "call can only be used on named entites. " +
					"The PropertyReference must start with #.");
				return;
			}
			
			var entity:IEntity = PBE.lookupEntity("console");
			var pr:PropertyReference = new PropertyReference(reference);
			
			var f:* = entity.getProperty(pr);
			
			if(f == null) // check for null here becuase this is a function
			{
				Logger.warn(Console, "call", reference + ", function does not exist.");
				return;
			}
				
			if(f is Function)
			{
				f.apply(null, args);	
			}
			else
			{
				Logger.warn(Console, "call", reference + " is not a function.");
				return;
			}
		}
		
		protected static function _dispatchEvent(reference:String, eventType:String):void
		{
			if(reference.substr(0,1) != "#")
			{
				Logger.warn(Console, "dispatch", "dispatch can only be used on named entites. " +
					"The PropertyReference must start with #.");
				return;
			}
			
			// remove the # from the entity and look it up
			var entity:IEntity = PBE.lookupEntity(reference.substring(1));
			
			if(entity)
			{
				entity.eventDispatcher.dispatchEvent(new Event(eventType));
			}
			else
			{
				Logger.warn(Console, "dispatch", "Could not find entity named \""+reference.substring(1)+"\".");
				return;
			}
			
			
		}
        
        protected static function ensureCommandsOrdered():void
        {
            // Avoid extra work.
            if(commandListOrdered == true)
                return;

            // Register default commands.
            if(commands.help == null)
                init();

            // Note we are done.
            commandListOrdered = true;
            
            // Do the sort.
            commandList.sort(function(a:ConsoleCommand, b:ConsoleCommand):int
            {
                if(a.name > b.name)
                    return 1;
                else
                    return -1;
            });
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
                    current.name + type + (current.alias != null ? " alias = " + current.alias : ""));
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
		
		/**
		 * The keycode to toggle the Console interface.
		 */		
		public static function set hotKeyCode(value:uint):void
		{
			Logger.print(Console, "Setting hotKeyCode to: "+value);
			_hotKeyCode = value;
		}
		
		public static function get hotKeyCode():uint
		{
			return _hotKeyCode;
		}
    }
}

final class ConsoleCommand
{
    public var name:String;
    public var callback:Function;
    public var docs:String;
}