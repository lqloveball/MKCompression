package com.ixiyou.geom
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.*;
	import flash.utils.getTimer;
	/**
	 * 页码控制器
	 * 
	 * 	post数据
	 * 
		page 第几页
		search 关键字
		shownum 每页条数
		searchType 搜索类
		--------------------------------------------------------------
		xml 数据
		-------------------------------------------------------------------
		<page search="" page="2" allnum="100" shownum='3' searchType="" />
		page         当前页码 
		search       搜索关键字
		shownum      每页显示多少个
		allnum       总数据
		searchType   搜索类型
		
		例子
		
		pageLister = new PageLister(_pageLister, true, true)
		pageLister.addEventListener('upData',upData)
		pageLister.postDataUrl = 'xml.xml'
		pageLister.postData(1,'',3)
		
		private function upData(e:Event):void 
		{
			
		}
		
	 * 
	 * @author maksim
	 */
	public class PageLister extends Sprite 
	{
		
		
		
		public function PageLister(_skin:Sprite=null,formerly:Boolean=false,parentBool:Boolean=false)
		{
			if (formerly) {
				x = _skin.x
				y = _skin.y
				//if(config.parent)config.parent.addChild(this)
			}
			if (_skin.parent && parentBool) {
				_skin.parent.addChild(this)
				//this.name=skin.name
			}
			if(_skin)skin=_skin
		}
		//<page search="" page="2" allnum="100" shownum='3' searchType="" />
		//列表搜索出来关键字
		protected var search:String = ''
		//搜索类型
		private var searchType:String;
		//当前第一个数据
		protected var pagenum:uint = 1
		//总数据数
		protected var allnum:uint = 1
		//每页多少数据
		protected var shownum:uint = 7
		//当前页码
		protected var nowGrounp:uint
		//总的页
		protected var allGrounp:uint
		//进行交互的页码
		protected var _postDataUrl:String = ''
		public var postRandom:Boolean=false
		
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
		 * 加载后的XML
		 */
		public function get xmlData():XML { return _xmlData; }
		
		/**
		 * 请求加载数据页码
		 * 
		 * @param	page 第几页
		 * @param	search 关键字
		 * @param	shownum 每页条数
		 * @param	searchType 搜索类
		 */
		public function postData(page1:Number=1,search1:String='',shownum1:Number=3,searchType1:String=''):void {
			var obj:Object={}
			obj.search=search1
			obj.searchType=searchType1
			obj.shownum=shownum1
			obj.page = page1
			var url:String = postDataUrl
			if (postRandom) url + '?randomData=' + getTimer();
			Tools.postDataUrl(postDataUrl,postBackFun,obj,errorFun)
		}
		private var _xmlData:XML
		/**
		 * 页码信息
		 * <page search="" page="2" allnum="100" shownum='3' searchType="" />
		 * @param	e
		 */
		private function postBackFun(e:Event):void 
		{
			var xml:XML = XML(URLLoader(e.target).data)
			_xmlData=xml
			var obj:Object = { }
			obj.search=xml.page.@search
			obj.page=xml.page.@page
			obj.allnum=xml.page.@allnum
			obj.shownum=xml.page.@shownum
			obj.searchType=xml.page.@searchType
			initPageInfo(obj.shownum, obj.page, obj.allnum, obj.search, obj.searchType)
			dispatchEvent(new Event('upData'))
		}
		
		private function errorFun():void 
		{
			trace(postDataUrl+'加载page列表数据错误')
		}

		
		protected function next():void 
		{
			var num:Number=nowGrounp + 1 
			if (num> this.allGrounp) {
				num=this.allGrounp
			}
			postData(num,this.search,shownum,searchType)
		}
		protected function previous():void 
		{
			var num:Number=nowGrounp - 1 
			if (num< 1) {
				num=1
			}
			postData(num,this.search,shownum,searchType)
		}
		
		protected function last():void 
		{
			postData(allGrounp,this.search,shownum,searchType)
		}
		
		protected function first():void 
		{
			postData(1,this.search,shownum,searchType)
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
				pageText.text = nowGrounp+'/'+allGrounp
				alltext.text=allnum+''
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
			alltext =skin.getChildByName('alltext') as TextField
			pageText = skin.getChildByName('pageText') as  TextField
			
			firstBtn = skin.getChildByName('firstBtn') as InteractiveObject
			firstBtn.addEventListener(MouseEvent.CLICK,firstFun)
			lastBtn = skin.getChildByName('lastBtn') as InteractiveObject
			lastBtn.addEventListener(MouseEvent.CLICK,lastFun)
			previousBtn = skin.getChildByName('previousBtn') as InteractiveObject
			previousBtn.addEventListener(MouseEvent.CLICK,previousFun)
			nextBtn = skin.getChildByName('nextBtn') as InteractiveObject
			nextBtn.addEventListener(MouseEvent.CLICK,nextFun)
		}
		
		//---------------------------------按钮------------------------------
		
		
	}
	
}