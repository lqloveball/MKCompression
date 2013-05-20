package view.projectView
{
	import com.ixiyou.managers.AlertManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	import view.AlertPanel;
	import view.ProjectPanel;
	import view.projectListView.ProjectListItem;
	import view.projectView.miniJsView.MiniJsListPanel;
	
	
	public class CompressionMiniJsPanel extends MovieClip
	{
		private var skin:CompressionMiniJsPanelSkin=new CompressionMiniJsPanelSkin();
		public var projectPanel:ProjectPanel;
		private var compressioning:CompressioningSkin=new CompressioningSkin();
		public function CompressionMiniJsPanel()
		{
			super();
			addChild(skin);
			initUI()
		}
		private var selectOutputFilesBtn:MovieClip;
		private var outputBtn:MovieClip
		private var upFilesBtn:MovieClip
		private var outputDirectoryText:TextField;
		private var compresstionJsText:TextField;
		
		
		
		private var list:MiniJsListPanel=new MiniJsListPanel();
		private function initUI():void
		{
			
			outputDirectoryText=skin.outDirectory;
			compresstionJsText=skin.compresstionJsText;
			selectOutputFilesBtn=skin.selectOutputFiles;
			outputBtn=skin.outputBtn;
			upFilesBtn=skin.upFilesBtn;
			
			Tools.setButton(selectOutputFilesBtn);
			Tools.setButton(outputBtn);
			Tools.setButton(upFilesBtn);
			selectOutputFilesBtn.addEventListener(MouseEvent.CLICK,function():void{selectOutputFiles()})
			outputBtn.addEventListener(MouseEvent.CLICK,function():void{output();})
			upFilesBtn.addEventListener(MouseEvent.CLICK,function():void{upFiles();})
			
			list.miniJsPanel=this;
			addChild(list)
			list.x=skin.list.x;
			list.y=skin.list.y;
			skin.removeChild(skin.list);
		}
		
		
		private function selectOutputFiles():void
		{
			var file:File=new File();
			file.browseForDirectory("select Project Directory");
			file.addEventListener(Event.SELECT, outputFileSelected);
			
		}
		protected function outputFileSelected(event:Event):void
		{
			var directory:File = event.target as File;
			outputDirectoryText.text=directory.nativePath;
			projectData.outputFile=directory.nativePath;
			upListToProjectlist();
		}
		
		private function output():void
		{
			if(!projectFile||!projectFile.exists){
				AlertPanel.show('error:no project file')
				return;
			}
			
			projectDirectory=projectFile.parent;
			if(!projectDirectory||!projectDirectory.exists){
				AlertPanel.show('error:no project Directory');
				return;
			}
			if(outputDirectory==null){
				AlertPanel.show('error:no output directory');
				return;
			}
			else if(!outputDirectory.exists){
				trace('outputDirectory createDirectory');
				outputDirectory.createDirectory();
			}
			
			AlertManager.getInstance().push(compressioning);
			compressioning.x=stage.stageWidth/2>>0;
			compressioning.y=stage.stageHeight/2>>0;
			
			var compilerFile:File=MKCompressionTools.instance.compilerFile;
			var processArgs:Vector.<String> = new Vector.<String>();
			processArgs.push('-jar');
			processArgs.push(compilerFile.nativePath);
			var cList:Array=list.getCompressionArray();
			for (var i:int = 0; i < cList.length; i++) 
			{
				var obj:Object=cList[i];
				processArgs.push('--js');
				processArgs.push(obj.url);
			}
			processArgs.push('--js_output_file');
			processArgs.push(outputDirectory.nativePath+'/'+compresstionJsText.text+'.min.js');
			MKCompressionTools.instance.runCompressionNativeProcess(processArgs,outputEnd);	
		}
		
		private function outputEnd():void
		{
			AlertManager.getInstance().remove(compressioning);
			AlertPanel.show('Compression min.js Ok');
		}
		private var projectItem:ProjectListItem;
		private var projectData:Object
		private var projectFile:File;
		private var projectDirectory:File;
		private var outputDirectory:File;
		public function initProject():void
		{
			outputDirectoryText.text='Please select a Project Directory';
			var fileStream:FileStream=new FileStream();
			fileStream.open(projectFile,FileMode.READ)
			var itemStr:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			
			trace('initProject site',itemStr);
			projectData=Tools.json_decode(itemStr);
			if(!projectData.outputFile)projectData.outputFile='';
			if(projectData.outputFile==''){
				outputDirectory=projectFile.parent;
				projectData.outputFile=outputDirectory.nativePath;
				upListToProjectlist();
			}
			else{
				outputDirectory=new File(projectData.outputFile);
			}
			if(outputDirectory){
				projectData.outputFile=outputDirectory.nativePath;
				outputDirectoryText.text=outputDirectory.nativePath;
			}
			Tools.addDefaultInfo(compresstionJsText,'');
			compresstionJsText.text=projectData.projectName;
			skin.projectDirectory.text=projectFile.parent.nativePath;
			
			upFiles();
		}
		private function upFiles():void
		{
			list.clearAll();
			getAllProjectJSFiles();
			analysisAllProjectJSFiles();
			var fileList:Array=projectData.fileList;
			list.iniList(fileList)	
			
			projectData.fileList=list.getFileListArray();
			upListToProjectlist();
		}
		public function upJSLists():void{
			projectData.fileList=list.getFileListArray();
			upListToProjectlist();
		}
		/**
		 *分析处理所有项目里面js文件 
		 * 
		 */		
		private function analysisAllProjectJSFiles():void
		{
			var i:int
			var file:File
			var url:String
			var fileList:Array=projectData.fileList;
			var projectFileList:Array=new Array();//项目目前文件路径
			var directoryFileList:Array=new Array();//项目文件夹实际文件路径
			var deleteList:Array=new Array();//删除文件路径
			
			//项目目前文件路径
			for (i = 0; i < fileList.length; i++) 
			{
				url=fileList[i].url;
				projectFileList.push(url);
			}
			//项目文件夹实际文件路径
			for (i = 0; i < allProjectJSFileArr.length; i++) 
			{
				url=File(allProjectJSFileArr[i]).nativePath;
				directoryFileList.push(url);
			}
			//判断新添加文件路径
			var addFileList:Array=new Array();
			for (i = 0; i < directoryFileList.length; i++) 
			{
				
				if(projectFileList.indexOf(directoryFileList[i])==-1){
					addFileList.push(directoryFileList[i]);
				}
			}
			//判断出过期需要删除的文件路径
			for (i = 0; i < projectFileList.length; i++) 
			{
				if(directoryFileList.indexOf(projectFileList[i])==-1){
					deleteList.push(projectFileList[i])
				}
			}
			
			//trace('old fileList:',fileList.length);
			var obj:Object;
			//进行添加
			for (i = 0; i < addFileList.length; i++) 
			{
				obj={};
				obj.url=addFileList[i];
				obj.hit=false;
				fileList.push(obj);
			}
			//var len:uint=fileList.length
			var newList:Array=[]
			//进行删除
			for (i = 0; i < fileList.length; i++) 
			{
				url=fileList[i].url;
				if(deleteList.indexOf(url)==-1)newList.push(fileList[i]);
			}
			fileList=newList;
			projectData.fileList=fileList;
			/*
			trace('deleteList:',deleteList.length);
			trace('addFileList:',addFileList.length);
			trace('allProjectJSFileArr:',allProjectJSFileArr.length);
			trace('projectFileList:',projectFileList.length);
			trace('new fileList:',fileList.length);
			*/
		}
		
		/**
		 *获取项目所有js文件 
		 * 
		 */	
		private var allProjectJSFileArr:Array
		private function getAllProjectJSFiles():void
		{
			
			allProjectJSFileArr=new Array();
			var files:Array=analysisDirectory(projectDirectory);
			getAllProjectJSFilesing(files);
		}	
		private function getAllProjectJSFilesing(files:Array):void
		{
			var length:int = files.length;
			var sourceFile:File; 
			for(var i:int = 0; i < length; i++)  
			{  
				sourceFile = files[i] as File; 
				if(sourceFile.isDirectory){
					var arr:Array=analysisDirectory(sourceFile);
					getAllProjectJSFilesing(arr);
				}else{
					if(sourceFile.extension.toLowerCase()=='js'){
						if(!isMiniJsFile(sourceFile))allProjectJSFileArr.push(sourceFile);
					}
				}
			}
		}
		private function analysisDirectory(value:File):Array
		{
			var files:Array=value.getDirectoryListing();
			return files;
		}	
		
		public function upListToProjectlist():void{
			if(!projectData)return;
			if(projectFile&&projectFile.exists){
				var fileStream:FileStream=new FileStream();
				fileStream.open(projectFile,FileMode.UPDATE)
				fileStream.writeUTFBytes(Tools.json_encode(projectData));
				fileStream.close();
			}
			if(projectItem)projectItem.setData(projectData);
			if(projectPanel)projectPanel.projectListBox.upListToProjectlist();
		}
		public function setItem(item:ProjectListItem):void
		{
			projectItem=item;
		}
		
		public function setProjectFile(file:File):void
		{
			projectFile=file;
			projectDirectory=projectFile.parent
		}
		/**
		 *判断是否.mini.js结尾 
		 * @param file
		 * @return 
		 * 
		 */		
		private function isMiniJsFile(file:File):Boolean{
			if(file.nativePath.length>7){
				var str:String=file.nativePath.substr(file.nativePath.length-7);
				if(str=='.min.js')return true;
				else return false;
			}
			else{
				return false;
			}
		}
	}
}