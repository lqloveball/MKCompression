package com.ixiyou.spe3d.five3d
{

	
	
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.ixiyou.geom.GalleryList;
	import com.ixiyou.spe3d.five3d.item.Gallery3DByMovieSkinItem;
	import com.ixiyou.speUI.mcontrols.MovieHSlider;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import net.badimon.five3D.display.*;
	
	public class Gallery3DByMovieSkin extends Sprite
	{
		private var skin:MovieClip
		//参考mc
		private var skinItemArr:Array
		
		
		//3d场景
		private var scene:Scene3D;
		
		private var slider:MovieHSlider
		private var lister:GalleryList
		
		//显示大小
		private var itmeW:Number=100;
		private var itmeH:Number=100;
		
		//原来数字
		private var oldvalue:Number=0;
		//运动方向
		private var showDirection:Boolean=true;
	
		
		private var _length:Number=100;
		public function Gallery3DByMovieSkin(skin:MovieClip)
		{
			super();
			this.skin=skin;
			
			skinItemArr=new Array();
			for (var i:int = 0; i < Sprite(skin.box).numChildren-2; i++) 
			{
				var temp:DisplayObject=Sprite(skin.box).getChildByName('item'+i) as DisplayObject;
				skinItemArr.push(temp);
			}
			
			scene = new Scene3D()
			addChild(scene)
			
			scene.x=skin.box.x;
			scene.y=skin.box.y;
			
			slider= new MovieHSlider(skin.mc_slider,true,true)
			addChild(slider)
			slider.addEventListener('upData',sliderUpData)
			
			
			
		}
		
	
		
		public function get length():Number
		{
			return _length;
		}

		public function init(w:Number=100,h:Number=100,length:Number=100):void{	
			_length=length;
			itmeW=w;
			itmeH=h;
			oldvalue=slider.value=0;
			
			if(lister){lister.removeEventListener('upData',upData)}
			var arr:Array=new Array();
			for (var i:int = 0; i < length; i++) 
			{
				var obj:Object={}
				obj.id=i;
				obj.item=null;
				arr.push(obj)
			}
			lister=new GalleryList(arr,skinItemArr.length)
			lister.addEventListener('upData',upData);
				
			
			sliderUpData();
		}
		
		
		protected function sliderUpData(event:Event=null):void
		{
			//trace(oldvalue,'/',slider.value);
			if(oldvalue>=slider.value)showDirection=true;
			else showDirection=false;
			oldvalue=slider.value;
			
			var num:Number=slider.value-1;
			if(num<0)num=lister.data.length-1;
			lister.selectNum=num;
			//upPage();
			
		}
		/**
		 * 更新页面面 
		 * 
		 */		
		private function upPage():void{
			
			
			
			
		}
		protected function upData(event:Event):void
		{
			var item:Gallery3DByMovieSkinItem
			var temp:DisplayObject
			var obj:Object
			var i:int=0;
			
			var oldObjData:Array=lister.oldObjData;
			var nowObjData:Array=lister.nowObjData;
			//trace('oldObjData',oldObjData)
			for ( i = 0; i < oldObjData.length; i++) 
			{
				obj=oldObjData[i]
				if(obj.item!=null){
					item=obj.item;
					if(scene.contains(item))scene.removeChild(item);
					item.dispose();
				}
				//trace('删除：'+obj.id,obj.item);
			}
			
			
			var arr:Array=new Array(nowObjData.length)
			var dic:Object={}
			for (i = 0; i < nowObjData.length; i++) 
			{
				obj=nowObjData[i];
				if(obj.item==null){
					item=new Gallery3DByMovieSkinItem(350,350);
					obj.item=item;
				}else{
					item=obj.item;
					item.upBitmapdata();
				}
				item.id=obj.id;
				
				
				/*
				item.x=temp.x;
				item.y=temp.y;
				item.z=temp.z;
				item.rotationY=temp.rotationY;
				item.rotationX=temp.rotationX;
				item.rotationZ=temp.rotationZ;
				item.alpha=.7;
				*/

				temp=Sprite(skin.box).getChildByName('item'+i) as DisplayObject;
				//计算层级位置
				arr[temp.parent.getChildIndex(temp)]=item;
				
				var ck_mc:DisplayObject=null;
				if(showDirection){
					ck_mc=Sprite(skin.box).getChildByName('remove0') as DisplayObject;
				}else{
					ck_mc=Sprite(skin.box).getChildByName('remove1') as DisplayObject;
				}
				item.x=ck_mc.x;
				item.y=ck_mc.y;
				item.z=ck_mc.z;
				item.rotationY=ck_mc.rotationY;
				item.rotationX=ck_mc.rotationX;
				item.rotationZ=ck_mc.rotationZ;
				item.alpha=0;
				
				item.showData={
					alpha:temp.alpha,x:temp.x,y:temp.y,z:temp.z,
					rotationY:temp.rotationY,rotationX:temp.rotationX,rotationZ:temp.rotationZ,
					ease:Cubic.easeOut
				 }
					
				//计算延迟时间
				var delay:Number=.1
				if(showDirection)item.showData.delay=nowObjData.length*delay-delay*i;
				else item.showData.delay=delay*i;
				
				TweenMax.to(item,.3,item.showData)
				

			}
			//计算层级关系
			for (i = 0; i < arr.length; i++) 
			{
				item=arr[i];
				if(item)scene.addChild(item);
			}
			//trace(scene.numChildren)
		}
		
			
	}
}