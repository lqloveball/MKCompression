package
{
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	
	import view.AlertPanel;
	import view.DragFileAlert;
	
	public class MKCompressionTools extends EventDispatcher
	{
		public function MKCompressionTools(){}
		private static var _instance:MKCompressionTools
		
		
		public static function get instance():MKCompressionTools {
			if (!_instance)_instance = new MKCompressionTools()
			return _instance
		}
		
		private var _root:MovieClip
		public var dragFileAlert:DragFileAlert;
		
		public function get root():MovieClip{return _root;}
		public function set root(value:MovieClip):void{
			_root = value;
			_compilerFile=File.applicationDirectory.resolvePath('tools/compiler.jar');
			_yuicompilerFile = File.applicationDirectory.resolvePath('tools/yuicompressor.jar');
			DebugOutput.add('本地进程程序是否支持:', NativeProcess.isSupported);
		}
		public var jsCompresstionModel:String='CC'//'YUI CC';
		public var yuiConfusion:Boolean=false;//YUI是否开启混淆
		public var ccAdvanced:Boolean=false;//CC是否开启高级默认
		public var javaFileUrl:String='/usr/bin/java';
		public function initConfing():void{
			var file:File=File.applicationStorageDirectory.resolvePath('confing.json');
			var fileStream:FileStream = new FileStream();
			try
			{
				fileStream.open(file,FileMode.UPDATE);
			}
			catch (error:Error)
			{
				return;
			}
			var confing:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
			var confingData:Object;
			if(confing==''){
				confingData={};
				jsCompresstionModel='CC';
				yuiConfusion=false;
				ccAdvanced=false;
				if (Capabilities.os.toLowerCase().indexOf("win") >= 0){
					if (Capabilities.supports64BitProcesses)javaFileUrl = 'file:///C:/Program%20Files%20(x86)/Java/jre6/bin/java.exe'
					else javaFileUrl='file:///C:/Program%20Files/Java/jre6/bin/java.exe';
				}else if(Capabilities.os.toLowerCase().indexOf("mac") >= 0){
					javaFileUrl='/usr/bin/java';
				}
				confingData.jsCompresstionModel=jsCompresstionModel;
				confingData.yuiConfusion=yuiConfusion;
				confingData.ccAdvanced=ccAdvanced;
				confingData.javaFileUrl=javaFileUrl;
				confing=Tools.json_encode(confingData)
				fileStream.writeUTFBytes(confing);
				fileStream.close();
			}else{
				confingData=Tools.json_decode(confing);
				fileStream.close();
			}
			jsCompresstionModel=confingData.jsCompresstionModel
			yuiConfusion=confingData.yuiConfusion
			ccAdvanced=confingData.ccAdvanced
			javaFileUrl=confingData.javaFileUrl;
			
		};
		public function upConfing():void{
			var file:File=File.applicationStorageDirectory.resolvePath('confing.json');
			var fileStream:FileStream = new FileStream();
			try
			{
				fileStream.open(file,FileMode.UPDATE);
			}
			catch (error:Error)
			{
				return;
			}
			var confing:String;
			var confingData:Object={};
			confingData.jsCompresstionModel=jsCompresstionModel;
			confingData.yuiConfusion=yuiConfusion;
			confingData.ccAdvanced=ccAdvanced;
			confingData.javaFileUrl=javaFileUrl;
			confing=Tools.json_encode(confingData)
			fileStream.writeUTFBytes(confing);
			fileStream.close();
		}
		private function selectJavaPath():void
		{
			var file:File;
			var txtFilter:FileFilter
			if (Capabilities.os.toLowerCase().indexOf("win") >= 0){
				if (Capabilities.supports64BitProcesses)file = File.applicationDirectory.resolvePath('file:///C:/Program%20Files%20(x86)/Java/jre6/bin')
				else file= File.applicationDirectory.resolvePath('file:///C:/Program%20Files/Java/jre6/bin');
				
				
			}else if(Capabilities.os.toLowerCase().indexOf("mac") >= 0){
				file=File.applicationDirectory.resolvePath('/usr/bin');
			}
			try 
			{
				if (Capabilities.os.toLowerCase().indexOf("win") >= 0)file.browseForOpen("select java",[new FileFilter("javae", "*.exe")] );
				else file.browseForOpen("select java");
				file.addEventListener(Event.SELECT, selectJavaPathEnd);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
		}
		private function selectJavaPathEnd(e:Event):void{
			var file:File=e.target as File;
			MKCompressionTools.instance.javaFileUrl=file.nativePath;
			upConfing();
		}
		private var parentFile:File;
		private var _compilerFile:File;
		public function get compilerFile():File
		{
			return _compilerFile;
		}
		private var _yuicompilerFile:File;
		public function get yuicompilerFile():File
		{
			return _yuicompilerFile;
		}
		
		private var javaStartupInfo:NativeProcessStartupInfo;
		private var javaProcess:NativeProcess;
		private var javaProcessDic:Dictionary=new Dictionary();
		private var javaFile:File;
		/**
		 * 初始化进程
		 */
		public function runCompressionNativeProcess(processArgs:Vector.<String>,endFun:Function=null):void 
		{
			//Mac OS: /usr/bin/java
			//Win OS: Default: C:\Program Files\Java or for 32-Bit in 64 Bit Windows: C:\Program Files (x86)\Java
			DebugOutput.add('系统：',Capabilities.os.toLowerCase());
			if (NativeProcess.isSupported==false){
				AlertPanel.show('Program does not support NativeProcess')
				return;
			}
			if (Capabilities.os.toLowerCase().indexOf("win") >= 0){
				javaFile = File.applicationDirectory.resolvePath(javaFileUrl);
			}else if(Capabilities.os.toLowerCase().indexOf("mac") >= 0){
				javaFile=File.applicationDirectory.resolvePath(javaFileUrl);
			}else{
				DebugOutput.add(Capabilities.os.toLowerCase()+'系统不支持');
				return;
			}
			DebugOutput.add(javaFile.nativePath,javaFile.exists)
			if (!javaFile.exists) {
				if (Capabilities.os.toLowerCase().indexOf("win") >= 0){
					AlertPanel.show('Set the select java.exe path',selectJavaPath);
				}else{
					AlertPanel.show('No JavaFramework for:'+Capabilities.os.toLowerCase());
				}
				return;
			}
			/*
			if (javaProcess) {
				if(javaProcess&&javaProcess.running)javaProcess.exit(true);
			}
			*/
			javaProcess=new NativeProcess();
			javaProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			javaProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			javaProcess.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			javaProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			javaProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
			javaProcessDic[javaProcess]={};
			javaProcessDic[javaProcess].endFun=endFun;
			
			//程序运行参数配置
			javaStartupInfo = new NativeProcessStartupInfo();
			javaStartupInfo.executable = javaFile;
			//javaStartupInfo.workingDirectory=File.applicationDirectory
			//程序启动参数设置
			//var processArgs:Vector.<String> = new Vector.<String>();
			//processArgs[0]= '-jar';
			//processArgs[1]= compilerFile.nativePath;
			//processArgs[2]= '--help'

			
			javaStartupInfo.arguments = processArgs;
			
			//启动进程
			javaProcess.start(javaStartupInfo);
			
		}
		
	
		
		protected function onIOError(event:IOErrorEvent):void
		{
			DebugOutput.add('onIOError');
		}
		
		protected function onExit(event:NativeProcessExitEvent):void
		{
			var javaPrc:NativeProcess = event.target as NativeProcess;
			javaPrc.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			javaPrc.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			javaPrc.removeEventListener(NativeProcessExitEvent.EXIT, onExit);
			javaPrc.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			javaPrc.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
			DebugOutput.add('exitHandler',javaPrc.running);
			if(javaProcessDic[javaPrc].endFun!=null)javaProcessDic[javaPrc].endFun();
			javaProcessDic[javaPrc]=null;
			javaProcess=null;
			
		}
		protected function onErrorData(event:ProgressEvent):void
		{
			var javaPrc:NativeProcess = event.target as NativeProcess;
			var outError:String = javaPrc.standardError.readUTFBytes(javaPrc.standardError.bytesAvailable);
			DebugOutput.add('errorOutputHandler',outError)
			
		}
		protected function onOutputData(event:ProgressEvent):void
		{
			var javaPrc:NativeProcess = event.target as NativeProcess;
			var outStd:String = javaPrc.standardOutput.readUTFBytes(javaPrc.standardOutput.bytesAvailable);
			DebugOutput.add('outputHandler:',outStd)
		}
	}
}