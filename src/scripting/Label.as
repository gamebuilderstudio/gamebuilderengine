package scripting
{

public class Label
{
	public var address:*;
	public var isExists:Boolean;
	
	public function Label ()
	{
		initialize();
	}
	
	public function initialize () : void
	{
		address = null;
		isExists = false;
	}
	
	public function commitAddress (address:int) : void
	{
		this.address = address;
		isExists = true;
	}
}

}