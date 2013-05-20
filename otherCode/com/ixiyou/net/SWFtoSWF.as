package com.ixiyou.net
{
	
	import com.ixiyou.events.DataSpeEvent;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * 进行swf与swf间或许通讯 
	 * @author maksim
	 * 
	 */	
	public class SWFtoSWF extends EventDispatcher
	{
		private var _name:String
		private var _connection:LocalConnection
		public function SWFtoSWF(value:String)
		{
			_connection=new LocalConnection()
			connection.allowDomain('*');
			connection.client=this;
			connection.addEventListener(StatusEvent.STATUS,onStatus)
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityError)
			connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError)
			_name=value;
			
		}
		protected function asyncError(event:AsyncErrorEvent):void
		{
			trace('asyncError');
		}
		
		protected function securityError(event:SecurityErrorEvent):void
		{
			trace('securityError');
		}
		protected function onStatus(event:StatusEvent):void
		{
			
			switch (event.level) {
				case "status":
					//DebugOutput.add(name+":LocalConnection.send() ok");
					break;
				case "error":
					//DebugOutput.add(name+":LocalConnection.send() error");
					break;
			}
		}
		/**
		 *发送消息 
		 */
		public function send(value:Object=null):void{
			connection.send(name,'readData',value);
		}
		/**
		 *接收消息 
		 */ 
		public function readData(value:Object):void{
			var event:DataSpeEvent=new DataSpeEvent('readData');
			event.data=value;
			dispatchEvent(event);
		}
		
		public function connect():void{
			try {
				connection.connect(name);
				DebugOutput.add('connect:',name);
			}catch (error:ArgumentError) {
				DebugOutput.add('connectError:',name)
				dispatchEvent(new Event('connectError'))
			}
		}
		
		public function get name():String
		{
			return _name;
		}

		public function get connection():LocalConnection
		{
			return _connection;
		}

	}
}