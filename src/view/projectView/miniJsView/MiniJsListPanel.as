package view.projectView.miniJsView
{
	import com.ixiyou.speUI.mcontrols.MovieToVScrollBar;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	import view.projectView.CompressionMiniJsPanel;
		
	
	public class MiniJsListPanel extends MovieClip
	{
		private var jsItemMenu:JsItemMenu=new JsItemMenu();
		private var skin:FListSkin=new FListSkin();
		public function MiniJsListPanel()
		{
			addChild(skin)
			initUI();
		}
		private var box:Sprite
		private var boxMask:Sprite
		private var sl:MovieToVScrollBar
		private function initUI():void
		{
			var arr:Array=new Array();
			for (var i:int = 0; i < 2; i++) 
			{
				var mc:MovieClip=skin['mc'+i];
				mc.id=i;
				arr.push(mc);
				mc.addEventListener(MouseEvent.CLICK,typeClick)
			}
			Tools.setSelectArr(arr);
			
			box=skin.box;
			boxMask=skin.boxMask;
			box.mask=boxMask;
			sl=new MovieToVScrollBar(skin.sl,null,true,true);
			sl.content=box;
			while(box.numChildren>0)box.removeChildAt(0);
			
			
			//addEventListener(MouseEvent.RIGHT_CLICK,rightClick)
		}
		private var jsType:String='jsList'
		protected function typeClick(event:MouseEvent):void
		{
			var mc:MovieClip=event.target as MovieClip;
			if(mc.id==0){
				jsType='jsList';
			}else{
				jsType='exclude';
			}
			upLists();
		}
		
		
		
		public var jsList:Array
		public var hitList:Array
		public var compresionList:Array
		public var miniJsPanel:CompressionMiniJsPanel;
		public function clearAll():void
		{
			if(jsList){
				for (var i:int = 0; i < jsList.length; i++) 
				{
					var item:JSItem=jsList[i];
					item.removeEventListener(MouseEvent.RIGHT_CLICK,rightClickFun);
				}
				
			}
			jsList=null;
			hitList=[]
			compresionList=[]
			while(box.numChildren>0)box.removeChildAt(0);
		}
		public function iniList(fileList:Array):void
		{
			while(box.numChildren>0)box.removeChildAt(0);
			jsType='jsList';
			Tools.setSelectArrByBtn(skin.mc0);
			jsList=[]
			compresionList=new Array();
			hitList=new Array();
			var item:JSItem
			for (var i:int = 0; i < fileList.length; i++) 
			{
				item=new JSItem();
				var data:Object=fileList[i]
				item.setItemData(data);
				if(data.hit==true){
					hitList.push(item);
				}else{
					compresionList.push(item);
				}
				item.addEventListener(MouseEvent.RIGHT_CLICK,rightClickFun)
				jsList.push(item);
			}
			
			for (i = 0; i < compresionList.length; i++) 
			{
				item=compresionList[i];
				item.y=i*30;
				box.addChild(item);
			}
			jsList=compresionList.concat(hitList);
		}
		public function upLists():void
		{
			var item:JSItem
			var i:uint
			while(box.numChildren>0)box.removeChildAt(0);
			if(jsType=='jsList'){
				for (i = 0; i < compresionList.length; i++) 
				{
					item=compresionList[i];
					item.y=i*30;
					box.addChild(item);
				}
			}else{
				for (i = 0; i < hitList.length; i++) 
				{
					item=hitList[i];
					item.y=i*30;
					box.addChild(item);
				}
			}
			
		}
		
		public function getFileListArray():Array{
			var arr:Array=new Array();
			var item:JSItem;
			var data:Object
			var i:int
			for (i = 0; i < compresionList.length; i++) 
			{
				item=compresionList[i];
				data=item.data;
				arr.push(data);
			}
			for (i = 0; i < hitList.length; i++) 
			{
				item=hitList[i];
				data=item.data;
				arr.push(data);
			}
			return arr;
		}
		public function getCompressionArray():Array{
			var arr:Array=new Array();
			var item:JSItem;
			var data:Object
			var i:int
			for (i = 0; i < compresionList.length; i++) 
			{
				item=compresionList[i];
				data=item.data;
				arr.push(data);
			}
			return arr;
		}
		public function upListToProjectlist():void{
			upLists();
			this.miniJsPanel.upJSLists();
		}
		protected function rightClickFun(e:MouseEvent):void
		{
			var item:JSItem=e.target as JSItem;
			jsItemMenu.x=stage.mouseX;
			jsItemMenu.y=stage.mouseY;
			if(jsItemMenu.y>=340)jsItemMenu.y=340;
			stage.addChild(jsItemMenu);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,stageDownhit);
			jsItemMenu.initJsItem(item,this,this.jsType);
		}
		protected function stageDownhit(e:MouseEvent):void
		{
			if(!stage){
				if(jsItemMenu.parent)jsItemMenu.parent.removeChild(jsItemMenu);
				return;
			}
			var dp:DisplayObject=e.target as DisplayObject;
			if(jsItemMenu.contains(dp))return;
			if(jsItemMenu.parent)jsItemMenu.parent.removeChild(jsItemMenu);
		}
	}
}