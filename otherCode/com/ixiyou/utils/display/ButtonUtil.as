package com.ixiyou.utils.display 
{
	import flash.display.*
	import flash.events.*

	/**
	 * 按钮处理
	 * @author spe
	 */
	public class ButtonUtil 
	{
		/**
		 * 转移焦点
		 * @param	oldBtn
		 * @param	hitBtn
		 */
		public static function hitAreaToOther(oldBtn:Sprite,hitBtn:Sprite):void {
			oldBtn.hitArea = hitBtn
			hitBtn.mouseChildren=false
			hitBtn.mouseEnabled =false
		}
		/**
		 * 设置无鼠标事件
		 * @param	btn
		 */
		public static function setNoMouse(btn:MovieClip):void {
			btn.gotoAndStop(1)
			btn.mouseChildren = false;
			btn.mouseEnabled = false;
		}
		/**
		 * 设置按钮
		 * @param	btn
		 */
		public static function setButton(btn:MovieClip, btn_mode:String = ''):void {
			if (!btn) return;
			btn.gotoAndStop(1)
			btn.mouseChildren = false;
			btn.buttonMode = true;
			if(btn_mode!='')btn.btn_mode=btn_mode
			btn.addEventListener(MouseEvent.MOUSE_OVER, buttonOver)
			btn.addEventListener(MouseEvent.MOUSE_OUT, buttonOut)	
		}
		
		static private function buttonOut(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			//btn.currentFrame
			if (btn.btn_mode == 'label') {
				MovieUtils.movieFrame(btn,'off')
			}
			else {
				MovieUtils.movieFrame(btn,1)
			}
		}
		
		static private function buttonOver(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			if (btn.btn_mode == 'label') {
				MovieUtils.movieFrame(btn,'on')
			}else {
				
				MovieUtils.movieFrame(btn,btn.totalFrames)
			}
		}
		/**
		 * 设置选择按钮
		 * @param	btn
		 * @param	select
		 */
		public static function setSelectBtn(btn:MovieClip, select:Boolean = true):void {
			if (select) btn.gotoAndStop(btn.totalFrames)
			else btn.gotoAndStop(1)
			btn.mouseChildren = false;
			btn.buttonMode = true;
			btn.select = select
			btn.addEventListener(MouseEvent.MOUSE_OVER,selectBtnOver)
			btn.addEventListener(MouseEvent.MOUSE_OUT,selectBtnOut)	
			btn.addEventListener(MouseEvent.CLICK,selectBtnClick)
		}
		
		static private function selectBtnClick(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			btn.select = !btn.select
			if (btn.select) btn.gotoAndStop(btn.totalFrames)
			else btn.gotoAndStop(1);
			btn.dispatchEvent(new Event('upSelect'))
		}
		
		static private function selectBtnOut(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			if (btn.select) {
				btn.gotoAndStop(btn.totalFrames)
			}else {
				btn.gotoAndStop(1);
			}
		}
		
		static private function selectBtnOver(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			if (btn.select) {
				btn.gotoAndStop(btn.totalFrames)
			}else {
				MovieUtils.movieFrame(btn,(btn.totalFrames-1))
			}
		}
		/**
		 * 设置选择按钮组
		 * @param	arr
		 * @param	select
		 */
		public static function setSelectArr(arr:Array, select:Number = 0):void {
			var btn:MovieClip 
			for (var i:int = 0; i < arr.length; i++) 
			{
				btn = arr[i] as MovieClip;
				btn.gotoAndStop(1);
				btn.selectButtonArr = arr
				btn.mouseChildren = false;
				btn.buttonMode = true;
				btn.select = false
				btn.id=i
				btn.addEventListener(MouseEvent.CLICK,selectArrClick)
				btn.addEventListener(MouseEvent.MOUSE_OVER,selectArrOver)
				btn.addEventListener(MouseEvent.MOUSE_OUT, selectArrOut)
			}
			if (select >= 0) {
				btn = arr[select];
				if (btn) setSelectArrByBtn(btn)
			}
		}
		
		static private function selectArrOut(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			//trace('Out',btn.select,btn.currentFrame,btn.totalFrames)
			if (btn.select) {
				MovieUtils.removeMovie(btn)
				btn.gotoAndStop(btn.totalFrames)
				//MovieUtils.movieFrame(btn,btn.totalFrames)
			}else {
				MovieUtils.movieFrame(btn,1)
			}
		}
		
		static private function selectArrOver(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			//trace('Over',btn.select,btn.currentFrame,btn.totalFrames)
			if (btn.select) {
				//MovieUtils.movieFrame(btn,btn.totalFrames)
				MovieUtils.removeMovie(btn)
				btn.gotoAndStop(btn.totalFrames)
			}else {
				MovieUtils.movieFrame(btn,(btn.totalFrames-1))
			}
		}
		
		static private function selectArrClick(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			if (!btn.select) {
				setSelectArrByBtn(btn)
			}
			
			
		}
		/**
		 * 设置选择的按钮
		 * @param	value
		 */
		public  static function setSelectArrByBtn(value:MovieClip):void {
			var btn:MovieClip = value as MovieClip
			btn.select = true;
			if (btn.select) btn.gotoAndStop(btn.totalFrames)
			var arr:Array=btn.selectButtonArr
			for (var i:int = 0; i < arr.length; i++) 
			{
				var temp:MovieClip = arr[i] as MovieClip;
				if (temp != btn) {
					temp.select = false
					temp.gotoAndStop(1);
				}
				else {
					temp.select = true
					temp.gotoAndStop(btn.totalFrames)
				}
			}
			btn.dispatchEvent(new Event('upSelect'))
		}
		
		/**
		 * 设置选择按钮
		 * @param	btn
		 */
		public static function setSelectButton(btn:MovieClip,select:Boolean=true):void {
			if (select) btn.gotoAndStop('on')
			else btn.gotoAndStop('off')
			btn.mouseChildren = false;
			btn.buttonMode = true;
			btn.select = select
			btn.selectButtonType='setSelectButton'
			btn.addEventListener(MouseEvent.MOUSE_OVER,selectButtonOver)
			btn.addEventListener(MouseEvent.MOUSE_OUT,selectButtonOut)	
			btn.addEventListener(MouseEvent.CLICK,selectButtonClick)
		}
		static private function selectButtonClick(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			if (btn.select) btn.select = false
			else btn.select = true
			if (btn.select)btn.gotoAndStop('on')
			else btn.gotoAndStop('off')
			btn.dispatchEvent(new Event('upSelect'))
		}
		/**
		 * 有 off on select
		 * @param	arr
		 */
		public static function setSelectButtonArr2(arr:Array,select:Number=0):void {
			for (var i:int = 0; i < arr.length; i++) 
			{
				var item:MovieClip = arr[i] as MovieClip;
				item.selectButtonArr = arr
				item.selectButtonType='select'
				ButtonUtil.setSelectButton(item)
				item.removeEventListener(MouseEvent.CLICK,selectButtonClick)
				item.addEventListener(MouseEvent.CLICK, selectButtonFun2)
				
			}
			item = arr[select]
			setSelecItem2(item)
		}
		/**
		 * 设置单选项2
		 * @param	btn
		 */
		public static function setSelecItem2(btn:MovieClip):void {
			var arr:Array = btn.selectButtonArr
			//trace(arr.length)
			for (var i:int = 0; i < arr.length; i++) 
			{
				var item:MovieClip = arr[i];
				//trace(i,item == btn)
				if (item == btn) {
					if (!item.select) {
						btn.dispatchEvent(new Event('upSelect'))
					}
					item.select=true
					item.gotoAndStop('select')
				}else {
					item.select=false
					MovieUtils.movieFrame(item,'off')
				}
			}
		}
		static private function selectButtonFun2(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			setSelecItem2(btn)
		}
		/**
		 * 只有 off on 
		 * @param	arr
		 */
		public static function setSelectButtonArr(arr:Array,select:Number=0,no:Boolean=false):void {
			for (var i:int = 0; i < arr.length; i++) 
			{
				var item:MovieClip = arr[i] as MovieClip;
				item.selectButtonArr = arr
				ButtonUtil.setSelectButton(item)
				if(no)item.gotoAndStop('off')
				item.removeEventListener(MouseEvent.CLICK,selectButtonClick)
				item.addEventListener(MouseEvent.CLICK, selectButtonFun)
				//if (i == select) {
					//item.select=true
					//MovieUtils.movieFrame(item,'on')
				//}
				if(select!=-1)setSelecItem(arr[select])
			}
		}
		/**
		 * 设置单选项2
		 * @param	btn
		 */
		public static function setSelecItem(btn:MovieClip):void {
			var arr:Array = btn.selectButtonArr
			//trace(arr.length)
			for (var i:int = 0; i < arr.length; i++) {
				var item:MovieClip = arr[i];
				if (item == btn) {
					if (!item.select) {
						btn.dispatchEvent(new Event('upSelect'))
					}
					//trace()
					item.select=true
					MovieUtils.movieFrame(item, 'on')
				}else {
					item.select=false
					MovieUtils.movieFrame(item,'off')
				}
			}
		}
		static private function selectButtonFun(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			var arr:Array = btn.selectButtonArr
			setSelecItem(btn)
			return
			//trace(arr.length)
			for (var i:int = 0; i < arr.length; i++) 
			{
				var item:MovieClip = arr[i];
				if (item == btn) {
					item.select=true
					MovieUtils.movieFrame(item, 'on')
					//btn.dispatchEvent(new Event('upSelect'))
				}else {
					item.select=false
					MovieUtils.movieFrame(item,'off')
				}
			}
		}
		/**
		 * 有 off on   off1 on1
		 * @param	arr
		 */
		public static function setSelectButtonArr3(arr:Array, select:Number = 0):void {
			//var arr2:Array=arr.concat()
			for (var i:int = 0; i < arr.length; i++) 
			{
				var item:MovieClip = arr[i] as MovieClip;
				item.selectButtonArr = arr
				item.selectButtonType='select2'
				ButtonUtil.setSelectButton(item)
				item.removeEventListener(MouseEvent.CLICK,selectButtonClick)
				item.addEventListener(MouseEvent.CLICK, selectButtonFun3)
				
			}
			item = arr[select]
			setSelecItem3(item)
			
		}
		/**
		 * 设置单选项3
		 * @param	btn
		 */
		public static function setSelecItem3(btn:MovieClip):void {
			var arr:Array = btn.selectButtonArr
			//trace('-----', arr.length)
			for (var i:int = 0; i < arr.length; i++) 
			{
				var item:MovieClip = arr[i];
				if (item == btn) {
					//trace('true---'+item.num,item.select)
					if (item.select) {
						//item.gotoAndStop('on')
						MovieUtils.movieFrame(item,'on')
					}else {
						item.gotoAndStop('off')
						item.gotoAndStop('on')
						MovieUtils.movieFrame(item, 'on')
						btn.dispatchEvent(new Event('upSelect'))
					}
					item.select = true
				}else{

					if (item.select != false) {
						item.gotoAndStop('on')
						MovieUtils.movieFrame(item, 'off' )
					}else {
						if (item.currentFrameLabel == 'on1') MovieUtils.movieFrame(item, 'off1')
						else item.gotoAndStop('off1')	
					}
					item.select = false
				}
			}
		}
		static private function selectButtonFun3(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			setSelecItem3(btn)
		}
		
		
		static private function selectButtonOut(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			if (btn.selectButtonType && btn.selectButtonType == 'select') {
				if (btn.select)btn.gotoAndStop('select')
				else MovieUtils.movieFrame(btn,'off')
			}else if (btn.selectButtonType && btn.selectButtonType == 'select2') {
				if (btn.select) {
					MovieUtils.movieFrame(btn,'on')
				}
				else {
					btn.gotoAndStop('on1')
					MovieUtils.movieFrame(btn,'off1')
				}
			}else if (btn.selectButtonType&&btn.selectButtonType == 'setSelectButton') {
				if (btn.select)MovieUtils.movieFrame(btn,'on')
				else MovieUtils.movieFrame(btn,'off')
			}
			else {
				if (btn.select)btn.gotoAndStop('on')
				else MovieUtils.movieFrame(btn,'off')
			}
			
		}
		
		static private function selectButtonOver(e:MouseEvent):void 
		{
			var btn:MovieClip = e.target as MovieClip
			if (btn.selectButtonType && btn.selectButtonType == 'select') {
				if (btn.select) {
					MovieUtils.movieFrame(btn,'on')
				}
				else {
					MovieUtils.movieFrame(btn,'on')
				}
			}else if (btn.selectButtonType && btn.selectButtonType == 'select2') {
				if (btn.select) {
					//btn.gotoAndStop('off')
					MovieUtils.movieFrame(btn,'on')
				}
				else {
					btn.gotoAndStop('off1')
					MovieUtils.movieFrame(btn,'on1')
				}
			}else if (btn.selectButtonType&&btn.selectButtonType == 'setSelectButton') {
				if (btn.select)MovieUtils.movieFrame(btn,'on')
				else MovieUtils.movieFrame(btn,'on')
			}
			else {
				if (btn.select)MovieUtils.movieFrame(btn,'on')
				else MovieUtils.movieFrame(btn,'off')
			}
		}
	}

}