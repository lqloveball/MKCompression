package com.ixiyou.net
{
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	/**
	 * P2P 视频流技术 (目前在局域网测试)
	 * @author spe email:md9yue@@q.com
	 */
	public class P2PStream extends EventDispatcher
	{
		private var _nc:NetConnection;
		private var _ncConnectBool:Boolean;
		private var _stream:NetStream
		private var _camera:Camera;
		private var _mic:Microphone;
		private var _clinetStream:NetStream;
		private var _publishName:String='mediac'
		public function P2PStream()
		{
			
		}
		private function showOmsg(msg:String):void
		{
		}
		private function onPeerConnect(tmpNS:NetStream):void
		{
			DebugOutput.add('有人连接我:'+tmpNS.farID)
		}
		/**
		 * 客户端视频流数据
		 * @param	msg
		 */
		private function clinetShowOmsg(msg:String):void {
			
		}
		
		/**
		 * 连接发布视频
		 * @param	value 发布视频的名字
		 * @param	peerID 发布视频的 方式地址  默认null，进行1对1的视频连接，  peerID是一个GroupSpecifier对象时候就获取播放组里视频， 当然也能传制定字符串地址
		 * @param	playType 发布的方式 
		 */
		public function publishStream(value:String='mediac',peerID:*=null,playType:String='live'):void {
			if (!nc) return
			if (_stream)_stream.client = null;
			
			DebugOutput.add( '开始连接传播自己的视频：',_publishName,camera,mic)
			_publishName=value;
			if(peerID&&peerID is GroupSpecifier){
				_stream = new NetStream(nc,GroupSpecifier(peerID).groupspecWithAuthorizations());
			}
			else _stream = new NetStream(nc,NetStream.DIRECT_CONNECTIONS);
			_stream.client = this;
			if (camera)
			{
				stream.attachCamera(camera);
			}
			if (mic)
			{
				stream.attachAudio(mic);
			}
			stream.publish(publishName, playType);
		}
		
		
		 /**
		  * 连接别人视频
		  * @param	videoName 视频的名称
		  * @param	peerID 默认null，进行1对1的视频连接，  peerID是一个GroupSpecifier对象时候就获取播放组里视频， 当然也能传制定字符串地址
		  * @param	video
		  */
		public function connectClinetStream(videoName:String='mediac',peerID:*=null,video:Video=null):void
		{
			if (!nc) return;
			if (clinetStream) clinetStream.client = new Object();
			
			if(peerID&&peerID is GroupSpecifier){
				_clinetStream = new NetStream(nc,GroupSpecifier(peerID).groupspecWithAuthorizations());
			}
			else if(peerID is String) _clinetStream = new NetStream(nc,peerID);
			else  _clinetStream = new NetStream(nc)
			
		
			var obj:Object=new Object()
			clinetStream.client=obj
			obj.showOmsg = this.clinetShowOmsg;
			if(video)video.attachNetStream(clinetStream);
			clinetStream.play(videoName);
		}
		
		/**
		 * 连接对象
		 */
		public function get nc():NetConnection { return _nc; }
		public function set nc(value:NetConnection):void{

			if(value)_nc=value
			else _nc = new NetConnection();
		}
		


		/**
		 * 视频流对象
		 */
		public function get stream():NetStream { return _stream; }
		/**
		 * 摄像头
		 */
		public function set camera(value:Camera):void 
		{
			
			if (!value)_camera = Camera.getCamera();
			else _camera = value;
			if (camera)
			{
				camera.setMode(320,240,10);
				camera.setQuality(0,90);
			}
			else
			{
				DebugOutput.add("你没有摄像头",1);
			}
		}
		public function get camera():Camera { return _camera; }
		/**
		 * 麦克风
		 */
		public function set mic(value:Microphone):void 
		{
			if (!value) {
				mic = Microphone.getMicrophone();
				_mic.rate = 44;
				_mic.setSilenceLevel(0, 1000);
				_mic.setLoopBack(true);
				_mic.setUseEchoSuppression(true);
			}
			else _mic = value;
			if (!mic)DebugOutput.add("你没有麦克风!",1);
		}
		public function get mic():Microphone { return _mic; }
		//连接别时候使用的视频流
		public function get clinetStream():NetStream { return _clinetStream; }
		/**
		 * 发布的名字
		 */
		public function get publishName():String { return _publishName; }
		
	}
}