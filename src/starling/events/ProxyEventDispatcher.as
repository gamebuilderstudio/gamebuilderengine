package starling.events 
{
	/**
	 * ...
	 * @author pautay
	 */
	public class ProxyEventDispatcher extends EventDispatcher
	{
		private var _proxy : EventDispatcher;
		
		public function ProxyEventDispatcher(proxy : EventDispatcher) 
		{
			_proxy = proxy;
		}
		
		public function get proxy():EventDispatcher 
		{
			return _proxy;
		}
		
	}

}