package com.ixiyou.socket 
{
	import com.adobe.crypto.SHA1;
	import com.dynamicflash.util.Base64;
	import com.ixiyou.socket.utils.WebSocketDecoder;
	import com.ixiyou.socket.utils.WebSocketUtil;
	import flash.net.ServerSocket
	import flash.events.EventDispatcher;
	import flash.net.Socket
	import flash.utils.ByteArray
	import com.ixiyou.socket.AIRSocketServer;
	import com.ixiyou.socket.ISocketServer;
	import com.ixiyou.socket.events.SocketServerEvent;
	/**
	 * 服务器端管理
	 * 
	 * 可以参考这个进行游戏服务器端方面的扩展
	 * @author spe email:md9yue@@q.com
	 */
	public class ServerManagers extends EventDispatcher
	{
		protected var _server:AIRSocketServer
		protected var _clientList:ClientList
		protected var webSocketDecoder:WebSocketDecoder = new WebSocketDecoder();
		
		public function ServerManagers() 
		{
			_server = new AIRSocketServer()
			_clientList = new ClientList()
			
			server.addEventListener(SocketServerEvent.SERVEROPEN,serverOpen)
			server.addEventListener(SocketServerEvent.SERVEROPEN_ERROR,serverOpen_Error)
			server.addEventListener(SocketServerEvent.SERVERCLOSE,serverClose)
			server.addEventListener(SocketServerEvent.SERVERCLOSECLIENT,serverCloseClient)
			server.addEventListener(SocketServerEvent.CLOSE,clientClose)
			server.addEventListener(SocketServerEvent.CONNECT,clientConnect)
			server.addEventListener(SocketServerEvent.RECEIVED,clientReceived)
			//server.addEventListener(SocketServerEvent.DECODE_ERROR,clientDecode_error)
			server.addEventListener(SocketServerEvent.SENDTOCLIENT,sendToClient)
			server.addEventListener(SocketServerEvent.SENDTOCLIENT_ERROR,sendToClient_Error)
			server.addEventListener(SocketServerEvent.CLIENTINVALID_ERROR,clientInvalid_Error)
			server.addEventListener(SocketServerEvent.IO_ERROR, clientClose_Error)
			
			
		}
		/**
		 * 关闭客户端
		 * @param	client
		 */
		public function closeClient(client:Socket):void {
			server.closeClient(client)
		}
		/**
		 * 发送消息给客户端
		 * @param	client
		 * @param	value
		 */
		public function sendClient(socket:Socket,value:Object):void {
			var clinet:Client = clientList.getClientBySocket(socket);
			clinet.send(value);
		}
		/**
		 * 群发消息
		 * @param	value 消息
		 * @param	oclient 排除掉不发的对象，比如不发自己
		 */
		public function sendAllClient(value:Object, oSocket:Socket = null):void {
			var soekct:Socket
			var clinet:Client
			for (var i:int = 0; i < clientList.list.length; i++) 
			{
				clinet = clientList.list[i] as Client;
				soekct = clinet.socket
				if (soekct != oSocket) {
					//不使用server来帮忙发送使用 客户端自己进行发送;
					clinet.send(value);
				}
			}
		}
		
		/**
		 *开启绑定服务端
		 */
		public function bind(value:int):void {
			server.bind(value)
		}
		//服务器开启
		protected function serverOpen(e:SocketServerEvent):void {
			DebugOutput.push('socket','服务器开启')
		}
		//服务器开启错误
		protected function serverOpen_Error(e:SocketServerEvent):void {
			DebugOutput.push('socket','服务器开启错误')
		}
		//服务器关闭
		protected function serverClose(e:SocketServerEvent):void {
			DebugOutput.push('socket','服务器关闭')
		}
		//服务器段关闭客户端
		protected function serverCloseClient(e:SocketServerEvent):void {
			closeClientUp(e.socket,true)
			//var client:Client=clientList.remove(e.socket)
			//DebugOutput.push('clinet','服务器段关闭客户端 '+'在线人数:'+clientList.length)
		}
		
		//客户端关闭
		protected function clientClose(e:SocketServerEvent):void {
			closeClientUp(e.socket,false)
			//var client:Client = clientList.remove(e.socket)
			//DebugOutput.push('clinet','客户端关闭 '+'在线人数:'+clientList.length)
		}
		/**
		 * 关闭客户端 更新列表
		 * @param	socket
		 * @param	serverClose
		 */
		protected function closeClientUp(socket:Socket,serverClose:Boolean):void {
			var client:Client = clientList.remove(socket)
			sendAllClient("user_"+client.atListNumber+' 用户下线了!',null)
			DebugOutput.push('clinet','关闭客户端 '+'在线人数:'+clientList.length+' 是否服务段关闭:'+serverClose)
		}
		/**
		 * 客户端连接上
		 * @param	e
		 */
		protected function clientConnect(e:SocketServerEvent):void {
			var client:Client = clientList.add(e.socket)
			/*
			server.send(client.socket,'userid:'+client.atListNumber)
			*/
			DebugOutput.push('clinet','客户端连接上 '+'在线人数:'+clientList.length)
			
		}
		/**
		 * 接收客户端数据
		 * @param	e
		 */
		protected function clientReceived(e:SocketServerEvent):void {
			var socket:Socket = e.socket;
			var socketBytes:ByteArray = new ByteArray();
			socket.readBytes(socketBytes);
			var event:SocketServerEvent = new SocketServerEvent(SocketServerEvent.RECEIVED, socket, socket.remotePort, socket.remoteAddress)
			var data:Object;
			var client:Client = clientList.getClientBySocket(e.socket);
			
			
			//如果是flashSocket 默认是flashSocket
			if (client.socketType == Client.FLASH_SOCKET) {
				//能够解读说明是flash socket对象,如果编码错误尝试去进行判断是否 webSocket协议消息,然后把客户端判断成webSocket方式连接
				try{                  
					socketBytes.uncompress();  
					data = socketBytes.readObject();	
					event.data = data;
					dispatchEvent(event);
					DebugOutput.push('clinet', '接收客户端数据 ' + clientList.getClientBySocket(e.socket).atListNumber + ":" + data);
				}catch (error:Error) {
					//判断是不是html5Websocket;
					var isWebSocket:* = WebSocketUtil.isHtml5WebSocket(socket,socketBytes);
					//判断不是Websocket
					if (isWebSocket == Client.WEB_SOCKET){
						client.setSocketType(Client.WEB_SOCKET);
						DebugOutput.push('socket','Websocket 连接成功')
					}
					else if (isWebSocket == Client.WEB_SOCKET_OLD){
						client.setSocketType(Client.WEB_SOCKET_OLD);
						DebugOutput.push('socket','Websocket 连接成功')
					}
					else {
						
						event = new SocketServerEvent(SocketServerEvent.DECODE_ERROR,socket,socket.remotePort,socket.remoteAddress)
						dispatchEvent(event);
						DebugOutput.push('socket', '接受客户端消息解码错误 判断isWebSocket时候');
						server.closeClient(socket);
					}
				}  
			
			}
			else if (client.socketType == Client.WEB_SOCKET) {
				//如果是webSocket 默认是flashSocket
					data = webSocketDecoder.process(socketBytes);
					if (data is String) {
						event.data = data;
						dispatchEvent(event); 
						DebugOutput.push('clinet', '接收客户端数据 ' + clientList.getClientBySocket(socket).atListNumber + ":" + data);
					}else {
						event = new SocketServerEvent(SocketServerEvent.DECODE_ERROR, socket, socket.remotePort, socket.remoteAddress);
						event.data = data;
						dispatchEvent(event)
						DebugOutput.push('socket', '接受客户端消息解码错误  解读WebSocket data时候');
					}
			}else if (client.socketType == Client.WEB_SOCKET_OLD) {
			}
		}
		
		
		/*
		//接受客户端消息解码错误  因为底层不再做解码
		protected function clientDecode_error(e:SocketServerEvent):void {
			DebugOutput.push('socket','接受客户端消息解码错误')
		}
		*/
		//发送消息给客户端
		protected function sendToClient(e:SocketServerEvent):void {
			//DebugOutput.push('clinet','发送消息给客户端'+clientList.getClientBySocket(e.socket).atListNumber+':'+e.data)
		}
		//发送消息给客户端错误
		protected function sendToClient_Error(e:SocketServerEvent):void {
			DebugOutput.push('socket','发送消息给客户端错误')
		}
		//发送消息给客户端 出现无效客户端
		protected function clientInvalid_Error(e:SocketServerEvent):void {
			DebugOutput.push('socket','发送消息给客户端 出现无效客户端')
		}
		//错误连接  关闭客户端时候出错
		protected function clientClose_Error(e:SocketServerEvent):void {
			DebugOutput.push('socket','错误连接  关闭客户端时候出错')
		}
		public function get server():AIRSocketServer { return _server; }
		/**
		 * 客户端对象列表
		 */
		public function get clientList():ClientList { return _clientList; }
		//public function get list():ClientList { return _clientList; }
	}

}