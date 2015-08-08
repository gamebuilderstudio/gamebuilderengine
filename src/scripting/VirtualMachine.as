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

	
public class VirtualMachine
{
	private var byteCode:Array;
	private var byteCodeLength:int;
	
	private var programCounter:int;
	
	private var global:Object;
	private var localObject:Object;
	private var thisObject:Object;
	
	private var returnValue:*;
	
	private var stack:Array;
	
	public var optimized: Boolean = false;
	public var runCoroutineMode:Boolean = false;
	
	public var registeredDynamicScopeVars:Array = [];
	
	public var externalSuspend:Boolean = false;
	public var returnSuspendTarget:int = -1;
	
	
	public function VirtualMachine ()
	{
		initialize();
	}
	
	public function initialize () :void
	{
		programCounter = 1;
		byteCode = [];
		
		stack = [];
		
		global = {};
		global.__scope = null;
		localObject = global;
		thisObject = global;
	}
	
	
	public function rewind():void
	{
		programCounter = 1;
	}
	
	public function setProgramCounter(p:int):void
	{
		programCounter = p;
	}
	
	public function runCoroutine(cname:String,parms:Array = null):Boolean
	{
		/*
		if (global[cname] == undefined)
		{
			// prepatory run
			while (execute()) {};
		}
		*/
		
		runCoroutineMode = true;
		
		var passedparms:Array;
		if (parms == null)
			passedparms = [];
		else	
			passedparms = parms;
		
		//return executeFunction({},passedparms,global[cname].__entryPoint,global[cname].__scope);
	
		this.thisObject = {};
		localObject = {arguments: passedparms, __scope:global[cname].__scope, __parentenvironment:localObject};
		
		manageDynamicScopeVars(localObject);
		
		programCounter = global[cname].__entryPoint;
		
		return execute();
		
	}
	
	public function manageDynamicScopeVars(lo:Object):void
	{
		// go through the list of stackal variables and set them
		for (var i:int = 0; i < registeredDynamicScopeVars.length; i++)
		{
			if (lo.__parentenvironment[registeredDynamicScopeVars[i]] != undefined)
			{
				var parentvalue:* = lo.__parentenvironment[registeredDynamicScopeVars[i]];
				if (parentvalue is Array)
				{
					var newarray:Array = [];
					for (var a:int = 0; a < parentvalue.length; a++)
					{
						newarray.push(parentvalue[a]);
					}
					lo[registeredDynamicScopeVars[i]] = newarray;
				}
				else
					lo[registeredDynamicScopeVars[i]] = parentvalue;
			}
			else
			{
				lo[registeredDynamicScopeVars[i]] = null;
			}
		}
	}
	
	public function getGlobalObject():Object
	{
		return global;
	}
	
	public function getLocalObject():Object
	{
		return localObject;
	}
	
	public function setByteCode (byteCode:Array) :void
	{
		this.byteCode = byteCode;
		byteCodeLength = byteCode.length;
	}
	
	public function getByteCode() : Array
	{
		return this.byteCode;
	}
	
	public function getByteCodeLength():int
	{
		return byteCodeLength;
	}
	
