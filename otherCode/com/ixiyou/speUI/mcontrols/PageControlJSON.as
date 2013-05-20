package com.ixiyou.speUI.mcontrols 
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	
	import flash.utils.getTimer;
	/**
	 * 页码数据控制器  返回数据格式 JSON
	 * 
	 * 
	 * 方式 post
		参数
		page 第几页 
		search 关键字
		shownum 每页条数
		searchType 搜索类

		返回
		page         当前页码 
		search       搜索关键字
		shownum      每页显示多少个
		allnum       总数据
		searchType   搜索类型

		arr: 单页数据
		{
		'type':0,
		'tip':'网络异常',
		search:,
		page:,
		allnum:,
		shownum:,
		searchType:,
		arr:[
		{'workid':1,'img':'img/1.jgp','userid':50,username:'dsfds',"num":1000,"ranking":29},
		{'workid':1,'img':'img/1.jgp','userid':50,username:'dsfds',"num":1000,"ranking":29}
		]
		}
		
		
		//
		dispatchEvent(new Event('start'))
		dispatchEvent(new Event('upSkin'))
		dispatchEvent(new Event('upData'))
		dispatchEvent(new Event('error'))
		
		//做内部按钮
		pageer = new PageControlJSON(pageBox, true, true, '作品列表',5)
			
		for (i = 0; i <5 ; i++) 
		{
			trace(temp,i)
			temp = pageerBox['mc' + i] as MovieClip
			temp.alpha = 0
			temp.gotoAndStop(1)
			temp.mouseChildren = false
			temp.buttonMode = true
			temp.mouseEnabled=false
		}
		
		//upData
		var arr:Array = pageer.pageData.arr;
			//pageData.now=nowGrounp
			//pageData.arr = arr
			//pageData.state=0
			var item:MovieClip
			for (i = 0; i <5 ; i++) 
			{
				item = pageerBox['mc' + i] as MovieClip
				item.alpha = 0;
				item.gotoAndStop(1)
				var num:Number
				if (arr) {
					if (arr[i]) {
						item.mouseChildren = false
						item.mouseEnabled=true
						item.buttonMode=true
						item.alpha = 1;
						item.label.text = arr[i];
						if (arr[i] == pageer.pageData.now) {
							item.gotoAndStop(2)
							item.mouseEnabled=false
						}
						item.num=arr[i]
						item.addEventListener(MouseEvent.CLICK,pageitemClick)
					}
				}
			}
		//---------------------------
	 * @author
	 */
	public class PageControlJSON extends Sprite 
	{
		//<page search="" page="2" allnum="100" shownum='3' searchType="" />
		/**列表搜索出来关键字**/
		public var search:String = ''
		/**搜索类型**/
		public var searchType:String;
		/**当前页码**/
		public var pagenum:Number = 1
		/**总数据数**/
		public var allnum:Number = 1
		/**每页多少数据**/
		public var shownum:Number = 7
		/**当前页码组*/
		public var nowGrounp:Number
		/**总的页组**/
		public var allGrounp:Number
		//进行交互的页码
		protected var _postDataUrl:String = ''
		public var postRandom:Boolean = false
		public var postRndomType:String='?'
		public var postName:String = ''
		
		//页码显示
		public var page_shownum:uint = 5
		
		//
		public var pageData:Object
		public function PageControlJSON(_skin:Sprite=null,formerly:Boolean=false,parentBool:Boolean=false,postName:String='',_page_shownum:uint=5) 
		{
			page_shownum=_page_shownum
			this.postName=postName
			if (formerly&&_skin) {
				x = _skin.x
				y = _skin.y
				//if(config.parent)config.parent.addChild(this)
			}
			if (_skin&&_skin.parent && parentBool) {
				_skin.parent.addChild(this)
				//this.name=skin.name
			}
			if(_skin)skin=_skin
		}
			
		//皮肤
		protected var _skin:Sprite
		private var alltext:TextField;
		private var pageText:TextField;
		private var firstBtn:InteractiveObject;
		private var lastBtn:InteractiveObject;
		private var previousBtn:InteractiveObject;
		private var nextBtn:InteractiveObject;
		
		/**
		 * 交互的页面地址
		 */
		public function get postDataUrl():String { return _postDataUrl; }
		
		public function set postDataUrl(value:String):void 
		{
			//Math.random()
			_postDataUrl = value;
		}
		/**
		 * 
		 * @param	url
		 * @param	search1
		 * @param	page1
		 * @param	shownum1
		 * @param	searchType1
		 */
		public function post(url:String = '', search1:String = '', page1:Number = 1, shownum1:Number = 3, searchType1:String = ''):void {
			_postDataUrl=url
			postData(search1,page1,shownum1,searchType1)
		}
		/**
		 * 请求加载数据页码
		 * 
		 * @param	page 第几页
		 * @param	search 关键字
		 * @param	shownum 每页条数
		 * @param	searchType 搜索类
		 */
		public function postData(search1:String='',page1:Number=1,shownum1:Number=3,searchType1:String=''):void {
			var obj:Object={}
			obj.search=search1
			obj.searchType=searchType1
			obj.shownum=shownum1
			obj.page = page1
			var url:String = postDataUrl
			if (postRandom) url + postRndomType+'randomData=' + getTimer();
			Tools.postDataUrl(postDataUrl, postBackFun, obj, errorFun)
			DebugOutput.add(postDataUrl, Tools.json_encode(obj))
			dispatchEvent(new Event('start'))
		}
		public var errorInfo:String = '';
		private var _data:Array
		/**
		 * 页码信息
		 * <page search="" page="2" allnum="100" shownum='3' searchType="" />
		 * @param	e
		 */
		private function postBackFun(e:Event):void 
		{
			var loader:URLLoader = e.target as URLLoader;
			var str:String = loader.data as String
			DebugOutput.add('postName 返回数据:' + str)
			var data:Object = Tools.json_decode(loader.data)
			if (!data) {
				//错误，无数据
				DebugOutput.add('postName 判断 json:' + str)
				errorInfo='无数据'
				dispatchEvent(new Event('error'))
			}else if (Number(data.type)==0) {
				//错误,判断
				errorInfo=data.tip
				dispatchEvent(new Event('error'))
				DebugOutput.add('postName 判断 错误:' + str)
			}else {
				//正确
				DebugOutput.add('正确');
				initPageInfo(Number(data.shownum), Number(data.page), Number(data.allnum), data.search, data.searchType)
				_data = data.arr;
			}
			dispatchEvent(new Event('upData'))
			
		}
		/**
		 * 数据
		 */
		public function get data():Array 
		{
			return _data;
		}
		private function errorFun(e:Event):void 
		{
			DebugOutput.add(postName + ': 错误')
			errorInfo='页面打开错误'
			dispatchEvent(new Event('error'))
		}
		
		
		protected function next():void 
		{
			trace('next')
			var num:Number=nowGrounp + 1 
			if (num> this.allGrounp) {
				num=this.allGrounp
			}
			postData(search,num,shownum,searchType)
		}
		protected function previous():void 
		{
			var num:Number=nowGrounp - 1 
			if (num< 1) {
				num=1
			}
			postData(this.search,num,shownum,searchType)
		}
		
		protected function last():void 
		{
			postData(this.search,allGrounp,shownum,searchType)
		}
		
		protected function first():void 
		{
			postData(this.search,1,shownum,searchType)
		}
		
		protected function nextFun(e:MouseEvent):void 
		{
			next()
		}
		
		protected function previousFun(e:MouseEvent):void 
		{
			previous()
		}
		
		protected function lastFun(e:MouseEvent):void 
		{
			last()
		}
		
		protected function firstFun(e:MouseEvent):void 
		{
			first()
		}
		
		/**
		 * 更新皮肤
		 */
		protected function showPanel():void {
			//trace('每页显示:', shownum, '总数据:' + pagenum + "/" + allnum, '页:' + nowGrounp+'/'+allGrounp, '开始数据:', startPage, '结束数据:', endPage)
			if (skin) {
				if(pageText)pageText.text = nowGrounp+'/'+allGrounp
				if(alltext)alltext.text='共'+allnum+''
			}
			pageData = { }
			var arr:Array=new Array()
			pageData.nowGrounp = nowGrounp
			pageData.now=nowGrounp
			pageData.arr = arr
			pageData.state=0
			var tempnum:uint = (page_shownum / 2 >> 0)
			var i:int
			if (nowGrounp > tempnum && nowGrounp <= (allGrounp - tempnum)) {
				trace('s1',page_shownum)
				tempnum = nowGrounp - tempnum
				for (i = tempnum; i < (tempnum+page_shownum) ; i++) 
				{
					if(i<=allGrounp)arr.push(i)
				}
				pageData.state=0
			}else if (nowGrounp < page_shownum ) {
				trace('s2')
				for (i = 1; i < (1+page_shownum) ; i++) 
				{
					if(i<=allGrounp)arr.push(i)
				}
				pageData.state=1
			}else {
				trace('s3')
				tempnum=allGrounp-tempnum
				for (i = tempnum; i <=allGrounp ; i++) 
				{
					if(i<=allGrounp)arr.push(i)
				}
				pageData.state=2
			}
			dispatchEvent(new Event('upSkin'))
		}
		/**
		 * 
		 * 初始化页码数据 工具条
		 * //<page search="" page="2" allnum="100" shownum='3' searchType="" />
		 * @param	shownum1 每页显示多少个
		 * @param	pagenum1 页码
		 * @param	allnum1 总数据数
		 * @param	search1 搜索关键字
		 * @param	searchType1 搜索类型
		 */
		protected function initPageInfo(shownum1:Number=7,pagenum:Number=1,allnum1:Number=1,search1:String='',searchType1:String=''):void {
			
			searchType=searchType1
			search =search1
			//pagenum =pagenum1
			allnum = allnum1
			if (pagenum < 1) pagenum = 1
			if (allnum < 1) allnum=1
			//最多七个页码
			shownum=shownum1
			//在第几页
			nowGrounp =pagenum
			//总页数
			allGrounp = Math.ceil(allnum / shownum)
			if (nowGrounp > allGrounp) nowGrounp = allGrounp
			initPageNumShow()
		}
		/**
		 * 处理页码显示表现
		 */
		protected function initPageNumShow():void {
			var i:int
			//开始数据
			var startPage:uint = (nowGrounp-1) * shownum+1
			//结束数据
			var endPage:uint = nowGrounp * shownum
			if (endPage > allnum) endPage = allnum
			//trace('每页显示:', shownum, '总数据:'  + allnum, '页:' + nowGrounp+'/'+allGrounp, '开始数据:', startPage, '结束数据:', endPage)
			showPanel()
		}
		
		//-------------------------------------------显示相关-----------------------------------
		public function get skin():Sprite { return _skin; }
		
		public function set skin(value:Sprite):void 
		{
			if(skin&&contains(skin))removeChild(skin)
			_skin = value;
			if (!_skin) return;
			if(skin.getChildByName('alltext'))alltext =skin.getChildByName('alltext') as TextField
			if(skin.getChildByName('pageText'))pageText = skin.getChildByName('pageText') as  TextField
			if(skin.getChildByName('firstBtn'))firstBtn = skin.getChildByName('firstBtn') as InteractiveObject
			if(firstBtn)firstBtn.addEventListener(MouseEvent.CLICK,firstFun)
			if(skin.getChildByName('lastBtn'))lastBtn = skin.getChildByName('lastBtn') as InteractiveObject
			if(lastBtn)lastBtn.addEventListener(MouseEvent.CLICK,lastFun)
			if(skin.getChildByName('previousBtn'))previousBtn = skin.getChildByName('previousBtn') as InteractiveObject
			if(previousBtn)previousBtn.addEventListener(MouseEvent.CLICK,previousFun)
			if(skin.getChildByName('nextBtn'))nextBtn = skin.getChildByName('nextBtn') as InteractiveObject
			if(nextBtn)nextBtn.addEventListener(MouseEvent.CLICK,nextFun)
		}
		
		
		//---------------------------------按钮------------------------------
	}

}