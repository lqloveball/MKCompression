package view
{
	import com.ixiyou.managers.AlertManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;	
	
	public class AlertPanel extends Sprite
	{
		private var skin:lib.AlertPanelSkin=new AlertPanelSkin();
		public function AlertPanel()
		{
			super();
			
			addChild(skin);
			initUI()
			addEventListener(Event.ADDED_TO_STAGE,addStage)
		}
		private function initUI():void
		{
			Tools.setButton(skin.closeBtn)
			skin.closeBtn.addEventListener(MouseEvent.CLICK,function():void{hit()});
			Tools.setButton(skin.okBtn)
			skin.okBtn.addEventListener(MouseEvent.CLICK,okBtnClick);
			
			
		}
		public static function show(value:String,fun:Function=null):void{
			var alrt:AlertPanel=new AlertPanel();
			alrt.show(value,fun);
		}
		protected function okBtnClick(event:MouseEvent):void
		{
			if(okFun!=null)okFun();
			hit()
		}
		
		private var okFun:Function=null
		public function show(value:String,fun:Function=null):void{
			okFun=fun;
			skin.errorText.text=value;
			AlertManager.getInstance().push(this,true,true,0x0);
		}
		
		protected function addStage(event:Event):void
		{
			stage.addEventListener(Event.RESIZE,reSize)
			reSize();

		}
		private function hit():void
		{
			AlertManager.getInstance().remove(this);
			
		}
		
		protected function reSize(event:Event=null):void
		{
			if(!stage)return;
			this.x=stage.stageWidth/2>>0
			this.y=stage.stageHeight/2>>0
			
		}
		
	}
}