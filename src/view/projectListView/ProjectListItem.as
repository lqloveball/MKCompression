package view.projectListView
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;	
	
	public class ProjectListItem extends MovieClip
	{
		private var skin:ProjectListItemSkin=new ProjectListItemSkin();
		private var labelMc:MovieClip
		private var label:TextField
		private var ico:MovieClip
		public function ProjectListItem()
		{
			super();
			addChild(skin);
			initUI();
			
		}
		private function initUI():void
		{
			ico=skin.ico;
			ico.gotoAndStop(1);
			
			skin.mouseChildren=false;
			this.mouseChildren=false;
			this.buttonMode=true;
			this.addEventListener(MouseEvent.MOUSE_OVER,museOverFun);
			this.addEventListener(MouseEvent.MOUSE_OUT,mouseOutFun)
			labelMc=skin.labelMc;
			label=labelMc.label;
			label.text='';
		}
		
		protected function mouseOutFun(event:MouseEvent):void
		{
			Tools.movieFrame(skin,1);
		}
		
		protected function museOverFun(event:MouseEvent):void
		{
			Tools.movieFrame(skin,skin.totalFrames);
		}
		
		
		
		private var _data:Object
		public function get data():Object
		{
			return _data;
		}
		/**
		 * 
		 * @param 	obj
					obj.projectName=projectName;
					obj.projectType=selectType;
					obj.projectFile=projectFile.nativePath;
					obj.fileList=[];
		 */		
		public function setData(obj:Object):void{
			_data=obj;
			label.text=data.projectName
			ico.gotoAndStop(data.projectType)
	
		}
		
	}
}