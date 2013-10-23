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

// Nov 20 2008 Sean Givan
// Fixed a bug where, if the last 'return' of a function was found inside an if/while/do/for statement, and this was the last
// statement of a function other than } tokens, then the parser would not throw in the last 'safety' return of a function.
// This would cause bugs, if the condition holding that last return turned out to be false.

// Dec 13 2008 Sean Givan
// added 'parseForceCoroutine' property to Parser, which is used in changing function definitions to coroutine definitions when parsing.

public class Parser implements IParser
{
	public var scanner:IScanner;
	private var generator:CodeGenerator;
	
	private var token:Token;
	
	private var parseForceCoroutine:Boolean = false;
	
	private var vmtarget:VirtualMachine = null;
	
	public function Parser (scanner:IScanner = null)
	{
		this.scanner = scanner;
	}
	
	private function getToken () : Token
	{
		return token;
	}
	private function nextToken () : Token
	{
		return (token = scanner.getToken());
	}
	private function isToken (type:String) : Boolean
	{
		if (token == null)
			return false;
		else
			return (token.type == type);
	}
	private function isNextToken (type:String) : Boolean
	{
		return (nextToken().type == type);
	}
	
	private function initialize () :void
	{
		scanner.rewind();
		generator = new CodeGenerator();
		breakLabelList = new Array();
		continueLabelList = new Array();
		functionStack = new Array();
		nextToken();
	}
	
	public function setForceCoroutine(fc:Boolean) :void
	{
		parseForceCoroutine = fc;
	}
	
	public function parse (ovm: VirtualMachine = null) : Array
	{
		initialize();
		
		if (ovm != null)
		{
			generator.vmtarget = ovm;
			generator.vmtarget.optimized = true;
			vmtarget = ovm;
		}
		
		parse_program();
		
		return generator.getCode();
	}
	
	private function causeSyntaxError (message:String) :void
	{
		throw new VMSyntaxError('Parser [causeSyntaxError] on line '+scanner.getLineNumber()+' '+message+' ('+getToken().type+')'+ ' ' +scanner.getLine());
	}
	
	private var breakLabelList:Array;
	private function pushBreakLabel (label:Label) :void
	{
		breakLabelList.unshift(label);
	}
	private function popBreakLabel () : Label
	{
		return Label(breakLabelList.shift());
	}
	private function getBreakLabel () : Label
	{
		if (breakLabelList.length < 1) {
			causeSyntaxError('break cannot be used here');
		}
		return breakLabelList[0];
	}
	private var continueLabelList:Array;
	private function pushContinueLabel (label:Label) :void
	{
		continueLabelList.unshift(label);
	}
	private function popContinueLabel () : Label
	{
		return Label(continueLabelList.shift());
	}
	private function getContinueLabel () : Label
	{
		if (continueLabelList.length < 1) {
			causeSyntaxError('continue cannot be used here');
		}
		return continueLabelList[0];
	}
	
	private var functionStack:Array;
	private function beginFunction () :void
	{
		functionStack.unshift(true);
	}
	private function endFunction () :void
	{
		functionStack.shift();
	}
	private function beginCoroutine () :void
	{
		functionStack.unshift(false);
	}
	private function endCoroutine () :void
	{
		functionStack.shift();
	}
	private function isAllowReturn () : Boolean
	{
		return functionStack.length > 0;
	}
	private function isInFunction () : Boolean
	{
		return (functionStack.length > 0 && functionStack[0]);
	}
	
	// ContinueStatementから
	
	// Program ::= SourceElements
	//
	// First(Program) ::= First(SourceElements)
	// Follow(Program) ::= EOF
	private function parse_program () :void
	{
		parse_sourceElements();
	}
	
	// SourceElements ::= SourceElement
	//	::= SourceElements SourceElement
	//
	// First(SourceElements) ::= First(SourceElement)
	private function parse_sourceElements () :void
	{
		parse_sourceElement();
		
		// ここを常に回すようにしておかないと、コード中に予期しないトークンが
		// 出現したときにエラーを出せない
		// while (isStatementFirst(getToken().type) || isToken('function')) {
		while (getToken() != null) {
			// Follow from FunctionBody
			if (isToken('}')) {
				return;
			}
			
			parse_sourceElement();
		}
	}
	
	// SourceElement ::= Statement
	//	::= FunctionDeclaration
	//	::= CorutineDeclaration (original)
	//
	// First(SourceElement) ::= First(Statement) First(FunctionDeclaration) First(CorutineDeclaration)
	private function parse_sourceElement () :void
	{
		if (isToken('function')) {
		
			if (parseForceCoroutine == true)
			{
				token.type = 'coroutine';
				parse_coroutineDeclaration();
			}
			else
				parse_functionDeclaration();
				
		}
		else if (isToken('coroutine')) {
			parse_coroutineDeclaration();
		}
		else if (isStatementFirst( getToken() == null ? null : getToken().type)) {
			parse_statement();
		}
		else {
			causeSyntaxError('SourceElement found an unexpected token');
		}
	}
	
	// FunctionDeclaration ::= 'function' Identifier '(' FormalParameterList? ')' '{' FunctionBody '}'
	//
	// First(FunctionDeclaration) ::= 'function'
	private function parse_functionDeclaration () :void
	{
		if (!isToken('function')) {
			causeSyntaxError("'function' not found in function declaration");
		}
		
		if (!isNextToken('identifier')) {
			causeSyntaxError('function name not found in function declaration');
		}
		
		var funcName:String = String(getToken().value);
		
		var label:Label = generator.putFunction();
		
		beginFunction();
		
		generator.beginNewScope();
		
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in function declaration");
		}
		
