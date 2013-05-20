/**
 * https://github.com/shove/as3ws
 */
package com.ixiyou.socket.utils
{
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.IDataInput;
	
	public interface WebSocketProcessor
	{
		function process(socket:IDataInput):*;
	}
}