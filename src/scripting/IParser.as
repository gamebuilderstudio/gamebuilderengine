package scripting
{

public interface IParser
{
	function parse (vm:VirtualMachine = null) : Array;
}

}