		if (isNextToken('identifier')) {
			parse_formalParameterList();
		}
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in function declaration");
		}
		
		if (!isNextToken('{')) {
			causeSyntaxError("'{' not found in function declaration");
		}
		
		if (!isNextToken('}')) {
			parse_functionBody();
		}
		
		if (!hasLastReturn) {
			generator.putReturnFunction(ExpressionResult.createLiteral(undefined));
		}
		
		if (!isToken('}')) {
			causeSyntaxError("'}' not found in function declaration");
		}
		
		endFunction();
		
		generator.closeScope();
		
		generator.setLabel(label);
		
		generator.putSetLocalVariable(funcName, ExpressionResult.createStack());
		generator.popAndDestroyStack();
		
		nextToken();
	}
	
	// FunctionExpression ::= 'function' Identifier? '(' FormalParamaterList? ')' '{' FunctionBody '}'
	//
	// First(FunctionExpression) ::= 'function'
	private function parse_functionExpression (expressionResult:ExpressionResult) : void
	{
		if (!isToken('function')) {
			causeSyntaxError("'function' not found in function expression");
		}
		
		var funcName:String = null;
		
		if (isNextToken('identifier')) {
			funcName = String(getToken().value);
			nextToken();
		}
		
		var label:Label = generator.putFunction();
		
		beginFunction();
		
		generator.beginNewScope();
		
		if (!isToken('(')) {
			causeSyntaxError("'(' not found in function expression");
		}
		
		if (isNextToken('identifier')) {
			parse_formalParameterList();
		}
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in function expression");
		}
		
		if (!isNextToken('{')) {
			causeSyntaxError("'{' not found in function expression");
		}
		
		if (!isNextToken('}')) {
			parse_functionBody();
		}
		
		if (!hasLastReturn) {
			generator.putReturnFunction(ExpressionResult.createLiteral(undefined));
		}
		
		if (!isToken('}')) {
			causeSyntaxError("'}' not found in function expression");
		}
		
		generator.closeScope();
		
		endFunction();
		
		generator.setLabel(label);
		
		if (funcName != null) {
			generator.putSetLocalVariable(funcName, ExpressionResult.createStack());
		}
		
		expressionResult.setTypeStack();
		
		nextToken();
	}
	
	// CoroutineDeclaration ::= 'coroutine' Identifier? '(' FormalParamaterList? ')' '{' FunctionBody '}'
	//
	// First(CoroutineDeclaration) ::= 'coroutine'
	private function parse_coroutineDeclaration (/*expressionResult:ExpressionResult*/) : void
	{
		if (!isToken('coroutine')) {
			causeSyntaxError("'coroutine' not found in coroutine declaration");
		}
		
		if (!isNextToken('identifier')) {
			causeSyntaxError("coroutine name not found in coroutine declaration");
		}
		
		var funcName:String = String(getToken().value);
		
		var label:Label = generator.putCoroutine();
		
		beginCoroutine();
		
		generator.beginNewScope();
		
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in coroutine declaration");
		}
		
		if (isNextToken('identifier')) {
			parse_formalParameterList();
		}
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in coroutine declaration");
		}
		
		if (!isNextToken('{')) {
			causeSyntaxError("'{' not found in coroutine declaration");
		}
		
		if (!isNextToken('}')) {
			parse_functionBody();
		}
		
		if (!hasLastReturn) {
			generator.putReturnCoroutine(ExpressionResult.createLiteral(undefined));
		}
		
		if (!isToken('}')) {
			causeSyntaxError("'}' not found in coroutine declaration");
		}
		
		generator.closeScope();
		
		endCoroutine();
		
		generator.setLabel(label);
		
		generator.putSetLocalVariable(funcName, ExpressionResult.createStack());
		generator.popAndDestroyStack();
		
		//expressionResult.setTypeStack();
		
		nextToken();
	}
	
	// CoroutineExpression ::= 'coroutine' Identifier? '(' FormalParamaterList? ')' '{' FunctionBody '}'
	//
	// First(CoroutineExpression) ::= 'coroutine'
	private function parse_coroutineExpression (expressionResult:ExpressionResult) : void
	{
		if (!isToken('coroutine')) {
			causeSyntaxError("'coroutine' not found in coroutine expression");
		}
		
		var funcName:String = null;
		
		if (isNextToken('identifier')) {
			funcName = String(getToken().value);
			nextToken();
		}
		
		var label:Label = generator.putCoroutine();
		
		beginCoroutine();
		
		generator.beginNewScope();
		
		if (!isToken('(')) {
			causeSyntaxError("'(' not found in coroutine expression");
		}
		
		if (isNextToken('identifier')) {
			parse_formalParameterList();
		}
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in coroutine expression");
		}
		
		if (!isNextToken('{')) {
			causeSyntaxError("'{' not found in coroutine expression");
		}
		
		if (!isNextToken('}')) {
			parse_functionBody();
		}
		
		if (!hasLastReturn) {
			generator.putReturnCoroutine(ExpressionResult.createLiteral(undefined));
		}
		
		if (!isToken('}')) {
			causeSyntaxError("'}' not found in coroutine expression");
		}
		
		generator.closeScope();
		
		endCoroutine();
		
		generator.setLabel(label);
		
		if (funcName != null) {
			generator.putSetLocalVariable(funcName, ExpressionResult.createStack());
		}
		
		expressionResult.setTypeStack();
		
		nextToken();
	}
	
	// FormalParameterList ::= Identifier
	//	::= FormalParameterList ',' Identifier
	//
	// First(FormalParameterList) ::= identifier
	private function parse_formalParameterList () :void
	{
		var argumentIndex:int = 0;
		
		for (;;) {
			if (!isToken('identifier')) {
				causeSyntaxError('Parameter name is required');
			}
			
			generator.putArgument(argumentIndex, String(getToken().value));
			
			argumentIndex++;
			
			if (isNextToken(',')) {
				nextToken();
				continue;
			}
			break;
		}
	}
	
	// FunctionBody ::= SourceElements
	//
	// First(FunctionBody) ::= First(SourceElements)
	private function parse_functionBody () :void
	{
		parse_sourceElements();
	}
	
	private var hasLastReturn:Boolean;
	private var lastReturnCaution:int = 0;
	
	// Statement ::= Block
	//	::= VariableStatement
	//	::= EmptyStatement
	//	::= ExpressionStatement
	//	::= IfStatement
	//	::= IterationStatement
	//	::= ContinueStatement
	//	::= BreakStatement
	//	::= ReturnStatement
	//	::= WithStatement
	//	::= LabelledStatement (not support)
	//	::= SwitchStatement
	//	::= SuspendStatement (original)
	//	::= LoopStatement (original)
	//	::= ThrowStatement (not support)
	//	::= TryStatement (not support)
	//
	// First(Statement) ::= ...
	private function parse_statement () :void
	{
		hasLastReturn = false;	// for FunctionExpression, FunctionDeclaration
		
		var stackBegin:int = generator.getStackLength();
		
		switch (getToken().type) {
			case '{':		parse_block(); break;
			case 'var':	parse_variableStatement(); break;
			case ';':		parse_emptyStatement(); break;
			case 'if':		parse_ifStatement(); break;
			case 'do':
			case 'while':
			case 'for':	parse_iterationStatement(); break;
			case 'continue':	parse_continueStatement(); break;
			case 'break':	parse_breakStatement(); break;
			case 'return':	parse_returnStatement(); break;
			case 'with':	parse_withStatement(); break;
			case 'switch':	parse_switchStatement(); break;
			
			case 'yield':	parse_yieldStatement(); break;
			case 'suspend':	parse_suspendStatement(); break;
			
			case 'loop':	parse_loopStatement(); break;
			
			default:
			{
				if (isExpressionFirst(getToken().type)) {
					parse_expressionStatement();
					break;
				}
				
				causeSyntaxError('Unexpected statement token');
			}
			case 'function':
			{
				causeSyntaxError('Functions are not defined in statements');
				break;
			}
		}
		
		generator.cleanUpStack(stackBegin);
	}
	private function isStatementFirst (type:String) : Boolean
	{
		return (type == '{' || type == 'var' || type == ';' || type == 'if' || type == 'do' ||
			type == 'while' || type == 'for' || type == 'for' || type == 'continue' ||
			type == 'break' || type == 'return' || type == 'with' || type == 'switch' ||
			type == 'yield' || type == 'suspend' || type == 'loop' || 
			(type != 'function' && type != 'coroutine' && /*type != '{' &&*/ isExpressionFirst(type))
			);
	}
	
	// Block ::= '{' StatementList? '}'
	//
	// First(Block) ::= '{'
	private function parse_block () : void
	{
		if (!isToken('{')) {
			causeSyntaxError("'{' not found in block");
		}
		
		if (!isNextToken('}')) {
			parse_statementList();
		}
		
		if (!isToken('}')) {
			causeSyntaxError("'}' not found in block");
		}
		
		nextToken();
	}
	
	// StatementList ::= Statement
	//	::= StatementList Statement
	//
	// First(StatementList) ::= First(Statement)
	private function parse_statementList () : void
	{
		parse_statement();
		
		for (;;) {
			// Follow from Block, CaseClause, DefaultClause
			if (isToken('}')) {
				return;
			}
			
			if (isStatementFirst(getToken().type)) {
				parse_statement();
				continue;
			}
			break;
		}
	}
	
	// VariableStatement ::= 'var' VariableDeclarationList ';'
	//
	// First(VariableStatement) ::= 'var'
	private function parse_variableStatement () : void
	{
		if (!isToken('var')) {
			causeSyntaxError("'var' not found in variable declaration");
		}
		
		nextToken();
		
		parse_variableDeclarationList();
		
		if (!isToken(';')) {
			causeSyntaxError('Variable declaration must end with ;');
		}
		
		nextToken();
	}
	
	// VariableDeclarationList ::= VariableDeclaration
	//	::= VariableDeclarationList ',' VariableDeclaration
	//
	// First(VariableDeclarationList) ::= First(VariableDeclaration)
	private function parse_variableDeclarationList () : void
	{
		parse_variableDeclaration();
		
		for (;;) {
			if (isToken(',')) {
				nextToken();
				parse_variableDeclaration();
				continue;
			}
			break;
		}
	}
	
	// VariableDeclaration ::= Identifier Initialiser?
	//
	// First(VariableDeclaration) ::= identifier
	private function parse_variableDeclaration () : void
	{
		if (!isToken('identifier')) {
			causeSyntaxError('Variable name not found in variable declaration');
		}
		
		var identifier:String = String(getToken().value);
		
		if (isNextToken('=')) {
			var rightExpression:ExpressionResult  = new ExpressionResult();
			parse_initialiser(rightExpression);
			generator.putExpressionResult(rightExpression);
			generator.putSetLocalVariable(identifier, rightExpression);
			generator.popAndDestroyStack();
		}
		else {
			generator.putSetLocalVariable(identifier, ExpressionResult.createLiteral(undefined));
			generator.popAndDestroyStack();
		}
	}
	
	// initialiser ::= '=' AssignmentExpression
	//
	// First(Initialiser) ::= '='
	private function parse_initialiser (expressionResult:ExpressionResult) : void
	{
		if (!isToken('=')) {
			causeSyntaxError("'=' not found in variable initialization");
		}
		
		nextToken();
		
		parse_assignmentExpression(expressionResult);
	}
	
	// EmptyStatement ::= ';'
	//
	// First(EmptyStatement) ::= ';'
	private function parse_emptyStatement () : void
	{
		if (!isToken(';')) {
			causeSyntaxError("';' not found in empty statement");
		}
		
		nextToken();
	}
	
	// ExpressionStatement ::= [lookahead { '{' , 'function' } ] Expression ';'
	//
	// First(ExpressionStatement) ::= First(Expression)
	private function parse_expressionStatement () : void
	{
		if (isToken('{') || isToken('function')) {
			causeSyntaxError('Ambiguity found in ExpressionStatement');
		}
		
		var expressionResult:ExpressionResult = new ExpressionResult();
		parse_expression(expressionResult);
		generator.putExpressionResult(expressionResult);
		
		if (!isToken(';')) {
			causeSyntaxError("';' not found in expression statement");
		}
		
		nextToken();
	}
	
	// IfStatement ::= 'if' '(' Expression ')' Statement 'else' Statement
	//	::= 'if' '(' Expression ')' Statement
	//
	// First(IfStatement) ::= 'if'
	private function parse_ifStatement () : void
	{
	
		lastReturnCaution++;  // For function declarations
	
		if (!isToken('if')) {
			causeSyntaxError("'if' not found in if statement");
		}
		
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in if statement");
		}
		
		nextToken();
		
		var condition:ExpressionResult  = new ExpressionResult();
		parse_expression(condition);
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in if statement");
		}
		
		generator.putExpressionResult(condition);
		
		var endIfLabel:Label  = new Label();
		
		generator.putIf(condition, endIfLabel);
		
		nextToken();
		
		parse_statement();
		
		if (isToken('else')) {
			var endElseLabel:Label = new Label();
			 generator.putJump(endElseLabel);
			
			generator.setLabel(endIfLabel);
			
			nextToken();
			parse_statement();
			
			generator.setLabel(endElseLabel);
		}
		else {
			generator.setLabel(endIfLabel);
		}
		
		lastReturnCaution--;
	}
	
	// IterationiStatement ::= 'do' Statement 'while' '(' Expression ')'
	//	::= 'while' '(' Expression ')' Statement
	//	::= 'for' '(' Expression? ';' Expression? ':' Expression? ')' Statement
	//	::= 'for' '(' 'var' VariableDeclaration ';' Expression? ';' Expression? ')' Statement
	//
	// First(IterationStatement) ::= 'do' 'while' 'for'
	private function parse_iterationStatement () : void
	{
		lastReturnCaution++;
	
		if (isToken('for')) {
			parse_forStatement();
		}
		else if (isToken('while')) {
			parse_whileStatement();
		}
		else if (isToken('do')) {
			parse_doStatement();
		}
		else {
			causeSyntaxError('unexpected token found in loop statement');
		}
		
		lastReturnCaution--;
		
	}
	private function parse_forStatement () : void
	{
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in for statement");
		}
		
		var conditionLabel:Label = new Label();
		var continueLabel:Label = new Label();
		var startLabel:Label = new Label();
		var endLabel:Label = new Label();
		
		pushBreakLabel(endLabel);
		pushContinueLabel(continueLabel);
		
		var stackBegin:int;
		
		// initialize expression, or variable declaration
		if (isNextToken('var')) {
			nextToken();
			parse_variableDeclaration();
		}
		else {
			if (!isToken(';')) {
				stackBegin = generator.getStackLength();
				var initializeExpression:ExpressionResult = new ExpressionResult();
				parse_expression(initializeExpression);
				generator.putExpressionResult(initializeExpression);
				generator.cleanUpStack(stackBegin);
			}
		}
		if (!isToken(';')) {
			causeSyntaxError("';' not found in for statement");
		}
		
		generator.setLabel(conditionLabel);
		
		// condition expression
		if (!isNextToken(';')) {
			stackBegin = generator.getStackLength();
			var conditionExpression:ExpressionResult = new ExpressionResult();
			parse_expression(conditionExpression);
			generator.putExpressionResult(conditionExpression);
			generator.putIf(conditionExpression, endLabel);
			generator.cleanUpStack(stackBegin);
		}
		if (!isToken(';')) {
			causeSyntaxError("';' not found in for statement");
		}
		
		generator.putJump(startLabel);
		
		generator.setLabel(continueLabel);
		
		// continue expression
		if (!isNextToken(')')) {
			stackBegin = generator.getStackLength();
			var continueExpression:ExpressionResult = new ExpressionResult();
			parse_expression(continueExpression);
			generator.putExpressionResult(continueExpression);
			generator.cleanUpStack(stackBegin);
		}
		
		generator.putJump(conditionLabel);
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in for statement");
		}
		
		nextToken();
		
		generator.setLabel(startLabel);
		
		parse_statement();
		generator.putJump(continueLabel);
		
		generator.setLabel(endLabel);
		
		popContinueLabel();
		popBreakLabel();
	}
	private function parse_whileStatement () : void
	{
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in while statement");
		}
		
		nextToken();
		
		var startLabel:Label = new Label();
		var endLabel:Label = new Label();
		
		pushBreakLabel(endLabel);
		pushContinueLabel(startLabel);
		
		generator.setLabel(startLabel);
		
		var condition:ExpressionResult = new ExpressionResult();
		parse_expression(condition);
		generator.putExpressionResult(condition);
		generator.putIf(condition, endLabel);
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in while statement");
		}
		nextToken();
		
		parse_statement();
		
		generator.putJump(startLabel);
		
		generator.setLabel(endLabel);
		
		popContinueLabel();
		popBreakLabel();
	}
	private function parse_doStatement () : void
	{
		nextToken();
		
		var startLabel:Label = new Label();
		var continueLabel:Label = new Label();
		var endLabel:Label = new Label();
		
		pushBreakLabel(endLabel);
		pushContinueLabel(continueLabel);
		
		generator.setLabel(startLabel);
		
		parse_statement();
		
		if (!isToken('while')) {
			causeSyntaxError("'while' not found in do statement");
		}
		
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in do-while statement");
		}
		
		nextToken();
		
		generator.setLabel(continueLabel);
		
		var condition:ExpressionResult = new ExpressionResult();
		parse_expression(condition);
		generator.putExpressionResult(condition);
		generator.putIf(condition, endLabel);
		generator.putJump(startLabel);
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in do-while statement");
		}
		
		generator.setLabel(endLabel);
		
		popContinueLabel();
		popBreakLabel();
		
		nextToken();
	}
	
	// ContinueStatement ::= 'continue' Identifier? ';'
	// *not support Identifier
	//
	// First(ContinueStatement) ::= 'continue'
	private function parse_continueStatement () : void
	{
		if (!isToken('continue')) {
			causeSyntaxError("'continue' not found in continue statement");
		}
		if (!isNextToken(';')) {
			causeSyntaxError("';' not found in continue statement");
		}
		
		generator.putJump(getContinueLabel());
		
		nextToken();
	}
	
	// BreakStatement ::= 'break' Identifier? ';'
	// *not support Identifier
	//
	// First(BreakStatement) ::= 'break'
	private function parse_breakStatement () : void
	{
		if (!isToken('break')) {
			causeSyntaxError("'break' not found in break statement");
		}
		if (!isNextToken(';')) {
			causeSyntaxError("';' not found in break statement");
		}
		
		generator.putJump(getBreakLabel());
		
		nextToken();
	}
	
	// ReturnStatement ::= 'return' Expression? ';'
	//
	// FIrst(ReturnStatement) ::= 'return'
	private function parse_returnStatement () : void
	{
		if (!isToken('return')) {
			causeSyntaxError("'return' not found in return statement");
		}
		
		if (!isAllowReturn()) {
			causeSyntaxError('return is only used in functions or coroutines');
		}
		
		if (lastReturnCaution == false)
			hasLastReturn = true;	// for FunctionExpression, FunctionDeclaration
		
		var returnValue:ExpressionResult;
		
		if (isExpressionFirst(nextToken().type)) {
			returnValue = new ExpressionResult();
			parse_expression(returnValue);
			generator.putExpressionResult(returnValue);
		}
		else {
			returnValue = ExpressionResult.createLiteral(undefined);
		}
		
		if (isInFunction()) {
			generator.putReturnFunction(returnValue);
		}
		else {
			generator.putReturnCoroutine(returnValue);
		}
		
		if (!isToken(';')) {
			causeSyntaxError("';' not found in return statement");
		}
		
		nextToken();
	}
	
	// WithStatement ::= 'with' '(' Expression ')' Statement
	//
	// First(WithStatement) ::= 'with'
	private function parse_withStatement () : void
	{
		if (!isToken('with')) {
			causeSyntaxError("'with' not found in with statement");
		}
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in with statement");
		}
		
		nextToken();
		var objectExpression:ExpressionResult = new ExpressionResult();
		parse_expression(objectExpression);
		generator.putExpressionResult(objectExpression);
		generator.putWith(objectExpression);
		
		generator.beginNewScope();
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in with statement");
		}
		
		nextToken();
		parse_statement();
		
		generator.closeScope();
		
		generator.putEndWith();
	}
	
	// SwitchStatement ::= 'switch' '(' Expression ')' CaseBlock
	//
	// First(SwitchStatement) ::= 'switch'
	private function parse_switchStatement () : void
	{
		if (!isToken('switch')) {
			causeSyntaxError("'switch' not found in switch statement");
		}
		if (!isNextToken('(')) {
			causeSyntaxError("'(' not found in switch statement");
		}
		
		nextToken();
		var condition:ExpressionResult = new ExpressionResult();
		parse_expression(condition);
		generator.putExpressionResult(condition);
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in switch statement");
		}
		
		var endLabel:Label = new Label();
		
		pushBreakLabel(endLabel);
		
		nextToken();
		parse_caseBlock(condition);
		
		generator.setLabel(endLabel);
		
		popBreakLabel();
	}
	
	// CaseBlcok ::= '{' CaseClauses? '}'
	//	::= '{' CaseClauses? DefaultClause CaseClauses? '}'
	//
	// First(CaseBlock) ::= '{'
	private function parse_caseBlock (condition:ExpressionResult) : void
	{
		if (!isToken('{')) {
			causeSyntaxError("'{' not found in switch-case statement");
		}
		
		var caseLabel:Label = new Label();
		var bodyLabel:Label = new Label();
		
		if (isNextToken('case')) {
			parse_caseClauses(condition, caseLabel, bodyLabel);
		}
		if (isToken('default')) {
			var defaultLabel:Label = new Label();
			
			generator.setLabel(defaultLabel);
			
			parse_defaultClause(bodyLabel);
			
			if (isToken('case')) {
				parse_caseClauses(condition, caseLabel, bodyLabel);
			}
			
			generator.setLabelAddress(caseLabel, defaultLabel.address);
			
			generator.setLabel(bodyLabel);
		}
		else {
			generator.setLabel(caseLabel);
			generator.setLabel(bodyLabel);
		}
		
		if (!isToken('}')) {
			causeSyntaxError("'}' not found in switch-case statement");
		}
		nextToken();
	}
	
	// CaseClauses ::= CaseClause
	//	::= CaseClauses CaseClause
	//
	// First(CaseClauses) ::= First(CaseClause)
	private function parse_caseClauses (condition:ExpressionResult, caseLabel:Label, bodyLabel:Label) : void
	{
		while (isToken('case')) {
			parse_caseClause(condition, caseLabel, bodyLabel);
		}
	}
	
	// CaseClause ::= 'case' Expression ':' StatementList?
	//
	// First(CaseClause) ::= 'case'
	private function parse_caseClause (condition:ExpressionResult, caseLabel:Label, bodyLabel:Label) : void
	{
		if (!isToken('case')) {
			causeSyntaxError("'case' not found in case statement");
		}
		
		generator.setLabel(caseLabel);
		caseLabel.initialize();
		
		if (!condition.isLiteral()) {
			generator.putDuplicate(condition);
		}
		
		nextToken();
		var caseCondition:ExpressionResult = new ExpressionResult();
		parse_expression(caseCondition);
		generator.putExpressionResult(caseCondition);
		generator.putBinaryOperation((vmtarget == null) ? 'CSEQ' : vmtarget.CSEQ, condition, caseCondition);
		generator.putIf(ExpressionResult.createStack(), caseLabel);
		
		if (!isToken(':')) {
			causeSyntaxError("':' not found in case statement");
		}
		
		generator.setLabel(bodyLabel);
		bodyLabel.initialize();
		
		if (isStatementFirst(nextToken().type)) {
			parse_statementList();
		}
		
		generator.putJump(bodyLabel);
	}
	
	// DefaultClause ::= 'default' ':' StatementList?
	//
	// First(DefaultClause) ::= 'default'
	private function parse_defaultClause (bodyLabel:Label) : void
	{
		if (!isToken('default')) {
			causeSyntaxError("'default' not found in default statement");
		}
		
		if (!isNextToken(':')) {
			causeSyntaxError("':' not found in default statement");
		}
		
		generator.setLabel(bodyLabel);
		bodyLabel.initialize();
		
		if (isStatementFirst(nextToken().type)) {
			parse_statementList();
		}
		
		generator.putJump(bodyLabel);
	}
	
	// YieldStatement ::= 'yield' ';'
	// *original
	//
	// First(YieldStatement) ::= 'yield'
	private function parse_yieldStatement () : void
	{
		if (!isToken('yield')) {
			causeSyntaxError("'yield' not found in yield statement");
		}
		if (!isNextToken(';')) {
			causeSyntaxError("';' not found in yield statement");
		}
		
		if (isInFunction()) {
			causeSyntaxError('yield statement can only be used in a coroutine');
		}
		
		generator.putSuspend();
		
		nextToken();
	}
	
	// SuspendStatement ::= 'suspend' ';'
	// *original
	//
	// First(SuspendStatement) ::= 'suspend'
	private function parse_suspendStatement () : void
	{
		if (!isToken('suspend')) {
			causeSyntaxError("'suspend' not found in suspend statement");
		}
		if (!isNextToken(';')) {
			causeSyntaxError("';' not found in suspend statement");
		}
		
		if (isInFunction()) {
			causeSyntaxError('suspend statement can only be used in a coroutine');
		}
		
		generator.putSuspend();
		
		nextToken();
	}
	
	// LoopStatement ::= 'loop' 'Statement
	// *original
	//
	// First(LoopStatement) ::= 'loop'
	private function parse_loopStatement () : void
	{
		if (!isToken('loop')) {
			causeSyntaxError("'loop' not found in loop statement");
		}
		
		nextToken();
		
		var startLabel:Label = new Label();
		var endLabel:Label = new Label();
		
		pushBreakLabel(endLabel);
		pushContinueLabel(startLabel);
		
		generator.setLabel(startLabel);
		
		parse_statement();
		
		generator.putJump(startLabel);
		
		generator.setLabel(endLabel);
		
		popContinueLabel();
		popBreakLabel();
	}
	
	// Expression ::= AssignmentExpression
	//	::= Expression ',' AssignmentExpression
	//
	// First(Expression) ::= First(AssignmentExpression)
	private function parse_expression (expressionResult:ExpressionResult) : void
	{
		parse_assignmentExpression(expressionResult);
		
		while (isToken(',')) {
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			generator.popAndDestroyStack();
			
			expressionResult.initialize();
			parse_assignmentExpression(expressionResult);
		}
	}
	private function isExpressionFirst (type:String) : Boolean
	{
		return isUnaryExpressionFirst(type);
	}
	
	private function areBothLiteral (a:ExpressionResult, b:ExpressionResult) : Boolean
	{
		return (a.isType('literal') && b.isType('literal'));
	}
	
	// AssignmentExpression ::= ConditionalExpression
	//	::= LeftHandSideExpression AssignmentOperator AssignmentExpression
	// AssignmentOperator ::= '=' '*=' '/=' '%=' '+=' '-=' '<<=' '>>=' '>>>=' '&=' '^=' '|='
	//
	// First(AssignmentExpression) ::= First(ConditionalExpression) First(LeftHandSideExpression)
	private function parse_assignmentExpression (expressionResult:ExpressionResult) : void
	{
		parse_conditionalExpression(expressionResult);
		
		var rightExpression:ExpressionResult;
		var objectExpression:ExpressionResult;
		var memberExpression:ExpressionResult;
		
		switch (getToken().type) {
			case '=': {
				nextToken();
				
				switch (expressionResult.type) {
					case 'member': {
						objectExpression = expressionResult.getObjectExpression();
						memberExpression = expressionResult.getMemberExpression();
						generator.putExpressionResult(memberExpression);
						rightExpression = new ExpressionResult();
						parse_assignmentExpression(rightExpression);
						generator.putExpressionResult(rightExpression);
						generator.putSetMember(objectExpression, memberExpression, rightExpression);
					}
					break;
					
					case 'variable': {
						rightExpression = new ExpressionResult();
						parse_assignmentExpression(rightExpression);
						generator.putExpressionResult(rightExpression);
						generator.putSetVariable(String(expressionResult.value), rightExpression);
					}
					break;
					
					default: {
						causeSyntaxError('L-value must be a variable or property');
					}
				}
				expressionResult.setTypeStack();
			}
			break;
			
			case '*=': case '/=': case '%=': case '+=': case '-=':
			case '<<=': case '>>=': case '>>>=': case '&=': case '^=':
			case '|=': {
				var operation:*;
				
				switch (getToken().type) {
					case '*=': operation = (vmtarget == null) ? 'MUL' : vmtarget.MUL; break;
					case '/=': operation = (vmtarget == null) ? 'DIV' : vmtarget.DIV; break;
					case '%=': operation = (vmtarget == null) ? 'MOD' : vmtarget.MOD; break;
					case '+=': operation = (vmtarget == null) ? 'ADD' : vmtarget.ADD; break;
					case '-=': operation = (vmtarget == null) ? 'SUB' : vmtarget.SUB; break;
					case '<<=': operation = (vmtarget == null) ? 'LSH' : vmtarget.LSH; break;
					case '>>=': operation = (vmtarget == null) ? 'RSH' : vmtarget.RSH; break;
					case '>>>=': operation = (vmtarget == null) ? 'URSH' : vmtarget.URSH; break;
					case '&=': operation = (vmtarget == null) ? 'AND' : vmtarget.AND; break;
					case '^=': operation = (vmtarget == null) ? 'XOR' : vmtarget.XOR; break;
					case '|=': operation = (vmtarget == null) ? 'OR' : vmtarget.OR; break;
				}
				
				nextToken();
				
				switch (expressionResult.type) {
					case 'member': {
						objectExpression = expressionResult.getObjectExpression();
						memberExpression = expressionResult.getMemberExpression();
						if (!memberExpression.isLiteral()) {
							generator.putExpressionResult(memberExpression);
							var s:* = generator.popStack();
							generator.putDuplicate(memberExpression);
							generator.pushStack(s);
							generator.putDuplicate(objectExpression);
							generator.swapStack(1, 2);
						}
						else {
							generator.putDuplicate(objectExpression);
						}
						generator.putGetMember(objectExpression, memberExpression);
						expressionResult.setTypeStack();
						rightExpression = new ExpressionResult();
						parse_assignmentExpression(rightExpression);
						generator.putExpressionResult(rightExpression);
						generator.putBinaryOperation(operation, expressionResult, rightExpression);
						generator.putSetMember(objectExpression, memberExpression, expressionResult);
					}
					break;
					
					case 'variable': {
						var identifier:String = String(expressionResult.value);
						generator.putGetVariable(identifier);
						expressionResult.setTypeStack();
						rightExpression = new ExpressionResult();
						parse_assignmentExpression(rightExpression);
						generator.putExpressionResult(rightExpression);
						generator.putBinaryOperation(operation, expressionResult, rightExpression);
						generator.putSetVariable(identifier, expressionResult);
					}
					break;
					
					default: {
						causeSyntaxError('L-value must be a variable or property');
					}
				}
				expressionResult.setTypeStack();
			}
			break;
			
			default:
			break;
		}
	}
	
	// ConditionalExpression ::= LogicalORExpression
	//	::= LogicalORExpression '?' AssignmentExpression ':' AssignmentExpression
	//
	// First(ConditionalExpression) ::= First(LogicalORExpression)
	private function parse_conditionalExpression (expressionResult:ExpressionResult) : void
	{
		parse_logicalORExpression(expressionResult);
		
		if (isToken('?')) {
			
			generator.putExpressionResult(expressionResult);
			var label:Label = new Label();
			generator.putIf(expressionResult, label);
			
			nextToken();
			expressionResult.initialize();
			parse_assignmentExpression(expressionResult);
			if (expressionResult.isType('literal')) {
				generator.putLiteral(expressionResult);
			}
			else {
				generator.putExpressionResult(expressionResult);
			}
			var patch:* = generator.popStack();
			
			var label2:Label = new Label();
			generator.putJump(label2);
			
			generator.setLabel(label);
			
			if (!isToken(':')) {
				causeSyntaxError("':' not found in ?: statement");
			}
			
			nextToken();
			expressionResult.initialize();
			parse_assignmentExpression(expressionResult);
			if (expressionResult.isType('literal')) {
				generator.putLiteral(expressionResult);
			}
			else {
				generator.putExpressionResult(expressionResult);
			}
			expressionResult.setType('stack');
			generator.setStackPatch(patch);
			
			generator.setLabel(label2);
		}
	}
	
	// LogicalORExpression ::= LogicalANDExpression
	//	::= LogicalORExpression '||' LogicalANDExpression
	//
	// First(LogicalORExpression) ::= First(LogicalANDExpression)
	private function parse_logicalORExpression (expressionResult:ExpressionResult) : void
	{
		parse_logicalANDExpression(expressionResult);
		
		while (isToken('||')) {
			nextToken();
			
			// ここどうにかならんかなぁ・・・
			
			generator.putExpressionResult(expressionResult);
			generator.putDuplicate(expressionResult);
			var patch:* = generator.popStack();
			expressionResult.setType('stack');
			var label:Label = new Label();
			generator.putNif(expressionResult, label);
			
			expressionResult.initialize();
			parse_logicalANDExpression(expressionResult);
			
			if (expressionResult.isType('literal')) {
				generator.putLiteral(expressionResult);
			}
			else {
				generator.putExpressionResult(expressionResult);
			}
			generator.setStackPatch(patch);
			expressionResult.setType('stack');
			
			generator.setLabel(label);
		}
	}
	
	// LogicalANDExpression ::= BitwiseORExpression
	//	::= LogicalANDExpression '&&' BitwiseORExpression
	//
	// First(LogicalANDExpression) ::= First(BitwiseORExpression)
	private function parse_logicalANDExpression (expressionResult:ExpressionResult) : void
	{
		parse_bitwiseORExpression(expressionResult);
		
		while (isToken('&&')) {
			nextToken();
			
			// ここどうにかならんかなぁ・・・
			
			generator.putExpressionResult(expressionResult);
			generator.putDuplicate(expressionResult);
			var patch:* = generator.popStack();
			expressionResult.setType('stack');
			var label:Label = new Label();
			generator.putIf(expressionResult, label);
			
			expressionResult.initialize();
			parse_bitwiseORExpression(expressionResult);
			
			if (expressionResult.isType('literal')) {
				generator.putLiteral(expressionResult);
			}
			else {
				generator.putExpressionResult(expressionResult);
			}
			generator.setStackPatch(patch);
			expressionResult.setType('stack');
			
			generator.setLabel(label);
		}
	}
	
	// BitwiseORExpression ::= BitwiseXORExpression
	//	::= BitwiseORExpression '|' BitwiseXORExpression
	//
	// First(BitwiseORExpression) ::= First(BitwiseXORExpression)
	private function parse_bitwiseORExpression (expressionResult:ExpressionResult) : void
	{
		parse_bitwiseXORExpression(expressionResult);
		
		while (isToken('|')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult = new ExpressionResult();
			
			parse_bitwiseXORExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			// 定数畳み込み
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				expressionResult.setValue(expressionResult.value | rightExpressionResult.value);
			}
			// 通常コード
			else {
				generator.putBinaryOperation((vmtarget == null) ? 'OR' : vmtarget.OR, expressionResult, rightExpressionResult);
				expressionResult.setType('stack');
			}
		}
	}
	
	// BitwiseXORExpression ::= BitwiseANDExpression
	//	::= BitiwseXORExpression '^' BitwiseANDExpression
	//
	// First(BitwiseXORExpression) ::= First(BitwiseANDExpression)
	private function parse_bitwiseXORExpression (expressionResult:ExpressionResult) : void
	{
		parse_bitwiseANDExpression(expressionResult);
		
		while (isToken('^')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult = new ExpressionResult();
			
			parse_bitwiseANDExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			// 定数畳み込み
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				expressionResult.setValue(expressionResult.value ^ rightExpressionResult.value);
			}
			else {
				generator.putBinaryOperation((vmtarget == null) ? 'XOR' : vmtarget.XOR, expressionResult, rightExpressionResult);
				expressionResult.setType('stack');
			}
		}
	}
	
	// BitwiseANDExpression ::= EqualityExpression
	//	::= BitwiseANDExpression '&' EqualityExpression
	//
	// First(BitwiseANDExpression) ::= First(EqualityEpxression)
	private function parse_bitwiseANDExpression (expressionResult:ExpressionResult) : void
	{
		parse_equalityExpression(expressionResult);
		
		while (isToken('&')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult  = new ExpressionResult();
			parse_equalityExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			// 定数畳み込み
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				expressionResult.setValue(expressionResult.value & rightExpressionResult.value);
			}
			else {
				generator.putBinaryOperation((vmtarget == null) ? 'AND' : vmtarget.AND, expressionResult, rightExpressionResult);
				expressionResult.setType('stack');
			}
		}
	}
	
	// EqualityExpression ::= RelationalExpression
	//	::= EqualityExpression '==' RelationalExpression
	//	::= EqualityExpression '!=' RelationalExpression
	//	::= EqualityExpression '===' RelationalExpression
	//	::= EqualityExpression '!==' RelationalExpression
	//
	// FIrst(EqualityEpxression) ::= First(RelationalExpression)
	private function parse_equalityExpression (expressionResult:ExpressionResult) : void
	{
		parse_relationalExpression(expressionResult);
		
		while (isToken('==') || isToken('!=') || isToken('===') || isToken('!==')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult = new ExpressionResult();
			parse_relationalExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				switch (operation) {
					case '==': expressionResult.setValue(expressionResult.value == rightExpressionResult.value); break;
					case '!=': expressionResult.setValue(expressionResult.value != rightExpressionResult.value); break;
					case '===': expressionResult.setValue(expressionResult.value === rightExpressionResult.value); break;
					case '!==': expressionResult.setValue(expressionResult.value !== rightExpressionResult.value); break;
				}
			}
			else {
				switch (operation) {
					case '==': generator.putBinaryOperation((vmtarget == null) ? 'CEQ' : vmtarget.CEQ, expressionResult, rightExpressionResult); break;
					case '!=': generator.putBinaryOperation((vmtarget == null) ? 'CNE' : vmtarget.CNE, expressionResult, rightExpressionResult); break;
					case '===': generator.putBinaryOperation((vmtarget == null) ? 'CSEQ' : vmtarget.CSEQ, expressionResult, rightExpressionResult); break;
					case '!==': generator.putBinaryOperation((vmtarget == null) ? 'CSNE' : vmtarget.CSNE, expressionResult, rightExpressionResult); break;
				}
				expressionResult.setType('stack');
			}
		}
	}
	
	// RelationalExpression ::= ShiftExpression
	//	::= RelationalExpression '<' ShiftExpression
	//	::= RelationalExpressioin '>' ShiftExpression
	//	::= RelationalExpression '<=' ShiftExpression
	//	::= RelationalExpression '>=' ShiftExpression
	//	::= RelationalExpression 'instanceof' ShiftExpression
	//	::= RelationalExpression 'in' ShiftExpression (not support)
	//
	// First(RelationalExpression) ::= First(ShiftExpression)
	private function parse_relationalExpression (expressionResult:ExpressionResult) : void
	{
		parse_shiftExpression(expressionResult);
		
		while (isToken('<') || isToken('>') || isToken('<=') || isToken('>=') || isToken('instanceof')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult = new ExpressionResult();
			parse_shiftExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				switch (operation) {
					case '<': expressionResult.setValue(expressionResult.value < rightExpressionResult.value); break;
					case '>': expressionResult.setValue(expressionResult.value > rightExpressionResult.value); break;
					case '<=': expressionResult.setValue(expressionResult.value <= rightExpressionResult.value); break;
					case '>=': expressionResult.setValue(expressionResult.value >= rightExpressionResult.value); break;
					case 'instanceof': expressionResult.setValue(expressionResult.value is rightExpressionResult.value); break;
				}
			}
			else {
				switch (operation) {
					case '<': generator.putBinaryOperation((vmtarget == null) ? 'CLT' : vmtarget.CLT, expressionResult, rightExpressionResult); break;
					case '>': generator.putBinaryOperation((vmtarget == null) ? 'CGT' : vmtarget.CGT, expressionResult, rightExpressionResult); break;
					case '<=': generator.putBinaryOperation((vmtarget == null) ? 'CLE' : vmtarget.CLE, expressionResult, rightExpressionResult); break;
					case '>=': generator.putBinaryOperation((vmtarget == null) ? 'CGE' : vmtarget.CGE, expressionResult, rightExpressionResult); break;
					case 'instanceof': generator.putBinaryOperation((vmtarget == null) ? 'INSOF' : vmtarget.INSOF, expressionResult, rightExpressionResult); break;
				}
				expressionResult.setType('stack');
			}
		}
	}
	
	// ShiftExpression ::= AdditiveExpression
	//	::= ShiftExpression '<<' AdditiveExpression
	//	::= ShiftExpression '>>' AdditiveExpression
	//	::= ShiftExpression '>>>' AdditiveExpression
	//
	// First(ShiftExpression) ::= First(AdditiveExpression)
	private function parse_shiftExpression (expressionResult:ExpressionResult) : void
	{
		parse_additiveExpression(expressionResult);
		
		while (isToken('<<') || isToken('>>') || isToken('>>>')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult = new ExpressionResult();
			parse_additiveExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				switch (operation) {
					case '<<': expressionResult.setValue(expressionResult.value << rightExpressionResult.value); break;
					case '>>': expressionResult.setValue(expressionResult.value >> rightExpressionResult.value); break;
					case '>>>': expressionResult.setValue(expressionResult.value >>> rightExpressionResult.value); break;
				}
			}
			else {
				switch (operation) {
					case '<<': generator.putBinaryOperation((vmtarget == null) ? 'LSH' : vmtarget.LSH, expressionResult, rightExpressionResult); break;
					case '>>': generator.putBinaryOperation((vmtarget == null) ? 'RSH' : vmtarget.RSH, expressionResult, rightExpressionResult); break;
					case '>>>': generator.putBinaryOperation((vmtarget == null) ? 'URSH' : vmtarget.URSH, expressionResult, rightExpressionResult); break;
				}
				expressionResult.setType('stack');
			}
		}
	}
	
	// AdditiveExpression ::= MultiplicativeExpression
	//	::= AdditiveExpression '+' MultiplicativeExpression
	//	::= AddtivieExpression '-' MultiplicativeExpression
	//
	// First(AdditiveExpression) ::= First(MultiplicativeExpression)
	private function parse_additiveExpression (expressionResult:ExpressionResult) : void
	{
		parse_multiplicativeExpression(expressionResult);
		
		while (isToken('+') || isToken('-')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult = new ExpressionResult();
			parse_multiplicativeExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				switch (operation) {
					case '+': expressionResult.setValue(expressionResult.value + rightExpressionResult.value); break;
					case '-': expressionResult.setValue(expressionResult.value - rightExpressionResult.value); break;
				}
			}
			else {
				switch (operation) {
					case '+': generator.putBinaryOperation((vmtarget == null) ? 'ADD' : vmtarget.ADD, expressionResult, rightExpressionResult); break;
					case '-': generator.putBinaryOperation((vmtarget == null) ? 'SUB' : vmtarget.SUB, expressionResult, rightExpressionResult); break;
				}
				expressionResult.setType('stack');
			}
		}
	}
	
	// MultiplicativeExpression ::= UnaryExpression
	//	::= MultiplicativeExpression '*' UnaryExpression
	//	::= MultiplicativeExpression '/' UnaryExpression
	//	::= MultiplicativeExpression '%' UnaryExpression
	//
	// First(MultiplicativeExpression) ::= First(UnaryEpxression)
	private function parse_multiplicativeExpression (expressionResult:ExpressionResult) : void
	{
		parse_unaryExpression(expressionResult);
		
		while (isToken('*') || isToken('/') || isToken('%')) {
			var operation:String = getToken().type;
			
			nextToken();
			
			generator.putExpressionResult(expressionResult);
			
			var rightExpressionResult:ExpressionResult = new ExpressionResult();
			parse_unaryExpression(rightExpressionResult);
			
			generator.putExpressionResult(rightExpressionResult);
			
			if (areBothLiteral(expressionResult, rightExpressionResult)) {
				switch (operation) {
					case '*': expressionResult.setValue(expressionResult.value * rightExpressionResult.value); break;
					case '/': expressionResult.setValue(expressionResult.value / rightExpressionResult.value); break;
					case '%': expressionResult.setValue(expressionResult.value % rightExpressionResult.value); break;
				}
			}
			else {
				switch (operation) {
					case '*': generator.putBinaryOperation((vmtarget == null) ? 'MUL' : vmtarget.MUL, expressionResult, rightExpressionResult); break;
					case '/': generator.putBinaryOperation((vmtarget == null) ? 'DIV' : vmtarget.DIV, expressionResult, rightExpressionResult); break;
					case '%': generator.putBinaryOperation((vmtarget == null) ? 'MOD' : vmtarget.MOD, expressionResult, rightExpressionResult); break;
				}
				expressionResult.setType('stack');
			}
		}
	}
	
	// UnaryExpression ::= PostfixExpression
	//	::= 'delete' UnaryExpression
	//	::= 'void' UnaryExpression
	//	::= 'typeof' UnaryExpression
	//	::= '++' UnaryExpression
	//	::= '--' UnaryExpression
	//	::= '+' UnaryExpression
	//	::= '-' UnaryExpression
	//	::= '~' UnaryExpression
	//	::= '!' UnaryExpression
	//
	// First(UnaryExpression) ::= First(PostfixExpression) 'delete' 'void' 'typeof' '++' '--' '-+' '-' '~' '!'
	private function parse_unaryExpression (expressionResult:ExpressionResult) : void
	{
		switch (getToken().type) {
			case 'delete': {
				nextToken();
				parse_unaryExpression(expressionResult);
				
				switch (expressionResult.type) {
					case 'member': {
						var objectExpression:ExpressionResult = expressionResult.getObjectExpression();
						var memberExpression:ExpressionResult = expressionResult.getMemberExpression();
						generator.putExpressionResult(memberExpression);
						generator.putDeleteMember(objectExpression, memberExpression);
					}
					break;
					
					case 'variable': {
						generator.putDelete(expressionResult);
					}
					break;
					
					default: {
						generator.putExpressionResult(expressionResult);
						generator.putDelete(expressionResult);
					}
					break;
				}
				expressionResult.setTypeStack();
			}
			break;
			
			case 'void': {
				// 今の所無視
				nextToken();
				parse_unaryExpression(expressionResult);
			}
			break;
			
			case 'typeof': {
				nextToken();
				parse_unaryExpression(expressionResult);
				
				generator.putExpressionResult(expressionResult);
				
				if (expressionResult.isType('literal')) {
					expressionResult.setValue(typeof expressionResult.value);
				}
				else {
					generator.putUnaryOperation((vmtarget == null) ? 'TYPEOF' : vmtarget.TYPEOF, expressionResult);
					expressionResult.setTypeStack();
				}
			}
			break;
			
			case '++': {
				nextToken();
				parse_unaryExpression(expressionResult);
				
				generator.putIncrement(expressionResult);
				
				expressionResult.setTypeStack();
			}
			break;
			
			case '--': {
				nextToken();
				parse_unaryExpression(expressionResult);
				
				generator.putDecrement(expressionResult);
				
				expressionResult.setTypeStack();
			}
			break;
			
			case '+': {
				nextToken();
				parse_unaryExpression(expressionResult);
			}
			break;
			
			case '-': {
				nextToken();
				parse_unaryExpression(expressionResult);
				
				generator.putExpressionResult(expressionResult);
				
				if (expressionResult.isType('literal')) {
					expressionResult.setValue(-expressionResult.value);
				}
				else {
					var zeroLiteral:ExpressionResult = new ExpressionResult();
					zeroLiteral.setTypeAndValue('literal', 0);
					
					generator.putBinaryOperation((vmtarget == null) ? 'SUB' : vmtarget.SUB, zeroLiteral, expressionResult);
					expressionResult.setType('stack');
				}
			}
			break;
			
			case '~': {
				nextToken();
				parse_unaryExpression(expressionResult);
				
				generator.putExpressionResult(expressionResult);
				
				if (expressionResult.isType('literal')) {
					expressionResult.setValue(~expressionResult.value);
				}
				else {
					generator.putUnaryOperation((vmtarget == null) ? 'NOT' : vmtarget.NOT, expressionResult);
					expressionResult.setType('stack');
				}
			}
			break;
			
			case '!':
			{
				nextToken();
				parse_unaryExpression(expressionResult);
				
				generator.putExpressionResult(expressionResult);
				
				if (expressionResult.isType('literal')) {
					expressionResult.setValue(!expressionResult.value);
				}
				else {
					generator.putUnaryOperation((vmtarget == null) ? 'LNOT' : vmtarget.LNOT, expressionResult);
					expressionResult.setType('stack');
				}
			}
			break;
			
			default: {
				parse_postfixExpression(expressionResult);
			}
			break;
		}
	}
	private function isUnaryExpressionFirst (type:String) : Boolean
	{
		return (type == 'delete' || type == 'void' || type == 'typeof' ||
			type == '++' || type == '--' || type == '+' || type == '-' ||
			type == '~' || type == '!' ||
			isMemberExpressionFirst(type)
			);
	}
	
	// PostfixExpression ::= LeftHandSideExpression
	//	::= LeftHandSideExpression '++'
	//	::= LeftHandSideExpression '--'
	//
	// First(PostfixExpression) ::= First(LeftHandSideExpression)
	private function parse_postfixExpression (expressionResult:ExpressionResult) : void
	{
		parse_leftHandSideExpression(expressionResult);
		
		if (isToken('++') || isToken('--')) {
			switch (getToken().type) {
				case '++': generator.putPostfixIncrement(expressionResult); break;
				case '--': generator.putPostfixDecrement(expressionResult); break;
			}
			expressionResult.setTypeStack();
			nextToken();
		}
	}
	
	// LeftHandSideExpression ::= NewExpression
	//	::= CallExpression
	// NewExpression ::= MemberExpression
	//	::= 'new' NewExpression (not support)
	// CallExpression ::= MemberExpression Arguments
	//	::= CallExpression Arguments
	//	::= CallExpression '[' Expression ']'
	//	::= CallExpression '.' Identifier
	//
	// ↑じゃ解析できないので
	//
	// LeftHandSideExpression ::= CallExpression
	// CallExpression ::= MemberExpression
	//	::= CallExpression Arguments
	// MemberExpression ::= PrimaryExpression
	//	::= FunctionExpression
	//	::= CoroutineExpression
	//	::= 'new' MemberExpression Arguments?
	//	::= MemberExpression '[' Expression ']'
	//	::= MemberExpression '.' Identifier
	//
	// First(LeftHandSideExpression) ::= First(CallExpression)
	// First(CallExpression) ::= First(MemberExpression)
	// First(MemberExpression) ::= First(PrimaryExpression) First(FunctionExpression) First(CoroutineExpression) 'new'
	private function parse_leftHandSideExpression (expressionResult:ExpressionResult) : void
	{
		parse_callExpression(expressionResult);
	}
	private function parse_callExpression (expressionResult:ExpressionResult) : void
	{
		parse_memberExpression(expressionResult);
		
		for (;;) {
			if (isToken('(')) {
				var numOfArguments:int = parse_arguments();
				
				switch (expressionResult.type) {
					case 'member': {
						var objectExpression:ExpressionResult = expressionResult.getObjectExpression();
						var memberExpression:ExpressionResult = expressionResult.getMemberExpression();
						generator.putExpressionResult(memberExpression);
						generator.putCallMember(objectExpression, memberExpression, numOfArguments);
					}
					break;
					
					case 'stack': {
						generator.putCallFunctor(numOfArguments);
					}
					break;
					
					default: {
						generator.putCall(expressionResult, numOfArguments);
					}
				}
				
				expressionResult.setType('stack');
				
				continue;
			}
			break;
		}
	}
	private function parse_memberExpression (expressionResult:ExpressionResult) : void
	{
		switch (getToken().type) {
			case 'function': {
				if (parseForceCoroutine == false)
					parse_functionExpression(expressionResult);
				else
				{
					token.type = 'coroutine';
					parse_coroutineExpression(expressionResult);
				}
			}
			break;
			
			case 'coroutine': {
				parse_coroutineExpression(expressionResult);
			}
			break;
			
			case 'new': {
				nextToken();
				
				parse_memberExpression(expressionResult);
				generator.putExpressionResult(expressionResult);
				
				var numOfArguments:int = 0;
				
				if (isToken('(')) {
					numOfArguments += parse_arguments();
				}
				
				generator.putNew(numOfArguments);
				
				expressionResult.setType('stack');
			}
			break;
			
			default: {
				parse_primaryExpression(expressionResult);
			}
		}
		
		for (;;) {
			if (isToken('[')) {
				nextToken();
				
				generator.putExpressionResult(expressionResult);
				
				var memberExpression:ExpressionResult = new ExpressionResult();
				parse_expression(memberExpression);
				expressionResult.setTypeMember(expressionResult.clone(), memberExpression);
				// expressionResult.setTypeAndValue('member', memberExpression);
				
				if (!isToken(']')) {
					causeSyntaxError("']' not found in array access");
				}
				
				nextToken();
				continue;
			}
			if (isToken('.')) {
				
				generator.putExpressionResult(expressionResult);
				
				if (!isNextToken('identifier')) {
					causeSyntaxError("'.' not found in property access");
				}
				
				expressionResult.setTypeMember(expressionResult.clone(), ExpressionResult.createLiteral(getToken().value));
				// expressionResult.setTypeAndValue('member', ExpressionResult.createLiteral(getToken().value));
				
				nextToken();
				continue;
			}
			break;
		}
	}
	private function isMemberExpressionFirst (type:String) : Boolean
	{
		return (type == 'new' || type == 'function' || isPrimaryExpressionFirst(type));
	}
	
	// Arguments ::= '(' ')'
	//	::= '(' ArgumentList ')'
	//
	// First(Arguments) ::= '('
	private function parse_arguments () : Number
	{
		if (!isToken('(')) {
			causeSyntaxError("'(' not found in argument list");
		}
		
		var numOfArguments:int = 0;
		
		if (!isNextToken(')')) {
			numOfArguments += parse_argumentList();
		}
		
		if (!isToken(')')) {
			causeSyntaxError("')' not found in argument list");
		}
		nextToken();
		
		return numOfArguments;
	}
	
	// ArgumentList ::= AssignmentExpression
	//	::= ArgumentList ',' AssignmentExpression
	//
	// First(ArgumentList) ::= First(AssignmentExpression)
	private function parse_argumentList () : Number
	{
		var numOfArguments:int = 0;
		
		for (;;) {
			var expressionResult:ExpressionResult = new ExpressionResult();
			parse_assignmentExpression(expressionResult);
			generator.putExpressionResult(expressionResult);
			generator.putPush(expressionResult);
			
			numOfArguments++;
			
			if (isToken(',')) {
				nextToken();
				continue;
			}
			break;
		}
		
		return numOfArguments;
	}
	
	
	// PrimaryExpression ::= 'this'
	//	::= Identifier
	//	::= Literal
	//	::= ArrayLiteral
	//	::= ObjectLiteral
	//	::= '(' Expression ')'
	//
	// First(PrimaryExpression) ::= 'this' Identifier Literal First(ArrayLiteral) First(ObjectLiteral) '('
	private function parse_primaryExpression (expressionResult:ExpressionResult) : void 
	{
		switch (getToken().type) {
			case 'this': {
				generator.putThis();
				expressionResult.setType('stack');
				nextToken();
			}
			break;
			
			case 'identifier': {
				expressionResult.setTypeAndValue('variable', getToken().value);
				nextToken();
			}
			break;
			
			case 'string':
			case 'number':
			case 'bool':
			case 'null':
			case 'undefined': {
				expressionResult.setTypeAndValue('literal', getToken().value);
				nextToken();
			}
			break;
			
			case '[': {
				var numOfElements:int = parse_arrayLiteral();
				generator.putArrayLiteral(numOfElements);
				expressionResult.setType('stack');
			}
			break;
			
			case '{': {
				var numOfProperties:int = parse_objectLiteral();
				generator.putObjectLiteral(numOfProperties);
				expressionResult.setType('stack');
			}
			break;
			
			case '(': {
				nextToken();
				parse_expression(expressionResult);
				if (!isToken(')')) {
					causeSyntaxError("matching ')' not found in expression");
				}
				nextToken();
			}
			break;
			
			default: {
				causeSyntaxError('unexpected token');
			}
			break;
		}
	}
	private function isPrimaryExpressionFirst (type:String) : Boolean
	{
		return (type == 'this' || type == 'identifier' || 
			type == 'string' || type == 'number' || type == 'bool' || type == 'undefined' ||
			type == 'null' || type == '{' || type == '[' || type == '('
			);
	}
	
	// ArrayLiteral ::= '[' Elision? ']'
	//	::= '[' ElementList ']'
	//	::= '[' ElementList ',' Elision? ']'
	//
	// First(ArrayLiteral) ::= '['
	private function parse_arrayLiteral () : Number
	{
		if (!isToken('[')) {
			causeSyntaxError("'[' not found in array initializer");
		}
		
		var numOfElements:int = 0;
		
		if (!isNextToken(']')) {
			if (isToken(',')) {
				numOfElements += parse_elision();
			}
			
			if (!isToken(']')) {
				numOfElements += parse_elementList();
			}
			
			if (isToken(',')) {
				numOfElements += parse_elision();
			}
		}
		if (!isToken(']')) {
			causeSyntaxError("']' not found in array initializer");
		}
		nextToken();
		
		return numOfElements;
	}
	
	// Elision ::= ','
	//	::= Elision ','
	//
	// First(Elision) ::= ','
	private function parse_elision () : Number
	{
		if (!isToken(',')) {
			causeSyntaxError("',' not found in elision");
		}
		
		var numOfElements:int = 1;
		
		var undefinedLiteral:ExpressionResult = ExpressionResult.createLiteral(undefined);
		
		for (;;) {
			generator.putPush(undefinedLiteral);
			numOfElements++;
			
			if (isNextToken(',')) {
				continue;
			}
			break;
		}
		
		if (isToken(']')) {
			generator.putPush(undefinedLiteral);
			numOfElements++;
		}
		
		return numOfElements;
	}
	
	// ElementList ::= Elision? AssignmentExpression
	//	::= ElementList ',' Elision? AssignmentExpression
	//
	// First(ElementList) ::= First(Elision) First(AssignmentExpression)
	private function parse_elementList () : Number
	{
		var numOfElements:int = 0;
		
		for (;;) {
			if (isToken(',')) {
				numOfElements += parse_elision();
				continue;
			}
			if (isToken(']')) {
				break;
			}
			
			var expressionResult:ExpressionResult = new ExpressionResult();
			parse_assignmentExpression(expressionResult);
			generator.putExpressionResult(expressionResult);
			generator.putPush(expressionResult);
			
			numOfElements++;
			
			if (isToken(',')) {
				nextToken();
				continue;
			}
			break;
		}
		
		return numOfElements;
	}
	
	// ObjectLiteral ::= '{' '}'
	//	::= '{' PropertyNameAndValueList '}'
	//
	// First(ObjectLiteral) ::= '{'
	private function parse_objectLiteral () : Number
	{
		if (!isToken('{')) {
			causeSyntaxError("'{' not found in object initializer");
		}
		
		var numOfProperties:int = 0;
		
		if (!isNextToken('}')) {
			numOfProperties += parse_propertyNameAndValueList();
		}
		
		if (!isToken('}')) {
			causeSyntaxError("'}' not found in object initializer");
		}
		nextToken();
		
		return numOfProperties;
	}
	
	// PropertyNameAndValueList ::= PropertyName ':' AssignmentExpression
	//	::= PropertyNameAndValueList ',' PropertyName ':' AssignmentExpression
	//
	// First(PropertyNameAndValueList) ::= First(PropertyName)
	private function parse_propertyNameAndValueList () : Number
	{
		var numOfProperties:int = 0;
		
		for (;;) {
			parse_propertyName();
			
			if (!isToken(':')) {
				causeSyntaxError("':' not found in object name-value initializer");
			}
			nextToken();
			
			var expressionResult:ExpressionResult = new ExpressionResult();
			parse_assignmentExpression(expressionResult);
			generator.putExpressionResult(expressionResult);
			generator.putPush(expressionResult);
			
			numOfProperties++;
			
			if (isToken(',')) {
				nextToken();
				continue;
			}
			break;
		}
		
		return numOfProperties;
	}
	
	// PropertyName ::= Identifier
	//	::= StringLiteral
	//	::= NumericLiteral
	//
	// First(PropertyName) ::= Identifier StringLiteral NumericLiteral
	private function parse_propertyName () : void
	{
		switch (getToken().type) {
			case 'identifier':
			case 'string':
			case 'number': {
				var propertyName:ExpressionResult = ExpressionResult.createLiteral(getToken().value);
				
				generator.putPush(propertyName);
				
				nextToken();
			}
			break;
			
			default: {
				causeSyntaxError('unexpected token in property name');
			}
			break;
		}
	}
}

}