package view.projectView.miniJsView
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	import lib.*;
	
	
	public class JsItemMenu extends Sprite
	{
		private var skin:JsItemMenuSkin=new JsItemMenuSkin();
		public function JsItemMenu()
		{
			super();
			addChild(skin);
			initUI();

		}
		
		
		private var front:MovieClip
		private var forward:MovieClip
		private var backward:MovieClip
		private var back:MovieClip
		private var show:MovieClip
		private var hide:MovieClip
		private function initUI():void
		{
			front=skin.front;
			forward=skin.forward;
			backward=skin.backward;
			back=skin.back;
			show=skin.show;
			hide=skin.hide;
			Tools.setButton(front);
			Tools.setButton(forward);
			Tools.setButton(backward);
			Tools.setButton(back);
			Tools.setButton(show);
			Tools.setButton(hide);
			hide.visible=false;
			show.visible=false;
			front.addEventListener(MouseEvent.CLICK,frontFun)
			forward.addEventListener(MouseEvent.CLICK,forwardFun)
			backward.addEventListener(MouseEvent.CLICK,backwardFun)
			back.addEventListener(MouseEvent.CLICK,backFun)
			show.addEventListener(MouseEvent.CLICK,showFun)
			hide.addEventListener(MouseEvent.CLICK,hideFun)
		}

		private var list:MiniJsListPanel;
		private var item:JSItem;
		private var type:String
		public function initJsItem(_item:JSItem,_list:MiniJsListPanel,_type:String):void{
			list=_list;
			item=_item;
			type=_type;
			if(type=='jsList'){
				hide.visible=true;
				show.visible=false;
			}else{
				hide.visible=false;
				show.visible=true;
			}
		}
		public function hit():void{
			if(this.parent)parent.removeChild(this);
		}
		protected function hideFun(event:MouseEvent):void
		{
			if(!list.stage)hit();
			var compresionList:Array=list.compresionList;
			var hitList:Array=list.hitList;
			
			item.data.hit=true;
			listArr=list.compresionList;
			var num:int=listArr.indexOf(item)
			trace('hit:',item.name,num)
			if(num!=-1){
				var arr:Array=listArr.splice(num,1);
				hitList.unshift(item);
			}
			list.upListToProjectlist();	
			hit();
		}
		protected function showFun(event:MouseEvent):void
		{
			if(!list.stage)hit();
			var compresionList:Array=list.compresionList;
			var hitList:Array=list.hitList;
			item.data.hit=false;
			listArr=list.hitList;
			var num:int=listArr.indexOf(item)
			if(num!=-1){
				var arr:Array=listArr.splice(num,1);
				compresionList.unshift(item);
			}
			list.upListToProjectlist();	
			hit();
		}
		private var listArr:Array
		protected function frontFun(event:MouseEvent):void
		{
			if(!list.stage)hit();
			if(type=='jsList')listArr=list.compresionList
			else listArr=list.hitList
			
			var num:int=listArr.indexOf(item)
			if(num!=-1){
				var arr:Array=listArr.splice(num,1);
				listArr.unshift(arr[0]);
			}
			list.upListToProjectlist();
			hit()
			
		}
		protected function backFun(event:MouseEvent):void
		{
			if(!list.stage)hit();
			if(type=='jsList')listArr=list.compresionList
			else listArr=list.hitList
			
			var num:int=listArr.indexOf(item)
			if(num!=-1){
				var arr:Array=listArr.splice(num,1);
				listArr.push(arr[0]);
			}
			list.upListToProjectlist();
			hit()
		}
		//置顶
		protected function forwardFun(event:MouseEvent):void
		{
			if(!list.stage)hit();
			if(type=='jsList')listArr=list.compresionList
			else listArr=list.hitList
			
			var num:int=listArr.indexOf(item)
			if(num!=-1){
				var arr:Array=listArr.splice(num,1);
				var index:int=num-1;
				if(index<=0)index=0
				listArr.splice(index,0,arr[0]);
			}
			list.upListToProjectlist();
			hit()
		}
		protected function backwardFun(event:MouseEvent):void
		{
			if(!list.stage)hit();
			if(type=='jsList')listArr=list.compresionList
			else listArr=list.hitList
			
			var num:int=listArr.indexOf(item)
			if(num!=-1){
				var arr:Array=listArr.splice(num,1);
				var index:int=num+1;
				if(index>=listArr.length)index=listArr.length-1;
				if(index<=0)index=0
				listArr.splice(index,0,arr[0]);
			}
			list.upListToProjectlist();
			hit()
		}
		
		
		
		
	}
}