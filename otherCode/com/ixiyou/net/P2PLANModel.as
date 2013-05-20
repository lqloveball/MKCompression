package com.ixiyou.net
{
	import com.ixiyou.events.DataSpeEvent;
	import com.ixiyou.utils.ObjectUtil;
	
	import flash.events.*;
	import flash.net.*;

	[Event(name = 'upUserList', type = "flash.events.Event")]
	/**
	 * P2P技术 (目前在局域网测试)
	 *   
	 *   
	    p2p=new P2PLANModel(null,acceptData);
		p2p.connectNC('openFire_SpriteSheetTools');
		p2p.addEventListener('p2pStatus',p2pStatus)
		 
		protected function p2pStatus(event:DataSpeEvent):void
		{
			if(event.data.code=='NetGroup.Neighbor.Connect'){
				
			}
			
		}	
		public function post(value:Object):void {
			p2p.post(value)
		}
		public function acceptData(info:Object):void{
			var value:Object=info.message;
			if(value.appName!=this.appName){
				if(this[value.fun]!=null&&this[value.fun]!=undefined){
					if(value.data!=null)this[value.fun](value.data)
					else this[value.fun]()
				}
			}
		}
	 * 
	 * @author spe email:md9yue@@q.com
	 */
	public class P2PLANModel extends EventDispatcher
	{
		private var _groupSpecifier:GroupSpecifier;
		private var _nc:NetConnection;
		private var _ncConnectBool:Boolean=false;
		private var _group:NetGroup;
		private var _groupName:String;
		private var _groupAddress:String;
		private var _userNearIDList:Array
		public var acceptData:Function=null
		public function P2PLANModel(nc:NetConnection=null,_acceptData:Function=null)
		{
			if(nc)this.nc=nc
			else this.nc=new NetConnection();
			if(_acceptData!=null)acceptData=_acceptData;
		}



		/**
		 * 关闭group连接
		 */
		public function groupClose():void {
			if(group)group.close()
			clearUserNearIDList()
		}

		/**
		 *关闭nc连接
		 *
		 */
		public function ncClose():void {
			if(nc)nc.close()
		}
		/**
		 *  发送数据
		 * @param	value
		 */
		public function post(value:Object):String {
			if(group)return group.post(value);
			return null
		}
		/**
		 * 连接
		 * @param name 连接的组名
		 * @param address 连接的地址端口 具体看帮助
		 * @param value 连接的地址
		 * @param ncValue 是否设置NC对象
		 *
		 */
		public function connectNC(name:String='mdP2P',serverUrl:String='rtmfp:',address:String='225.225.0.1:30303',ncValue:NetConnection=null):void {

			if (group) {
				group.close()
				group.removeEventListener(NetStatusEvent.NET_STATUS,p2pStatus );
			}
			setGroupSpecifier(name, address);
			if(ncValue!=null)nc=ncValue
			_ncConnectBool=false
			nc.connect(serverUrl);
		}
		/**
		 * 连接组
		 * @param	name
		 * @param	address
		 */
		public function connectGroup(name:String='mdP2P',address:String='225.225.0.1:30303'):void{
			if(!ncConnectBool)return;
			setGroupSpecifier(name, address);
			autoGroup()
		}
		/**
		 * nc事件  但组连接成也在这个里面
		 */
		private function ncStatus(e:NetStatusEvent):void {
			var info:Object = e.info
			DebugOutput.push('p2p','ncStatus:'+info.code)
			switch(info.code) {
			
				
				case "NetConnection.Connect.Success":
					_ncConnectBool=true
					autoGroup();
				break;
				
				case "NetGroup.Connect.Success":
					DebugOutput.push('p2p','连接P2P组成功')
				break;
				case "NetGroup.Connect.Closed":
					DebugOutput.push('p2p','断开P2P组')
				break;
				case "NetGroup.Connect.Failed":
					DebugOutput.push('p2p','NetGroup 连接尝试失败。info.group 属性指示哪些 NetGroup 已失败。')
				break;
				case "NetGroup.Connect.Rejected":
					DebugOutput.push('p2p','NetGroup 没有使用函数的权限。info.group 属性指示哪些 NetGroup 被拒绝。')
				break;
				
				
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.InvalidApp":
				case "NetConnection.Connect.Rejected":
					_ncConnectBool = false
					//关闭NC时候，组也会被关闭
					clearUserNearIDList();
				break;
			}
			dispatchEvent(new DataSpeEvent('ncStatus',info))
			info=null
		}
		/**
		 * P2P连接事件
		 * @param	event
		 */
		private function p2pStatus(e:NetStatusEvent):void {
			var info:Object = e.info
			//DebugOutput.add('p2pStatus:', info.code)
			switch(info.code){
				case "NetGroup.LocalCoverage.Notify":
					DebugOutput.push('p2p','此节点负责的组地址空间的一部分发生更改时发送。')
				break;

				case "NetGroup.Neighbor.Connect":
					//var nncStr:String = '有邻居连接上\n'
					//nncStr=nncStr+'用户数：'+group.neighborCount +'\n'
					//nncStr = nncStr + '我自己标识nearID:' + nc.nearID +'\n'
					//nncStr = nncStr + '新连接标识peerID:' + info.peerID + '\n'
					//nncStr = nncStr + '邻域的组地址 neighbor:' + info.neighbor + '\n-------------------------------------'
					//group.post('用户数:'+group.neighborCount)
					//DebugOutput.add(nncStr)
					addUserNearIDList(info.peerID)
				break;
				case "NetGroup.Neighbor.Disconnect":
					//var nncStr1:String = '有邻居断开\n'
					//nncStr1=nncStr1+'用户数：'+group.neighborCount +'\n'
					//nncStr1 = nncStr1 + '我自己标识nearID:' + nc.nearID +'\n'
					//nncStr1 = nncStr1 + '断开开标识peerID:' + info.peerID + '\n'
					//nncStr1 = nncStr1 +'邻域的组地址 neighbor:'+info.neighbor+'\n--------------------------------------'
					//DebugOutput.add(nncStr1)
					removeUserNearIDList(info.peerID)
				break;

				case "NetGroup.Posting.Notify":
					//DebugOutput.add('当收到新的 Group Posting 时发送。info.message:Object 属性是消息。info.messageID:String 属性是消息的 messageID。')
					//DebugOutput.add( 'Group Posting>> '+info.messageID+':'+info.message)
					if(acceptData!=null)acceptData(info)
				break;
				case "NetGroup.Replication.Fetch.Failed":
					//当提取对象请求（之前已使用 NetGroup.Replication.Fetch.SendNotify 进行通知）失败或被拒绝时发送。如果仍需要此对象，则将重新尝试提取对象。info.index:Number 属性是已请求的对象的索引。
					DebugOutput.push('p2p','NetGroup.Replication.Fetch.Failed')
					break;
				case "NetGroup.Replication.Fetch.Result":
					DebugOutput.push('p2p','NetGroup.Replication.Fetch.Result')
					break;
				case "NetGroup.Replication.Fetch.SendNotify":
					DebugOutput.push('p2p','当 Object Replication 系统即将向邻域发送对象请求时发送。info.index:Number 属性是请求的对象的索引。')
					break;
				case "NetGroup.Replication.Request":
					DebugOutput.push('p2p','NetGroup.Replication.Request')
					break;
				case "NetGroup.SendTo.Notify":
					DebugOutput.push('p2p','NetGroup.SendTo.Notify')
					break;
			}
			dispatchEvent(new DataSpeEvent('p2pStatus', info));
			info=null
		}
		
		
		
		
		/**
		 * nc连接后主动连接进行P2P组连接
		 */
		private function autoGroup():void
		{
			if(!ncConnectBool)return;
			//groupSpecifier.groupspecWithAuthorizations()
			DebugOutput.push('p2p','进行P2P组连接>>');
			if(group)group.removeEventListener(NetStatusEvent.NET_STATUS,p2pStatus);
			clearUserNearIDList()
			_group = new NetGroup(nc,groupSpecifier.groupspecWithAuthorizations());
			group.addEventListener(NetStatusEvent.NET_STATUS,p2pStatus);
		}
		/**
		 * 设置P2P组 信息规格
		 * @param	name p2p组名
		 * @param	address
		 */
		public function setGroupSpecifier(name:String='mdP2P',address:String="225.225.0.1:30303"):void
		{
			_groupName = name
			_groupAddress=address;
			_groupSpecifier = new GroupSpecifier(name);
			_groupSpecifier.postingEnabled = true;
			_groupSpecifier.ipMulticastMemberUpdatesEnabled = true;
			_groupSpecifier.multicastEnabled =true;
			_groupSpecifier.serverChannelEnabled=true
			_groupSpecifier.addIPMulticastAddress(address);
		}
		/**
		 * 组信息 GroupSpecifier对象
		 */
		public function get groupSpecifier():GroupSpecifier { return _groupSpecifier; }
		/**
		 * 连接对象
		 */
		public function get nc():NetConnection { return _nc; }
		public function set nc(value:NetConnection):void{
			if (nc) nc.removeEventListener(NetStatusEvent.NET_STATUS, ncStatus);
			if(value)_nc=value
			else _nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, ncStatus);
			_ncConnectBool=false
			groupClose()
		}
		/**
		 * 组
		 */
		public function get group():NetGroup { return _group; }
		/**
		 * 组名
		 */
		public function get groupName():String { return _groupName; }
		/**
		 * 组地址
		 */
		public function get groupAddress():String { return _groupAddress; }
		/**
		 * nc是否连接
		 * @return
		 *
		 */
		public function get ncConnectBool():Boolean
		{
			return _ncConnectBool;
		}
		/**
		 * 你的 唯一标识
		 * @return
		 *
		 */
		public function get nearID():String
		{
			if(!nc||!nc.nearID)return ''
			return nc.nearID;
		}
		/**
		 *用户
		 * @return
		 *
		 */
		public function get userNearIDList():Array
		{
			return _userNearIDList;
		}
		/**
		 *是否在用户组列表中
		 * @return
		 *
		 */
		public function inUserNearIDList(value:String):Boolean{
			if(!userNearIDList)return false;
			for (var i:int = 0; i < userNearIDList.length; i++)
			{
				if(value==userNearIDList[i])return true;
			}
			return false;
		}
		/**
		 * 组成员数
		 * @return
		 *
		 */
		public function get neighborCount():Number{
			if(group)return group.neighborCount
			return 0
		}
		/**
		 * 添加用户
		 * @param value
		 *
		 */
		public function addUserNearIDList(value:String):void{
			if(!userNearIDList)_userNearIDList=new Array();
			userNearIDList.push(value);
			dispatchEvent(new Event('upUserList'));
			//trace('addUser')
			dispatchEvent(new DataSpeEvent('addUser',value))
		}
		/**
		 * 删除用户
		 * @param value
		 *
		 */
		public function removeUserNearIDList(value:String):String{
			if(!userNearIDList)return ''
			for (var i:int = 0; i < userNearIDList.length; i++)
			{
				if(value==userNearIDList[i]){
					var user:String=userNearIDList.splice(i,1);
					dispatchEvent(new Event('upUserList'));
					dispatchEvent(new DataSpeEvent('removeUser',user))
					return user;
				}
			}
			return ''
		}
		public function clearUserNearIDList():void{
			if(userNearIDList){
				_userNearIDList=null;
				dispatchEvent(new Event('upUserList'))
				dispatchEvent(new DataSpeEvent('clearUserList'))
			}
		}

	}

}