package scripting
{

public class Token
{
	public var type:String;
	public var value:*;
	
	public function Token (type:String, value:*)
	{
		this.type = type;
		this.value = value;
	}
}

}