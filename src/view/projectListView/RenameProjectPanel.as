package view.projectListView
{
	import com.ixiyou.managers.AlertManager;
	import com.ixiyou.utils.StringUtil;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	import view.ProjectPanel;
	
	public class RenameProjectPanel extends MovieClip
	{
		private var skin:lib.RenameProjectPanelSkin=new RenameProjectPanelSkin();
		private var renameText:TextField;
		private var renameBtn:MovieClip;
		public function RenameProjectPanel()
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
			
			renameText=skin.renameText;
			renameBtn=skin.renameBtn;
			
			renameText.text='';
			Tools.setTxtInData(renameText,"A-Z a-z 0-9 _-");
			Tools.setButton(renameBtn);
			
			renameBtn.addEventListener(MouseEvent.CLICK,renameFun)
			
		}
		
		protected function renameFun(event:MouseEvent):void
		{
			var rename:String=renameText.text
			rename=StringUtil.trim(rename);
			if(rename=='')hit();
			else if(rename==data.projectName)hit();
			else {
				projectPanel.renameProject(rename)
				hit();
			}
			
		}
		
		
		private function hit():void
		{
			AlertManager.getInstance().remove(this);
			
		}
		private var data:Object
		public var projectPanel:ProjectPanel;
		public function initProject(selectItem:ProjectListItem):void
		{
			renameText.text='';
			data=selectItem.data;
			renameText.text=data.projectName;
		}
	}
}