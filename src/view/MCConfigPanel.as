package view
{
	import com.ixiyou.managers.AlertManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	
	import lib.*;
	
	
	public class MCConfigPanel extends Sprite
	{
		private var skin:MCConfigPanelSkin=new MCConfigPanelSkin();
		public function MCConfigPanel()
		{
			super();
			addChild(skin);
			initUI();
			addEventListener(Event.ADDED_TO_STAGE,addStage)
		}
		
		
		
		private function initUI():void
		{
			Tools.setButton(skin.closeBtn)
			skin.closeBtn.addEventListener(MouseEvent.CLICK,closeFun);
			
			//Tools.setButton(skin.advanced)
			//Tools.setButton(skin.confusion)
			
			skin.advanced.gotoAndStop(1)
			skin.confusion.gotoAndStop(1)
			skin.advanced.mouseChildren=skin.confusion.mouseChildren=false;
			skin.advanced.buttonMode=skin.confusion.buttonMode=true;
			var arr:Array=new Array();
			for (var i:int = 0; i < 2; i++) 
			{
				var mc:MovieClip=skin['mc'+i];
				mc.id=i
				arr.push(mc);	
				mc.addEventListener(MouseEvent.CLICK,selectTypeFun)
			}
			Tools.setSelectArr(arr);
			
			Tools.setButton(skin.selecJavaFiles)
			skin.selecJavaFiles.addEventListener(MouseEvent.CLICK,javaSelecFun)
				
			skin.advanced.addEventListener(MouseEvent.CLICK,advancedFun);
			skin.confusion.addEventListener(MouseEvent.CLICK,confusionFun);
		}
		
		protected function confusionFun(event:MouseEvent):void
		{
			MKCompressionTools.instance.yuiConfusion=!MKCompressionTools.instance.yuiConfusion;
			if(MKCompressionTools.instance.yuiConfusion){
				Tools.movieFrame(skin.confusion,skin.confusion.totalFrames)
			}else{
				Tools.movieFrame(skin.confusion,1)
			}
			MKCompressionTools.instance.upConfing();
		}
		
		protected function advancedFun(event:MouseEvent):void
		{
			MKCompressionTools.instance.ccAdvanced=!MKCompressionTools.instance.ccAdvanced;
			if(MKCompressionTools.instance.ccAdvanced){
				Tools.movieFrame(skin.advanced,skin.advanced.totalFrames)
			}else{
				Tools.movieFrame(skin.advanced,1)
			}
			MKCompressionTools.instance.upConfing();
		}
		
		protected function javaSelecFun(event:MouseEvent):void
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
			skin.javaUrl.text=MKCompressionTools.instance.javaFileUrl;
			MKCompressionTools.instance.upConfing();
		}
		protected function selectTypeFun(event:MouseEvent):void
		{
			var mc:MovieClip=event.target as MovieClip;
			if(mc.id==0){
				MKCompressionTools.instance.jsCompresstionModel='CC';
			}else{
				MKCompressionTools.instance.jsCompresstionModel='YUI';
			}
			MKCompressionTools.instance.upConfing();
		}
		
		protected function closeFun(event:MouseEvent):void
		{
			AlertManager.getInstance().remove(this);
			
		}
		protected function addStage(event:Event):void
		{
			if (Capabilities.os.toLowerCase().indexOf("win") >= 0){
				skin.info.text=Capabilities.os.toLowerCase()+' '+(Capabilities.supports64BitProcesses?'64Bit':'32Bit');
			}else{
				skin.info.text=Capabilities.os.toLowerCase()+' '+(Capabilities.supports64BitProcesses?'Bit64':'Bit32');
			}
			skin.javaUrl.text=MKCompressionTools.instance.javaFileUrl;
			if(MKCompressionTools.instance.jsCompresstionModel=='CC'){
				Tools.setSelectArrByBtn(skin.mc0)
			}else{
				Tools.setSelectArrByBtn(skin.mc1)
			}
			
			if(MKCompressionTools.instance.ccAdvanced){
				Tools.movieFrame(skin.advanced,skin.advanced.totalFrames)
			}else{
				Tools.movieFrame(skin.advanced,1)
			}
			
			if(MKCompressionTools.instance.yuiConfusion){ 
				Tools.movieFrame(skin.confusion,skin.confusion.totalFrames)
			}else{
				Tools.movieFrame(skin.confusion,1)
			}
		}
	}
}