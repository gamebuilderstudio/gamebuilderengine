/*******************************************************************************
 * BISE is licensed under the MIT license.
 * 
 * Copyright (c) 2008 Yoshihiro Shindo and Sean Givan
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the “Software”), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *******************************************************************************/
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