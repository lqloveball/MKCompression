package view
{
	import com.ixiyou.managers.AlertManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import lib.*;
	
	public class DragFileAlert extends MovieClip
	{
		private var skin:DragFileAlertSkin=new DragFileAlertSkin();
		private var processing:MovieClip
		public function DragFileAlert()
		{
			addChild(skin);
			initUI()
			addEventListener(Event.ADDED_TO_STAGE,addStage)
		}
		private var sinaglefileBool:Boolean=true;
		private function initUI():void
		{
			processing=skin.processing;
			Tools.setButton(skin.closeBtn);
			skin.closeBtn.addEventListener(MouseEvent.CLICK,function():void{hit()});			
		}
		
		protected function addStage(event:Event):void
		{
			this.x=this.stage.stageWidth/2>>0
			this.y=this.stage.stageHeight/2>>0
		}		
		
		public function show(files:Array):void{
			
			AlertManager.getInstance().push(this,true,true,0x0,.4);
			skin.gotoAndStop(1);
			processing.visible=true;
			analysisFile(files);
		}
		private function hit():void
		{
			clearTimeout(delayTimer);
			AlertManager.getInstance().remove(this);
		}
		private var delayTime:Number=5*1000;
		private var delayTimer:Number=0;
		private function delayHit(value:Number=5):void{
			delayTime=value*1000;
			clearTimeout(delayTimer);
			delayTimer=setTimeout(delayHitPanel,delayTime)
		}
		private function delayHitPanel():void
		{
			clearTimeout(delayTimer);
			hit();
		}
		private var jsfiles:Array;
		private var cssfiles:Array;
		private var htmlfiles:Array;
		private var parentFile:File
		private function analysisFile(files:Array):void{
			clearTimeout(delayTimer);
			//trace('analysisFile',files);
			jsfiles=new Array();
			cssfiles=new Array();
			htmlfiles=new Array();
			parentFile=null
			if(files.length>0){
				if(File(files[0]).parent)parentFile=File(files[0]).parent;
				else parentFile=File.desktopDirectory;
			}
			analysisFiles(files);
			upGotoUI();
		}
		private function analysisFiles(files:Array):void{
			var length:int = files.length;
			var sourceFile:File; 
			for(var i:int = 0; i < length; i++)  
			{  
				sourceFile = files[i] as File;  
				if(sourceFile.isDirectory){
					analysisDirectory(sourceFile);
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
						//trace('other:',sourceFile.extension)
					}
				}
			}
		}
		private function analysisDirectory(value:File):void
		{
			var files:Array=value.getDirectoryListing();
			analysisFiles(files);
		}
		
		/**
		 *判断处理方式 
		 * 
		 */		
		private function upGotoUI():void
		{
			//trace('jsfiles:',jsfiles.length);
			//trace('cssfiles:',cssfiles.length);
			//trace('htmlfiles:',htmlfiles.length);
			if(cssfiles.length==0&&htmlfiles.length==0&&jsfiles.length==0){
				Tools.movieFrame(skin,'noFiles',function():void{
					processing.visible=false;
				})
				return;
			}
			//压缩js
			if(cssfiles.length==0&&jsfiles.length>0){
				if(jsfiles.length==1)jsfileComperssion();
				else showJslistUI();
			}
			else if(jsfiles.length==0&&cssfiles.length>0){
				//压缩css
				if(cssfiles.length==1)cssfileComperssion();
				else showCsslistUI();
			}
			else {
				showSelectCompressionUI()
			}
		}
		
		
		
		private function showSelectCompressionUI():void
		{
			Tools.movieFrame(skin,'selectCompression',selectCompressionUIEnd)
		}
		private function selectCompressionUIEnd():void
		{
			processing.visible=false;
			Tools.setButton(skin.allCompression);
			Tools.setButton(skin.cssCompression);
			Tools.setButton(skin.jsCompression);
			skin.allCompression.addEventListener(MouseEvent.CLICK,allCompression)
			skin.cssCompression.addEventListener(MouseEvent.CLICK,cssCompression)
			skin.jsCompression.addEventListener(MouseEvent.CLICK,jsCompression)
		}		
		protected function allCompression(event:MouseEvent):void
		{	
			
		}
		protected function jsCompression(event:MouseEvent):void
		{
			showJslistUI();
			
		}
		protected function cssCompression(event:MouseEvent):void
		{
			showCsslistUI();
		}
	
		//--------------------------css压缩--------------------------
		private function cssfileComperssion():void{
			var file:File=cssfiles[0];
			if(isMiniCssFile(file)){
				Tools.movieFrame(skin,'noFiles',function():void{
					processing.visible=false;
				})
				return;
			}
			var compilerFile:File=MKCompressionTools.instance.yuicompilerFile;
			var outputName:String=file.nativePath;
			outputName=outputName.substr(0,outputName.length-4)+'.min.css';
			var processArgs:Vector.<String> = new Vector.<String>();
			processArgs.push('-jar');
			processArgs.push(compilerFile.nativePath);
			processArgs.push('--type');
			processArgs.push('css');
			processArgs.push('--charset');
			processArgs.push('utf-8');
			processArgs.push('-o');
			processArgs.push(outputName);
			processArgs.push(file.nativePath);
			MKCompressionTools.instance.runCompressionNativeProcess(processArgs,cssfileComperssionEnd);
		}
		
		private function cssfileComperssionEnd():void
		{
			Tools.movieFrame(skin,'compressCssEnd',function():void{
				processing.visible=false;
				Tools.setButton(skin.cssBtn);
				skin.cssBtn.addEventListener(MouseEvent.CLICK,function():void{hit();});
			})
			delayHit();
		}
		private function showCsslistUI():void
		{
			Tools.movieFrame(skin,'compressCssListEnd',showCsslistUIEnd)
		}
		private var cssListText:TextField
		private function showCsslistUIEnd():void
		{

			processing.visible=false;
			Tools.setButton(skin.cssListBtn);

			skin.cssListBtn.addEventListener(MouseEvent.CLICK,function():void{hit();});
			skin.cssListBtn.visible=false;
			
			cssListText=skin.cssListText;
			cssListText.text='';
			cssListComperssion();	
		}
		private var cssLists:Array
		private var cssComperssionNum:int
		private function cssListComperssion():void
		{
			cssLists=cssfiles.concat();
			cssComperssionNum=-1;
			cssListComperssioning();
		}
		
		private function cssListComperssioning():void
		{
			cssComperssionNum++;
			cssListText.text=(cssComperssionNum)+'/'+cssLists.length;
			//trace('jsListComperssioning:',cssComperssionNum);
			if(cssComperssionNum>=cssLists.length){
				cssListComperssionEnd();
				return;
			}
			if(!stage)return;
			
			var file:File=cssLists[cssComperssionNum];
			//如果已经是.mini.js结尾文件就不再压缩
			if(isMiniCssFile(file)){
				cssListComperssioning();
				return;
			}
			var compilerFile:File=MKCompressionTools.instance.yuicompilerFile;
			var outputName:String=file.nativePath;
			outputName=outputName.substr(0,outputName.length-4)+'.min.css';
			var processArgs:Vector.<String> = new Vector.<String>();
			processArgs.push('-jar');
			processArgs.push(compilerFile.nativePath);
			processArgs.push('--type');
			processArgs.push('css');
			processArgs.push('--charset');
			processArgs.push('utf-8');
			processArgs.push('-o');
			processArgs.push(outputName);
			processArgs.push(file.nativePath);
			MKCompressionTools.instance.runCompressionNativeProcess(processArgs,cssListComperssioning);
			
		}
		
		private function cssListComperssionEnd():void
		{
			skin.cssListBtn.visible=true;
			delayHit();	
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
		//--------------------------js压缩--------------------------
		private function jsfileComperssion():void{
			var file:File=jsfiles[0];
			if(isMiniJsFile(file)){
				Tools.movieFrame(skin,'noFiles',function():void{
					processing.visible=false;
				})
				return;
			}
			var compilerFile:File=MKCompressionTools.instance.compilerFile;
			var outputName:String=file.nativePath;
			outputName=outputName.substr(0,outputName.length-3)+'.min.js';
			var processArgs:Vector.<String> = new Vector.<String>();
			if(MKCompressionTools.instance.jsCompresstionModel=='CC'){
				processArgs.push('-jar');
				processArgs.push(compilerFile.nativePath);
				processArgs.push('--js');
				processArgs.push(file.nativePath);
				processArgs.push('--js_output_file');
				processArgs.push(outputName);
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
				processArgs.push(outputName);//输出文件
				processArgs.push(file.nativePath); //源文件
			}
			
			MKCompressionTools.instance.runCompressionNativeProcess(processArgs,sinaglefileComperssionEnd);
		}
		private function sinaglefileComperssionEnd():void{
			Tools.movieFrame(skin,'compressJsEnd',function():void{
				processing.visible=false;
				Tools.setButton(skin.jsBtn);
				skin.jsBtn.addEventListener(MouseEvent.CLICK,function():void{hit();});
			})
			delayHit();
		}
		private function showJslistUI():void{
			Tools.movieFrame(skin,'compressJsListEnd',showJslistUIEnd)
		}
		private var jsListText:TextField
		private function showJslistUIEnd():void{
			processing.visible=false;
			Tools.setButton(skin.jsListBtn);
			//trace(skin.jsListBtn)
			skin.jsListBtn.addEventListener(MouseEvent.CLICK,function():void{hit();});
			skin.jsListBtn.visible=false;
			jsListText=skin.jsListText;
			jsListText.text='';
			jsListComperssion();	
		}
		private var jsLists:Array
		private var jsComperssionNum:int;
		private function jsListComperssion():void{
			//trace('jsListComperssion')
			jsLists=jsfiles.concat();
			jsComperssionNum=-1;
			jsListComperssioning();
		}
		
		private function jsListComperssioning():void{
			
			jsComperssionNum++;
			jsListText.text=(jsComperssionNum)+'/'+jsLists.length;
			trace('jsListComperssioning:',jsComperssionNum);
			if(jsComperssionNum>=jsLists.length){
				jsListComperssionEnd();
				return;
			}
			if(!stage)return;
			
			var file:File=jsfiles[jsComperssionNum];
			//如果已经是.mini.js结尾文件就不再压缩
			if(isMiniJsFile(file)){
				jsListComperssioning();
				return;
			}
			var compilerFile:File=MKCompressionTools.instance.compilerFile;
			var outputName:String=file.nativePath;
			outputName=outputName.substr(0,outputName.length-3)+'.min.js';
			var processArgs:Vector.<String> = new Vector.<String>();
			if(MKCompressionTools.instance.jsCompresstionModel=='CC'){
				processArgs.push('-jar');
				processArgs.push(compilerFile.nativePath);
				processArgs.push('--js');
				processArgs.push(file.nativePath);
				processArgs.push('--js_output_file');
				processArgs.push(outputName);
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
				processArgs.push(outputName);//输出文件
				processArgs.push(file.nativePath); //源文件
			}
			
			MKCompressionTools.instance.runCompressionNativeProcess(processArgs,jsListComperssioning);
			
		}
		private function jsListComperssionEnd():void{
			skin.jsListBtn.visible=true;
			delayHit();
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