package com.ixiyou.media 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.media.*;
	
	import com.ixiyou.utils.display.ButtonUtil;
	import com.ixiyou.utils.display.MovieUtils;
	import com.ixiyou.utils.StringUtil
	import com.greensock.loading.*;
	import com.greensock.events.*;
	
	import com.ixiyou.speUI.mcontrols.MovieHSlider
	/**
	 * Video播放器
	 * @author maksim
	 */
	public class VideoPlayOld extends MovieClip 
	{
		private var _skin:MovieClip
		//屏幕按钮
		private var mc_screen:MovieClip
		//播放
		private var btn_screen_play:MovieClip
		//暂停
		private var btn_screen_pause:MovieClip
		
		
		//放播放与暂停的盒子
		private var btn_playBox:MovieClip
		
		//播放
		private var btn_play:MovieClip
		//暂停
		private var btn_pause:MovieClip
		//停止播放
		private var btn_stop:MovieClip
		
		//全屏
		private var btn_fullScreen:MovieClip
		private var btn_sound:MovieClip
		private var mc_playTime:MovieClip
		private var text_playTime:TextField
		
		//播放条
		private var playSlider:MovieClip
		private var slider:MovieClip
		private var loading:MovieClip
		private var playing:MovieClip
		private var slider_bg:MovieClip
		private var sliderBg:MovieClip
		private var slider_w:Number = 0
		
		//遮罩层
		private var videoMask:MovieClip
		private var imgBox:MovieClip
		private var imgRect:Rectangle=new Rectangle()
		private var videoBox:MovieClip
		private var videoRect:Rectangle=new Rectangle()
		private var videoBg:MovieClip
		//播放进度拖动
		private var sliderDown:Boolean=false
		//
		private var mc_preloader:MovieClip
		
		private var _videoloader:VideoLoader
		
		
		private var soundSlider:MovieHSlider
		//private var sound_slider:MovieClip
		//private var sound_show:MovieClip
		//private var sound_bg:MovieClip
		
		private var _playSliderMode:String='type1'
		public function VideoPlayOld(_skinTemp:MovieClip,confing:Object=null) 
		{
			if (confing) {
				if(confing.playSliderMode!=null)playSliderMode=confing.playSliderMode
			}
			skin = _skinTemp
			videoloader = new VideoLoader('',{autoPlay:true,scaleMode:'stretch',width:videoRect.width,height:videoRect.height})
			//videoloader.load(true)
		}
		
		public function get skin():MovieClip 
		{
			return _skin;
		}
		
		public function set skin(value:MovieClip):void 
		{
			
			if (_skin == value) return;
			if (skin ){
				if (contains(skin)) removeChild(skin)
			}
			_skin = value
			this.x = _skin.x
			this.y=_skin.y
			_skin.x = _skin.y = 0
			
			addChild(_skin);
			
			if (soundSlider) {
				if(soundSlider.parent)soundSlider.parent.removeChild(soundSlider)
			}
			
			if (_skin.soundSlider) {
				soundSlider = new MovieHSlider(_skin.soundSlider,true,true)
				if(soundSlider.parent)soundSlider.parent.removeChild(soundSlider)
				soundSlider.value=soundValue*100
				soundSlider.addEventListener('upData',soundUpData)
				soundSlider.addEventListener(Event.ADDED_TO_STAGE,soundSliderAddStage)
			}else {
				soundSlider = null
				trace('no skin.soundSlider')
			}
			
			if (skin.mc_screen) {
				mc_screen = skin.mc_screen as MovieClip;
				mc_screen.buttonMode = true
				mc_screen.addEventListener(MouseEvent.MOUSE_OVER, mc_screenOver)
				mc_screen.addEventListener(MouseEvent.MOUSE_OUT, mc_screenOut)
				mc_screen.addEventListener(MouseEvent.CLICK,mc_screenClick)
				btn_screen_pause = mc_screen.mc_screen_box.btn_screen_pause as MovieClip
				btn_screen_play = mc_screen.mc_screen_box.btn_screen_play as MovieClip
				
				ButtonUtil.setButton(btn_screen_pause)
				ButtonUtil.setButton(btn_screen_play)
			}else {
				trace('no skin.mc_screen')
			}
			
			
			
			
			
			
			if (skin.btn_playBox ) {
				btn_playBox = skin.btn_playBox as MovieClip;
				btn_play = btn_playBox.btn_play as MovieClip;
				btn_pause = btn_playBox.btn_pause as MovieClip;
				
				
				btn_playBox.addEventListener(MouseEvent.CLICK,btn_playClick)
				ButtonUtil.setButton(btn_play)
				ButtonUtil.setButton(btn_pause)
			}else {
				trace('no skin.btn_playBox')
			}
			
			
			if (skin.btn_stop) {
				btn_stop = skin.btn_stop as MovieClip;
				ButtonUtil.setButton(btn_stop)
				btn_stop.addEventListener(MouseEvent.CLICK, function():void {
					close()
				})
			}else {
				trace('no skin.btn_stop')
			}
			if (skin.btn_sound) {
				btn_sound = skin.btn_sound as MovieClip;
				btn_sound.buttonMode = true
				btn_sound.mouseChildren = false
				btn_sound.addEventListener(MouseEvent.CLICK, btn_soundFun)
				btn_sound.addEventListener(MouseEvent.MOUSE_OVER, soundover)
			}else {
				trace('no skin.btn_sound')
			}
			
			
			if (skin.mc_playTime) {
				mc_playTime = skin.mc_playTime as MovieClip;
				text_playTime = mc_playTime.text_playTime as TextField;
			}else {
				trace('no skin.mc_playTime')
			}
			
			if (skin.btn_fullScreen) {
				btn_fullScreen = skin.btn_fullScreen as MovieClip;
				//ButtonUtil.setButton(btn_fullScreen)
				btn_fullScreen.buttonMode = true
				btn_fullScreen.mouseChildrenf=false
				btn_fullScreen.addEventListener(MouseEvent.CLICK,btn_fullScreenFun)
			}else {
				trace('no skin.btn_fullScreen')
			}
			
			if (skin.playSlider) {
				playSlider = skin.playSlider as MovieClip;
				slider = playSlider.slider as MovieClip
				ButtonUtil.setButton(slider);
				slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderDownFun)
				loading = playSlider.loading as MovieClip;
				loading.mouseChildren = false
				loading.mouseEnabled=false
				playing = playSlider.playing as MovieClip;
				playing.mouseChildren = false
				playing.mouseEnabled=false
				slider_bg = playSlider.slider_bg as MovieClip;
				sliderBg = playSlider.sliderBg
				sliderBg.buttonMode = true
				sliderBg.addEventListener(MouseEvent.CLICK, sliderBgCLick)
				slider_w = loading.width;
			}
			else {
				trace('no skin.playSlider')
			}
			
			if (skin.imgBox) {
				imgBox = skin.imgBox as MovieClip;
				imgRect.width = imgBox.width;
				imgBox.height = imgBox.height;
				while (imgBox.numChildren > 0) imgBox.removeChildAt(0);
			}else {
				trace('no skin.imgBox')
			}
			
			if (skin.videoBox) {
				videoBox = skin.videoBox as MovieClip;
				videoRect.width = videoBox.width;
				videoRect.height = videoBox.height;
				while (videoBox.numChildren > 0) videoBox.removeChildAt(0);
			}else {
				trace('no skin.videoBox')
			}
			
			
			if ( skin.videoBg) {
				videoBg = skin.videoBg as MovieClip;
			}else {
				trace('no skin.videoBg')
			}
			
			if (skin.mc_preloader) {
				mc_preloader=skin.mc_preloader
			}else {
				trace('no skin.mc_preloader')
			}
			if (skin.videoMask ) {
				videoMask = skin.videoMask as MovieClip;
				if(videoBox)videoBox.mask = videoMask
				//videoBox.mask=videoMask
				if(imgBox)imgBox.mask = videoMask
			}else {
				trace('no skin.videoMask')
			}
			
			
			upBuffer()
			upPlayState()
			upTime()
			upLoadState()
			upSound()
			upVideoShow()
			
		}
		
		
		
		private function soundUpData(e:Event):void 
		{
			//trace(soundSlider.value/100)
			soundValue = (soundSlider.value / 100)
			if(soundSlider.parent)soundSlider.parent.removeChild(soundSlider)
			upSound()
		}
		
	
		
		private function soundover(e:MouseEvent):void 
		{
			if (soundSlider && skin) {
				skin.addChild(soundSlider)
			}
		}
		
		private function soundSliderAddStage(e:Event):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, soundSliderDown)
			//stage.addEventListener(MouseEvent.MOUSE_OVER,soundSliderOut)
		}
		
		private function soundSliderDown(e:MouseEvent):void 
		{
			if (soundSlider && skin) {
				if (soundSlider.contains(e.target as DisplayObject)) {
					return
				}
				if(soundSlider.parent)soundSlider.parent.removeChild(soundSlider)
			}
		}
		
		
		/**
		 * 声音
		 * @param	e
		 */
		private function btn_soundFun(e:MouseEvent):void 
		{
			soundStopPlay()
		}
		/**
		 * 点击背景选择播放进度
		 * @param	e
		 */
		private function sliderBgCLick(e:MouseEvent):void 
		{
			
			if (videoloader) {
				slider.x = playSlider.mouseX
				var w:Number=0
				if (playSliderMode == 'type1') w=slider_w
				else if (playSliderMode == 'type2') w=slider_w - slider.width
				else  w=slider_w
				videoloader.gotoVideoTime(videoloader.duration*(slider.x/w))
			}
		}
		
		/**
		 * 开始拖放播放进度
		 * @param	e
		 */
		private function sliderDownFun(e:MouseEvent):void {
			var rect:Rectangle
			var w:Number=0
			if (playSliderMode == 'type1') w=slider_w
			else if (playSliderMode == 'type2') w=slider_w - slider.width
			else  w=slider_w
			rect = new Rectangle(0, 0, w, 0)
			sliderDown=true
			slider.startDrag(false, rect)
			stage.addEventListener(MouseEvent.MOUSE_MOVE,stageMove)
			stage.addEventListener(MouseEvent.MOUSE_UP,stageUp)
		}
		
		private function stageMove(e:MouseEvent):void 
		{
			playing.width = slider.x
		}
		/**
		 * 释放 到播放进度
		 * @param	e
		 */
		private function stageUp(e:MouseEvent):void 
		{
			sliderDown=false
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUp)
			if (videoloader) {
				var w:Number=0
				if (playSliderMode == 'type1') w=slider_w
				else if (playSliderMode == 'type2') w=slider_w - slider.width
				else  w=slider_w
				videoloader.gotoVideoTime(videoloader.duration*(slider.x/w))
			}
			slider.stopDrag()
		}
		
		private function btn_fullScreenFun(e:MouseEvent):void 
		{
			if(!stage)return
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.addEventListener(Event.RESIZE,stageReSize)
				stage.displayState = StageDisplayState.FULL_SCREEN
			}else {
				stage.displayState = StageDisplayState.NORMAL
			}
			fullScreen()
		}
		
		private function stageReSize(e:Event):void 
		{
			if (!stage) {
				stage.removeEventListener(Event.RESIZE,stageReSize)
				return
			}
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				
			}
		}
		
		
		
		private function btn_playClick(e:MouseEvent):void 
		{
			if (videoloader) {
				if (videoloader.videoPaused) {
					videoloader.playVideo()
				}else {
					videoloader.pauseVideo()
				}
			}
		}
		
		private function mc_screenClick(e:MouseEvent):void 
		{
			if (videoloader) {
				if (videoloader.videoPaused) {
					videoloader.playVideo()
				}else {
					videoloader.pauseVideo()
				}
			}
		}
		
		private function mc_screenOut(e:MouseEvent):void 
		{
			MovieUtils.movieFrame(mc_screen,'off')
		}
		
		private function mc_screenOver(e:MouseEvent):void 
		{
			MovieUtils.movieFrame(mc_screen, 'on')
			
			if (mc_screen) {
				if (videoloader &&videoloader.bufferProgress==1 ) {
					MovieUtils.movieFrame(mc_screen, 'on')
				}
				else {
					MovieUtils.movieFrame(mc_screen,'off')
				}
			}
		}
		
		
		/**
		 * VideoLoader对象
		 */
		public function get videoloader():VideoLoader 
		{
			return _videoloader;
		}
		
		public function set videoloader(value:VideoLoader):void 
		{
			if(_videoloader == value)return;
			if (_videoloader) {
				_videoloader.removeEventListener(LoaderEvent.ERROR,videoError)
				_videoloader.removeEventListener(LoaderEvent.PROGRESS,videoloadProgress);
				_videoloader.removeEventListener(LoaderEvent.INIT, videoTotalTime);
				_videoloader.removeEventListener(VideoLoader.VIDEO_COMPLETE, videoComplete);
				_videoloader.removeEventListener(VideoLoader.PLAY_PROGRESS, videolayProgress);
				_videoloader.removeEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);
				_videoloader.removeEventListener(VideoLoader.VIDEO_BUFFER_EMPTY, bufferEmptyHandler);
				_videoloader.removeEventListener(VideoLoader.VIDEO_PAUSE, videoPauseFun);
				_videoloader.removeEventListener(VideoLoader.VIDEO_PLAY, videoPlayFun);
				_videoloader.removeEventListener(LoaderEvent.OPEN,videoOpenFun)
				
			}
			
			_videoloader = value;
			
			_videoloader.addEventListener(LoaderEvent.ERROR,videoError)
			_videoloader.addEventListener(LoaderEvent.PROGRESS,videoloadProgress);
			_videoloader.addEventListener(LoaderEvent.INIT, videoTotalTime);
			_videoloader.addEventListener(VideoLoader.VIDEO_COMPLETE, videoComplete);
			_videoloader.addEventListener(VideoLoader.PLAY_PROGRESS,videolayProgress);
			_videoloader.addEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);
			_videoloader.addEventListener(VideoLoader.VIDEO_BUFFER_EMPTY, bufferEmptyHandler);
			_videoloader.addEventListener(VideoLoader.VIDEO_PAUSE, videoPauseFun);
			_videoloader.addEventListener(VideoLoader.VIDEO_PLAY, videoPlayFun);
			_videoloader.addEventListener(LoaderEvent.OPEN,videoOpenFun)
			
			upBuffer()
			upPlayState()
			upTime()
			if (videoBox) {
				while (videoBox.numChildren > 0) videoBox.removeChildAt(0);
				videoBox.addChild(videoloader.content)
				videoBox.mask = videoMask;
				
				Sprite(videoloader.content).width = videoRect.width;
				Sprite(videoloader.content).height = videoRect.height;
				//videoBox.addChild(videoloader.rawContent)
			}
			
		}
		/**
		 * 更新皮肤SKIN后进行转移
		 */
		private function upVideoShow():void 
		{
			if (skin&&videoloader) {
				videoBox.addChild(videoloader.content)
				videoBox.mask = videoMask;
			}
		}
		private var tempSoundValue:Number=0
		/**
		 * 静音 与播放
		 */
		public function soundStopPlay():void {
			
			if (videoloader&&skin) {
				if (soundValue > 0) {
					tempSoundValue=soundValue
					soundValue = 0
					
				}else {
					soundValue = tempSoundValue
				}
				upSound()
			}
		}
		/**
		 * 声音表现
		 */
		public function upSound():void {
			if (!stream) {
				if(soundSlider)soundSlider.value=0
				if(btn_sound)MovieUtils.movieFrame(btn_sound, 'on')
				return
			}
			if (soundValue == 0) {
				if(soundSlider)soundSlider.value=0
				if(btn_sound)MovieUtils.movieFrame(btn_sound,'off')
			}else {
				if(soundSlider)soundSlider.value=soundValue*100
				if(btn_sound)MovieUtils.movieFrame(btn_sound,'on')
			}
		}
		/**
		 * NetStream 流对象
		 */
		public function get stream():NetStream {
			if (videoloader) {
				return videoloader.netStream
			}
			return null; 
			
		}
		/**
		 * 音量
		 */
		public function get soundValue():Number {
			if (stream) return stream.soundTransform.volume
			else return 0
		}
		public function set soundValue(value:Number):void 
		{
			if (stream) {
				var soundTransform:SoundTransform = stream.soundTransform
				soundTransform.volume=value
				stream.soundTransform=soundTransform
			}
		}
		/**
		 * 播放跳拖动模式
		 * type1 拖动点在中心 type2 拖动点在 0 0点，需要计算播放条的扣除宽
		 */
		public function get playSliderMode():String 
		{
			return _playSliderMode;
		}
		
		public function set playSliderMode(value:String):void 
		{
			_playSliderMode = value;
		}
		/**
		 * 全屏
		 */
		public function fullScreen():void 
		{
			if (!stage) return
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, stageFullScreen)
			if (stage.displayState == StageDisplayState.NORMAL) {
				MovieUtils.movieFrame(btn_fullScreen,'off')
			}else {
				MovieUtils.movieFrame(btn_fullScreen,'on')
			}
			dispatchEvent(new Event('fullScreen'))
		}
		
		private function stageFullScreen(e:FullScreenEvent):void 
		{
			fullScreen()
		}
		/**
		 * 加载进度
		 */
		public function upLoadState():void 
		{
			if (skin && videoloader) {
				//trace(videoloader.progress)
				if(loading)loading.width = slider_w * videoloader.progress;
			}else {
				if(loading)loading.width = slider_w * 0
			}
		}
		/**
		 * 缓冲加载中。。。
		 */
		public function upBuffer():void {
			if (mc_preloader) {
				if (videoloader&&videoloader.bufferMode) mc_preloader.visible = videoloader.bufferMode
				else mc_preloader.visible =false
			}
			
		}
		/**
		 * 播放状态
		 */
		public function upPlayState():void {
			if (skin) {
				if (videoloader) {
					if (videoloader.videoPaused) {
						btn_play.visible = true
						btn_pause.visible = false
						
						btn_screen_play.visible=true
						btn_screen_pause.visible =false
						
					}
					else {
						btn_play.visible = false
						btn_pause.visible = true
						
						btn_screen_play.visible=false
						btn_screen_pause.visible =true
					}
				}
				else
				{
					btn_play.visible = true
					btn_pause.visible = false
					
					btn_screen_play.visible=true
					btn_screen_pause.visible =false
				}
			}
		}
		
		/**
		 * 播放时间
		 */
		public function upTime():void {
			if (videoloader&&skin) {
				var minutes:String = StringUtil.force2Digits(int(videoloader.duration / 60));
				var seconds:String = StringUtil.force2Digits(int(videoloader.duration % 60));
				
				var str:String = minutes + ":" + seconds;	
				
				var time:Number = videoloader.videoTime;
				minutes = StringUtil.force2Digits(int(time / 60));
				seconds = StringUtil.force2Digits(int(time % 60));
				
				if(text_playTime)text_playTime.text = minutes + ":" + seconds + '/' + str

				
				if (sliderDown)return
				if (videoloader.playProgress) {
					var w:Number=0
					if (playSliderMode == 'type1') w=slider_w
					else if (playSliderMode == 'type2') w=slider_w - slider.width
					else  w = slider_w
					
					if(slider)slider.x = w*videoloader.playProgress
					if(playing)playing.width=slider.x
				}else {
					if(slider)slider.x = slider_w * 0
					if(playing)playing.width=slider_w *0
				}
				
			}
		}
		
		private function videoPauseFun(e:LoaderEvent=null):void 
		{
			//trace('videoPauseFun')
			upPlayState()
		}
		
		private function videoPlayFun(e:LoaderEvent=null):void 
		{
			//trace('videoPlayFun')
			upPlayState()
		}
		/**
		 * 开始加载视频
		 * @param	e
		 */
		private function videoOpenFun(e:LoaderEvent):void 
		{
			upBuffer()
			upPlayState()
			upLoadState()
			upTime()
			if (mc_preloader) mc_preloader.visible = true
			if(soundSlider)soundSlider.value=soundValue*100
		}
		/**
		 * 缓冲区满
		 * @param	e
		 */
		private function bufferFullHandler(e:LoaderEvent=null):void 
		{
			//trace('bufferFullHandler')
			upBuffer()
		}
		private function bufferEmptyHandler(e:LoaderEvent=null):void 
		{
			//trace('bufferEmptyHandler')
			upBuffer()
		}
		/**
		 * 缓冲区不满
		 * @param	e
		 */
		private function videolayProgress(e:LoaderEvent=null):void 
		{
			upTime()
		}
		
		private function videoError(e:LoaderEvent=null):void 
		{
			upBuffer()
			upPlayState()
			upLoadState()
			upTime()
		}
		
		private function videoComplete(e:LoaderEvent=null):void 
		{
			upLoadState()
		}
		
		
		private function videoTotalTime(e:LoaderEvent=null):void 
		{
			upTime()
			if (videoloader && videoloader.vars.autoPlay) {
				videoloader.playVideo()
			}
		}
		
		private function videoloadProgress(e:LoaderEvent=null):void 
		{
			upLoadState()
		}
		public var url:String
		public function load(url:String):void {
			//videoloader.url = url
			this.url=url
			videoloader.request.url=url
			videoloader.load(true)
		}
		//public function load
		public function close():void {
			if(videoloader)videoloader.pauseVideo()
		}
		
		public function pauseVideo():void {
			if(videoloader)videoloader.pauseVideo()
		}
		
	}

}