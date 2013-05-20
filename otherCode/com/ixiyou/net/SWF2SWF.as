package com.ixiyou.net
{

	import flash.events.*;
	import flash.net.*;
	public class SWF2SWF extends EventDispatcher
	{
		private var _name:String
		private var _connection:LocalConnection
	
		public function SWF2SWF(value:String)
		{
			_connection=new LocalConnection()
			connection.allowDomain('*');
			_name='_'+value;
			connection.addEventListener(StatusEvent.STATUS,onStatus)
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityError)
			connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError)
			connection.connect(name);
			
			
		}
		
		protected function asyncError(event:AsyncErrorEvent):void
		{
			trace('asyncError');
		}
		
		protected function securityError(event:SecurityErrorEvent):void
		{
			trace('securityError');
		}
		
		public function send(fun:String,...avalue):void{
			if(avalue.length==0)connection.send(name, fun);
			if(avalue.length==1)connection.send(name, fun,avalue[0]);
			if(avalue.length==2)connection.send(name, fun,avalue[0],avalue[1]);
			if(avalue.length==3)connection.send(name, fun,avalue[0],avalue[1],avalue[2]);
			if(avalue.length==4)connection.send(name, fun,avalue[0],avalue[1],avalue[2],avalue[3]);
		}
		
		public function get client():Object
		{
			return connection.client;
		}

		public function set client(value:Object):void
		{
			connection.client = value;
		}

		protected function onStatus(event:StatusEvent):void
		{
			switch (event.level) {
				case "status":
					DebugOutput.add(name+":LocalConnection.send() ok");
					break;
				case "error":
					DebugOutput.add(name+":LocalConnection.send() error");
					break;
			}
		}
		
		public function get connection():LocalConnection
		{
			return _connection;
		}

		public function get name():String
		{
			return _name;
		}

	}
}