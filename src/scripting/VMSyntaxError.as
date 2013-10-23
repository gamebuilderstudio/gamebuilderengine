package scripting
{

public class VMSyntaxError extends Error
{
	//public var name:String = 'VMSyntaxError';
	
	public function VMSyntaxError (message:String)
	{
		super(message);
		this.name = 'VMSyntaxError';
	}
}

}