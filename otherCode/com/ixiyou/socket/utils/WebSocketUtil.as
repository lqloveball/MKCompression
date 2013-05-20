package com.ixiyou.socket.utils
{
	//import by.blooddy.crypto.MD5;
	import com.adobe.crypto.MD5;
	import com.adobe.crypto.SHA1;
	import com.dynamicflash.util.Base64;
	import com.ixiyou.socket.Client;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author maskim
	 */
	public class WebSocketUtil
	{
		
		/**
		 * 判断客户端是否 WebSocket
		 * @param	socket
		 * @param	socketBytes
		 * @return
		 */
		public static function isHtml5WebSocket(socket:Socket, socketBytes:ByteArray):*
		{
			try
			{
				var message:String = socketBytes.readUTFBytes(socketBytes.bytesAvailable);
			}
			catch (error:Error)
			{
				return null
			}
			//消息属于握手协议
			if (message.indexOf("GET ") == 0)
			{
				trace('实现webSocket握手');
				//协议
				var fields:Object = getWebSocketAgreement(message)
				var requestedURL:String = "";
				if (fields.requestedURL)
					requestedURL = fields.requestedURL
				var i:uint
				
				var protocol:uint = 0
				if (fields["Sec-WebSocket-Version"] != null)
				{
					//有Sec-WebSocket-Version版本号的握手
					protocol = uint(fields["Sec-WebSocket-Version"]);
				}
				else
				{
					//旧的WebSocket握手协议
					protocol = 0;
				}
				switch (protocol)
				{
					case 0: 
						//sendHybi00Response(fields, requestedURL);
						return handshakeProtocol0(fields, socket,socketBytes);
						break;
					case 8: 
						return handshakeProtocol13(fields, socket);
						break;
					case 13: 
						return handshakeProtocol13(fields, socket);
						break;
					default: 
						socket.close();
						return null;
						break;
				}
				return null
			}
			else
			{
				//属于接受到消息
			}
			return null;
		}
		
		
		protected static function handshakeProtocol13(fields:Object, socket:Socket):String
		{
			//var websocketKey:String = "dGhlIHNhbXBsZSBub25jZQ==";//test
			var websocketKey:String = fields["Sec-WebSocket-Key"];
			
			var guid:String = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
			var hash:String = websocketKey + guid;
			hash = SHA1.hash(hash);
			
			var hashBytes:ByteArray = new ByteArray();
			for(var i:uint = 0; i < hash.length; i += 2)
			{
				hashBytes.writeByte(parseInt(hash.substr(i, 2), 16));
			}
			hash = Base64.encodeByteArray(hashBytes);
			var response:String = "HTTP/1.1 101 Switching Protocols\r\n" +
				"Upgrade: websocket\r\n" +
				"Connection: Upgrade\r\n" +
				"Sec-WebSocket-Accept: " + hash + "\r\n" +
				"\r\n";
			
			var responseBytes:ByteArray = new ByteArray();
			responseBytes.writeUTFBytes(response);
			responseBytes.position = 0;
			socket.writeBytes(responseBytes);
			socket.flush();
			return Client.WEB_SOCKET;
		}
		/**
		 * 进握手协议 版0
		 * @param	fields
		 * @param	socket
		 * @return
		 */
		public static function handshakeProtocol0(fields:Object, socket:Socket,socketBytes:ByteArray):String {
			var result:* = fields["Sec-WebSocket-Key1"].match(/[0-9]/gi);
			var key1Nr:uint = (result is Array) ? uint(result.join("")) : 1;
			result = fields["Sec-WebSocket-Key1"].match(/ /gi);
			var key1SpaceCount:uint = (result is Array) ? result.length : 1;
			var key1Part:Number = key1Nr / key1SpaceCount;
			
			result = fields["Sec-WebSocket-Key2"].match(/[0-9]/gi);
			var key2Nr:uint = (result is Array) ? uint(result.join("")) : 1;
			result = fields["Sec-WebSocket-Key2"].match(/ /gi);
			var key2SpaceCount:uint = (result is Array) ? result.length : 1;
			var key2Part:Number = key2Nr / key2SpaceCount;
			
			//calculate binary md5 hash
			var bytesToHash:ByteArray = new ByteArray();
			
			bytesToHash.writeUnsignedInt(key1Part);
			bytesToHash.writeUnsignedInt(key2Part);
			bytesToHash.writeBytes(socketBytes, socketBytes.length - 8);
			
			
			var bytesToHashStr:String=bytesToHash.readUTFBytes(bytesToHash.bytesAvailable)
			//hash it
			var hash:String = MD5.hash(bytesToHashStr);
			
			var response:String = "HTTP/1.1 101 WebSocket Protocol Handshake\r\n" +
				"Upgrade: WebSocket\r\n" +
				"Connection: Upgrade\r\n" +
				"Sec-WebSocket-Origin: " + fields["Origin"] + "\r\n" +
				"Sec-WebSocket-Location: ws://" + fields["Host"] + fields.requestedURL + "\r\n" +
				"\r\n";
			var responseBytes:ByteArray = new ByteArray();
			responseBytes.writeUTFBytes(response);
			for(var i:uint = 0; i < hash.length; i += 2)
			{
				responseBytes.writeByte(parseInt(hash.substr(i, 2), 16));
			}
			
			responseBytes.writeByte(0);
			responseBytes.position = 0;
			socket.writeBytes(responseBytes);
			socket.flush();
			socketBytes.clear();
			return Client.WEB_SOCKET_OLD;
		}
		/**
		 * 获取WebSocket握手协议对象
		 * @param	message
		 * @return
		 */
		private static function getWebSocketAgreement(message:String):Object
		{
			var messageLines:Array = message.split("\n");
			var fields:Object = {};
			var requestedURL:String = "";
			var line:String
			var index:int
			var getSplit:Array
			var key:String
			var i:uint
			for (i = 0; i < messageLines.length; i++)
			{
				line = messageLines[i];
				if (i == 0)
				{
					getSplit = line.split(" ");
					if (getSplit.length > 1)
						requestedURL = getSplit[1];
				}
				else
				{
					index = line.indexOf(":");
					if (index > -1)
					{
						key = line.substr(0, index);
						fields[key] = line.substr(index + 1).replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
					}
				}
				line = messageLines[i];
				if (i == 0)
				{
					getSplit = line.split(" ");
					if (getSplit.length > 1)
					{
						requestedURL = getSplit[1];
					}
				}
				else
				{
					index = line.indexOf(":");
					if (index > -1)
					{
						key = line.substr(0, index);
						fields[key] = line.substr(index + 1).replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
					}
				}
			}
			fields.requestedURL = requestedURL;
			//trace(Tools.json_encode(fields),requestedURL)
			return fields;
		}
	}

}