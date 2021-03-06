package view.projectListView
{
	import com.ixiyou.managers.AlertManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	import view.ProjectPanel;
	

	public class NewProjectPanel extends MovieClip
	{
		private var skin:lib.NewProjectPanelSkin=new NewProjectPanelSkin();
		public function NewProjectPanel()
		{
			super();
			addChild(skin);
			initUI();
			addEventListener(Event.ADDED_TO_STAGE,addStage)
		
		}
		private var projectNameText:TextField
		private var projectDirectoryText:TextField
		private function initUI():void
		{
			Tools.setButton(skin.closeBtn)
			skin.closeBtn.addEventListener(MouseEvent.CLICK,function():void{hit()});
			
		
			var arr:Array=[];
			for (var i:int = 0; i <2; i++) 
			{
				var mc:MovieClip=skin['mc'+i] as MovieClip;
				mc.id=i;
				arr.push(mc);
				mc.addEventListener(MouseEvent.CLICK,selectTypeFun)
			}
			Tools.setSelectArr(arr);
			
			projectDirectoryText=skin.projectDirectoryText
			projectDirectoryText.text='select Project Directory';
			//Project Directory 
			//Tools.addDefaultInfo(outputText,'');
			
			projectNameText=skin.projectNameText;
			Tools.addDefaultInfo(projectNameText,'');
			Tools.setTxtInData(projectNameText,"A-Z a-z 0-9 _-");
			
			Tools.setButton(skin.selectProjectDirectory);
			Tools.setButton(skin.okBtn);
			
			skin.selectProjectDirectory.addEventListener(MouseEvent.CLICK,selectProjectDirectory);
			skin.okBtn.addEventListener(MouseEvent.CLICK,cProjectFun)
			
		}
		
		protected function cProjectFun(event:MouseEvent):void
		{
			projectName=projectNameText.text;
			var file:File
			var fileStream:FileStream
			file=projectFile.resolvePath(projectName+'.mkproject');
			
			
			var projectData:Object={};
			projectData.projectName=projectName;
			projectData.projectType=selectType;
			projectData.projectFile=file.nativePath;
			projectData.fileList=[];
			fileStream= new FileStream();
			fileStream.open(file,FileMode.WRITE);
			var projectSaveData:String=Tools.json_encode(projectData);
			fileStream.writeUTFBytes(projectSaveData);
			fileStream.close();
			projectData.project=file.nativePath;
			
			projectPanel.addProject(file);
			
			hit();
		}
		private var projectFile:File=new File();
		protected function selectProjectDirectory(event:MouseEvent):void
		{
			try
			{
				projectFile.browseForDirectory("select Project Directory");
				projectFile.addEventListener(Event.SELECT, projectFileSelected);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
		}
		
		protected function projectFileSelected(event:Event):void
		{
			//var directory:File = event.target as File;
			//trace(projectFile.nativePath);
			var name:String=projectFile.nativePath.substr(projectFile.nativePath.lastIndexOf('/')+1);
			projectDirectoryText.text=projectFile.nativePath;
			projectNameText.text=name;
			projectName=name;
		}
		
		private var selectType:String='miniJs';
		private var projectName:String='';
		public var projectPanel:ProjectPanel;
		protected function selectTypeFun(event:MouseEvent):void
		{
			var mc:MovieClip=event.target as MovieClip;
			if(mc.id==0)selectType='miniJs';
			else selectType='miniSite';
		}
		protected function addStage(event:Event):void
		{
			stage.addEventListener(Event.RESIZE,reSize)
			reSize();
			
			selectType='miniJs';
			Tools.setSelectArrByBtn(skin.mc0);
			
			projectDirectoryText.text=''
			projectNameText.text='';
			
			projectName='';
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