	public function execute (returningValue:* = undefined) : Boolean
	{
		var _byteCode:Array = byteCode;
		var _programCounter:int = programCounter;
		
		var _byteCodeLength:int = byteCodeLength;
		
		var next:*;
		
		// Jun 16, 2011
		// Expanding externalSuspend - Sean Givan
		
		
		if (/*(returningValue != undefined)&&*/(returnSuspendTarget != -1))
		{
			trace("updating with returningValue");
			_byteCode[_byteCode[returnSuspendTarget]] = returningValue;
			returnSuspendTarget = -1;
		}
		
		if ((optimized == false) && (runCoroutineMode == false))
		{
			for (; _programCounter < _byteCodeLength; ) {
			 //trace("proccess : "+("00"+_programCounter).substr(-2,2)+" : "+_byteCode[_programCounter]);
			
			 
				if ((next = this[_byteCode[_programCounter]](_byteCode, _programCounter)) == null) {
					
					programCounter = _programCounter + 1;
					// このタイミングでいらない値は破棄しておこう．．．
					delete _byteCode[0];
					
					return true;
				}
				_programCounter = next;
			}
		}
		else if ((optimized == true) && (runCoroutineMode == false) )
		{
			for (; _programCounter < _byteCodeLength; ) {
				// trace("proccess : "+("00"+_programCounter).substr(-2,2)+" : "+_byteCode[_programCounter]);
				
				
				if ((next = _byteCode[_programCounter](_byteCode, _programCounter)) == null) {
					
					programCounter = _programCounter + 1;
					// このタイミングでいらない値は破棄しておこう．．．
					delete _byteCode[0];
					
					return true;
				}
				_programCounter = next;
			}
		}
		else if ((optimized == false) && (runCoroutineMode == true))
		{
			for (; _programCounter < _byteCodeLength; ) {
			 //trace("proccess : "+("00"+_programCounter).substr(-2,2)+" : "+_byteCode[_programCounter]);
			
				if (_programCounter == 0) break;
			 
				if ((next = this[_byteCode[_programCounter]](_byteCode, _programCounter)) == null) {
					
					if (externalSuspend == true)
						programCounter = returnSuspendTarget + 1;
					else
						programCounter = _programCounter + 1;
					// このタイミングでいらない値は破棄しておこう．．．
					delete _byteCode[0];
					
					externalSuspend = false;
					
					return true;
				}
				_programCounter = next;
			}
		}
		else
		{
			for (; _programCounter < _byteCodeLength; ) {
				// trace("proccess : "+("00"+_programCounter).substr(-2,2)+" : "+_byteCode[_programCounter]);
				
				if (_programCounter == 0) break;
				
				if ((next = _byteCode[_programCounter](_byteCode, _programCounter)) == null) {
					
					if (externalSuspend == true)
						programCounter = returnSuspendTarget + 1;
					else
						programCounter = _programCounter + 1;
						
					// このタイミングでいらない値は破棄しておこう．．．
					delete _byteCode[0];
					
					externalSuspend = false;
					
					return true;
				}
				
				// June 18 2011 - Sean Givan
				// New feature when using code in runCoroutine mode
				// do a check for external suspension with each opcode
				
				_programCounter = next;
			}
		}
		
		programCounter = _programCounter;
		
		// このタイミングでいらない値は破棄しておこう．．．
		delete _byteCode[0];
		
		runCoroutineMode = false;
		
		return false;
	}
	
	public function suspend():void
	{
		externalSuspend = true;
	}
	
	private function executeFunction (thisObject:Object, args:Array, entryPoint:*, scope:*) :*
	{
		var _thisObject:Object = this.thisObject;
		var _localObject:Object = localObject;
		var _programCounter:int = programCounter;
		
		this.thisObject = thisObject;
		localObject = {arguments: args, __scope:scope};
		programCounter = entryPoint;
		
		while (execute()) {}
		
		programCounter = _programCounter;
		localObject = _localObject;
		this.thisObject = _thisObject;
		
		return returnValue;
	}
	
