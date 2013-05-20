package com.ixiyou.utils.display 
{
	import flash.display.MovieClip
	import flash.display.FrameLabel
	import flash.events.Event
	import flash.utils.Dictionary
	/**
	 * 影片剪辑控制器
	 * @author spe email:md9yue@@q.com
	 */
	public class MovieUtils
	{
		private static var dic:Dictionary=new Dictionary()
		public function MovieUtils() 
		{
			
		}
		/**
		 * 获取帧表情开始帧
		 * @param	movie
		 * @param	value
		 * @return
		 */
		public static function getMovieLabelNum(movie:MovieClip,value:String):uint {
			var labels:Array = movie.currentLabels;
			var num:uint=1
			for (var i:uint = 0; i < labels.length; i++) {
				var label:FrameLabel = labels[i];
				//trace("frame " + label.frame + ": " + label.name,value);
				if (label.name == value) {
					
					num = label.frame
					return num
					break
				}
				
			}
			return 0
		}
		public static function removeMovie(movie:MovieClip):void {
			if (dic[movie] != null) {
				movie.removeEventListener(Event.ENTER_FRAME, enterFrame)
				dic[movie]=null
			}
		}
		/**
		 * 运动到指定帧
		 * @param	movie
		 * @param	value
		 */
		public static function movieFrame(movie:MovieClip, value:*,endFun:Function=null):void {
			var obj:Object
			if (dic[movie] == null) {
				obj=new Object()
				dic[movie] = obj
			}else {
				movie.removeEventListener(Event.ENTER_FRAME, enterFrame)
				obj = dic[movie]
				//trace(movie.name,obj.movie.name,obj.end)
			}
			obj.movie = movie
			if (value is String) {
				var labels:Array = movie.currentLabels;
				var num:uint=1
				for (var i:uint = 0; i < labels.length; i++) {
					var label:FrameLabel = labels[i];
					if (label.name == value) {
						num=label.frame
						break
					}
					//trace("frame " + label.frame + ": " + label.name);
				}
				//value=movie.currentFrameLabel
				obj.end=num
			}else {
				obj.end=value
			}
			
			if(obj.end>movie.totalFrames)obj.end=movie.totalFrames
			if (movie.currentFrame < obj.end) obj.aspect = true
			else obj.aspect = false
			obj.start = movie.currentFrame
			obj.endFun=endFun
			movie.addEventListener(Event.ENTER_FRAME,enterFrame)
			//trace('播放：'+obj.end,obj.start,obj.aspect)
		}
		
		private static function enterFrame(e:Event):void 
		{ 
			
			var movie:MovieClip = e.target as MovieClip
			var obj:Object = dic[movie]
			//trace(movie.currentFrame,obj.end)
			if (obj == null) return
			if ( movie.currentFrame == obj.end ) {
				//trace('删除',movie.currentFrame)
				movie.removeEventListener(Event.ENTER_FRAME, enterFrame)
			}
			if (obj.aspect) {
				//trace('正播',movie.currentFrame , obj.end )
				if (movie.currentFrame >= obj.end ) {
					//trace('删除',movie.currentFrame)
					movie.gotoAndStop(obj.end)	
					movie.removeEventListener(Event.ENTER_FRAME, enterFrame)
					if(obj.endFun!=null)obj.endFun()
				}else {
					
					movie.gotoAndStop(movie.currentFrame + 1)
					//trace('播放',movie.currentFrame)
					if (movie.currentFrame == obj.end ) {
						movie.gotoAndStop(obj.end)
						movie.removeEventListener(Event.ENTER_FRAME, enterFrame)
						//trace('删除',movie.currentFrame)
						if(obj.endFun!=null)obj.endFun()
					}
				}
			}
			else {
				if ( movie.currentFrame<=obj.end) {
					movie.gotoAndStop(obj.end)	
					movie.removeEventListener(Event.ENTER_FRAME, enterFrame)
					if(obj.endFun!=null)obj.endFun()
				}else {
					//trace('enterFrame:',obj.end,'>',obj.start,obj.aspect,movie)
					movie.gotoAndStop(movie.currentFrame-1)
					if ( movie.currentFrame == obj.end ) {
						movie.removeEventListener(Event.ENTER_FRAME, enterFrame)
						if(obj.endFun!=null)obj.endFun()
					}
				}
			}
		}
	}

}