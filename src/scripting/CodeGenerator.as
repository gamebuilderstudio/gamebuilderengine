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

// Dec 11 2008, Sean Givan - Changes to setStackPatch.

public class CodeGenerator
{
	private var code:Array;
	private var stackList:Array;
	private var localVariableList:Array;
	
	public var vmtarget:VirtualMachine;
	
	public function CodeGenerator ()
	{
		initialize();
	}
	
	public function initialize () : void
	{
		code = [];
		stackList = [];
		localVariableList = [];
		
		// reserved
		put(null);
		
		beginNewScope();
	}
	
	private function error (message:String) : void
	{
		throw new Error('CodeGenerator [error] '+message);
	}
	
	public function getCode () : Array
	{
		return code;
	}
	
	public function put (element:*) : Number
	{
		return code.push(element)-1;
	}
	public function putStoreStack () : void
	{
		stackList.push(put(null));
	}
	public function putLoadStack () : void
	{
		var _code:Array = code;
		
		var current:Number = Number(stackList.pop());
		var next:*;
		
		var address:int = put(null);
		
		for (;;) {
			next = _code[current];
			_code[current] = address;
			if (next == null) break;
			current = next;
		}
	}
	public function popStack () : Number
	{
		return Number(stackList.pop());
	}
	public function pushStack (address:int) : void
	{
		stackList.push(address);
	}
	public function setStackPatch (address:int) : void
	{
		// code[stackList[stackList.length-1]] = address;
		
		// Dec 11 2008, Sean Givan - Say, hold it, what if it's not null?
		// In the case of a nested ?: structure, the above code can cause trouble.
		// The outer ?: stack patching can wipe out the inner ?: stack patching.
		// This can also happen with nested || and && structures, too.
		
		if (code[stackList[stackList.length-1]] != null)
		{
			setStackPatchRecursive( code[stackList[stackList.length-1]], address);
		}
		else
			code[stackList[stackList.length-1]] = address;
		
	}
	public function setStackPatchRecursive(cd:*,address:int) : void
	{
		if (code[cd] == null)
			code[cd] = address;
		else
			setStackPatchRecursive(code[cd],address);
	}
	
	
	public function putCrossLoadStack () : void
	{
		swapStack(undefined,undefined)
		putLoadStack();
		putLoadStack();
	}
	public function swapStack (a:*, b:*) : void
	{
		a = stackList.length - (a !== undefined ? a : 0) - 1;
		b = stackList.length - (b !== undefined ? b : 1) - 1;
		
		var n:* = stackList[a];
		stackList[a] = stackList[b];
		stackList[b] = n;
	}
	public function getStackLength () : Number
	{
		return stackList.length;
	}
	public function cleanUpStack (begin:*) : void
	{
		if (begin === undefined ) begin = 0;
		
		var _stackList:Array = stackList;
		
		for (; _stackList.length > begin; ) {
			popAndDestroyStack();
		}
	}
	public function popAndDestroyStack () : void
	{
		var _code:Array = code;
		var current:Number = Number(stackList.pop());
		var next:*;
		for (;;) {
			next = _code[current];
			_code[current] = 0;
			if (next == null) break;
			current = next;
		}
	}
	
	public function putLabel (label:Label) : void
	{
		if (label.isExists) {
			put(label.address);
		}
		else {
			label.address = put(label.address);
		}
	}
	public function setLabel (label:Label) : void
	{
		var address:int = code.length;
		setLabelAddress(label, address);
		label.commitAddress(address);
	}
	public function setLabelAddress (label:Label, address:int) : void
	{
		var _code:Array = code;
		
		var current:* = label.address;
		var next:*;
		
		for (;;) {
			if (current == null) break;
			
			next = _code[current];
			_code[current] = address;
			current = next;
		}
	}
	
	public function beginNewScope () : void
	{
		localVariableList.unshift(new Object());
	}
	public function closeScope () : void
	{
		localVariableList.shift();
	}
	public function isLocalVariable (identifier:*) : Boolean
	{
		return localVariableList[0].hasOwnProperty(String(identifier));
	}
	public function addLocalVariable (identifier:*) : void
	{
		localVariableList[0][identifier] = true;
	}
	
