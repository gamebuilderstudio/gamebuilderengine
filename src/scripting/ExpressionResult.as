package scripting
{

public class ExpressionResult
{
	public var type:String;
	public var value:*;
	
	public var isLeftHandSide:Boolean = false;
	
	public function ExpressionResult ()
	{
		initialize();
	}
	
	public static function createLiteral (value:*) : ExpressionResult
	{
		var instance:ExpressionResult = new ExpressionResult();
		instance.setTypeLiteral(value);
		return instance;
	}
	public static function createStack () : ExpressionResult
	{
		var instance:ExpressionResult = new ExpressionResult();
		instance.setTypeStack();
		return instance;
	}
	
	public function clone () : ExpressionResult
	{
		var instance:ExpressionResult = new ExpressionResult();
		instance.setTypeAndValue(type, value);
		return instance;
	}
	
	public function initialize () : void
	{
		type = 'empty';
		value = null;
	}
	public function setType (type:String) : void
	{
		this.type = type;
	}
	public function isType (type:String) : Boolean
	{
		return (this.type == type);
	}
	public function setValue (value:*) : void
	{
		this.value = value;
	}
	public function setTypeAndValue (type:String, value:*) : void 
	{
		this.type = type;
		this.value = value;
	}
	public function isLiteral () : Boolean
	{
		return isType('literal');
	}
	public function isVariableOrMember () : Boolean
	{
		return isVariable() || isMember();
	}
	public function isVariable () : Boolean
	{
		return isType('variable');
	}
	public function isMember () : Boolean
	{
		return isType('member');
	}
	public function setTypeStack () : void
	{
		setType('stack');
	}
	public function setTypeLiteral (value:*) : void
	{
		setTypeAndValue('literal', value);
	}
	public function setTypeMember (objectExpression:ExpressionResult, memberExpression:ExpressionResult) : void
	{
		setTypeAndValue('member', {object: objectExpression, member: memberExpression});
	}
	public function getObjectExpression () : ExpressionResult
	{
		if (!isMember()) return null;
		
		return value.object;
	}
	public function getMemberExpression () : ExpressionResult
	{
		if (!isMember()) return null;
		
		return value.member;
	}
}

}