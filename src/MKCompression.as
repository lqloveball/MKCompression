package
{
	import com.ixiyou.air.ui.AIRWindowBase;
	import com.ixiyou.managers.AlertManager;
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	import view.DragFileAlert;
	import view.MCConfigPanel;
	import view.ProjectPanel;
	
	[SWF(frameRate = 30, width = 400, height = 400, backgroundColor = 0xffffff)]
	public class MKCompression extends AIRWindowBase
	{
		private var skin:lib.MainSkin=new MainSkin();
		public var dragFileAlert:DragFileAlert=new DragFileAlert();
		
		public function MKCompression()
		{
			if (stage) init()
			else addEventListener(Event.ADDED_TO_STAGE,init)
			
			stage.scaleMode=StageScaleMode.NO_SCALE;
			DebugOutput.setStage(stage);
			AlertManager.getInstance().stage=stage;
			addChild(skin);
			MKCompressionTools.instance.dragFileAlert=dragFileAlert;
			MKCompressionTools.instance.root=this;
			initDragFileEvent();
			initUI();
			
			MKCompressionTools.instance.initConfing();
			
		}
		
		private function initDragFileEvent():void
		{
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);       
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop); 
		}
		protected function onDrop(event:NativeDragEvent):void
		{
			var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;  
			dragFileAlert.show(files);
		}
		protected function onDragIn(event:NativeDragEvent):void
		{
			NativeDragManager.acceptDragDrop(this);
		}		
		
		
		private var topBg:Sprite
		private var closeBtn:MovieClip;
		private var projectPanel:ProjectPanel;
		private var confingPanel:MCConfigPanel=new MCConfigPanel();
		private function initUI():void
		{
			topBg=skin.top.bg;
			closeBtn=skin.top.closeBtn;
			topBg.addEventListener(MouseEvent.MOUSE_DOWN,topMoveDown);
			Tools.setButton(closeBtn);
			closeBtn.addEventListener(MouseEvent.CLICK,function():void{closeApp();});
			
			Tools.setButton(skin.top.setupBtn);
			skin.top.setupBtn.addEventListener(MouseEvent.CLICK,setupConfing)
			
			projectPanel=new ProjectPanel();
			addChild(projectPanel);
			
			
		}
		
		protected function setupConfing(event:MouseEvent):void
		{
			AlertManager.getInstance().push(confingPanel);
		}
		protected function topMoveDown(event:MouseEvent):void
		{
			window.startMove();
		}
		
		
		
	}
}