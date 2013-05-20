package view
{
	import com.greensock.TweenMax;
	import com.ixiyou.managers.AlertManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	import view.projectListView.NewProjectPanel;
	import view.projectListView.ProjectListBox;
	import view.projectListView.ProjectListItem;
	import view.projectListView.RemoveProjectAlert;
	import view.projectListView.RenameProjectPanel;
	import view.projectView.CompressionMiniJsPanel;
	import view.projectView.CompressionMiniSitePanel;

	public class ProjectPanel extends MovieClip
	{
		private var skin:ProjectPanelSkin=new ProjectPanelSkin();
		private var newProjectPanel:NewProjectPanel=new NewProjectPanel();
		private var renameProjectPanel:RenameProjectPanel=new RenameProjectPanel();
		private var removeAlert:RemoveProjectAlert=new RemoveProjectAlert();
		public var projectListBox:ProjectListBox=new ProjectListBox();
		private var box:Sprite=new Sprite();
		public function ProjectPanel()
		{
			newProjectPanel.projectPanel=this;
			projectListBox.projectPanel=this;
			renameProjectPanel.projectPanel=this;
			removeAlert.projectPanel=this;
			addChild(skin);
			addChild(box);
			initUI();
		}
		private var morePanel:MovieClip
		private var moreOutRect:Rectangle
		private function initUI():void
		{
			Tools.setButton(skin.newProjectBtn);
			Tools.setButton(skin.moreBtn);
			
			morePanel=skin.morePanel;
			
			
			moreOutRect=new Rectangle(morePanel.x,morePanel.y,morePanel.width,morePanel.height);
			
			morePanel.ox=morePanel.x;
			morePanel.oy=morePanel.y;
			morePanel.owidth=morePanel.width;
			morePanel.oheight=morePanel.height;
			
			morePanel.parent.removeChild(morePanel);
			
			Tools.setButton(morePanel.openBtn);
			Tools.setButton(morePanel.removeBtn);
			Tools.setButton(morePanel.renameBtn);
			
			
			skin.moreBtn.addEventListener(MouseEvent.MOUSE_OVER,moreOver);
			skin.moreBtn.addEventListener(MouseEvent.MOUSE_OUT,moreOut);
			
			skin.newProjectBtn.addEventListener(MouseEvent.CLICK,newProject);
			morePanel.openBtn.addEventListener(MouseEvent.CLICK,openProject);
			morePanel.removeBtn.addEventListener(MouseEvent.CLICK,removeProjecMouset);
			morePanel.renameBtn.addEventListener(MouseEvent.CLICK,renameProjectMouse);
			
			addChild(projectListBox);
			projectListBox.x=skin.projectListBox.x
			projectListBox.y=skin.projectListBox.y
			skin.removeChild(skin.projectListBox);
			
			projectListBox.addEventListener('upData',upSelectItemData);
			this.compressionMiniSitePanel.projectPanel=this;
			this.compressionMiniJsPanel.projectPanel=this;
			upSelectItemData();
		}
		private var compressionMiniSitePanel:CompressionMiniSitePanel=new CompressionMiniSitePanel();
		private var compressionMiniJsPanel:CompressionMiniJsPanel=new CompressionMiniJsPanel();
		protected function upSelectItemData(event:Event=null):void
		{
			var item:ProjectListItem=projectListBox.selectItem;
			if(item==null){
				while(box.numChildren>0)box.removeChildAt(0);
				return;
			}
			var data:Object=item.data;
			var file:File;
			var fileStream:FileStream;
			file=new File(data.projectFile);
			if(!file.exists){
				AlertPanel.show('no project!');
				projectListBox.removieProjectByItem(item);
				projectListBox.upListToProjectlist();
				return;
			}
			fileStream=new FileStream();
			fileStream.open(file,FileMode.READ)
			var itemStr:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			var itemData:Object=Tools.json_decode(itemStr);
			item.setData(itemData);
			projectListBox.upListToProjectlist();
			
			while(box.numChildren>0)box.removeChildAt(0);
			if(itemData.projectType=='miniJs'){
				compressionMiniJsPanel.setItem(item);
				compressionMiniJsPanel.setProjectFile(file)
				compressionMiniJsPanel.initProject()
				box.addChild(compressionMiniJsPanel)
			}
			else if(itemData.projectType=='miniSite'){
				compressionMiniSitePanel.setItem(item)
				compressionMiniSitePanel.setProjectFile(file)
				compressionMiniSitePanel.initProject();
				box.addChild(compressionMiniSitePanel)
			}
		}
		
		protected function newProject(event:MouseEvent=null):void
		{
			AlertManager.getInstance().push(newProjectPanel,true,true,0x0,.2)
			
		}
		protected function openProject(event:MouseEvent=null):void
		{	
			
		}
		protected function removeProjecMouset(event:MouseEvent=null):void
		{
			AlertManager.getInstance().push(removeAlert,true,true,0x0,.2)
			
		}
		protected function renameProjectMouse(event:MouseEvent=null):void
		{
			renameProjectPanel.initProject(projectListBox.selectItem);
			AlertManager.getInstance().push(renameProjectPanel,true,true,0x0,.2);
		}
		
		public function removeProjec():void{
			projectListBox.removeProject();
		}
		public function renameProject(value:String):void
		{
			projectListBox.renameProject(value);
			
		}
		/**
		 * 添加了一个项目
		 */
		public function addProject(file:File):void
		{
			projectListBox.addProject(file);
			
		}
		//more移动上去的效果
		protected function moreOver(event:MouseEvent):void
		{
			addChild(morePanel);
			morePanel.mouseChildren=false;
			morePanel.mouseEnabled=false;
			morePanel.alpha=0;
			morePanel.y=morePanel.oy-20;
			TweenMax.to(morePanel,.3,{alpha:1,x:morePanel.ox,y:morePanel.oy})
		}
		protected function moreOut(event:MouseEvent):void
		{
			morePanel.mouseChildren=true;
			morePanel.mouseEnabled=true;
			TweenMax.delayedCall(.1,delayStageMove)
		}
		private function delayStageMove():void{
			//trace('delayStageMove:',moreOutRect.contains(this.mouseX,this.mouseY))
			if(!moreOutRect.contains(this.mouseX,this.mouseY)){
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,moreMove);
				TweenMax.to(morePanel,.5,{alpha:0,y:morePanel.oy-20,onComplete:function(morePanel:MovieClip):void{
					if(morePanel.parent)morePanel.parent.removeChild(morePanel);
					morePanel.mouseChildren=false;
					morePanel.mouseEnabled=false;
				},onCompleteParams:[morePanel]})
			}else{
				stage.addEventListener(MouseEvent.MOUSE_MOVE,moreMove);
			}
		}
		protected function moreMove(event:MouseEvent):void
		{
			//trace('moreMove:',moreOutRect.contains(this.mouseX,this.mouseY))
			if(!moreOutRect.contains(this.mouseX,this.mouseY)){
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,moreMove);
				TweenMax.to(morePanel,.5,{alpha:0,y:morePanel.oy-20,onComplete:function(morePanel:MovieClip):void{
					if(morePanel.parent)morePanel.parent.removeChild(morePanel);
					morePanel.mouseChildren=false;
					morePanel.mouseEnabled=false;
				},onCompleteParams:[morePanel]})
			}
			
		}
		
		
	}
}