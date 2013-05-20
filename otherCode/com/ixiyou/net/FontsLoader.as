package com.ixiyou.net 
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*
	import flash.text.*;
	/**
	 * 加载字体
	 * @author maksim
	 */
	public class FontsLoader extends EventDispatcher 
	{
		
		private var loader:Loader=new Loader()
		private var _fontName:String
		private var _font:Font = null
		private var _loaded:Boolean = false
		private var _state:String=''
		public function FontsLoader(value:String) {
			_fontName=value
		}
		public function load(value:String):void {
			_loaded = false
			_font=null
			loader=new Loader()
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fontComplete); 
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,fontError)
			loader.load(new URLRequest(value))
			_state='程序初始化'
		}
		
		private function fontError(e:IOErrorEvent):void 
		{
			_state='加载SWF文件出错'
			_loaded=false
		}
		
		private function fontComplete(e:Event):void 
		{
			
			var arr:Array = Font.enumerateFonts()
			for (var i:int = 0; i < arr.length; i++) 
			{
				if (arr[i].fontName == fontName) {
					_font = arr[i];
					_loaded=true
					//trace('字体:',fontName,'获取成功')
					break;
				}
			}
			if (_font)_state = '字体获取成功'
			else _state = 'swf内无指定字体'
			dispatchEvent(new Event(Event.COMPLETE))
			//trace(fontName,'字体加载完成')
		}
		
		public function get fontName():String 
		{
			return _fontName;
		}
		
		public function get font():Font 
		{
			return _font;
		}
		
		public function get state():String 
		{
			return _state;
		}
		
		public function get loaded():Boolean 
		{
			return _loaded;
		}
		public function destroy():void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fontComplete); 
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,fontError)
		}
			
	}

}