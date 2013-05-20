package com.ixiyou.utils 
{
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	/**
	 * ...
	 * https://github.com/a-jie/-TOOL--library-for-as3/blob/master/tool/url/SNS.as
	 */
	public class SNS 
	{

		static private var _title:String;
		static private var _message:String;
		static private var _url:String;
		static private var _web:String;
		static private var _pic:String;

		static public function get sina	()	:String
		{
			return "http://v.t.sina.com.cn/share/share.php?title=" + encodeURIComponent(title) + "&url=" + encodeURIComponent(url) +"&pic="+pic;
		}

		static public function get kaixin	()	:String
		{
			return "http://www.kaixin001.com/repaste/share.php?rtitle=" + encodeURIComponent(title) + "&rurl=" + encodeURIComponent(url) + "&rcontent=" +  _message;
		}

		static public function get renren	()	:String
		{
			return "http://share.renren.com/share/buttonshare.do?link=" + encodeURIComponent(url) + "&title=" + encodeURIComponent(title);
		}

		static public function get msn	()	:String
		{
			return "http://profile.live.com/badge?url=" + encodeURIComponent(url) + "&title=" + encodeURIComponent(title);
		}


		static public function get sohu	()	:String
		{
			return "http://t.sohu.com/third/post.jsp?url=" + encodeURIComponent(url) +"&title=" + title + "&content=" + _message;
		}

		static public function get w163	()	:String
		{          
			return "http://t.163.com/article/user/checkLogin.do?source=" + encodeURIComponent(_web) + "&info=" + _message;
		}

		static public function get qqblog	()	:String
		{
			return 'http://share.v.t.qq.com/index.php?c=share&a=index&site=""&url='+ encodeURIComponent(url) + "&title=" + encodeURIComponent(title)+"&pic="+ pic;
			//return "http://v.t.qq.com/share/share.php?title="+encodeURIComponent(title)+"&url="+encodeURIComponent(url)+"&appkey=118cd1d635c44eab9a4840b2fbf8b0fb&site=www.ogilvy.com.cn&pic=";
		}

		static public function get qqzone	()	:String
		{
			return "http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=" + encodeURIComponent(url);
		}

		static public function get douban	()	:String
		{
			return "http://www.douban.com/recommend/?url=" + url + "&title=" + encodeURIComponent(title) + "&v=1";
		}

		///////////////////////////////////////////////////
		static public function  get title():String
		{
			return _title;
		}
		static public function get url():String
		{
			return _url;
		}
		static public function get pic():String
		{
			return _pic;
		}

		static public function get message():String
		{
			return _message;
		}

		static public function toSNS($type:String, $title:String = "" ,$web:String = "",$pic:String='', $message:String = ""):void
		{
			_web = $web;
			_url = $web;
			_title = $title;
			_message = encodeURIComponent($message);
			_pic = $pic;
			 //trace($type)
			 if ($type == "sina") {
				 trace('sina:',sina)
				 navigateToURL(new URLRequest(sina),'_blank')
			 }	
			else if ($type == "kaixin")
				navigateToURL(new URLRequest(kaixin),'_blank')	
			else if ($type == "renren")
				navigateToURL(new URLRequest(renren),'_blank')
				
			else if ($type == "msn")
				navigateToURL(new URLRequest(msn),'_blank')
				
			else if ($type == "sohu")
				
				navigateToURL(new URLRequest(sohu),'_blank')
			else if ($type == "w163")
				
				navigateToURL(new URLRequest(w163),'_blank')
			else if ($type == "qqblog")
				
				navigateToURL(new URLRequest(qqblog),'_blank')
			else if ($type == "qqzone")
				
				navigateToURL(new URLRequest(qqzone),'_blank')
			
		}
		public static const KAIXIN:String = 'kaixin';
		public static const SINA:String = 'sina';
		public static const RENREN:String = 'renren';
		public static const MSN:String = 'msn';
		public static const SOHU:String = 'sohu';
		public static const W163:String = 'w163';
		public static const QQBLOG:String = 'qqblog';
		public static const QQZONE:String = 'qqzone';
		public static const COPY:String = 'copy';	
		public static const DOUBAN:String = 'douban';	
		public static const FAVORITES:String = 'favorites';

	}

}