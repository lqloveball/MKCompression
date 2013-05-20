package com.ixiyou.utils.text 
{

	import com.ixiyou.net.FontsLoader;
	import com.ixiyou.utils.StringUtil;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.Dictionary;
	import com.ixiyou.utils.display.MovieUtils

	/**
	 * 文本常用处理器
	 * @author spe email:md9yue@qq.com
	 */
	public class TextUtil
	{
		/**
		 * 获取文本宽度 
		 * @param value
		 * @return 
		 * 
		 */		
		public static function getTextWidth(value:TextField):Number{
			//var w:Number=value.width;
			//value.width=3000
			var rect:Rectangle
			if(value.text.length>0)rect= value.getCharBoundaries(value.text.length-1);
			//trace(rect,value.text.length)
			//value.width
			if(rect)return rect.x+rect.width 
			return 0;
			
		}
		/**
		 * 输入最大字符数
		 * @param	text
		 * @param	value
		 */
		public static function setMaxChars(text:TextField, value:int):void {
			text.maxChars = value;
		}
		/**
		 * 设置可输入字符可输入字符串
		 * @param	text
		 * @param	restrict "A-Z a-z 0-9"输入英文 空格 数字，"^a-z"不能输入小写英文字符
		 */
		public static function setTxtInData(text:TextField,restrict:String="A-Z a-z 0-9"):void {
			text.restrict=restrict
		}
		/**
		 * 默认输入背景字典
		 */
		private static var textInPutBgDic:Dictionary = new Dictionary()
	
		/**
		 * 添加文本背景动画
		 * @param	text
		 * @param	movie 背景动画
		 * @param	move 是否移动时候也有效果
		 */
		public static function addTextMovieBg(text:TextField, movie:MovieClip,move:Boolean=false):void {
			if (textInPutBgDic[text] == null) {
				textInPutBgDic[text]={text:text,movie:movie,move:move,focus:false}
			}else {
				textInPutBgDic[text].text = text
				textInPutBgDic[text].movie = movie
				textInPutBgDic[text].move = move
				textInPutBgDic[text].focus=false
			}
			text.type = 'input'
			text.addEventListener(FocusEvent.FOCUS_IN, inPutFocusIn)
			text.addEventListener(FocusEvent.FOCUS_OUT, inPutFocusOut)
			text.addEventListener(MouseEvent.MOUSE_OVER, inPutFocusOVER)
			text.addEventListener(MouseEvent.MOUSE_OUT,inPutFocusOUT)
		}
		
		static private function inPutFocusOUT(e:MouseEvent):void 
		{
			var text:TextField = e.target as TextField
			var movie:MovieClip
			var move:Boolean
			if (textInPutBgDic[text] != null) {
				movie = textInPutBgDic[text].movie as MovieClip
				
				
				move = textInPutBgDic[text].move
				if (move) {
					if (movie) {
						if (textInPutBgDic[text].focus) {
							MovieUtils.movieFrame(movie,movie.totalFrames)
							//movie.gotoAndStop(2)
						}
						else {
							MovieUtils.movieFrame(movie,1)
							//movie.gotoAndStop(1)
						}
					}else {
						removeTextMovieBg(text)
					}
				}
				
			}
		}
		
		static private function inPutFocusOVER(e:MouseEvent):void 
		{
			var text:TextField = e.target as TextField
			var movie:MovieClip
			var move:Boolean
			if (textInPutBgDic[text] != null) {
				movie = textInPutBgDic[text].movie as MovieClip
				move = textInPutBgDic[text].move
				if (move) {
					if (movie) {
						MovieUtils.movieFrame(movie,movie.totalFrames)
						//movie.gotoAndStop(2)
					}else {
						removeTextMovieBg(text)
					}
				}
				
			}
		}
		/**
		*删除文本背景动画
		*/
		public static function removeTextMovieBg(text:TextField):void {
			if (textInPutBgDic[text] != null) {
				textInPutBgDic[text]=null
			}
			text.removeEventListener(FocusEvent.FOCUS_IN, inPutFocusIn)
			text.removeEventListener(FocusEvent.FOCUS_OUT, inPutFocusOut)
			text.removeEventListener(MouseEvent.MOUSE_OVER, inPutFocusOVER)
			text.removeEventListener(MouseEvent.MOUSE_OUT,inPutFocusOUT)
		}
		static private function inPutFocusOut(e:FocusEvent):void 
		{
			var text:TextField = e.target as TextField
			var movie:MovieClip
			if (textInPutBgDic[text] != null) {
				movie = textInPutBgDic[text].movie as MovieClip
				textInPutBgDic[text].focus=false
				 if (movie) {
					 MovieUtils.movieFrame(movie,1)
					 //movie.gotoAndStop(1)
				}else {
					removeTextMovieBg(text)
				}
			}
		}
		
		static private function inPutFocusIn(e:FocusEvent):void 
		{
			var text:TextField = e.target as TextField
			var movie:MovieClip
			if (textInPutBgDic[text] != null) {
				movie = textInPutBgDic[text].movie as MovieClip
				textInPutBgDic[text].focus=true
				 if (movie) {
					 MovieUtils.movieFrame(movie,movie.totalFrames)
					 //movie.gotoAndStop(2)
				}else {
					removeTextMovieBg(text)
				}
			}
		}
		
		
		/**
		 * 默认输入字典
		 */
		private static var defaultInfoDic:Dictionary = new Dictionary()
		/**
		 * 默认输入字符
		 * @param	text
		 * @return
		 */
		public static function getDefaultInfo(text:TextField):String {
			if (defaultInfoDic[text] == null) {
				return null
			}else {
				return defaultInfoDic[text].value
			}
		}
		/**
		 * 是否输入
		 * @param	text
		 * @return
		 */
		public static function getDefaultBool(text:TextField):Boolean {
			if (text.text == '' || text.text == getDefaultInfo(text)) {
				return false
			}else {
				if(StringUtil.ltrim(StringUtil.rtrim(text.text))!='')return true
				return false
			}
		}
		/**
		 * 设置默认输入
		 * @param	text
		 * @param	value
		 */
		public static function addDefaultInfo(text:TextField,value:String,password:Boolean=false):void {
			if (defaultInfoDic[text] == null) {
				defaultInfoDic[text]={text:text,value:value,password:password}
			}else {
				defaultInfoDic[text].value=value
			}
			text.type = 'input'
			text.text=value
			text.addEventListener(FocusEvent.FOCUS_IN, defaultFocusIn)
			text.addEventListener(FocusEvent.FOCUS_OUT,defaultFocusOut)
		}
		
		static private function defaultFocusOut(e:FocusEvent):void 
		{
			var text:TextField= e.target as TextField
			if (defaultInfoDic[text] != null) {
				if (text.text == defaultInfoDic[text].value || text.text == '') {
					text.text = defaultInfoDic[text].value
					text.displayAsPassword=false
				}
				else {
					if(defaultInfoDic[text].password)text.displayAsPassword=true
				}
			}else {
				removeDefaultInfo(text)
			}
		}
		static private function  defaultFocusIn(e:FocusEvent):void 
		{
			var text:TextField= e.target as TextField
			if (defaultInfoDic[text] != null) {
				if (text.text == defaultInfoDic[text].value || text.text == '') {
					if (defaultInfoDic[text].password) text.displayAsPassword = true
					else text.displayAsPassword = false
					text.text=''
				}
			}else {
				removeDefaultInfo(text)
			}
		}
		/**
		 * 删除默认文本输入
		 * @param	text
		 */
		public static function removeDefaultInfo(text:TextField):void {
			if (defaultInfoDic[text] != null) {
				text.removeEventListener(FocusEvent.FOCUS_IN, defaultFocusIn)
				text.removeEventListener(FocusEvent.FOCUS_OUT, defaultFocusOut)
				defaultInfoDic[text]=null
			}
		}
		/**
		 * 使用CSS并开启设备字体
		 * @param	text
		 * @param	_css
		 */
		public static function setEmbedFontsAndCSS(text:TextField, _css:String):void {
			var css:StyleSheet = new StyleSheet()
			css.parseCSS(_css)
			text.embedFonts = true; 
			text.styleSheet = css; 
			
		}
		
		/**
		 * 使用嵌入字体
		 * @param	text 文本框
		 * @param	fontName 嵌入的字体名称
		 * @param	bool 是否嵌入
		 */
		public static function setEmbedFonts(text:TextField,fontName:String,bool:Boolean=true):void {
			if (bool) {
				text.embedFonts = true
				var tf:TextFormat = new TextFormat();
				if(getFont(fontName)!=null)tf.font = getFont(fontName).fontName;
				text.setTextFormat(tf)
			}else {
				removeEmbedFonts(text)
			}
		}
		
		/**
		 * 带嵌入字体的 CSS
		 * @param	text
		 * @param	sheet
		 * @param	style
		 */
		public static function setEmbedFontsByCSS(text:TextField,sheet:StyleSheet,style:String):void {
			text.embedFonts = true
			var cssFormat:TextFormat
			var obj:Object = sheet.getStyle(style);
			cssFormat = sheet.transform(obj);
			text.setTextFormat(cssFormat)
		}
		
		/**
		 * 删除嵌入字体
		 */
		public static function removeEmbedFonts(text:TextField):void {
			text.embedFonts = false
			var tf1:TextFormat = new TextFormat();
			text.setTextFormat(tf1)
		}
		
		//------------------------------------其实这些没太多使用意义，只要加载SWF就可以了-------------------
		/**
		 * 加载嵌入字体
		 * @param	url
		 */
		public static function loadFonts(url:String, fontName:String):FontsLoader {
			
			if (fontsLibrary[fontName] != null) {
				fontsLibrary[fontName].destroy()
			}
			var loader:FontsLoader
			loader = new FontsLoader(fontName)
			fontsLibrary[fontName] = loader
			fontsLibrary[loader] = loader;
			loader.load(url)
			return loader
		}
		/**
		 * 字库字典
		 */
		private static var fontsLibrary:Dictionary = new Dictionary()
		/**
		 * 获取字体
		 * @param	fontName
		 * @return
		 */
		public static function getFont(fontName:String):Font {
			var arr:Array = Font.enumerateFonts()
			for (var i:int = 0; i < arr.length; i++) 
			{
				if (arr[i].fontName == fontName) {
					return arr[i];
				}
			}
			return null
		}
		/**
		 * 通过字体名称来获取字体
		 * @param	fontName
		 * @return
		 */
		public static function getLoadFontByName(fontName:String):FontsLoader {
			if (fontsLibrary[fontName] != null) {
				return fontsLibrary[fontName];
			}
			return null
		}
		/**
		 * 通过字体加载对象获取字体
		 * @param	loader
		 * @return
		 */
		public static function getLoadFontByLoader(loader:FontsLoader):FontsLoader {
			if (fontsLibrary[loader] != null) {
				return fontsLibrary[loader];
			}
			return null
		}

		
	}
}

