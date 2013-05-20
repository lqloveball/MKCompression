package com.ixiyou.utils.net
{
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Dictionary;

	/**
	* 多了本地保存
	* @author
	*/
	
	public class NetUtilCS4 
	{
		
		protected static var saveData:FileReference = new FileReference();
		private static var openFileDic:Dictionary
		/**保存数据
		 * 
		 * @param 
		 * @return 
		*/
		public static function save(Stream:*,defaultFileName:String = null):void {
			saveData.save(Stream,defaultFileName)
		}
		/**
		 * 打开数据 
		 * @return 
		 * 
		 */		
		public static function openFile(value:String='打开文件 *.*',type:String='*.*',openEndFun:Function=null):FileReference{
			
			var file:FileReference=new FileReference();
			
			openFileDic=new Dictionary();
			openFileDic[file]=openEndFun
				
			file.addEventListener(Event.SELECT, onFileSelected);
			file.addEventListener(Event.COMPLETE, onFileLoaded);
			file.browse([new FileFilter(value, type)]);
			return file;
		}
		private static function onFileSelected(e:Event):void {
			var file:FileReference=e.target as FileReference
			file.addEventListener(Event.COMPLETE,onFileLoaded);
			file.addEventListener(Event.OPEN,function():void{trace('file load start')});
			file.load();
		}
		
		private static function onFileLoaded(e:Event):void {
			var file:FileReference=e.target as FileReference;
			var fun:Function=openFileDic[file]
			if(fun!=null){
				fun(file);
			}
			trace('file load end',fun)
		}
		
		/**打开网页
		 * 
		 * @param 
		 * @return 
		*/
		public static function getUrll(url:String, window:String = "_blank"):void {
			var getURLRequest:URLRequest = new URLRequest(url)
			navigateToURL(getURLRequest,window);
		}
		/**
		 * post数据
		 * @param 
		 * @return 
		*/
		public static function post(url:String,data:*=null,window:String="_blank"):void {
			var getURLRequest:URLRequest = new URLRequest(url)
			var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			getURLRequest.requestHeaders.push(header);
			getURLRequest.method = URLRequestMethod.POST;
			getURLRequest.data = data;
			navigateToURL(getURLRequest,window);
		}
	}
	
}