package scripting
{

public interface IScanner
{
	function rewind (): void ;
	function getToken () : Token;
	
	function getLineNumber() : Number;
	function getLine () : String;
}

}