	public function putExpressionResult (expressionResult:ExpressionResult) : void
	{
		switch (expressionResult.type) {
			case 'variable': {
				putGetVariable(String(expressionResult.value));
				expressionResult.setType('stack');
			}
			break;
			
			case 'member': {
				putGetMember(expressionResult.getObjectExpression(), expressionResult.getMemberExpression());
				expressionResult.setType('stack');
			}
			break;
		}
	}
	
	private function putValue (expressionResult:ExpressionResult) : void
	{
		switch (expressionResult.type) {
			case 'literal': {
				put(expressionResult.value);
			}
			break;
			
			case 'stack': {
				putLoadStack();
			}
			break;
			
			default : {
				error('putValueError');
			}
		}
	}
	private function putBinaryValue (left:ExpressionResult, right:ExpressionResult) : void
	{
	    //trace("putBinaryValue: l is " + left.type + " and r is " + right.type);
	
		if (left.isType('literal') && right.isType('literal')) {
			put(left.value);
			put(right.value);
		}
		else if (left.isType('stack') && right.isType('stack')) {
			putCrossLoadStack();
		}
		else if (left.isType('stack')) {
			putLoadStack();
			put(right.value);
		}
		else if (right.isType('stack')) {
			put(left.value);
			putLoadStack();
		}
		else {
			error('putBinaryValueError');
		}
	}
	
	public function putSuspend () : void
	{
		put((vmtarget == null) ? 'SPD' : (vmtarget.SPD));
	}
	
