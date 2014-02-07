//
// C:\Program Files (x86)\FlashDevelop\Tools\flexsdk\frameworks\libs\air\airglobal.swc\flash\events\IEventDispatcher
//
package starling.events
{
	
	public interface IEventDispatcher
	{
		
		function addEventListener (type:String, listener:Function) : void;

		/**
		 * Dispatches an event into the event flow. The event target is the
		 * EventDispatcher object upon which dispatchEvent() is called.
		 * @param	event	The event object dispatched into the event flow.
		 * @return	A value of true unless preventDefault() is called on the event, 
		 *   in which case it returns false.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		function dispatchEvent (event:Event) : void;

		/**
		 * Checks whether the EventDispatcher object has any listeners registered for a specific type 
		 * of event. This allows you to determine where an EventDispatcher object has altered handling of an event type in the event flow hierarchy. To determine whether 
		 * a specific event type will actually trigger an event listener, use IEventDispatcher.willTrigger().
		 * The difference between hasEventListener() and willTrigger() is that hasEventListener() examines only the object to which it belongs, whereas willTrigger() examines the entire event flow for the event specified by the type parameter.
		 * @param	type	The type of event.
		 * @return	A value of true if a listener of the specified type is registered; false otherwise.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		function hasEventListener (type:String) : Boolean;

		/**
		 * Removes a listener from the EventDispatcher object. If there is no matching listener 
		 * registered with the EventDispatcher object, a call to this method has no effect.
		 * @param	type	The type of event.
		 * @param	listener	The listener object to remove.
		 * @param	useCapture	Specifies whether the listener was registered for the capture phase or the target and bubbling phases. If the listener was registered for both the capture phase and the target and bubbling phases, two calls to removeEventListener() are required to remove both: one call with useCapture set to true, and another call with useCapture set to false.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		function removeEventListener (type:String, listener:Function) : void;

		/**
		 * Checks whether an event listener is registered with this EventDispatcher object or any of its ancestors for the specified event type. This method returns true if an event listener is triggered during any phase of the event flow when an event of the specified type is dispatched to this EventDispatcher object or any of its descendants.
		 * The difference between hasEventListener() and willTrigger() is that hasEventListener() examines only the object to which it belongs, whereas willTrigger() examines the entire event flow for the event specified by the type parameter.
		 * @param	type	The type of event.
		 * @return	A value of true if a listener of the specified type will be triggered; false otherwise.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		//function willTrigger (type:String) : Boolean;
	}
}
