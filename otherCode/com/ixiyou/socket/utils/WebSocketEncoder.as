/**
 * https://github.com/shove/as3ws
 */
package com.ixiyou.socket.utils
{

	
	import flash.utils.ByteArray;
	


	public class WebSocketEncoder
	{

		public static function encode(message:String):ByteArray {
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(message);
			data.position = 0;
			
			var buffer:ByteArray = new ByteArray();
			buffer.writeByte(0x80 | WebSocketOps.TEXT_FRAME);
			
			if(data.length > 125) {
				if(data.length < 65536) {
					buffer.writeByte(126 | 0x80);
					buffer.writeShort(data.length);
				} else {
					return null;
				}
			} else {
				buffer.writeByte(data.length | 0x80);
			}
			
			/*这里是进行加key
			var key:uint = Math.floor(Math.random() * uint.MAX_VALUE);
			buffer.writeUnsignedInt(key);
			for(var i:uint = 0; i < data.length;i++) {
				data[i] = (data[i] ^ (key >>> ((3 - (i % 4)) * 8)));
			}
			*/
			buffer.writeBytes(data);
			buffer.position = 0;
			
			return buffer;
		}
	}
}