package com.ixiyou.speUI.mcontrols
{
	import adobe.utils.CustomActions;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.*;
	import flash.text.*;
	import com.greensock.loading.*;
	import com.greensock.events.*;
	/**
	 * 网站背景声音
	 * @author maksim
	 */
	public class MovietToMP3Button extends Sprite 
	{
		private var mp3Arr:Array = new Array()
		private var selectMp3:MP3Loader
		private var _skin:MovieClip
		private var _volume:Number=1
		private var _autoPlay:Boolean = true;
		private var _soundPlay:Boolean = true;
		private var _nextBool:Boolean = false;
		private var _repeat:Number = -1
	
		private var soundChannel:SoundChannel;
		public function MovietToMP3Button(config:MovieClip,formerly:Boolean=false,parentBool:Boolean=false) 
		{
			_skin =config
			if (formerly) {
				x = config.x
				y = config.y
			}
			if (_skin.parent && parentBool) {
				_skin.parent.addChild(this)
				this.name=_skin.name
			}
			_skin.x = 0
			_skin.y=0
			addChild(_skin)
			_skin.mouseChildren = false
			_skin.mouseEnabled = true
			_skin.buttonMode = true
			_skin.addEventListener(MouseEvent.CLICK, clickFun)
			upPlay()
		}
		
		private function clickFun(e:MouseEvent):void 
		{
			soundPlay=!soundPlay
		}
		/**
		 * 播放指定声音，没有就添加一首
		 * @param	value
		 */
		public function playSound(value:String):void {
			if (selectMp3) {
				if (selectMp3.url == value) {
					DebugOutput.add('已经存在这个首音乐在播放中了')
					return
				}
				selectMp3.unload()
			}
			var waitMP3:MP3Loader
			var newBool:Boolean=true
			for (var i:int = 0; i < mp3Arr.length; i++) 
			{
				var temp:MP3Loader = mp3Arr[i]as MP3Loader
				if (temp.url == value) {
					temp=new MP3Loader(value, { name:name, repeat:repeat, autoPlay:false, onComplete:completeHandler, onError:errorHandler } );
					temp.addEventListener('soundComplete', soundComplete)
					mp3Arr[i] = temp;
					waitMP3=temp
					newBool=false
				}
			}
			if (newBool) {
				waitMP3=addMp3(value)
			}
			selectMp3 = waitMP3;
			selectMp3.load();
			
		}
		/**
		 * 设置一组背景音乐
		 * @param	arr
		 */
		public function setMp3Arr(arr:Array):void {
			for (var i:int = 0; i < arr.length; i++) 
			{
				if (arr[i] is  String) addMp3(arr[i]);
			}
		}
		/**
		 * 添加一个音乐
		 * @param	value
		 */
		public function addMp3(value:String,name:String=''):MP3Loader {
			var temp:MP3Loader = new MP3Loader(value, { name:name,repeat:repeat, autoPlay:false, onComplete:completeHandler, onError:errorHandler } );
			temp.addEventListener('soundComplete',soundComplete)
			mp3Arr.push(temp);
			
			if (selectMp3 == null) {
				selectMp3 = temp;
				selectMp3.load();
			}
			return temp
		}
		
		private function soundComplete(e:Event):void 
		{
			var nowTemp:MP3Loader=e.target as MP3Loader
			//trace('soundComplete', e.target)
			trace('soundComplete')
			if (nextBool) {
				var num:Number=0
				for (var i:int = 0; i < mp3Arr.length; i++) 
				{
					if (nowTemp == mp3Arr[i]) {
						num = i
						break;
					}
				}
				num += 1
				if (num >= mp3Arr.length) num = 0
				nowTemp = mp3Arr[num];
				playSound(nowTemp.url);
			}
		}
		
		private function errorHandler(e:LoaderEvent):void 
		{
			trace("error occured with " + e.target + ": " + e.text);
		}
		
		private function completeHandler(e:LoaderEvent):void 
		{
			var temp:MP3Loader = e.target as MP3Loader
			if (selectMp3 != temp) return;
			var sound:Sound=temp.content as flash.media.Sound
			temp.volume = volume;
			if (autoPlay) {
				temp.playSound()
			}
		}
		
		/**
		 * 声音大小
		 */
		public function get volume():Number 
		{
			return _volume;
		}
		
		public function set volume(value:Number):void 
		{
			_volume = value;
			if (soundChannel) {
				soundChannel.soundTransform.volume =_volume
			}
		}
		/**
		 * 是否自动播放
		 */
		public function get autoPlay():Boolean 
		{
			return _autoPlay;
		}
		
		public function set autoPlay(value:Boolean):void 
		{
			_autoPlay = value;
		}
		/**
		 * 设置声音是否播放
		 */
		public function get soundPlay():Boolean 
		{
			return _soundPlay;
		}
		
		public function set soundPlay(value:Boolean):void 
		{
			_soundPlay = value;
			upPlay()
		}
		/**
		 * 自动播放下一个首
		 */
		public function get nextBool():Boolean 
		{
			return _nextBool;
		}
		
		public function set nextBool(value:Boolean):void 
		{
			_nextBool = value;
		}
		/**
		 * 循环播放次数
		 */
		public function get repeat():Number 
		{
			return _repeat;
		}
		
		public function set repeat(value:Number):void 
		{
			_repeat = value;
		}
		/**
		 * 更新播放状态
		 */
		public function upPlay():void {
			if (soundPlay) {
				_skin.gotoAndStop('on')
			}
			else {
				_skin.gotoAndStop('off')
			}
			if (selectMp3)selectMp3.soundPaused=!soundPlay

		}
		
	}

}