package view.projectListView
{
	import com.ixiyou.managers.AlertManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	import view.ProjectPanel;
	
	public class RemoveProjectAlert extends MovieClip
	{
		private var skin:RemoveProjectAlertSkin=new RemoveProjectAlertSkin();
		public var projectPanel:ProjectPanel;
		public function RemoveProjectAlert()
		{
			super();
			addChild(skin);
			initUI();
			addEventListener(Event.ADDED_TO_STAGE,addStage);
		}
		
		
		
		protected function addStage(event:Event):void
		{
			stage.addEventListener(Event.RESIZE,reSize)
			reSize();
			
		}
		protected function reSize(event:Event=null):void
		{
			if(!stage)return;
			this.x=this.stage.stageWidth/2>>0;
			this.y=this.stage.stageHeight/2>>0;
		}
		private function initUI():void
		{
			Tools.setButton(skin.closeBtn)
			skin.closeBtn.addEventListener(MouseEvent.CLICK,function():void{hit()});
			
			Tools.setButton(skin.okBtn)
			Tools.setButton(skin.cancelBtn);
			skin.okBtn.addEventListener(MouseEvent.CLICK,okFun)
			skin.cancelBtn.addEventListener(MouseEvent.CLICK,cancelFun)
		}
		
		protected function cancelFun(event:MouseEvent):void
		{
			hit();
		}
		
		protected function okFun(event:MouseEvent):void
		{
			projectPanel.removeProjec();	
			hit();
		}
		
		private function hit():void
		{
			AlertManager.getInstance().remove(this);
			
		}
	}
}