	public function putLiteral (expressionResult:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'LIT' : (vmtarget.LIT));
		put(expressionResult.value);
		putStoreStack();
	}
	
	public function putCall (identifier:ExpressionResult, numOfArguments:int) : void
	{
		if (isLocalVariable(identifier.value)) {
			put((vmtarget == null) ? 'CALLL' : vmtarget.CALLL);
		}
		else {
			put((vmtarget == null) ? 'CALL' : vmtarget.CALL);
		}
		put(identifier.value);
		put(numOfArguments);
		putStoreStack();
	}
	public function putCallMember (objectExpression:ExpressionResult, memberExpression:ExpressionResult, numOfArguments:int) : void
	{
		put((vmtarget == null) ? 'CALLM' : vmtarget.CALLM);
		putBinaryValue(objectExpression, memberExpression);
		/*
		if (ExpressionResult(memberExpression.value).isType('literal')) {
			putLoadStack();
			put(ExpressionResult(memberExpression.value).value);
		}
		else {
			putCrossLoadStack();
		}
		*/
		put(numOfArguments);
		putStoreStack();
	}
	public function putCallFunctor (numOfArguments:int) : void
	{
		put((vmtarget == null) ? 'CALLF' : vmtarget.CALLF);
		putLoadStack();
		put(numOfArguments);
		putStoreStack();
	}
	
	public function putReturnFunction (returnValue:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'RET' : vmtarget.RET);
		putValue(returnValue);
	}
	public function putReturnCoroutine (returnValue:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'CRET' : vmtarget.CRET);
		putValue(returnValue);
	}
	public function putFunction () : Label
	{
		var label:Label = new Label();
		
		put((vmtarget == null) ? 'FUNC' : vmtarget.FUNC);
		putLabel(label);
		putStoreStack();
		
		return label;
	}
	public function putCoroutine () : Label
	{
		var label:Label = new Label();
		
		put((vmtarget == null) ? 'COR' : vmtarget.COR);
		putLabel(label);
		putStoreStack();
		
		return label;
	}
	public function putArgument (argumentIndex:*, identifier:String) : void
	{
		put((vmtarget == null) ? 'ARG' : vmtarget.ARG);
		put(argumentIndex);
		put(identifier);
		addLocalVariable(identifier);
	}
	
	public function putJump (label:Label) : void
	{
		put((vmtarget == null) ? 'JMP' : vmtarget.JMP);
		putLabel(label);
	}
	
	public function putIf (expressionResult:ExpressionResult, label:Label) : void
	{
		put((vmtarget == null) ? 'IF' : vmtarget.IF);
		putValue(expressionResult);
		putLabel(label);
	}
	public function putNif (expressionResult:ExpressionResult, label:Label) : void
	{
		put((vmtarget == null) ? 'NIF' : vmtarget.NIF);
		putValue(expressionResult);
		putLabel(label);
	}
	
	// ñZ
	public function putBinaryOperation (operation:*, left:ExpressionResult, right:ExpressionResult) : void
	{
		put(operation);
		putBinaryValue(left, right);
		putStoreStack();
	}
	
	// PZ
	public function putUnaryOperation (operation:*, expression:ExpressionResult) : void
	{
		put(operation);
		putValue(expression);
		putStoreStack();
	}
	
	public function putIncrement (expressionResult:ExpressionResult) : void
	{
		putIncDec((vmtarget == null) ? 'INC' : vmtarget.INC, false, expressionResult);
	}
	public function putDecrement (expressionResult:ExpressionResult) : void
	{
		putIncDec((vmtarget == null) ? 'DEC' : vmtarget.DEC, false, expressionResult);
	}
	public function putPostfixIncrement (expressionResult:ExpressionResult) : void
	{
		putIncDec((vmtarget == null) ? 'INC' : vmtarget.INC, true, expressionResult);
	}
	public function putPostfixDecrement (expressionResult:ExpressionResult) : void
	{
		putIncDec((vmtarget == null) ? 'DEC' : vmtarget.DEC, true, expressionResult);
	}
	private function putIncDec (operation:*, isPostfix:Boolean, expressionResult:ExpressionResult) : void
	{
		var s:*;
		switch (expressionResult.type) {
			case 'member': {
				var objectExpression:ExpressionResult = expressionResult.getObjectExpression();
				var memberExpression:ExpressionResult = expressionResult.getMemberExpression();
				if (!memberExpression.isLiteral()) {
					putExpressionResult(memberExpression);
					s = popStack();
					putDuplicate(memberExpression);
					pushStack(s);
					putDuplicate(objectExpression);
					swapStack(1, 2);
				}
				else {
					putDuplicate(objectExpression);
				}
				putGetMember(objectExpression, memberExpression);
				expressionResult.setTypeStack();
				if (isPostfix) {
					putDuplicate(expressionResult);
					s = popStack();
					putUnaryOperation(operation, expressionResult);
					putSetMember(objectExpression, memberExpression, expressionResult);
					popAndDestroyStack();
					pushStack(s);
				}
				else {
					putUnaryOperation(operation, expressionResult);
					putSetMember(objectExpression, memberExpression, expressionResult);
				}
			}
			break;
			
			case 'variable': {
				var identifier:String = String(expressionResult.value);
				putGetVariable(identifier);
				expressionResult.setTypeStack();
				if (isPostfix) {
					putDuplicate(expressionResult);
				}
				putUnaryOperation(operation, expressionResult);
				putSetVariable(identifier, expressionResult);
				if (isPostfix) {
					popAndDestroyStack();
				}
			}
			break;
			
			default: {
				error('putIncDecError');
			}
		}
	}
	
	public function putWith (objectExpression:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'WITH' : vmtarget.WITH);
		putValue(objectExpression);
	}
	public function putEndWith () : void
	{
		put((vmtarget == null) ? 'EWITH' : vmtarget.EWITH);
	}
	
	public function putPush (expressionResult:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'PUSH' : vmtarget.PUSH);
		putValue(expressionResult);
	}
	public function putPop () : void
	{
		put((vmtarget == null) ? 'POP' : vmtarget.POP);
		putStoreStack();
	}
	
	public function putDuplicate (expressionResult:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'DUP' : vmtarget.DUP);
		putValue(expressionResult);
		putStoreStack();
		putStoreStack();
	}
	
	public function putThis () : void
	{
		put((vmtarget == null) ? 'THIS' : vmtarget.THIS);
		putStoreStack();
	}
	
	public function putArrayLiteral (numOfElements:int) : void
	{
		put((vmtarget == null) ? 'ARRAY' : vmtarget.ARRAY);
		put(numOfElements);
		putStoreStack();
	}
	public function putObjectLiteral (numOfProperties:int) : void
	{
		put((vmtarget == null) ? 'OBJ' : vmtarget.OBJ);
		put(numOfProperties);
		putStoreStack();
	}
	
	public function putGetVariable (identifier:String) : void
	{
		if (isLocalVariable(identifier)) {
			put((vmtarget == null) ? 'GETL' : vmtarget.GETL);
		}
		else {
			put((vmtarget == null) ? 'GET' : vmtarget.GET);
		}
		put(identifier);
		putStoreStack();
	}
	public function putSetVariable (identifier:String, right:ExpressionResult) : void
	{
		if (isLocalVariable(identifier)) {
			put((vmtarget == null) ? 'SETL' : vmtarget.SETL);
		}
		else {
			put((vmtarget == null) ? 'SET' : vmtarget.SET);
		}
		put(identifier);
		putValue(right);
		putStoreStack();
	}
	public function putSetLocalVariable (identifier:String, right:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'SETL' : vmtarget.SETL);
		put(identifier);
		putValue(right);
		putStoreStack();
		addLocalVariable(identifier);
	}
	// Sean Givan - Jan 4 2008 - Added bugfix to allow
	// member expressions with a variable as the memberExpression
	public function putGetMember (objectExpression:ExpressionResult, memberExpression:ExpressionResult) : void
	{
		if (memberExpression.isType('variable'))
		{
			put((vmtarget == null) ? 'GETMV' : vmtarget.GETMV);
			if (objectExpression.isType('literal'))
			{
				put(objectExpression.value);
			}
			else
			{
				putLoadStack();
			}
			
			if (isLocalVariable(memberExpression.value)) 
			{
				put((vmtarget == null) ? 'GETL' : vmtarget.GETL);
			}
			else 
			{
				put((vmtarget == null) ? 'GET' : vmtarget.GET);
			}
			put(memberExpression.value);
			putStoreStack();
		}
		
		else
		{
			put((vmtarget == null) ? 'GETM' : vmtarget.GETM);
			putBinaryValue(objectExpression, memberExpression);
			putStoreStack();
		}
	}
	public function putSetMember (objectExpression:ExpressionResult, memberExpression:ExpressionResult, right:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'SETM' : vmtarget.SETM);
		if (objectExpression.isLiteral()) {
			if (memberExpression.isLiteral()) {
				if (right.isLiteral()) {
					put(objectExpression.value);
					put(memberExpression.value);
					put(right.value);
				}
				else {
					put(objectExpression.value);
					put(memberExpression.value);
					putLoadStack();
				}
			}
			else {
				if (right.isLiteral()) {
					put(objectExpression.value);
					putLoadStack();
					put(right.value);
				}
				else {
					put(objectExpression.value);
					putCrossLoadStack();
				}
			}
		}
		else {
			if (memberExpression.isLiteral()) {
				if (right.isLiteral()) {
					putLoadStack();
					put(memberExpression.value);
					put(right.value);
				}
				else {
					swapStack(undefined,undefined)
					putLoadStack();
					put(memberExpression.value);
					putLoadStack();
				}
			}
			else {
				if (right.isLiteral()) {
					putCrossLoadStack();
					put(right.value);
				}
				else {
					swapStack(0, 2);
					putLoadStack();
					putLoadStack();
					putLoadStack();
				}
			}
		}
		putStoreStack();
	}
	
	public function putNew (numOfArguments:int) : void
	{
		put((vmtarget == null) ? 'NEW' : vmtarget.NEW);
		putLoadStack();
		put(numOfArguments);
		putStoreStack();
	}
	
	public function putDelete (expressionResult:ExpressionResult) : void
	{
		if (expressionResult.isType('variable') || expressionResult.isType('literal')) {
			if (isLocalVariable(expressionResult.value)) {
				put((vmtarget == null) ? 'DELL' : vmtarget.DELL);
			}
			else {
				put((vmtarget == null) ? 'DEL' : vmtarget.DEL);
			}
			put(expressionResult.value);
			putStoreStack();
		}
		else {
			put((vmtarget == null) ? 'DEL' : vmtarget.DEL);
			putLoadStack();
			putStoreStack();
		}
	}
	public function putDeleteMember (objectExpression:ExpressionResult, expressionResult:ExpressionResult) : void
	{
		put((vmtarget == null) ? 'DELM' : vmtarget.DELM);
		putBinaryValue(objectExpression, expressionResult);
		/*
		if (ExpressionResult(expressionResult.value).isType('literal')) {
			putLoadStack();
			put(ExpressionResult(expressionResult.value).value);
		}
		else {
			putCrossLoadStack();
		}
		*/
		putStoreStack();
	}
}

}