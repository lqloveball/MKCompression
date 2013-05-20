package view.projectView
{
	import com.greensock.TweenMax;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	import view.AlertPanel;
	import view.ProjectPanel;
	import view.projectListView.ProjectListItem;
	public class CompressionMiniSitePanel extends MovieClip
	{
		private var skin:CompressionMiniSitePanelSkin=new CompressionMiniSitePanelSkin();
	
		public function CompressionMiniSitePanel()
		{
			super();
			addChild(skin);
			initUI();
			
		}
		
		private var selectOutputFilesBtn:MovieClip;
		private var outputBtn:MovieClip
		private var outputDirectoryText:TextField
		private var directoryText:TextField
		private var pMc:MovieClip
		private var pMask:MovieClip;
		private var pBox:MovieClip
		private var pText:TextField;
		private function initUI():void
		{
			selectOutputFilesBtn=skin.selectOutputFiles
			outputBtn=skin.outputBtn
			directoryText=skin.directory;
			outputDirectoryText=skin.outputDirectory;
			
			Tools.setButton(selectOutputFilesBtn)
			Tools.setButton(outputBtn)
			selectOutputFilesBtn.addEventListener(MouseEvent.CLICK,selectOutputFiles)
			outputBtn.addEventListener(MouseEvent.CLICK,outputFun)
				
			pBox=skin.pMc;
			pText=skin.pMc.pText;
			pMc=skin.pMc.pMc;
			pMask=skin.pMc.pMask;
			pMc.mask=pMask;
			pMask.owidth=pMask.width;
			pMask.width=25;
		}
		
		protected function outputFun(event:MouseEvent):void
		{
			outputProject();
			
		}
		
		protected function selectOutputFiles(event:MouseEvent):void
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
		
		public var projectPanel:ProjectPanel;
		private var projectItem:ProjectListItem;
		private var projectData:Object
		private var projectFile:File;
		private var projectDirectory:File;
		private var outputDirectory:File;
		
		public function initProject():void
		{
			pBox.visible=false;
			outputDirectoryText.text='Please select a Project Directory';
			var fileStream:FileStream=new FileStream();
			fileStream.open(projectFile,FileMode.READ)
			var itemStr:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			projectData=Tools.json_decode(itemStr);
			
			if(!projectData.outputFile)projectData.outputFile='';
			
			trace('initProject site',projectData.outputFile);
			if(projectData.outputFile=='')outputDirectory=null;
			else outputDirectory=new File(projectData.outputFile);
			if(outputDirectory){
				projectData.outputFile=outputDirectory.nativePath;
				outputDirectoryText.text=outputDirectory.nativePath;
			}
			
			outputBtn.alpha=1;
			outputBtn.mouseChildren=true;
			outputBtn.mouseEnabled=true;
		}
		private function outputProject():void
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
				AlertPanel.show('error:no output directory')
				return;
			}
			else if(outputDirectory.exists&&!outputDirectory.isDirectory){
				AlertPanel.show('error:no output directory')
				return;
			}
			else if(outputDirectory.exists&&outputDirectory.isDirectory){
				outputDirectory.deleteDirectory(true)
				outputDirectory.createDirectory();
			}
			else if(!outputDirectory.exists){
				trace('outputDirectory createDirectory')
				outputDirectory.createDirectory();
			}
			trace('projectFile:',projectFile.nativePath);
			trace('projectDirectory:',projectDirectory.nativePath);
			trace('outputDirectory:',outputDirectory.nativePath,outputDirectory.exists,outputDirectory.isDirectory);
			copyToOutPutDirectory();
			trace('coypToOutPutDirectory End');
			getFileList();
			comperssionStart();
		}	
		private var jsComperssionNum:int
		private var cssComperssionNum:int
		private var allComperssionNum:int
		private function comperssionStart():void{
			outputBtn.alpha=.5;
			outputBtn.mouseChildren=false;
			outputBtn.mouseEnabled=false;
			jsComperssionNum=-1
			cssComperssionNum=-1
			allComperssionNum=jsfiles.length+cssfiles.length;
			pBox.visible=true;
			TweenMax.to(pBox,.3,{alpha:1});
			pText.text='';
			pMask.width=0;
			jsListComperssioning();
		}
		
		private function jsListComperssioning():void
		{
			jsComperssionNum++;
			if(jsComperssionNum>=jsfiles.length){
				jsListComperssionEnd();
				return;
			}
			
			var file:File=jsfiles[jsComperssionNum];
			if(isMiniJsFile(file)){
				jsListComperssioning();
				return;
			}
			var compilerFile:File=MKCompressionTools.instance.compilerFile;
			var processArgs:Vector.<String> = new Vector.<String>();
			var tempFile:File=File.applicationStorageDirectory.resolvePath('miniSiteTemp.js');
			file.copyTo(tempFile,true);
			/*
			processArgs.push('-jar');
			processArgs.push(compilerFile.nativePath);
			processArgs.push('--js');
			processArgs.push(tempFile.nativePath);
			processArgs.push('--js_output_file');
			processArgs.push(file.nativePath);
			*/
			if(MKCompressionTools.instance.jsCompresstionModel=='CC'){
				processArgs.push('-jar');
				processArgs.push(compilerFile.nativePath);
				processArgs.push('--js');
				processArgs.push(tempFile.nativePath);
				processArgs.push('--js_output_file');
				processArgs.push(file.nativePath);
				if(MKCompressionTools.instance.ccAdvanced)
				{
					processArgs.push('--compilation_level');
					processArgs.push('ADVANCED_OPTIMIZATIONS');
				}
			}else{
				
				processArgs.push('-jar');
				processArgs.push(compilerFile.nativePath);
				processArgs.push('--type');
				processArgs.push('js');
				processArgs.push('--charset');
				processArgs.push('utf-8');
				processArgs.push('-v');
				if(MKCompressionTools.instance.yuiConfusion) { processArgs.push('--nomunge'); }  //只压缩，不混淆, Minify only. Do not obfuscate local symbols.
				processArgs.push('-o');
				processArgs.push(file.nativePath);//输出文件
				processArgs.push(tempFile.nativePath); //源文件
			}
			
			
			MKCompressionTools.instance.runCompressionNativeProcess(processArgs,jsListComperssioning);
			upComperssionProgress();
		}
		
		private function jsListComperssionEnd():void
		{
			trace('jsListComperssionEnd');
			cssListComperssioning();
		}
		private function cssListComperssioning():void
		{
			cssComperssionNum++;
			if(cssComperssionNum>=cssfiles.length){
				cssListComperssionEnd();
				return;
			}
			//pText.text= 'css comperssion:'+(cssComperssionNum+1)+'/'+cssfiles.length;
			var file:File=cssfiles[cssComperssionNum];
			//如果已经是.mini.js结尾文件就不再压缩
			if(isMiniCssFile(file)){
				cssListComperssioning();
				return;
			}
			var compilerFile:File=MKCompressionTools.instance.yuicompilerFile;
			var tempFile:File=File.applicationStorageDirectory.resolvePath('miniSiteTemp.css');
			file.copyTo(tempFile,true);
			
			var processArgs:Vector.<String> = new Vector.<String>();
			processArgs.push('-jar');
			processArgs.push(compilerFile.nativePath);
			processArgs.push('--type');
			processArgs.push('css');
			processArgs.push('--charset');
			processArgs.push('utf-8');
			processArgs.push('-o');
			processArgs.push(tempFile.nativePath);
			processArgs.push(file.nativePath);
			MKCompressionTools.instance.runCompressionNativeProcess(processArgs,cssListComperssioning);
			upComperssionProgress();
		}
		
		private function cssListComperssionEnd():void
		{
			comperssionEnd();
		}
		private function comperssionEnd():void
		{
			trace('comperssionEnd');
			upComperssionProgress();
			TweenMax.to(pBox,1,{alpha:0});
			AlertPanel.show('comperssion the miniSite is completed');
			outputBtn.alpha=1;
			outputBtn.mouseChildren=true;
			outputBtn.mouseEnabled=true;
		}
		private function upComperssionProgress():void{
			pBox.visible=true;
			var _w:Number=pMask.owidth-25;
			var s:Number=(jsComperssionNum+cssComperssionNum)/allComperssionNum;
			//pMask.width=25+(s*_w);
			TweenMax.to(pMask,.5,{width:25+(s*_w)})
			
			pText.text= 'js:'+(jsComperssionNum>=jsfiles.length?jsfiles.length:(jsComperssionNum+1))+'/'+jsfiles.length +'  '+
						'css:'+(cssComperssionNum>=cssfiles.length?cssfiles.length:(cssComperssionNum+1))+'/'+cssfiles.length ;
		}
		private var jsfiles:Array
		private var cssfiles:Array
		private var htmlfiles:Array
	
		public function getFileList():void{
			jsfiles=new Array();
			cssfiles=new Array();
			htmlfiles=new Array();
			var files:Array=analysisDirectory(outputDirectory);
			analysisFiles(files);
		}
		public function copyToOutPutDirectory():void{
			var files:Array=analysisDirectory(projectDirectory);
			var length:int = files.length;
			var sourceFile:File; 
			var copyToStr:String
			var copyFile:File
			for(var i:int = 0; i < length; i++)  
			{  
				sourceFile = files[i] as File;  
				copyToStr=projectDirectory.getRelativePath(sourceFile);
				copyFile=outputDirectory.resolvePath(copyToStr);
				//trace(sourceFile.nativePath,'  ',copyFile.nativePath)
				if(sourceFile.isDirectory){
					try 
					{
						sourceFile.copyTo(copyFile,true);
					}
					catch (error:Error)
					{
						trace("copyTo Error:", error.message);
					}
				}else{
					if(sourceFile.extension.toLowerCase()!='mkproject'){
						try 
						{
							sourceFile.copyTo(copyFile,true);
						}
						catch (error:Error)
						{
							trace("copyTo Error:", error.message);
						}
					}
				}
			}
		}
		
		
		private function analysisFiles(files:Array):void{
			var length:int = files.length;
			var sourceFile:File; 
			for(var i:int = 0; i < length; i++)  
			{  
				sourceFile = files[i] as File;  
				if(sourceFile.isDirectory){
					var arr:Array=analysisDirectory(sourceFile);
					analysisFiles(arr);
				}else{
					if(sourceFile.extension.toLowerCase()=='js'){
						if(!isMiniJsFile(sourceFile))jsfiles.push(sourceFile);
					}
					else if(sourceFile.extension.toLowerCase()=='css'){
						if(!isMiniCssFile(sourceFile))cssfiles.push(sourceFile);
					}
					else if(sourceFile.extension.toLowerCase()=='html'||sourceFile.extension.toLowerCase()=='htm'){
						htmlfiles.push(sourceFile);
					}else{
					}
				}
			}
		}
		private function analysisDirectory(value:File):Array
		{
			var files:Array=value.getDirectoryListing();
			return files;
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
		/**
		 *判断是否.mini.js结尾 
		 * @param file
		 * @return 
		 * 
		 */		
		private function isMiniCssFile(file:File):Boolean{
			if(file.nativePath.length>8){
				var str:String=file.nativePath.substr(file.nativePath.length-8);
				if(str=='.min.css')return true;
				else return false;
			}
			else{
				return false;
			}
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
			projectFile=file
		}
	}
}