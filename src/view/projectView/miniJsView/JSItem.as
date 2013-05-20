package view.projectView.miniJsView
{
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	public class JSItem extends MovieClip
	{
		private var skin:JSItemSkin=new JSItemSkin();
		public function JSItem()
		{
			super();
			addChild(skin);
			initUI();
		}
		private var label:TextField
	
		private function initUI():void
		{
			label=skin.labelMc.label;
			label.text='';
			skin.gotoAndStop(1);
			this.mouseChildren=false;
			this.buttonMode=false;
			this.addEventListener(MouseEvent.MOUSE_OVER,btnOver)
			this.addEventListener(MouseEvent.MOUSE_OUT,btnOut)
			this.addEventListener(MouseEvent.CLICK,btnClick)
				
			
		}
		
		protected function btnClick(event:MouseEvent):void
		{
			
			
		}
		
		protected function btnOut(event:MouseEvent):void
		{
			Tools.movieFrame(skin,1)
			
		}
		
		protected function btnOver(event:MouseEvent):void
		{
			Tools.movieFrame(skin,skin.totalFrames)
			
		}
		public var data:Object
		
		public function setItemData(value:Object):void{
			data=value;
			var file:File=File.applicationDirectory.resolvePath(value.url)
			label.text=file.name;
			this.name=file.name
		}
		
	}
}