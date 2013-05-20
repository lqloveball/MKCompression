package com.ixiyou.speUI.mcontrols 
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.net.*;
	//数据更新
	[Event(name="upData", type="flash.events.Event")]
	/**
	 * ...
	 * @author maskim
	 */
	public class Movie100ToVScrollBar extends Sprite 
	{
		private var _wheelBool:Boolean=true;
		private var _width:Number;
		private var _height:Number;
		private var _slider:MovieClip;
		protected var _skin:MovieClip
		
		public function Movie100ToVScrollBar(skin:MovieClip,formerly:Boolean = true,parentBool:Boolean=true,config:*= null) 
		{
			if (formerly) {
				this.x = skin.x
				this.y = skin.y
				skin.x = skin.y = 0
				_width = skin.width
				_height=skin.height
			}
			if (skin.parent && parentBool) {
				//trace(skin.parent)
				skin.parent.addChild(this)
				this.name=skin.name
			}
			//graphics.beginFill(0)
			//graphics.drawRect(0,0,150,150)
			this.skin = skin
			addEventListener(MouseEvent.MOUSE_DOWN,mouseBgDown)
		}
		
		/**组件皮肤*/
		public function get skin():MovieClip{return _skin}
		public function set skin(value:MovieClip):void {
			
			_skin = value;
			addChild(_skin)
			skin.gotoAndStop(1);
			_slider = skin._slider;
			Tools.setButton(_slider);
			_slider.addEventListener(MouseEvent.MOUSE_DOWN,sliderDown)
		}
		private var oldy:Number=0
		
		private function sliderDown(e:MouseEvent):void 
		{
			oldy = this.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, sliderMove)
			stage.addEventListener(MouseEvent.MOUSE_UP,sliderUp)
		}
		
		private function sliderUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, sliderMove)
			stage.removeEventListener(MouseEvent.MOUSE_UP,sliderUp)
		}
		
		private function sliderMove(e:MouseEvent):void 
		{
			oldy = this.mouseY
			var num:Number = oldy / _height;
			if (num > 1) num = 1
			if (num < 0) num = 0;
			value = num;
		
		}
		/**
		 * 是否支持滚轮
		 */
		public function set wheelBool(value:Boolean):void 
		{
			if (_wheelBool == value) return
			if (!_content) return;
			_wheelBool = value
			if (_wheelBool) if (_content is InteractiveObject) InteractiveObject(_content).addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel)
			else if (_content is InteractiveObject) InteractiveObject(_content).removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel)
		}
		public function get wheelBool():Boolean { return _wheelBool; }
		private var _value:Number=0;
		
		
		
		//控制的显示对象
		protected var _content:DisplayObject
		//显示对象对应的遮罩
		protected var _mask:DisplayObject
		/**
		 * 设置内容
		 */
		public function set content(value:DisplayObject):void {
			if (_content == value) return;
			if (value.mask == null) return;
			if (_content && _content.hasEventListener(Event.RESIZE))_content.removeEventListener(Event.RESIZE, contentResize)
			
			_content = value
			_mask = _content.mask
			
			if (_content is InteractiveObject)_content.addEventListener(Event.RESIZE,contentResize)
			if (wheelBool) if (_content is InteractiveObject) InteractiveObject(_content).addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel)
			else if (_content is InteractiveObject) InteractiveObject(_content).removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel)
			upSlider()
		}
		
		/**
		 * 包含滑块的位置，并且此值介于 minimum 属性和 maximum 属性之间。
		 */
		public function set value(va:Number):void {
			_value = va
			skin.gotoAndStop((value * 100 >> 0) + 1);
			if (content) {
				content.y=_mask.y-(computeContentSize()*value)>>0
			}
			dispatchEvent(new Event('upData'))
		}
		public function get value():Number { return _value }
		public function upSlider():void {
			skin.gotoAndStop((computeNumFormContent()*100>>0)+1)
			//value = computeNumFormContent();
			
		}
		/**
		 * 根据对象计算当前百分比
		 * @return
		 */
		public function computeNumFormContent():Number {
			computeCMBool()
			return (_mask.y-content.y)/computeContentSize()
		}
		/**
		 * 计算可以移动范围
		 * @return
		 */
		public function computeContentSize():Number {
			var _size:Number = 0
			if (computeCMBool()) {
				_size = content.height - content.mask.height
				return _size
			}
			else return _size
		}
		/**
		 * 计算位置合理性
		 */
		private function  computeCMBool():Boolean {
			var bool:Boolean=false
			if (content != null && content.mask != null) {
				if (content.height > content.mask.height) bool = true
				//if (coordinateBool&&content.x > content.mask.x) content.x = content.mask.x
				if (content.y > content.mask.y) content.y = content.mask.y
				if (bool && content.y < content.mask.y &&  content.mask.y-content.y  > content.height - content.mask.height) content.y=content.mask.y-(content.height-content.mask.height)
			}
			return bool
		}
		private function contentResize(e:Event):void 
		{
			 upSlider();
		}
		
		private function mouseWheel(e:MouseEvent):void 
		{
			var num:Number=0
			if (e.delta > 0) num=this.value-.1
			else num = this.value+.1
			if (num > 1) num = 1
			if (num < 0) num = 0
			this.value=num
		}
		public function get content():DisplayObject { return _content; }
		
		private function mouseBgDown(e:MouseEvent):void 
		{
			
		}
		
	}

}