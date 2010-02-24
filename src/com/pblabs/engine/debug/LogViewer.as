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
    import com.pblabs.engine.core.InputKey;
    
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.setTimeout;
    
    /**
     * Console UI, which shows console log activity in-game, and also accepts input from the user.
     */
    public class LogViewer extends Sprite implements ILogAppender
    {
        protected var _messageQueue:Array = [];
        protected var _maxLength:uint = 200000;
        protected var _truncating:Boolean = false;
        
        protected var _width:uint = 500;
        protected var _height:uint = 150;
        
        protected var _consoleHistory:Array = [];
        protected var _historyIndex:uint = 0;
        
        protected var _output:TextField;
        protected var _input:TextField;
        
        protected var tabCompletionPrefix:String = "";
        protected var tabCompletionCurrentStart:int = 0;
        protected var tabCompletionCurrentEnd:int = 0;
        protected var tabCompletionCurrentOffset:int = 0;
        
        public function LogViewer():void
        {
            layout();
            addListeners();
			
			name = "Console";
			Console.registerCommand("clear", onClearCommand, "Clears the console history.");
        }
        
        protected function layout():void
        {
            if(!_output) createOutputField();
            if(!_input) createInputField();
            
            resize();
            
            addChild(_output);
            addChild(_input);
            
            graphics.clear();
                        
            graphics.beginFill(0x666666, .95);
            graphics.drawRoundRect(0,0,_width,_height,5);
            graphics.endFill();

            graphics.beginFill(0xFFFFFF, 1);
            graphics.drawRoundRect(4,4,_width-8,_height-30,5);
            graphics.endFill();

        }
        
        protected function addListeners():void
        {
            _input.addEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown, false, 1, true);
        }
        
        protected function removeListeners():void
        {
            _input.removeEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown);
        }
		
		protected function onClearCommand():void
		{
			_output.htmlText = "";
		}
        
        protected function resize():void
        {
            _output.x = 5;
            _output.y = 0;
            _input.x = 5;
            
            if(stage)		
            {
                _width = stage.stageWidth-1;
                _height = (stage.stageHeight / 3) * 2;
            }
            
            _output.height = _height-30;
            _output.width = _width-10;
            
            _input.height = 18;
            _input.width = _width-10;
            
            _input.y = _output.height + 7;
        }
        
        protected function createOutputField():TextField
        {
            _output = new TextField();
            _output.type = TextFieldType.DYNAMIC;
            _output.multiline = true;
            _output.wordWrap = true;
            _output.condenseWhite = false;
            var format:TextFormat = _output.getTextFormat();
            format.font = "_typewriter";
            format.size = 11;
            format.color = 0x0;
            _output.setTextFormat(format);
            _output.defaultTextFormat = format;
            _output.htmlText = "";
            _output.embedFonts = false;
			_output.name = "ConsoleOutput";
            
            return _output;
        }
        
        protected function createInputField():TextField
        {
            _input = new TextField();
            _input.type = TextFieldType.INPUT;
            _input.border = true;
            _input.borderColor = 0xFFFFFF;
            _input.multiline = false;
            _input.wordWrap = false;
            _input.condenseWhite = false;
            _input.background = true;
            _input.backgroundColor = 0xFFFFFF;
            var format:TextFormat = _input.getTextFormat();
            format.font = "_typewriter";
            format.size = 11;
            format.color = 0x0;
            _input.setTextFormat(format);
            _input.defaultTextFormat = format;
            _input.restrict = "^`";		// Tilde's are not allowed in the input since they close the window
			_input.name = "ConsoleInput";
            
            return _input;
        }
        
        protected function setHistory(old:String):void
        {
            _input.text = old;
            PBE.callLater(function():void { _input.setSelection(_input.length, _input.length); });
        }
        
        protected function onInputKeyDown(event:KeyboardEvent):void
        {
            // If this was a non-tab input, clear tab completion state.
            if(event.keyCode != Keyboard.TAB && event.keyCode != Keyboard.SHIFT)
            {
                tabCompletionPrefix = _input.text;
                tabCompletionCurrentStart = -1;
                tabCompletionCurrentOffset = 0;
            }

            if(event.keyCode == Keyboard.ENTER)
            {
                // Execute an entered command.
                if(_input.text.length <= 0)
				{
					// display a blank line
					addLogMessage("CMD", ">", _input.text);
					return;
				}
                
                // If Enter was pressed, process the command
                processCommand();
            }
            else if (event.keyCode == Keyboard.UP)
            {
                // Go to previous command.
                if(_historyIndex > 0)
                {
                    setHistory(_consoleHistory[--_historyIndex]); 
                }
                else if (_consoleHistory.length > 0)
                {
                    setHistory(_consoleHistory[0]);
                }
                
                event.preventDefault();
            }
            else if(event.keyCode == Keyboard.DOWN)
            {
                // Go to next command.
                if(_historyIndex < _consoleHistory.length-1)
                {
                    setHistory(_consoleHistory[++_historyIndex]); 
                }
                else if (_historyIndex == _consoleHistory.length-1)
                {
                    _input.text = "";
                }
                
                event.preventDefault();
            }
            else if(event.keyCode == Keyboard.PAGE_UP)
            {
                // Page the console view up.
                _output.scrollV -= Math.floor(_output.height / _output.getLineMetrics(0).height);
            }
            else if(event.keyCode == Keyboard.PAGE_DOWN)
            {
                // Page the console view down.
                _output.scrollV += Math.floor(_output.height / _output.getLineMetrics(0).height);
            }
            else if(event.keyCode == Keyboard.TAB)
            {
                // We are doing tab searching.
                var list:Array = Console.getCommandList();
                
                // Is this the first step?
                var isFirst:Boolean = false;
                if(tabCompletionCurrentStart == -1)
                {
                    tabCompletionPrefix = _input.text.toLowerCase();
                    tabCompletionCurrentStart = int.MAX_VALUE;
                    tabCompletionCurrentEnd = -1;

                    for(var i:int=0; i<list.length; i++)
                    {
                        // If we found a prefix match...
                        if(list[i].name.substr(0, tabCompletionPrefix.length).toLowerCase() == tabCompletionPrefix)
                        {
                            // Note it.
                            if(i < tabCompletionCurrentStart)
                                tabCompletionCurrentStart = i;
                            if(i > tabCompletionCurrentEnd)
                                tabCompletionCurrentEnd = i;

                            isFirst = true;
                        }
                    }
                    
                    tabCompletionCurrentOffset = tabCompletionCurrentStart;
                }
                
                // If there is a match, tab complete.
                if(tabCompletionCurrentEnd != -1)
                {
                    // Update offset if appropriate.
                    if(!isFirst)
                    {
                        if(event.shiftKey)
                            tabCompletionCurrentOffset--;
                        else
                            tabCompletionCurrentOffset++;
                        
                        // Wrap the offset.
                        if(tabCompletionCurrentOffset < tabCompletionCurrentStart)
                        {
                            tabCompletionCurrentOffset = tabCompletionCurrentEnd;
                        }
                        else if(tabCompletionCurrentOffset > tabCompletionCurrentEnd)
                        {
                            tabCompletionCurrentOffset = tabCompletionCurrentStart;
                        }
                    }

                    // Get the match.
                    var potentialMatch:String = list[tabCompletionCurrentOffset].name;
                    
                    // Update the text with the current completion, caret at the end.
                    _input.text = potentialMatch;
                    _input.setSelection(potentialMatch.length + 1, potentialMatch.length + 1);
                }
                
                // Make sure we keep focus. TODO: This is not ideal, it still flickers the yellow box.
                var oldfr:* = stage.stageFocusRect;
                stage.stageFocusRect = false;
                PBE.callLater(function():void {
                    stage.focus = _input;
                    stage.stageFocusRect = oldfr;
                });
            }
            else if(event.keyCode == InputKey.TILDE.keyCode)
            {
                // Hide the console window, have to check here due to 
                // propagation stop at end of function.
                parent.removeChild(this);
                deactivate();
            }
            
            // Keep console input from propagating up to the stage and messing up the game.
            event.stopImmediatePropagation();
        }
        
        protected function truncateOutput():void
        {
            // Keep us from exceeding too great a size of displayed text.
            if (_output.text.length > maxLength)
            {
                _output.text = _output.text.slice(-maxLength);
                
                // Display helpful message that we have capped the log length.
                if(!_truncating)
                {
                    _truncating = true;
                    Logger.warn(this, "truncateOutput", "You have exceeded "+_maxLength+" characters in LogViewerAS. " +
                        "It will now only show the latest "+_maxLength+" characters of the log.");
                }
            }
        }
        
        protected function processCommand():void
        {
            addLogMessage("CMD", ">", _input.text);
            Console.processLine(_input.text);
            _consoleHistory.push(_input.text);
            _historyIndex = _consoleHistory.length;
            _input.text = "";
        }
        
        public function addLogMessage(level:String, loggerName:String, message:String):void
        {
            var color:String = LogColor.getColor(level);
            
            // Cut down on the logger level if verbosity requests.
            if(Console.verbosity < 2)
            {
                var dotIdx:int = loggerName.lastIndexOf("::");
                if(dotIdx != -1)
                    loggerName = loggerName.substr(dotIdx + 2);
            }
            
            var text:String = ((Console.verbosity > 0) ? level + ": " : "") + loggerName + " - " + message;

            if (_output)
            {
                Profiler.enter("LogViewer.addLogMessage");
                
                var append:String = "<p><font size=\"" +
                    _input.getTextFormat().size+"\" color=\"" + 
                    color +"\"><b>" + 
                    PBUtil.escapeHTMLText(text) + "</b></font></p>";
                
                // We should use appendText but it introduces formatting issues,
                // so we stick with htmlText for now. appendText should be good
                // speed up.
                _output.htmlText += append;
                truncateOutput();
                
                _output.scrollV = _output.maxScrollV;

                Profiler.exit("LogViewer.addLogMessage");
            }
        }
        
        public function get maxLength():uint
        {
            return _maxLength;
        }
        
        public function set maxLength(value:uint):void
        {
            _maxLength = value;
            truncateOutput();
        }
        
        public function activate():void
        {
            layout();
            _input.text = "";
            addListeners();
            PBE.mainStage.focus = _input;
        }
        
        public function deactivate():void
        {
            removeListeners();
            PBE.mainStage.focus = null;
        }
    }
}
