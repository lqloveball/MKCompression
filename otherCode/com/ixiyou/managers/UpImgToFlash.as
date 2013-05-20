package com.ixiyou.managers 
{
	import com.greensock.loading.*;
	import com.greensock.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.net.*;
	[Event(name="loadEnd", type="flash.events.Event")]
	/**
	 * 快速进行选择图片上传编辑操作
	   import com.ixiyou.managers.UpImgToFlash
	   var upImger:UpImgToFlash=new UpImgToFlash()
	   upImger.setUI(box,btn);
	 * @author maskim
	 */
	public class UpImgToFlash extends EventDispatcher 
	{
		private var file:FileReference;
		private var loader:Loader;
		
		public function UpImgToFlash(box:Sprite=null, selectBtn:MovieClip=null, cancelBtn:MovieClip=null):void
		{
			setUI(box, selectBtn, cancelBtn);
		}
		public var box:Sprite
		public var selectBtn:MovieClip
		public var cancelBtn:MovieClip
		private var _imgBox:Sprite 
		
		public var width:Number
		public var height:Number
		private var _dragBool:Boolean=true
		/**
		 * 
		 * @param	box
		 * @param	selectBtn
		 * @param	cancelBtn
		 */
		public function setUI(box:Sprite=null, selectBtn:MovieClip=null, cancelBtn:MovieClip=null):void {
			this.box = box;
			if (this.box) {
				width=this.box.width
				height=this.box.height
			}
			this.selectBtn = selectBtn;
			this.cancelBtn = cancelBtn;
			if (this.selectBtn) {
				Tools.setButton(this.selectBtn)
				this.selectBtn.addEventListener(MouseEvent.CLICK,selectFun)
			}
			if (this.cancelBtn) {
				Tools.setButton(this.cancelBtn)
				this.cancelBtn.addEventListener(MouseEvent.CLICK,cancelFun)
			}
		}
		
		private function cancelFun(e:MouseEvent):void 
		{
			
		}
		
		private function selectFun(e:MouseEvent):void 
		{
			file=new FileReference();
			
			file.addEventListener(Event.SELECT, onFileSelected);
			file.addEventListener(Event.COMPLETE, onFileLoaded);
			file.browse([new FileFilter("选择图片", "*.jpg;*.png")]);
			
		}
		private  function onFileSelected(e:Event):void {
			var file:FileReference=e.target as FileReference
			file.addEventListener(Event.COMPLETE,onFileLoaded);
			file.addEventListener(Event.OPEN,function():void{trace('file load start')});
			file.load();
		}
		
		private  function onFileLoaded(e:Event):void {
			if(loader)loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,imgLoadEnd)
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imgLoadEnd)
			loader.loadBytes(file.data)
		}
		
		private function imgLoadEnd(e:Event):void 
		{
			trace('imgLoadEnd')
			_imgBox = new Sprite();
			imgBox.addChild(loader);
			loader.x = -(loader.width / 2 >> 0);
			loader.y = -(loader.height / 2 >> 0);
			if (box) {
				while (box.numChildren > 0) box.removeChildAt(0)
				box.addChild(imgBox)
				imgBox.x = width / 2 >> 0;
				imgBox.y = height / 2 >> 0;
				
			}
			imgBox.addEventListener(MouseEvent.MOUSE_DOWN,imgDown)
			dispatchEvent(new Event('loadEnd'));
		}
		
		private function imgDown(e:MouseEvent):void 
		{
			if (dragBool) {
				imgBox.startDrag()
				imgBox.stage.addEventListener(MouseEvent.MOUSE_UP,stageUP)
			}
		}
		
		private function stageUP(e:MouseEvent):void 
		{
			imgBox.stage.removeEventListener(MouseEvent.MOUSE_UP, stageUP)
			imgBox.stopDrag();
			//imgBox.stage.addChild(getBmp())
		}
		
		public function get imgBox():Sprite 
		{
			return _imgBox;
		}
		
		public function get dragBool():Boolean 
		{
			return _dragBool;
		}
		
		public function set dragBool(value:Boolean):void 
		{
			_dragBool = value;
		}
		
		public function getBmp():Bitmap {
			var bmp:Bitmap = new Bitmap(getBmpDta());
			//bmp.bitmapData.draw(box);
			return bmp
		}
		
		public function getBmpDta():BitmapData {
			var bmp:BitmapData = new BitmapData(width, height)
			bmp.draw(box)
			return bmp
		}
		
	}

}