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
            _output.x = 0;
            _output.y = 0;
            _input.x = 0;
            
            if(stage)		
            {
                _width = stage.stageWidth-1;
                _height = (stage.stageHeight / 3) * 2;
            }
            
            _output.height = _height-30;
            _output.width = _width;
            
            _input.height = 18;
            _input.width = _width;
            
            _input.y = _output.height + 2;
        }
        
        protected function createOutputField():TextField
        {
            _output = new TextField();
            _output.type = TextFieldType.DYNAMIC;
            _output.border = true;
            _output.borderColor = 0;
            _output.background = true;
            _output.backgroundColor = 0xFFFFFF;
            _output.multiline = true;
            _output.wordWrap = true;
            _output.condenseWhite = false;
            var format:TextFormat = _output.getTextFormat();
            format.font = "_typewriter";
            format.size = 11;
            _output.setTextFormat(format);
            _output.defaultTextFormat = format;
            _output.htmlText = "";
			_output.name = "ConsoleOutput";
            
            return _output;
        }
        
        protected function createInputField():TextField
        {
            _input = new TextField();
            _input.type = TextFieldType.INPUT;
            _input.border = true;
            _input.borderColor = 0;
            _input.background = true;
            _input.backgroundColor = 0xFFFFFF;
            _input.multiline = false;
            _input.wordWrap = false;
            _input.condenseWhite = false;
            var format:TextFormat = _input.getTextFormat();
            format.font = "_typewriter";
            format.size = 11;
            _input.setTextFormat(format);
            _input.defaultTextFormat = format;
            _input.restrict = "^`";		// Tilde's are not allowed in the input since they close the window
			_input.name = "ConsoleInput";
            
            return _input;
        }
        
        protected function setHistory(old:String):void
        {
            _input.text = old;
            setTimeout(function():void { _input.setSelection(_input.length, _input.length); }, 0);
        }
        
        protected function onInputKeyDown(event:KeyboardEvent):void
        {
            if(event.keyCode == Keyboard.ENTER)
            {
                if(_input.text.length <= 0)
				{
					// Enter a blank line
					addLogMessage("CMD", ">", _input.text);
					return;
				}
                
                // If Enter was pressed, process the command
                processCommand();
            }
            else if (event.keyCode == Keyboard.UP)
            {
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
                var append:String = "<p><font size=\"" +
                    _input.getTextFormat().size+"\" color=\"" + 
                    color +"\"><b>" + 
                    PBUtil.escapeHTMLText(text) + "</b></font></p>";
                _output.htmlText += append;
                truncateOutput();
                
                _output.scrollV = _output.maxScrollV;
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
            resize();
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
