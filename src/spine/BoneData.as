/*******************************************************************************
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
package spine
{
		
	public class BoneData {
		public var length : Number;
		public var x : Number;
		public var y : Number;
		public var rotation : Number;
		public var scaleX : Number = 1;
		public var scaleY : Number = 1;
	
		protected var _name : String;
		protected var _parent : BoneData;
	
		/** @param parent May be null. */
		public function BoneData (name : String, parent : BoneData = null) : void {
			if (name == null) 
				throw new Error("name cannot be null.");
			this._name = name;
			this._parent = parent;
		}
	
		public function clone(parent : BoneData):BoneData
		{
			var data : BoneData = new BoneData(this.name, parent); 
			data.length = this.length;
			data.x = this.x;
			data.y = this.y;
			data.rotation = this.rotation;
			data.scaleX = this.scaleX;
			data.scaleY = this.scaleY;
			return data;
		}
	
		/** @return May be null. */
		public function get parent () : BoneData{
			return _parent;
		}
	
		public function get name () : String {
			return _name;
		}
	
		public function toString () : String{
			return name;
		}
	}
}