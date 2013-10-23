package scripting
{

public class Scanner implements IScanner
{
	private var _source:String;
	private var index:int;
	
	private var linesCount:int;
	
	public function Scanner (source:String = "")
	{
		this._source = source;
		rewind();
	}
	
	public function get source():String{ return _source; }
	public function set source(val : String):void
	{
		_source = val;
		rewind();
	}
	
	public function rewind () :void
	{
		index = 0;
		linesCount = 0;
	}
	
	public function getLineNumber () : Number
	{
		return linesCount+1;
	}
	public function getLine () : String
	{
		return (_source.split("\n"))[linesCount];
	}
	
	private function getChar () : String
	{
		return _source.charAt(index);
	}
	private function nextChar () : String
	{
		if (getChar() == "\n") {
			linesCount++;
		}
		
		return _source.charAt(++index);
	}
	
	private function isSpace (c:String) : Boolean
	{
		return (c==" " || c=="\t" || c=="\r" || c=="\n");
	}
	private function isAlphabet (c:String) : Boolean
	{
		var code:int = c.charCodeAt(0);
		return ((65 <= code && code <= 90) || (97 <= code && code <= 122));
	}
	private function isNumber (c:String) : Boolean
	{
		var code:int = c.charCodeAt(0);
		return (48 <= code && code <= 57);
	}
	private function isAlphabetOrNumber (c:String) : Boolean
	{
		var code:int = c.charCodeAt(0);
		return ((48 <= code && code <= 57) || (65 <= code && code <= 90) || (97 <= code && code <= 122));
	}
	private function isHex (c:String) : Boolean
	{
		var code:int = c.charCodeAt(0);
		return ((48 <= code && code <= 57) || (65 <= code && code <= 70) || (97 <= code && code <= 102));
	}
	private function isIdentifier (c:String) : Boolean
	{
		var code:int = c.charCodeAt(0);
		return (code==36 || code==95 || (48 <= code && code <= 57) || (65 <= code && code <= 90) || (97 <= code && code <= 122));
	}
	
	public function getToken () : Token
	{
		var c:String = getChar();
		var value:String;
		var type:String;
		
		while (isSpace(c)) {
			c = nextChar();
		}
		
		if (!c) return null;
		
		if (isAlphabet(c) || c=='$' || c=='_') {
			value = c;
			while ((c = nextChar()) && isIdentifier(c)) {
				value += c;
			}
			type = value.toLowerCase();
			switch (type) {
				case 'break':
				case 'case':
				// case 'catch':
				case 'continue':
				case 'default':
				case 'delete':
				case 'do':
				case 'else':
				// case 'finally':
				case 'for':
				case 'function':
				case 'if':
				// case 'in':
				case 'instanceof':
				case 'new':
				case 'return':
				case 'switch':
				case 'this':
				// case 'throw':
				// case 'try':
				case 'typeof':
				case 'var':
				// case 'void':
				case 'while':
				case 'with':
				//
				// original
				//
				case 'coroutine':
				case 'suspend':
				case 'yield':
				case 'loop':
				{
					return new Token(type, null);
				}
				
				case 'null':	return new Token('null', null);
				case 'undefined':	return new Token('undefined', undefined);
				case 'true':	return new Token('bool', true);
				case 'false':	return new Token('bool', false);
				
				default:
				{
					return new Token('identifier', value);
				}
			}
		}
		
		if (isNumber(c)) {
			value = c;
			if (c == '0') {
				if ((c = nextChar()) && c == 'x' || c == 'X') {
					value += c;
					while ((c = nextChar()) && isHex(c)) {
						value += c;
					}
				}
				else if (isNumber(c)) {
					value += c;
					while ((c = nextChar()) && isNumber(c)) {
						value += c;
					}
				}
			}
			else {
				while ((c = nextChar()) && isNumber(c)) {
					value += c;
				}
			}
			if (c == '.') {
				value += c;
				while ((c = nextChar()) && isNumber(c)) {
					value += c;
				}
				return new Token('number', parseFloat(value));
			}
			else {
				return new Token('number', parseInt(value));
			}
		}
		
		if (c == "'") {
			value = '';
			while ((c = nextChar()) && c != "'") {
				if (c == '\\') {
					c = nextChar();
					if (c == 'n') {
						value += "\n";
						c = nextChar();
						continue;
					}
					if (c == '\\') {
						value += "\\";
						c = nextChar();
						continue;
					}
				}
				value += c;
			}
			if (c != "'") {
				throw new VMSyntaxError('String literal is not closed.');
			}
			nextChar();
			return new Token('string', value);
		}
		if (c == '"') {
			value = "";
			while ((c = nextChar()) && c != '"') {
				if (c == '\\') {
					c = nextChar();
					if (c == 'n') {
						value += "\n";
						c = nextChar();
						continue;
					}
					if (c == '\\') {
						value += "\\";
						c = nextChar();
						continue;
					}
				}
				value += c;
			}
			if (c != '"') {
				throw new VMSyntaxError('String literal is not closed.');
			}
			nextChar();
			return new Token('string', value);
		}
		
		if (c == '/') {
			if ((c = nextChar())) {
				if (c == '=') {
					nextChar();
					return new Token('/=', null);
				}
				else if (c == '/') {
					while ((c = nextChar()) && c != "\n") {
					}
					nextChar();
					return getToken();
				}
				else if(c == '*') {
					for (c=nextChar(); c; ) {
						if (c == '*') {
							if ((c = nextChar()) && c == '/') {
								break;
							}
							continue;
						}
						c = nextChar();
					}
					nextChar();
					return getToken();
				}
			}
			return new Token('/', null);
		}
		
		/*
			*
			*=
			%
			%=
			^
			^=
		*/
		if (c == '*' || c == '%' || c == '^') {
			type = c;
			if ((c = nextChar()) && c == '=') {
				nextChar();
				return new Token(type+'=', null);
			}
			return new Token(type, null);
		}
		
		/*
			+
			++
			+=
			-
			--
			-=
			&
			&&
			&=
			|
			||
			|=
		*/
		if (c == '+' || c == '-' || c == '|' || c == '&') {
			type = c;
			if ((c = nextChar())) {
				if (c == type) {
					nextChar();
					return new Token(type+type, null);
				}
				if (c == '=') {
					nextChar();
					return new Token(type+'=', null);
				}
			}
			return new Token(type, null);
		}
		
		/*
			=
			==
			===
			!
			!=
			!==
		*/
		if (c == '=' || c == '!') {
			type = c;
			if ((c = nextChar()) && c == '=') {
				if ((c = nextChar()) && c == '=') {
					nextChar();
					return new Token(type+'==', null);
				}
				return new Token(type+'=', null);
			}
			return new Token(type, null);
		}
		
		/*
			>
			>=
			>>
			>>=
			>>>
			>>>=
			<
			<=
			<<
			<<=
		*/
		if (c == '>' || c == '<') {
			type = c;
			if ((c = nextChar())) {
				if (c == '=') {
					nextChar();
					return new Token(type+'=', null);
				}
				if (c == type) {
					if ((c = nextChar())) {
						if (type == '>' && c == '>') {
							if ((c = nextChar()) && c == '=') {
								nextChar();
								return new Token('>>>=', null);
							}
							return new Token('>>>', null);
						}
						if (c == '=') {
							nextChar();
							return new Token(type+type+'=', null);
						}
					}
					return new Token(type+type, null);
				}
			}
			return new Token(type, null);
		}
		
		switch (c) {
			case '{':
			case '}':
			case '(':
			case ')':
			case '[':
			case ']':
			case '.':
			case ';':
			case ',':
			case '~':
			case '?':
			case ':':
			{
				nextChar();
				return new Token(c, null);
			}
			default:
			{
				throw new VMSyntaxError('Unknown character : "'+c+'" at index '+index+'.');
			}
		}
		
		return null;
	}
}

}