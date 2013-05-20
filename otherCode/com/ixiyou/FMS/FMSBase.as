package com.ixiyou.FMS 
{
	
	/**
	 *fms 底层
	 * 
		fmsClient=new FmsClient();
		fmser=new FMSBase(fmsClient);
		fmser.addEventListener(FmsEvent.LINK_START,linkStart);
		fmser.addEventListener(FmsEvent.LINK_SUCCESS,linkOk);
		fmser.addEventListener(FmsEvent.LINK_CLOSE,linkClose);
		fmser.addEventListener(FmsEvent.LINK_REJECTED,linkRejected);
		fmser.addEventListener(FmsEvent.LINK_FAILED,linkError);
		fmser.addEventListener(FmsEvent.LINK_RETRY,linkRetry);
		fmsClient.addEventListener(FmsEvent.FMS_CALL,fmsCall);
	 * @author 
	 */
	import com.ixiyou.FMS.FmsClient;
	import com.ixiyou.FMS.IFMSClient;
	import com.ixiyou.FMS.events.FmsEvent;
	
	import flash.events.*;
	import flash.net.*;

	public class FMSBase extends EventDispatcher
	{
		
		/*--------------------Event Type Start-------------------------------------*/
		//public static var LINK_START:String="linkStart"//开始连接
		//public static var LINK_SUCCESS:String="Success"//连接成功
		//public static var LINK_FAILED:String="Failed"//网络错未能连接上
		//public static var LINK_CLOSENO:String="CloseNo"//未登录过后的断开
		//public static var LINK_CLOSED:String="Closed"//曾经登录过后的断开
		//public static var LINK_REJECTED:String = "Rejected"//服务器拒绝连接
		//服务器拒绝连接
		//public static var LINK_REJECTED_MSG:String = "Rejected_msg"
		//执行重新连接命令
		//public static var LINK_RETRY:String="Retry"
		//public static var LINK_CLOSE:String="Close"//close命令执行的关闭
		/*--------------------Event Type End-------------------------------------*/
		public var name:String='FMSServer';
		//曾经连接通
		private var atOneTime:Boolean;
		//FMS连接
		private var _nc:NetConnection
		//服务器链接情况状况
		private var _ncCode:String;
		//第一次连接
		private var _linkBool:Boolean;
		//重连次数
		private var retryConnectNum:uint = 0;
		//临时存储的传输变量
		private var _linkValue:Object;
		//临时存储的链接地址；
		private var _server:String;
		// 拒绝错误信息
		private var _rejectedStr:String;
		//客户端
		private var _client:IFMSClient;
		/**
		 * 构造函数
		 */
		public function FMSBase(value:IFMSClient = null) {
			_nc = new NetConnection();
			_nc.addEventListener(NetStatusEvent.NET_STATUS, ncStatus);
			_nc.addEventListener(IOErrorEvent.IO_ERROR,IO_ERROR)
			if (value != null) client = value
			else client =new FmsClient()
			
		}
		/**
		 * 错误
		 * @param	e
		 */
		public function IO_ERROR(e:IOErrorEvent):void {
			trace('fms io error')
		}
		/*重新连接FMS
		 * */
		public function retryConnect():void{
			trace("重新连接FMS...")
			retryConnectNum+=1
			if(retryConnectNum>5) return 
			connect(_server,_linkValue)
			dispatchEvent(new FmsEvent(FmsEvent.LINK_RETRY))
		}
		/*连接FMS服务器
		 * */
		public function connect(server:String="rtmp://localhost/test/",value:Object=null,Encoding:uint=3) :void
		{
			trace('开始连接FMS:'+server,value)
			_linkBool = false
			atOneTime=false
			_linkValue=value
			_server=server
			if(!nc.objectEncoding)nc.objectEncoding = Encoding;
			if (value== null) nc.connect(_server)
			else nc.connect(_server,_linkValue)
			dispatchEvent(new FmsEvent(FmsEvent.LINK_START))
		}
		/*连接状态监听
		 * 
		 */
		private function ncStatus(obj:NetStatusEvent):void 
		{
			_ncCode = obj.info.code//nc对象状态
			trace(_ncCode)
			switch (_ncCode) {
				case "NetConnection.Connect.Success" :
					atOneTime = true
					retryConnectNum=0
					trace("FMS服务器链接成功")	
					this.dispatchEvent(new FmsEvent(FmsEvent.LINK_SUCCESS))
					break;
				case "NetConnection.Connect.Failed" :					
					trace("FMS未能连接上服务器,请检查网络")
					this.dispatchEvent(new FmsEvent(FmsEvent.LINK_FAILED))
					break;
				case "NetConnection.Connect.Rejected" :
					trace("服务器拒绝链接，原因:" + obj.info);
					dispatchEvent(new FmsEvent(FmsEvent.LINK_REJECTED,obj.info.application))
					break;
				case "NetConnection.Connect.Closed" :
					if (atOneTime) {
						//trace("FMS服务器断开链接:曾经登录过")
						this.dispatchEvent(new FmsEvent(FmsEvent.LINK_CLOSED))
						//dispatchEvent(new FmsEvent(FmsEvent.LINK_CLOSE))
					}else{
						//trace("FMS服务器断开链接:未登录过")
						this.dispatchEvent(new FmsEvent(FmsEvent.LINK_CLOSENO))
						//dispatchEvent(new FmsEvent(FmsEvent.LINK_CLOSE))
					}
					close()
					break;
				default:
					break;
				
			}
		}
		/**
		 * 设置客户端
		 */
		public function set client(value:IFMSClient):void {
			if (_client == value) return
			_client = value
			nc.client=_client
			_client.fmsBase=this
		}
		/**
		 * 客户端
		 */
		public function get client():IFMSClient { return _client; }
		/**
		 * 作为重新连接使用
		 */
		public function get linkValue():Object { return _linkValue; }
		/**
		 * 拒绝连接原因
		 */
		public function get rejectedStr():String { return _rejectedStr; } 
		/**
		 * FMS连接对象
		 */
		public function get nc():NetConnection  { return _nc; }
		/**
		 * 服务器链接情况状况
		 */
		public function get ncCode():String { return _ncCode; }
	
		/**
		 * 关闭
		 * @param isClient 是否客户端自己关闭
		 * 
		 */		
		public function close(isClient:Boolean=false):void{
			//if (nc.connected) nc.close()
			nc.close()
			trace("FMS服务器链接断开:执行断开命令 是否录过:"+atOneTime)	;
			dispatchEvent(new FmsEvent(FmsEvent.LINK_CLOSE));
			
			//区别对待 关闭是否是自身关闭行为
			if(isClient)dispatchEvent(new FmsEvent(FmsEvent.LINK_CLIENT_CLOSE,{login:atOneTime}))
			else dispatchEvent(new FmsEvent(FmsEvent.LINK_SERVER_CLOSE,{login:atOneTime}))
			
		}
		/**
		 * 调用服务器方法 
		 * @param funName fms服务器的方法名
		 * @param value 参数
		 * @param result 调用成功后方法
		 * @param error  调用错误后方法
		 * 
		 */		
		public function callFmsByName(funName:String,value:*=null,result:Function=null,error:Function=null):void{
			if(result==null){
				result=callFmsResult
			}
			if(error==null){
				error=callFmsError
			}
			var responder:Responder=new Responder(result,error);
			nc.call(funName,responder,value);
		}
		
		/**
		 * 调用服务器callFms方法 
		 * @param value 参数
		 * @param result 调用成功后方法
		 * @param error  调用错误后方法
		 * 
		 */		
		public function callFms(value:*=null,result:Function=null,error:Function=null):void{
			callFmsByName('callFms',value,result,error);
		}
		
		/**
		 * 调用fms方法成功
		 * @param value
		 * 
		 */		
		private function callFmsResult(value:*):void{
			DebugOutput.add(this.name+" 调用服务器方法成功:")
		}
		/**
		 * 调用fms方法错误 
		 * @param value
		 * 
		 */		
		private function callFmsError(value:*):void{
			DebugOutput.add(this.name+" 调用服务器方法错误:",Tools.json_encode(value))
		}
	}
	
}