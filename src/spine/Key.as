package spine
{
	public class Key {
		public var slotIndex : int;
		public var name : String;
		protected var _hashCode : int;
		
		public function set(slotName : int, name : String) : void {
			if (name == null) throw new Error("attachmentName cannot be null.");
			this.slotIndex = slotName;
			this.name = name;
			_hashCode = 31 * (31 + Key.GetHashCodeInt(name)) + slotIndex;
		}
		
		public function get hashCode () : int {
			return _hashCode;
		}
		
		public function equals (object : Object) : Boolean {
			if (object == null) return false;
			var other : Key = object as Key;
			if (slotIndex != other.slotIndex) return false;
			if (!name == other.name) return false;
			return true;
		}
		
		public function toString () : String {
			return slotIndex + ":" + name;
		}
		
		public static function GetHashCodeInt(str:String):int
		{
			var hashString:String = str;
			hashString = hashString.split(/[\s]+/)[0];
			hashString = hashString.substring(1); // get rid of first char
			return int("0x"+hashString);
		} 
	}
}
