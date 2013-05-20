package view.projectListView
{
	import com.greensock.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	import view.AlertPanel;
	import view.ProjectPanel;
	
	public class ProjectListBox extends MovieClip
	{
		private var skin:lib.ProjectListBoxSkin=new ProjectListBoxSkin();
		private var listPanel:MovieClip
		private var listRect:Rectangle
		private var listLabel:TextField;
		private var labelBox:MovieClip
		
		private var listBox:Sprite=new Sprite();
		
		private var box:Sprite
		private var boxMask:Sprite
		private var mouseRect:Sprite

		private var listData:Object;

		private var lists:Array;
		public function ProjectListBox()
		{
			addChild(skin);
			initUI();
		}
		
	

		private function initUI():void
		{
			listPanel=skin.listPanel;
			listRect=new Rectangle(listPanel.x,listPanel.y,listPanel.width,listPanel.height);
			listPanel.ox=listPanel.x
			listPanel.oy=listPanel.y
			listPanel.owidth=listPanel.width
			listPanel.oheight=listPanel.height
			skin.removeChild(skin.listPanel);
			
			labelBox=skin.labelBox;
			Tools.setButton(labelBox);
			listLabel=labelBox.listLabel;
			labelBox.addEventListener(MouseEvent.CLICK,showList)
			listLabel.text='';
			
			box=listPanel.box;
			while(box.numChildren>0)box.removeChildAt(0);
			
			boxMask=listPanel.boxMask;
			mouseRect=listPanel.mouseRect;
			box.addChild(listBox);
			
			mouseRect.mouseChildren=false;
			mouseRect.mouseEnabled=false;
			addEventListener(Event.ADDED_TO_STAGE,addStage)
			initList();
		}
		
		protected function addStage(event:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseRectMove)
			
		}
		
		protected function mouseRectMove(event:MouseEvent):void
		{
			var sl:Number=mouseRect.mouseY/mouseRect.height;
			if(sl<0)sl=0;
			if(sl>1)sl=1;
			var _h:Number=listBox.height>boxMask.height?boxMask.height-listBox.height:0;
			listBox.y=_h*sl;
		}
		
		private function initList():void{
			var file:File=File.applicationStorageDirectory.resolvePath('projectlist.json');
			var fileStream:FileStream = new FileStream();
			try
			{
				fileStream.open(file,FileMode.UPDATE);
			}
			catch (error:Error)
			{
				return;
			}
			var listJson:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
			listData={};
			//trace('initList:',listJson);
			if(listJson==''){
				listData.lists=[];
				listJson=Tools.json_encode(listData);
				fileStream.writeUTFBytes(listJson);
				fileStream.close();
			}else{
				listData=Tools.json_decode(listJson);
				fileStream.close();
			}
			lists=listData.lists;
			trace('initList:',lists.length);
			uptListItem();
			defaultSelect();
		}
		private var items:Array
		private function uptListItem():void
		{
			while(listBox.numChildren>0)listBox.removeChildAt(0);
			var item:ProjectListItem;
			var i:int;
			if(items){
				for (i= 0; i < items.length; i++) 
				{
					item=items[i];
					item.removeEventListener(MouseEvent.CLICK,itemClick)
				}
				
			}
			if(!lists||lists.length<=0){
				trace('no proejct')
				selectItem=null;
				return;
			}
			items=new Array();
			for (i = 0; i < lists.length; i++) 
			{
				item=new ProjectListItem();
				var data:Object=lists[i];
				item.setData(data);
				items.push(item);
				item.y=35*i;
				listBox.addChild(item);
				item.addEventListener(MouseEvent.CLICK,itemClick)
			}
		}
		private function defaultSelect():void{
			if(!items||items.length<=0)return;
			if(selectItem==null){
				if(items[0])selectItem=items[0];
			}
			else if(items.indexOf(selectItem)==-1){
				if(items[0])selectItem=items[0];
			}
		}
		private var _selectItem:ProjectListItem=null;
		public var projectPanel:ProjectPanel;
		public function get selectItem():ProjectListItem
		{
			return _selectItem;
		}
		
		public function set selectItem(value:ProjectListItem):void
		{
			if(_selectItem==value){
				if(_selectItem==null)listLabel.text='No Project';
				return;
			}
			_selectItem = value;
			if(_selectItem==null){
				listLabel.text='No Project';
			}else{
				var data:Object=selectItem.data;
				listLabel.text=data.projectName;
			}
			dispatchEvent(new Event('upData'));
		}
		private function itemClick(e:MouseEvent):void
		{
			var item:ProjectListItem=e.target as ProjectListItem;
			var file:File;
			var fileStream:FileStream;
			var data:Object=item.data;
			file=new File(data.projectFile);
			trace('itemClick:',file.exists,file.nativePath)
			if(!file.exists){
				AlertPanel.show('no project!')
				removeProject();
				return;
			}
			selectItem=item;
			hitlist();
		}
		/**
		 * 重新命名 
		 * @param value
		 * 
		 */		
		public function renameProject(value:String):void
		{
			if(!selectItem)return;
			
			var file:File;
			var fileStream:FileStream;
			var data:Object=selectItem.data;
			trace('renameProject:',data.projectName,'to', value);
			data.projectName=value;
			file=new File(data.projectFile);
			//判断项目文件是否存在
			if(file.exists){
				var renamefile:File=file.parent.resolvePath(data.projectName+'.mkproject');
				data.projectFile=renamefile.nativePath;
				fileStream = new FileStream();
				fileStream.open(renamefile,FileMode.UPDATE);
				fileStream.writeUTFBytes(Tools.json_encode(data));
				fileStream.close();
				file.moveToTrash();
			}else{
				AlertPanel.show('no project!')
				removeProject();
				return;
			}
			
			upListToProjectlist();
			uptListItem();
			data=selectItem.data;
			listLabel.text=data.projectName;
			
		}
		/**
		 * 更新数据到程序项目list配置文件中 
		 * projectName
		 * projectFile
		 * projectType
		 * fileList
		 * outputFile
		 */		
		public function upListToProjectlist():void{
			var file:File;
			var fileStream:FileStream;
			lists=new Array();
			for (var i:int = 0; i < items.length; i++) 
			{
				var item:ProjectListItem=items[i];
				var temp:Object=item.data;
				var data:Object={
					projectName:temp.projectName,
					projectFile:temp.projectFile,
					projectType:temp.projectType
				}
				lists.push(data);
			}
			listData.lists=lists;
			file=File.applicationStorageDirectory.resolvePath('projectlist.json');
			fileStream = new FileStream();
			try
			{
				fileStream.open(file,FileMode.UPDATE);
			}
			catch (error:Error)
			{
				trace("Failed:",error, error.message);
				return;
			}
			var listJson:String=Tools.json_encode(listData);
			fileStream.writeUTFBytes(listJson);
			fileStream.close();
		}
		
		public function removeProject():void
		{
			if(!selectItem)return;
			var num:int=items.indexOf(selectItem);
			if(num==-1)return;
			items.splice(num,1);
			lists=new Array();
			for (var i:int = 0; i < items.length; i++) 
			{
				var item:ProjectListItem=items[i];
				var temp:Object=item.data;
				var data:Object={
					projectName:temp.projectName,
						projectFile:temp.projectFile,
						projectType:temp.projectType
				}
				lists.push(data);
			}
			listData.lists=lists;
			
			var fileStream:FileStream;
			var file:File;
			file=File.applicationStorageDirectory.resolvePath('projectlist.json');
			fileStream = new FileStream();
			try
			{
				fileStream.open(file,FileMode.UPDATE);
			}
			catch (error:Error)
			{
				trace("Failed:",error, error.message);
				return;
			}
			var listJson:String=Tools.json_encode(listData);
			fileStream.writeUTFBytes(listJson);
			fileStream.close();
			
			uptListItem();
			defaultSelect();
		}
		
		public function removieProjectByItem(value:ProjectListItem):void{
			var num:int=items.indexOf(value);
			if(num==-1){
				return;
			}
			items.splice(num,1);
			lists=new Array();
			for (var i:int = 0; i < items.length; i++) 
			{
				var item:ProjectListItem=items[i];
				var temp:Object=item.data;
				var data:Object={
					projectName:temp.projectName,
						projectFile:temp.projectFile,
						projectType:temp.projectType
				}
				lists.push(data);
			}
			listData.lists=lists;
			
			var fileStream:FileStream;
			var file:File;
			file=File.applicationStorageDirectory.resolvePath('projectlist.json');
			fileStream = new FileStream();
			try
			{
				fileStream.open(file,FileMode.UPDATE);
			}
			catch (error:Error)
			{
				trace("Failed:",error, error.message);
				return;
			}
			var listJson:String=Tools.json_encode(listData);
			fileStream.writeUTFBytes(listJson);
			fileStream.close();
			
			uptListItem();
			defaultSelect();
		}
		public function addProject(file:File):void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(file,FileMode.READ)
			var projectStr:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			
			var temp:Object=Tools.json_decode(projectStr);
			var projectData:Object={
				projectName:temp.projectName,
					projectFile:temp.projectFile,
					projectType:temp.projectType
			}
			
			trace('list addProject:',Tools.json_encode(projectData));
			lists.push(projectData);

			file=File.applicationStorageDirectory.resolvePath('projectlist.json');
			fileStream = new FileStream();
			try
			{
				fileStream.open(file,FileMode.WRITE);
			}
			catch (error:Error)
			{
				trace("Failed:",error, error.message);
				return;
			}
			var listJson:String=Tools.json_encode(listData);
			fileStream.writeUTFBytes(listJson);
			fileStream.close();
			uptListItem();

			var item:ProjectListItem=items[items.length-1] as ProjectListItem
			selectItem=item;
		}
		
		
		//---------------------下拉显示列表-------------------------
		public function showList(event:MouseEvent=null):void
		{
			listPanel.alpha=0;
			listPanel.y=listPanel.oy-20;
			addChildAt(listPanel,0);
			TweenMax.to(listPanel,.3,{alpha:1,y:listPanel.oy})
			stage.addEventListener(MouseEvent.MOUSE_DOWN,stageDown)
			stage.removeEventListener(MouseEvent.MOUSE_OVER,stageOver)
			TweenMax.delayedCall(.5,delayStageOver)
			
		}	
		private function delayStageOver():void
		{
			stage.addEventListener(MouseEvent.MOUSE_OVER,stageOver)
			
		}
		
		protected function stageOver(event:MouseEvent):void
		{
			var mc:DisplayObject=event.target as DisplayObject;
			if(!this.contains(mc)){
				hitlist();
			}
		}
		
		protected function stageDown(event:MouseEvent):void
		{
			var mc:DisplayObject=event.target as DisplayObject;
			if(!listPanel.contains(mc)){
				hitlist();
			}
		}
		public function hitlist():void{
			TweenMax.to(listPanel,.3,{alpha:0,y:listPanel.oy-20,
				onComplete:function(listPanel:MovieClip):void{
					if(listPanel.parent)listPanel.parent.removeChild(listPanel);
				}
				,onCompleteParams:[listPanel]
			})
		}
		
	
		
		
	}
}