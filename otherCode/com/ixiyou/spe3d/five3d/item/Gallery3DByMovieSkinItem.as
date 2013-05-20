package com.ixiyou.spe3d.five3d.item
{
	import com.ixiyou.utils.display.BitmapDataUtils;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	
	import net.badimon.five3D.display.*;
	import net.badimon.five3D.typography.HelveticaBold;
	
	public class Gallery3DByMovieSkinItem extends Sprite3D
	{
		private var bmp3d:Bitmap3D = new Bitmap3D();
		private var shadow:Bitmap3D=new Bitmap3D();
		private var w:uint;
		private var h:uint;
		private var _bitmapdata:BitmapData;
		
		private var _id:Number
		private var text:DynamicText3D
		public function Gallery3DByMovieSkinItem(w:Number,h:Number)
		{
			
			addChild(bmp3d)
			addChild(shadow)
			text=new DynamicText3D(HelveticaBold.instance);
			addChild(text)
			setSize(w,h)
		}

		public function get id():Number
		{
			return _id;
		}

		public function set id(value:Number):void
		{
			_id = value;
			text.text=id+'';
		}

		public function setSize(w:uint, h:uint):void {
			this.w = w;
			this.h = h;
			upBitmapdata();
		}
		public function upBitmapdata():void{
			bitmapdata= new BitmapData(w, h,false,0xffffff*Math.random());
			bmp3d.x = -w / 2
			bmp3d.y = -h / 2
			shadow.x = bmp3d.x
			shadow.y = h/2+2
				
			text.x=bmp3d.x
			text.y=bmp3d.y
		}
		public function get bitmapdata():BitmapData { return _bitmapdata; }
		
		public function set bitmapdata(value:BitmapData):void 
		{
			if (_bitmapdata == value) return
			if(_bitmapdata)_bitmapdata.dispose()
			_bitmapdata = value;
			//if(loader)bitmapdata.draw(loader)
			bmp3d.bitmapData = bitmapdata
			var temp:Bitmap=new Bitmap(bitmapdata.clone())
			shadow.bitmapData=BitmapDataUtils.Reflection(temp,.5,0,0,100).bitmapData
		}
		
		public function dispose():void{
			bmp3d.bitmapData.dispose()
			shadow.bitmapData.dispose()
		}
		/**
		 *用于动画的数据 
		 */		
		public var showData:Object
		
	}
}