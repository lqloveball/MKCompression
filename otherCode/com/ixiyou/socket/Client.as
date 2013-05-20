package com.ixiyou.socket
{
	import com.ixiyou.socket.utils.WebSocketEncoder;
	import flash.events.*;
	import flash.net.*
	import flash.utils.*;
	/**
	 * 客户端
	 * @author spe email:md9yue@@q.com
	 */
	public class Client extends EventDispatcher 
	{
		public static const WEB_SOCKET:String = "webSocket"; 
		public static const WEB_SOCKET_OLD:String = "webSocket_Old"; 
		public static const FLASH_SOCKET:String = "flashSocket"; 
		
		//连接的客户端类型 webSocket flashSocket webSocket_Old
		private var _socketType:String = Client.FLASH_SOCKET;
		//webSocket 协议版本
		private var _webSocketVersion:Number=0
		
		private var _socket:Socket;
		private var _userData:IUserSocket
		//创建这个客户端时间
		private var _birthTime:uint
		
		private var _activation:Boolean = false
		//第几个连接上服务器的客户端
		private var _atListNumber:uint=0
		/**
		 * 构造函数
		 * @param	socket
		 */
		public function Client(socket:Socket,num:uint) 
		{
			this.socket = socket
			_atListNumber=num
			_birthTime=getTimer()
		}
		public function setSocketType(value:String):void {
			_socketType = value;
			if (_socketType==Client.WEB_SOCKET) {
				_webSocketVersion = 13;
			}
			else {
				_webSocketVersion=0
			}
		}
		/**
		 * 客户端的连接的socket对象
		 */
		public function get socket():Socket { return _socket; }
		public function set socket(value:Socket):void 
		{
			if(_socket == value)return 
			_socket = value;
		}
		/**
		 * 客户端是否激活
		 */
		public function get activation():Boolean { return _activation; }
		
		public function set activation(value:Boolean):void 
		{
			_activation = value;
		}
		/**
		 * 客户端连接的用户数据的id
		 * 如果是空说明用户数据还未绑定
		 */
		public function get id():String {
			if(userData)return userData.id;
			else return ''
		}
		
		/**
		 * 用户数据 绑定用户数据
		 */
		public function get userData():IUserSocket { return _userData; }
		public function set userData(value:IUserSocket):void 
		{
			if (!userData) {
				_userData = value;
				_userData.socket = socket
				_userData.client=this
			}
		}
		/**
		 * 这客户端对象创建时间
		 */
		public function get birthTime():uint { return _birthTime; }
		/**
		 * 第几个连接上来的
		 */
		public function get atListNumber():uint { return _atListNumber; }
		/**
		 * 连接的客户端类型 webSocket flashSocket
		 */
		public function get socketType():String 
		{
			return _socketType;
		}
		/**
		 * webSocket连接版本
		 */
		public function get webSocketVersion():Number 
		{
			return _webSocketVersion;
		}
		
		
		
		/**
		 * 发送数据给Flash客户端
		 */
		public function send(value:Object):Boolean 
		{
			if (socketType == Client.FLASH_SOCKET) return sendByFlash(value);
			if (socketType == Client.WEB_SOCKET_OLD) return sendByOldWebSocket(value);
			if (socketType == Client.WEB_SOCKET) return sendByWebSocket(value);
			return false;
		}
		/**
		 * 发数据给flash
		 * @param	value
		 * @return
		 */
		private function sendByFlash(value:Object):Boolean {
			if (!socket.connected) {
				return false;
			}
			var bytes:ByteArray = new ByteArray();  
			bytes.writeObject(value); 
			bytes.compress();  
			socket.writeBytes(bytes);  
			socket.flush();  
			return true
		}
		/**
		 * 发送数据给WebSocket
		 * @param	value
		 * @return
		 */
		private function sendByWebSocket(value:Object):Boolean {
			if (!socket.connected) {
				return false;
			}
			
			var serialized:String = '';
			if (value is String) serialized = value as String
			else serialized=Tools.json_encode(value);
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(serialized);
			
			var webBytes:ByteArray = encodeWebSocketByteArray(true, false, false, false, 0x01, bytes);
			
			if (webBytes) {
				socket.writeBytes(webBytes);
				socket.flush();
				trace('发送给websocket数据成功')
				return true;
			}else {
				return false;
			}
		}
		
		
		protected function encodeWebSocketByteArray(aWriteFinal:Boolean, aRes1:Boolean, aRes2:Boolean, aRes3:Boolean, aWriteCode:int, aStream:ByteArray):ByteArray
		{
			var bt:int = 0;
			var sendLen:int = 0;
			var i:int;
			var len:int = 0;
			var stream:ByteArray = new ByteArray();
			var bytes:ByteArray;
			var masks:ByteArray
			var send:ByteArray = new ByteArray();
			var fMasking:Boolean = false;//do not mask when we are sending data

			
				try
				{
					bt = (aWriteFinal ? 1 : 0) * 0x80;
					bt += (aRes1 ? 1 : 0) * 0x40;
					bt += (aRes2 ? 1 : 0) * 0x20;
					bt += (aRes3 ? 1 : 0) * 0x10;
					bt += aWriteCode;
					
					stream.writeByte(bt);
					
					//length & mask
					len = (fMasking ? 1 : 0) * 0x80;
					if (aStream.length < 126) len += aStream.length;
					else if (aStream.length < 65536) len += 126;
					else len += 127;
					stream.writeByte(len);
					
					if (aStream.length >= 126)
					{
						trace("longer stream");
						bytes = new ByteArray();
						if (aStream.length < 65536)
						{
							bytes.writeShort(aStream.length);
						}
						else
						{
							bytes.writeInt(aStream.length);
						}
						//reverse?
						//if (BitConverter.IsLittleEndian) bytes = ReverseBytes(bytes);
						stream.writeBytes(bytes, 0, bytes.length);
					}
					
					//masking
					if (fMasking)
					{
						masks = new ByteArray();
						masks.writeByte(Math.floor(Math.random() * 256));
						masks.writeByte(Math.floor(Math.random() * 256));
						masks.writeByte(Math.floor(Math.random() * 256));
						masks.writeByte(Math.floor(Math.random() * 256));
						stream.writeBytes(masks, 0, masks.length);
					}

					//send data
					aStream.position = 0;
					
					aStream.readBytes(send);
					
					if(fMasking)
					{
						for(i = 0; i < send.length; i++)
						{
							send[i] = (send[i] ^ masks[i % 4]);
						}
					}
					
					stream.writeBytes(send, 0, send.length);
					
					return stream;
				
				}
				catch (e:Error)
				{
					
				}
			
			return null;
		}

		/**
		 * 旧版协议发送数据给客户端
		 * @param	value
		 * @return
		 */
		private function sendByOldWebSocket(value:Object):Boolean {
			if (!socket.connected) {
				return false;
			}
			var serialized:String = '';
			if (value is String) serialized = value as String
			else serialized=Tools.json_encode(value);
			
			var bytes:ByteArray = new ByteArray();
			
			bytes.writeByte(0);
			bytes.writeUTFBytes(serialized);
			bytes.writeByte(255);
			socket.writeBytes(bytes);
			socket.flush();
			
			return true;
		}
		
		/**
		 * 摧毁这个客户端
		 */
		public function destroy():void {
			
		}
		
	}

}