	private function __resolve (name:String) :int
	{
		throw new Error('VirtualMachine [UnknownOperation] : '+name+' at pc'+arguments[1]);
		return 0;
	}
	//
	//nop
	//(no operation)
	//何もしない
	public function NOP (code:Array, pc:int) :*
	{
		return pc+1;
	}
	//
	//spd
	//(suspend)
	//処理を中断する
	public function SPD (code:Array, pc:int) :*
	{
		return null;
	}
	//
	//lit v %
	//(literal)
	//リテラルvを%に代入
	public function LIT (code:Array, pc:int) :*
	{
		code[code[pc+2]] = code[pc+1];
		
		return pc+3;
	}
	//
	//call id n %
	//(call function)
	//関数idをn個の引数で呼び出して結果を%に代入
	public function CALL (code:Array, pc:int) :*
	{
		var id:String = code[pc + 1];
		
		//trace("CALL: id is " + id);
		
		var func:* = null;
		
		for (var o:Object = localObject; o != null; o = o.__scope) {
			if (id in o) {
				func = o[id];
				break;
			}
		}
		
		var numOfArguments:int = code[pc+2] + 1;
		var _stack:Array = stack;
		var args:Array = [];
		while (--numOfArguments) {
			args.push(_stack.pop());
		}
		args.reverse();
		
		//if (func.__entryPoint !== undefined) {
		if ("__entryPoint" in func) {
			_stack.push(pc+4);
			_stack.push(thisObject);
			_stack.push(localObject);
			_stack.push(code[pc+3]);
			
			thisObject = global;
			localObject = {arguments: args, __scope: func.__scope, __parentenvironment:localObject};
			
			manageDynamicScopeVars(localObject);
			
			return func.__entryPoint;
		}
		
		//code[code[pc + 3]] = func.apply(global, args);
		
		var result:* = func.apply(global, args);
		
		if (externalSuspend == false)
			code[code[pc + 3]] = result;
		else
		{
			returnSuspendTarget  = (pc + 3);
			return null;
		}
		
		
		return pc+4;
	}
	//
	//calll id n %
	//(call local function)
	//関数idをn個の引数で呼び出して結果を%に代入
	public function CALLL (code:Array, pc:int) :*
	{
		var func:* = localObject[code[pc + 1]];
		
		//trace("CALLL: func is " + code[pc + 1]);
		
		var numOfArguments:int = code[pc+2] + 1;
		var _stack:Array = stack;
		var args:Array = [];
		while (--numOfArguments) {
			args.push(_stack.pop());
		}
		args.reverse();
		
		//if (func.__entryPoint !== undefined) {
		if ("__entryPoint" in func) {
			_stack.push(pc+4);
			_stack.push(thisObject);
			_stack.push(localObject);
			_stack.push(code[pc+3]);
			
			thisObject = global;
			localObject = {arguments: args, __scope: func.__scope, __parentenvironment:localObject};
			
			manageDynamicScopeVars(localObject);
			
			return func.__entryPoint;
		}
		
		
		// code[code[pc + 3]] = func.apply(global, args);
		var result:* = func.apply(global, args);
		
		if (externalSuspend == false)
			code[code[pc + 3]] = result;
		else
		{
			returnSuspendTarget  = (pc + 3);
			return null;
		}
		
		return pc+4;
	}
	//
	//callm o id n %
	//(call member function)
	//関数v.idをn個の引数で呼び出して結果を%に代入
	public function CALLM (code:Array, pc:int) :*
	{
		var o:* = code[pc + 1];
		
		//trace("CALLM: " + code[pc + 2]);
		
		var func:* = o[code[pc+2]];
		
		var numOfArguments:int = code[pc+3] + 1;
		var _stack:Array = stack;
		var args:Array = [];
		while (--numOfArguments) {
			args.push(_stack.pop());
		}
		args.reverse();
		
		//if (func.__entryPoint !== undefined) {
		if ("__entryPoint" in func) {
			_stack.push(pc+5);
			_stack.push(thisObject);
			_stack.push(localObject);
			_stack.push(code[pc+4]);
			
			thisObject = o;
			localObject = {arguments: args, __scope: func.__scope, __parentenvironment:localObject};
			
			manageDynamicScopeVars(localObject);
			
			return func.__entryPoint;
		}
		
		//code[code[pc + 4]] = func.apply(o, args);
		var result:* = func.apply(global, args);
		
		if (externalSuspend == false)
			code[code[pc + 4]] = result;
		else
		{
			returnSuspendTarget  = (pc + 4);
			return null;
		}
		
		return pc+5;
	}
	//
	//callf o n %
	//(call functor)
	//関数オブジェクトoをn個の引数で呼び出して結果を%に代入
	public function CALLF (code:Array, pc:int) :*
	{
		var func:* = code[pc + 1];
		
		//trace("CALLF: " + code[pc + 1]);
		
		var numOfArguments:int = code[pc+2] + 1;
		var _stack:Array = stack;
		var args:Array = [];
		while (--numOfArguments) {
			args.push(_stack.pop());
		}
		args.reverse();
		
		//if (func.__entryPoint !== undefined) {
		if ("__entryPoint" in func) {
			_stack.push(pc+4);
			_stack.push(thisObject);
			_stack.push(localObject);
			_stack.push(code[pc+3]);
			
			thisObject = global;
			localObject = {arguments: args, __scope: func.__scope, __parentenvironment:localObject};
			
			manageDynamicScopeVars(localObject);
			
			return func.__entryPoint;
		}
		
		//code[code[pc+3]] = func.apply(global, args);
		
		var result:* = func.apply(global, args);
		
		if (externalSuspend == false)
			code[code[pc + 3]] = result;
		else
		{
			returnSuspendTarget  = (pc + 3);
			return null;
		}
		
		return pc+4;
	}
	//
	//ret v
	//(return function)
	//戻り値vで関数の呼び出し元に戻る
	public function RET (code:Array, pc:int) :*
	{
		returnValue = code[pc+1];
		
		return byteCodeLength;
	}
	//
	//cret v
	//(return coroutine)
	//戻り値vでコルーチンの呼び出し元に戻る
	public function CRET (code:Array, pc:int) :*
	{
		var _stack:Array = stack;
		
		code[_stack.pop()] = code[pc+1];
		
		localObject = _stack.pop();
		thisObject = _stack.pop();
		
		return Number(_stack.pop());
	}
	//
	//func :% %
	//(function declare)
	//:%までを本体とする関数オブジェクトを生成して%に代入
	public function FUNC (code:Array, pc:int) :*
	{
		var vm:VirtualMachine = this;
		var entryPoint:* = pc + 3;
		var scope:Object = localObject;
		code[code[pc+2]] = function ():*
		{
			return vm.executeFunction(this, arguments, entryPoint, scope);
		};
		return code[pc+1];
	}
	//
	//cor :% %
	//(coroutine declare)
	//:%までを本体とするコルーチンを生成して%に代入
	public function COR (code:Array, pc:int) :*
	{
		code[code[pc+2]] = {__entryPoint:pc+3, __scope:localObject};
		return code[pc+1];
	}
	//
	//arg n id
	//(get argument)
	//n番目の引数を変数idに代入
	public function ARG (code:Array, pc:int) :*
	{
		localObject[code[pc+2]] = localObject.arguments[code[pc+1]];
		
		// Nov 23 2008 - Sean Givan
		// Added new feature where the localObject collects parameter information
		// as well as arguments information
		if (localObject.parameters == undefined)
			localObject.parameters = [];
		
		localObject.parameters.push(code[pc+2]);
		// End addition
		
		return pc+3;
	}
	//
	//jmp :%
	//(jump)
	//:%に飛ぶ
	public function JMP (code:Array, pc:int) :*
	{
		return code[pc+1];
	}
	//
	//if v :%
	//(jump if)
	//vが真で「なければ」:%に飛ぶ（真であれば次のコードが実行される）
	public function IF (code:Array, pc:int) :*
	{
		if (code[pc+1]) {
			return pc+3;
		}
		return code[pc+2];
	}
	//
	//nif v :%
	//(jump if not)
	//vが偽で「なければ」:%に飛ぶ（偽であれば次のコードが実行される）
	public function NIF (code:Array, pc:int) :*
	{
		if (code[pc+1]) {
			return code[pc+2];
		}
		return pc+3;
	}
	//
	//add v1 v2 %
	//(add)
	//v1+v2を%に代入
	public function ADD (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] + code[pc+2];
		return pc+4;
	}
	//
	//sub v1 v2 %
	//(subtract)
	//v1-v2を%に代入
	public function SUB (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] - code[pc+2];
		return pc+4;
	}
	//
	//mul v1 v2 %
	//(multiply)
	//v1*v2を%に代入
	public function MUL (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] * code[pc+2];
		return pc+4;
	}
	//
	//div v1 v2 %
	//(divide)
	//v1/v2を%に代入
	public function DIV (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] / code[pc+2];
		return pc+4;
	}
	//
	//mod v1 v2 %
	//(modulo)
	//v1%v2を%に代入
	public function MOD (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] % code[pc+2];
		return pc+4;
	}
	//
	//and v1 v2 %
	//(bitwise and)
	//v1&v2を%に代入
	public function AND (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] & code[pc+2];
		return pc+4;
	}
	//
	//or v1 v2 %
	//(bitwise or)
	//v1|v2を%に代入
	public function OR (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] | code[pc+2];
		return pc+4;
	}
	//
	//xor v1 v2 %
	//(bitwise xor)
	//v1^v2を%に代入
	public function XOR (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] ^ code[pc+2];
		return pc+4;
	}
	//
	//not v %
	//(bitwise not)
	//~vを%に代入
	public function NOT (code:Array, pc:int) :*
	{
		code[code[pc+2]] = ~code[pc+1];
		return pc+3;
	}
	//
	//lnot v %
	//(logical not)
	//!vを%に代入
	public function LNOT (code:Array, pc:int) :*
	{
		code[code[pc+2]] = !code[pc+1];
		return pc+3;
	}
	//
	//lsh v1 v2 %
	//(left shift)
	//v1<<v2を%に代入
	public function LSH (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] << code[pc+2];
		return pc+4;
	}
	//
	//rsh v1 v2 %
	//(signed right shift)
	//v1>>v2を%に代入
	public function RSH (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] >> code[pc+2];
		return pc+4;
	}
	//
	//ursh v1 v2 %
	//(unsigned right shift)
	//v1>>>v2を%に代入
	public function URSH (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] >>> code[pc+2];
		return pc+4;
	}
	//
	//inc v %
	//(increment)
	//vを加算して%に代入
	public function INC (code:Array, pc:int) :*
	{
		code[code[pc+2]] = code[pc+1] + 1;
		return pc+3;
	}
	//
	//dec v %
	//(decrement)
	//vを減算して%に代入
	public function DEC (code:Array, pc:int) :*
	{
		code[code[pc+2]] = code[pc+1] - 1;
		return pc+3;
	}
	//
	//ceq v1 v2 %
	//(compare equal)
	//v1==v2の結果を%に代入
	public function CEQ (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] == code[pc+2];
		return pc+4;
	}
	//
	//cseq v1 v2 %
	//(compare strict equal)
	//v1===v2の結果を%に代入
	public function CSEQ (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] === code[pc+2];
		return pc+4;
	}
	//
	//cne v1 v2 %
	//(compare not equal)
	//v1!=v2の結果を%に代入
	public function CNE (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] != code[pc+2];
		return pc+4;
	}
	//
	//csne v1 v2 %
	//(compare not strict equal)
	//v1!==v2の結果を%に代入
	public function CSNE (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] !== code[pc+2];
		return pc+4;
	}
	//
	//clt v1 v2 %
	//(compare less than)
	//v1<v2の結果を%に代入
	public function CLT (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] < code[pc+2];
		return pc+4;
	}
	//
	//cgt v1 v2 %
	//(compare greater than)
	//v1>v2の結果を%に代入
	public function CGT (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] > code[pc+2];
		return pc+4;
	}
	//
	//cle v1 v2 %
	//(compare less than or equal)
	//v1<=v2の結果を%に代入
	public function CLE (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] <= code[pc+2];
		return pc+4;
	}
	//
	//cge v1 v2 %
	//(compare greater than or equal)
	//v1>=v2の結果を%に代入
	public function CGE (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] >= code[pc+2];
		return pc+4;
	}
	//
	//dup v %1 %2
	//(duplicate)
	//%1と%2にvを代入
	public function DUP (code:Array, pc:int) :*
	{
		var value:* = code[pc+1];
		code[code[pc+2]] = value;
		code[code[pc+3]] = value;
		return pc+4;
	}
	//
	//this %
	//(this)
	//thisを%に代入
	public function THIS (code:Array, pc:int) :*
	{
		code[code[pc+1]] = thisObject;
		return pc+2;
	}
	//
	//array n %
	//(initialize array)
	//n個の要素を持つ配列を生成して%に代入
	public function ARRAY (code:Array, pc:int) :*
	{
		var elements:* = code[pc+1];
		var instance:Array = new Array(elements);
		var _stack:Array = stack;
		for (var i:int=0; i<elements; ++i) {
			instance[i] = _stack.pop();
		}
		instance.reverse();
		code[code[pc+2]] = instance;
		return pc+3;
	}
	//
	//obj n %
	//(initialize object)
	//n個のキーと値のペアを持つオブジェクトを生成して%に代入
	public function OBJ (code:Array, pc:int) :*
	{
		var properties:* = code[pc+1];
		var instance:Object = {};
		var _stack:Array = stack;
		for (var i:int=0; i<properties; ++i) {
			var value:* = _stack.pop();
			instance[_stack.pop()] = value;
		}
		code[code[pc+2]] = instance;
		return pc+3;
	}
	//
	//setl id v %
	//(set local variable)
	//現在の実行コンテキスト上の変数idにvを代入（変数idが存在しなければ生成; スコープチェーンは見ない）
	public function SETL (code:Array, pc:int) :*
	{
		localObject[code[pc+1]] = code[code[pc+3]] = code[pc+2];
		return pc+4;
	}
	//
	//getl id %
	//(get local variable)
	//現在の実行コンテキスト上の変数idを探して%に代入（スコープチェーンは見ない）
	public function GETL (code:Array, pc:int) :*
	{
		code[code[pc+2]] = localObject[code[pc+1]];
		return pc+3;
	}
	//
	//set id v %
	//(set variable)
	//現在の実行コンテキストを基点とするスコープチェーンから変数idを探してvを代入
	public function SET (code:Array, pc:int) :*
	{
		var id:String = code[pc+1];
		for (var o:Object = localObject; o != null; o = o.__scope) {
			if (id in o) {
				o[id] = code[code[pc+3]] = code[pc+2];
				return pc+4;
			}
		}
		global[id] = code[code[pc+3]] = code[pc+2];
		return pc+4;
	}
	//
	//get id %
	//(get variable)
	//現在の実行コンテキストを基点とするスコープチェーンから変数idを探して%に代入
	public function GET (code:Array, pc:int) :*
	{
		var id:String = code[pc+1];
		for (var o:Object = localObject; o != null; o = o.__scope) {
			if (id in o) {
				code[code[pc+2]] = o[id];
				return pc+3;
			}
		}
		code[code[pc+2]] = undefined;
		return pc+3;
	}
	//
	//setm o id v %
	//(set member)
	//o.idにvを代入
	public function SETM (code:Array, pc:int) :*
	{
		code[pc+1][code[pc+2]] = code[code[pc+4]] = code[pc+3];
		return pc+5;
	}
	//
	//getm o id %
	//(get member)
	//o.idを%に代入
	public function GETM (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1][code[pc+2]];
		return pc+4;
	}
	// Sean Givan - Jan 4 2008 - Added bugfix to allow
	// member expressions with a variable as the memberExpression
	public function GETMV (code:Array, pc:int) :*
	{
		var thefield:*;
		if (code[pc+2] == 'GETL')
		{
			thefield = localObject[code[pc+3]];
		}
		else // GET
		{
			for (var o:Object = localObject; o != null; o = o.__scope) {
			if (code[pc+3] in o) 
			{
				thefield = o[code[pc+3]];
			}
		}
		}
	
		code[code[pc+4]] = code[pc+1][thefield];
		return pc+5;
	}
	
	
	//
	//new v n %
	//(new instance)
	//クラスvをn個の引数で生成して%に代入
	public function NEW (code:Array, pc:int) :*
	{
		var constructor:Function = code[pc+1];
		_constructor.prototype = constructor.prototype;
		//var instance = new _constructor();
		var instance:* = constructor;
		var argLen:int = code[pc+2]+1;
		var _stack:Array = stack;
		var args:Array = [];
		while (--argLen) {
			args.push(_stack.pop());
		}
		code[code[pc+3]] = constructor.apply(instance, args) || instance;
		return pc+4;
	}
	private function _constructor () :*
	{
	}
	//
	//del id %
	//(delete)
	//変数idを削除し、その成否を%に代入
	public function DEL (code:Array, pc:int) :*
	{
		var id:String = code[pc+1];
		for (var o:Object = localObject; o != null; o = o.__scope) {
			if (id in o) {
				code[code[pc+2]] = delete o[id];
				return pc+3;
			}
		}
		code[code[pc+2]] = false;
		return pc+3;
	}
	//
	//dell id %
	//(delete local)
	//変数idを削除し、その成否を%に代入
	public function DELL (code:Array, pc:int) :*
	{
		code[code[pc+2]] = delete localObject[code[pc+1]];
		return pc+3;
	}
	//
	//delm o id %
	//(delete member)
	//o.idを削除し、その成否を%に代入
	public function DELM (code:Array, pc:int) :*
	{
		code[code[pc+3]] = delete code[pc+1][code[pc+2]];
		return pc+4;
	}
	//
	//typeof v %
	//(typeof)
	//typeof vの結果を%に代入
	public function TYPEOF (code:Array, pc:int) :*
	{
		code[code[pc+2]] = typeof code[pc+1];
		return pc+3;
	}
	//
	//insof v1 v2 %
	//(instanceof)
	//v1 instanceof v2の結果を%に代入
	public function INSOF (code:Array, pc:int) :*
	{
		code[code[pc+3]] = code[pc+1] is code[pc+2];
		return pc+4;
	}
	//
	//num v %
	//(to number)
	//Number(v)の結果を%に代入
	public function NUM (code:Array, pc:int) :*
	{
		code[code[pc+2]] = Number(code[pc+1]);
		return pc+3;
	}
	//
	//str v %
	//(to string)
	//String(v)の結果を%に代入
	public function STR (code:Array, pc:int) :*
	{
		code[code[pc+2]] = String(code[pc+1]);
		return pc+3;
	}
	//
	//with v
	//(start with)
	//スコープチェーンの先頭にvを追加
	public function WITH (code:Array, pc:int) :*
	{
		var o:Object = code[pc+1];
		
		o.__scope = localObject;
		localObject = o;
		
		return pc+2;
	}
	//
	//ewith
	//(end with)
	//スコープチェーンから先頭のオブジェクトを取り除く
	public function EWITH (code:Array, pc:int) :*
	{
		localObject = localObject.__scope;
		return pc+1;
	}
	//
	//push v
	//(push)
	//vをスタックに積む
	public function PUSH (code:Array, pc:int) :*
	{
		stack.push(code[pc+1]);
		return pc+2;
	}
	//
	//pop %
	//(pop)
	//スタックから値を取り出し%に代入
	public function POP (code:Array, pc:int) :*
	{
		code[code[pc+1]] = stack.pop();
		return pc+2;
	}
	
	/* FECMAScriptɂN[W̊TO
	
	eFunctiońA`ꂽꏊɂXR[v`F[A
	vpeBƂĎB
	
	j
	globalɒ`ꂽ֐f́AglobalXR[v`F[ɎB
	f().__proto__ == global
	fɒ`ꂽ֐ǵAfActivationObjectXR[v`F[ɎB
	g().__proto__ == ActivationObject(f)
	ActivationObject(f).__proto__ = f().__proto__
	
	eFunctionJnƂAActivationObjecti[Jϐ
	i[̈̂悤Ȃ́jÃXR[v`F[͊֐̂
	XR[v`F[ɐݒ肳B
	
	ɂA
	
	///////////////////////////////////////
	var a = 1;
	
	function f (g:Function) 
	{
		var b = 1;
		a = g(b);
	}
	
	f(function(n) 
	{
		return a + n;
	});
	///////////////////////////////////////
	
	ƂR[h́A֐fA֐igjɃO[o̕ϐa
	ANZXł̂łB
	
	֐fϐQƂƂA
	ActivationObject(f) (-> ActivationObject(f).__proto__ -> f().__proto__) -> global
	ƂŎQƂA֐ϐaQƂƂl̎菇ōsB
	
	֐ϐQƂƂA
	ActivationObject() (-> ActivationObject().__proto__ -> ().__proto__) -> global
	ƂŎQƂ邽߁A֐f̕ϐbɂ̓ANZXłȂB
	
	ϐbActivationObject(f)ɍ쐬B
	
	*/
}

}