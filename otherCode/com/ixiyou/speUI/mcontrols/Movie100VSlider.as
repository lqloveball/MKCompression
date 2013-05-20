package com.ixiyou.speUI.mcontrols 
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.net.*;
	
	/**
	 * ...
	 * @author maskim
	 */
	public class Movie100VSlider extends Sprite 
	{
		private var _value:Number=0;
		private var _width:Number;
		private var _height:Number;
		private var _slider:MovieClip;
		protected var _skin:MovieClip
		public function Movie100VSlider(skin:MovieClip,formerly:Boolean = true,parentBool:Boolean=true,config:*= null) 
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
		private function mouseBgDown(e:MouseEvent):void 
		{
			
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
		 * 包含滑块的位置，并且此值介于 minimum 属性和 maximum 属性之间。
		 */
		public function set value(va:Number):void {
			_value = va
			if (_value > 1)_value = 1;
			if(_value<0)_value=0
			skin.gotoAndStop((value * 100 >> 0) + 1);
			dispatchEvent(new Event('upData'))
		}
		public function get value():Number { return _value }
		
	}

}