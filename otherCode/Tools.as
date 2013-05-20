package
{

	import com.adobe.serialization.json.*;
	import com.ixiyou.utils.display.ButtonUtil;
	import com.ixiyou.utils.display.MovieUtils;
	import com.ixiyou.utils.text.TextUtil;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	/**
	 * 常用工具
	 * @author spe email:md9yue@@q.com
	 */
	public class Tools
	{
		/**
		 *获取是否 html里面参数配置 
		 * @param mc
		 * @param value
		 * @return 
		 * 
		 */		
		public static function getLoaderInfoParameters(mc:DisplayObject,value:String):String{
			var bool:Boolean=false;
			if (mc.loaderInfo.parameters && mc.loaderInfo.parameters[value] != null && mc.loaderInfo.parameters[value] != '') bool = true;
			if(bool)return mc.loaderInfo.parameters[value]
			return null;
		}
		/**
		 *设置按钮区域 
		 * @param btn
		 * @param hit
		 * 
		 */		
		public static function setHitBtn(btn:Sprite,hit:Sprite):void{
			hit.mouseEnabled=false
			btn.hitArea=hit
		}
		/**
		 * 编译json
		 * @param	value
		 * @return
		 */
		public static function json_decode(value:String):Object {
			var obj:Object = null
			try {
				obj= JSON10.decode(value)
			}
			catch (e:*) {
				DebugOutput.add('JSON decodeError:'+value)
				obj=null
			}
			return obj
		}
		/**
		 * 反编译json
		 * @param	value
		 * @return
		 */
		public static function json_encode(value:Object):String {
			var srt:String = ''
			try {
				srt= JSON10.encode(value)
			}
			catch (e:*) {
				DebugOutput.add('JSON encodeError:'+value)
				srt=''
			}
			return srt
		}
		/**
		 * 使用嵌入字体
		 * @param	text 文本框
		 * @param	fontName 嵌入的字体名称
		 * @param	bool 是否嵌入
		 */
		public static function setEmbedFonts(text:TextField,fontName:String,bool:Boolean=true):void {
			TextUtil.setEmbedFonts(text, fontName, bool);
		}
		/**
		 * 删除嵌入字体
		 */
		public static function removeEmbedFonts(text:TextField):void {
			TextUtil.removeEmbedFonts(text)	
		}
		/**
		 * 带嵌入字体的 CSS
		 * @param	text
		 * @param	sheet
		 * @param	style
		 */
		public static function setEmbedFontsByCSS(text:TextField, sheet:StyleSheet, style:String):void {
			TextUtil.setEmbedFontsByCSS(text,sheet,style)
		}
		/**
		 * 输入最大字符数
		 * @param	text
		 * @param	value
		 */
		public static function setMaxChars(text:TextField, value:int):void {
			TextUtil.setMaxChars(text,value)
		}
		/**
		 * 设置可输入字符可输入字符串
		 * @param	text
		 * @param	restrict "A-Z a-z 0-9"输入英文 空格 数字，"^a-z"不能输入小写英文字符
		 */
		public static function setTxtInData(text:TextField, restrict:String = "A-Z a-z 0-9"):void {
			TextUtil.setTxtInData(text,restrict)
		}
		
		/**
		 * 添加文本背景动画
		 * @param	text
		 * @param	movie 背景动画
		 * @param	move 是否移动时候也有效果
		 */
		public static function addTextMovieBg(text:TextField, movie:MovieClip, move:Boolean = false):void {
			TextUtil.addTextMovieBg(text,movie,move)
		}
		
		/**
		*删除文本背景动画
		*/
		public static function removeTextMovieBg(text:TextField):void {
			TextUtil.removeTextMovieBg(text)
		}
		/**
		 * 设置默认输入
		 * @param	text
		 * @param	value
		 */
		public static function addDefaultInfo(text:TextField, value:String, password:Boolean = false):void {
			TextUtil.addDefaultInfo(text,value,password)
		}
		
		/**
		 * 是否输入
		 * @param	text
		 * @return
		 */
		public static function getDefaultBool(text:TextField):Boolean {
			return TextUtil.getDefaultBool(text)
		}
		/**
		 * 快速设置延迟执行
		 * @param	fun
		 * @param	delay
		 * @param	rest
		 * @return
		 */
		public static function setTimeOut(fun:Function,delay:Number,rest:*=null):uint {
			return setTimeout(fun,delay,rest)
		}
		
		public static function clearTimeOut(value:uint):void {
			clearTimeout(value)
		}
		/**
		 * 设置选择按钮组
		 * @param	arr
		 * @param	select
		 */
		public static function setSelectArr(arr:Array, select:Number = 0):void {
			ButtonUtil.setSelectArr(arr,select)
		}
		/**
		 * 设置选择的按钮
		 * @param	value
		 */
		public  static function setSelectArrByBtn(value:MovieClip):void {
			ButtonUtil.setSelectArrByBtn(value)
		}
		/**
		 * 设置选择按钮
		 * @param	btn
		 * @param	select
		 */
		public static function setSelectBtn(btn:MovieClip, select:Boolean = true):void {
			ButtonUtil.setSelectBtn(btn,select)
		}
		/**
		 * 快速设置按钮
		 * @param	btn
		 * @param	btn_mode
		 */
		public static function setButton(btn:MovieClip, btn_mode:String = '',hitBtn:Boolean=false):MovieClip {
			ButtonUtil.setButton(btn, btn_mode)
			if (hitBtn&&btn&&btn.btn) {
				Tools.setHitBtn(btn,btn.btn)
			}
			return btn
		}
		
		/**
		 * 动画播放控制
		 * @param movie 影片对象
		 * @param value 播放的帧 或着帧的标签
		 * @param endFun 播放结束执行事件
		 *
		 */
		public static function movieFrame(movie:MovieClip, value:*,endFun:Function=null):void{
			MovieUtils.movieFrame(movie,value,endFun);
		}
		/**
		 * 获取帧标签开始帧
		 * @param	movie
		 * @param	value
		 * @return
		 */
		public static function getMovieLabelNum(movie:MovieClip, value:String):uint {
			return MovieUtils.getMovieLabelNum(movie,value)
		}
		/**
		 * 删除动画控制
		 * @param movie
		 *
		 */
		public static function removeMovie(movie:MovieClip):void{
			MovieUtils.removeMovie(movie)
		}
		/**
		 * 编码转换 是否GBK或UTF8
		 * @param	value
		 */
		public static function toGBKUTF8(value:Boolean):void
		{
			System.useCodePage=value;
		}

		/**
		 * js 调用
		 * @param	fun
		 * @param	value
		 */
		public static function callJs(fun:String, value:String):void
		{
			trace('callJs',fun,value)
			if (ExternalInterface.available)
			{
				ExternalInterface.call(fun, value)
			}
		}

		/**
		 *
		 * @param fun
		 * @param value
		 * @param value1
		 */
		public static function callJs2(fun:String, value:String, value1:String):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call(fun, value, value1)
			}
		}

		/**
		 *
		 * @param fun
		 * @param arr
		 */
		public static function callJsArr(fun:String, ... arr):void
		{
			DebugOutput.add('callJsArr:',fun,arr)
			if (ExternalInterface.available)
			{
				if (arr.length == 0)
					ExternalInterface.call(fun)
				if (arr.length == 1)
					ExternalInterface.call(fun, arr[0])
				if (arr.length == 2)
					ExternalInterface.call(fun, arr[0], arr[1])
				if (arr.length == 3)
					ExternalInterface.call(fun, arr[0], arr[1], arr[2])
				if (arr.length == 4)
					ExternalInterface.call(fun, arr[0], arr[1], arr[2], arr[3])
				if (arr.length == 5)
					ExternalInterface.call(fun, arr[0], arr[1], arr[2], arr[3], arr[4])
			}
		}

		/**
		 * 简单数据提交交互
		 */
		public static function getDataUrl(url:String, barkFun:Function, errorFun:Function=null,bytBool:Boolean=false):URLLoader
		{
			var request:URLRequest=new URLRequest(url)
			var loader:URLLoader=new URLLoader()
			if (errorFun == null)
			{
				loader.addEventListener(IOErrorEvent.IO_ERROR, function():void
					{
						trace('提交 ERROR: ' + url + '\n')
					})
			}
			else
			{
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorFun)
			}
			if (bytBool) loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, barkFun)
			loader.load(request)
			return loader
		}

		/**
		 *执行一个连接，不打开
		 * @param url
		 */
		public static function getToURL(url:String):void
		{
			sendToURL(new URLRequest(url))
		}

		/**
		 * 简单数据提交交互
		 */
		public static function postDataUrl(url:String, barkFun:Function, data:Object=null, errorFun:Function=null, contentType:String='application/x-www-form-urlencoded'):URLLoader
		{
			var request:URLRequest=new URLRequest(url)
			request.contentType=contentType
			if (data&&contentType=='application/x-www-form-urlencoded')
			{
				var variables:URLVariables=new URLVariables();
				for (var prop:*in data)
				{
					variables[prop]=data[prop]
				}
				//trace(url,' post>>>: ',variables.toString())
				request.data=variables
			}else if (data && contentType == 'application/octet-stream') {
				request.data=data
			}
			request.method=URLRequestMethod.POST;
			var loader:URLLoader=new URLLoader()
			if (errorFun == null)
			{
				loader.addEventListener(IOErrorEvent.IO_ERROR, function():void
					{
						trace('提交 ERROR: ' + url + '\n')
					})
			}
			else
			{
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorFun)
			}
			loader.addEventListener(Event.COMPLETE, barkFun)
			loader.load(request)
			return loader
		}
		/**
		 * post提交数据
		 * @param	url
		 * @param	barkFun
		 * @param	data
		 * @param	errorFun
		 * @param	contentType
		 * @return
		 */
		public static function postDataUrlByData(url:String, barkFun:Function, data:Object=null, errorFun:Function=null, contentType:String='application/x-www-form-urlencoded'):URLLoader
		{
			var request:URLRequest=new URLRequest(url)
			request.contentType=contentType
			if (data)
			{
				var variables:URLVariables=new URLVariables();
				for (var prop:*in data)
				{
					variables[prop]=data[prop]
				}
				//trace(url,' post>>>: ',variables.toString())
				request.data=variables
			}
			request.method=URLRequestMethod.POST;
			var loader:URLLoader=new URLLoader()
			if (errorFun == null)
			{
				loader.addEventListener(IOErrorEvent.IO_ERROR, function():void
					{
						trace('提交 ERROR: ' + url + '\n')
					})
			}
			else
			{
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorFun)
			}
			loader.addEventListener(Event.COMPLETE, barkFun)
			loader.dataFormat=URLLoaderDataFormat.VARIABLES
			loader.load(request)
			return loader
		}
		/**
		 * 打开窗口
		 * @param	url
		 * @param	window
		 */
		public static function getUrl(url:String, window:String='_blank'):void
		{
			navigateToURL(new URLRequest(url), window)
		}

		/**
		 * 返回交互错误提取
		 * @param	value
		 * @return
		 */
		public static function getNetError(value:String):String
		{
			if (value.indexOf('Error') == 0)
			{
				var num:uint=value.indexOf(':')
				return value.slice(num + 1)
			}
			else
			{
				return 'true'
			}
		}
	}

}