package com.ixiyou.speUI.mcontrols 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap
	import flash.events.IOErrorEvent;
	import flash.net.*
	import flash.events.Event
	import flash.events.ProgressEvent
	import flash.utils.ByteArray;
	
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "progress", type = "flash.events.ProgressEvent")]
	[Event(name = "ioError", type = "flash.events.IOErrorEvent")]
	/**
	 * 快速加载图片器
	 * @author spe email:md9yue@qq.com
	 */
	public class QuickImg extends Sprite
	{
		private var _loader:Loader
		private var _url:String
		private var _loadend:Boolean = false
		private var _plan:Number = 0
		private var completeFun:Function = null
		private var progressFun:Function = null
		private var errorFun:Function = null
		//是否指定大小
		private var _rectBool:Boolean = true
		//大小
		public var rectw:uint = 0
		public var recth:uint = 0
		//缩放
		public var scaleMode:String = 'proportionalInside'
		//剧中
		private var _middle:Boolean = false
		//背景
		public var bgBool:Boolean = false
		public var bgColor:uint=0xffffff
		/**
		 * 构造函数
		 * @param	url 加载地址
		 * @param	completeFun 加载完成事件 传递本对象
		 * @param	progressFun 加载进度 传递本对象
		 * @param	errorFun 加载错误 传递本对象
		 */
		public function QuickImg(url:String = '', confing:Object = null ) 
		{
			if (confing) {
				if (confing.completeFun!=null) this.completeFun = confing.completeFun
				if (confing.onComplete!=null) this.completeFun = confing.onComplete
				if (confing.progressFun!=null) this.progressFun = confing.progressFun
				if (confing.errorFun != null) this.errorFun = confing.errorFun
				if (confing.onError  != null) this.errorFun = confing.onError 
				if (confing.x != null) this.x = confing.x
				if (confing.y != null) this.y = confing.y
				if (confing.width != null) this.rectw = confing.width
				if (confing.height != null) this.recth = confing.height
				if (confing.rectw != null) this.rectw = confing.rectw
				if (confing.recth != null) this.recth = confing.recth
				if (confing.scaleMode != null) this.scaleMode = confing.scaleMode
				if (confing.rectBool != null) this.rectBool = confing.rectBool
				if (confing.bgBool != null) this.bgBool = confing.bgBool
			}
			
			
			if (url != '') {
				load(url)
			}
		}
		/**
		 * 加载进度
		 * @param	e
		 */
		private function progress(e:ProgressEvent):void 
		{
			_loadend = false
			_plan=e.bytesLoaded/e.bytesTotal
			dispatchEvent(e)
			if (progressFun != null) progressFun(this)
			dispatchEvent(e)
		}
		
		/**
		 * 加载错误
		 * @param	e
		 */
		private function error(e:IOErrorEvent):void 
		{
			
			_plan=0
			_loadend = false
			if (errorFun != null) errorFun(this)
			dispatchEvent(e)
		}
		/**
		 * 加载完成
		 * @param	e
		 */
		private function complete(e:Event):void 
		{
			_plan=1
			dispatchEvent(new Event(Event.COMPLETE))
			_loadend = true
			if (loader.content is Bitmap) {
				Bitmap(loader.content).smoothing=true
			}
		
			if (loader.content.width != 0 && loader.content.height != 0) {
				middleFun(null)
			}else {
				loader.addEventListener(Event.ENTER_FRAME,middleFun)
			}
			if (completeFun != null) completeFun(e)
			dispatchEvent(e)
		}
		/**
		 * 加载完成计算布局
		 * @param	e
		 */
		private function middleFun(e:Event=null):void {
			if (loader&&loader.content&&loader.content.width != 0 && loader.content.height != 0) {
				loader.removeEventListener(Event.ENTER_FRAME, middleFun)
					if (middle) {
						loader.x = -loader.width / 2;
						loader.y = -loader.height / 2;
					}
					if (rectBool) {
						var num:Number = 1
						//trace('加载完成计算布局',scaleMode)
						if (scaleMode == 'proportionalInside') {
							///*
							//这个算法是 如果都比容器小，就剧中  太大就压小
							var num1:Number = rectw/loader.content.width
							var num2:Number = recth / loader.content.height
							if (num1 < 1 || num2 < 1) num = Math.min(num1, num2)
							//*/
							
							/*
							//这个算法是 比容器就压缩 比容器太小就拉伸
							var num1:Number = loader.content.width/rectw
							var num2:Number =loader.content.height/rectwh
							if(Math.min(num1,num2)<1&&Math.max(num1,num2)>1){
								num = Math.min(num1, num2)
							}else{
								num1 = rectw/loader.content.width
								num2 = recth / loader.content.height
								num = Math.min(num1, num2)
							}
							*/
							//trace('计算布局',num1,num2,num)
							loader.content.scaleX=loader.content.scaleY=  num
							
							loader.x=(rectw-loader.content.width)/2
							loader.y = (recth - loader.content.height) / 2
							if (bgBool) {
								graphics.clear()
								graphics.beginFill(bgColor)
								graphics.drawRect(0,0,rectw,recth)
							}
						}else {
							if(rectw!=0)loader.content.width = rectw;
							if(recth!=0)loader.content.height = recth;
						}
						
					}
					
			}
		}
		/**
		 * 开始加载
		 * @param	value
		 */
		public function load(value:String):void {
			if (_loader) {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete)
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, error)
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress)
				loader.removeEventListener(Event.ENTER_FRAME,middleFun)
				removeChild(loader)
			}
			_url = value
			_loadend = false
			_loader = new Loader()
			addChild(loader)
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete)
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, error)
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progress)
			var request:URLRequest=new URLRequest(url)
			loader.load(request)
		}
		
		public function loadByteArray(value:ByteArray):void {
			
			if (_loader) {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete)
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, error)
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress)
				loader.removeEventListener(Event.ENTER_FRAME,middleFun)
				removeChild(loader)
			}
			
			_loadend = false
			_loader = new Loader()
			addChild(loader)
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete)
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, error)
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progress)
			
			loader.loadBytes(value)
		}
		/**
		 * 图片地址
		 */
		public function get url():String { return _url; }
		/**
		 * 加载对象
		 */
		public function get loader():Loader { return _loader; }
		/**
		 * 显示对象
		 */
		public function get content():DisplayObject {
				if (loader&&loader.content) {
					return loader.content
				}else {
					return null
				}
		}
		/**
		 * 是否加载完成
		 */
		public function get loadend():Boolean { return _loadend; }
		/**
		 * 进度
		 */
		public function get plan():Number { return _plan; }
		/**
		 * 居中
		 */
		public function get middle():Boolean { return _middle; }
		
		public function set middle(value:Boolean):void 
		{
			_middle = value;
		}
		/**
		 * 加载完成后缩放
		 */
		public function get rectBool():Boolean { return _rectBool; }
		
		public function set rectBool(value:Boolean):void 
		{
			_rectBool = value;
		}
		public function setRect(w:uint, h:uint):void {
			rectw =w
			recth = h
			//middleFun()
		}
		/**
		 * 破坏所有索引，垃圾回收
		 */
		public function destory():void {
			if (loader ) {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete)
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, error)
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,progress)
				if(loadend)loader.unload()
			}
			
		}
		
		
	}

}