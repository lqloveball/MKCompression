﻿/*
 * com.vj.fx.Pixelator
 * 
 * @author: Erik Hallander
 * @build: 1.1 (21-08-08)
 * @purpose: "Pixelating" transition between two displayobjects.
 * @collaborators: None.
 * @communicates: Two events; PIXEL_PHASE_2 once the first phase is complete, PIXEL_TRANSITION_COMPLETE once second phase is complete.
 * 
 * @destructs: Nothing. Source objects gets hidden.
 * @modifies: Nothing.
 * 
 * @aux: Can be a decent idea to not have source and destination addchilded anywhere and just pass them to this class
 * otherwise they will just remain in the overhead :/ (alternatively take advantage of PIXEL_TRANSITION_COMPLETE and prepare them for
 * GC at that point.)
 * 
 * @public properties: None. Static constants only.
 * @public methods:
 * 			Pixelator(_source:DisplayObject, _dest:DisplayObject, _cutoff:int) - Constructor. 
 * 			reconfigure(_source:DisplayObject, _dest:DisplayObject, _cutoff:int) - Reconfigures the display data for additional transitions
 * 			startTransition(_tempo:Number) - starts transition defined by constructor or reconfigure(). Dispatches events when done.
 * 			destroy() - Removes all internal objects and references. This will render the class useless and ready for GC when removed from DL.
 * /---------使用方法-------------/
 * 
    var img1:Bitmap = new Bitmap(new lpica(1,1));
	var img2:Bitmap = new Bitmap(new lpicb(1,1));
	var _bike:Boolean = true;
	
	
    px = new Pixelator(img1, img2, 100);
	px.addEventListener(Pixelator.PIXEL_TRANSITION_COMPLETE, onComplete);
	px.x = 25; px.y = 50; px.buttonMode = true; px.mouseChildren = false;
	addChild(px);
	px.addEventListener(MouseEvent.CLICK, startTransition);
		
	function startTransition(e:MouseEvent):void {
		px.mouseEnabled = false;
		px.startTransition(Pixelator.PIXELATION_FAST); // SLOWEST, SLOW, MEDIUM, FAST & FASTEST;
	};
	
	function onComplete(e:Event):void {
		px.mouseEnabled = true;
		// Keep it alive
		if (_bike) 
		{
			_bike = false;
			px.reconfigure(img1, img2, 100);
		} else 
		{
			_bike = true;
			px.reconfigure(img2, img1, 100);
		}
	};
 * 
 * 
 * 
 * 
 * 
 * 
 */
package com.ixiyou.effects 
{
	
	/**
	 * 马赛克过度
	 * @author spe
	 */
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;

	public class Pixelator extends Sprite{
	
		private var _src:Sprite;
		private var _dst:Sprite;
		private var _destination:DisplayObject;
		private var _inAction:Boolean = false;
		private var _zoomin:Boolean = true;
		private var _pixelSize:Number = 1;
		private var _scaleMatrix:Matrix;
		private var _bitmapProcess:BitmapData;
		private var _bitmap:Bitmap;
		private var _overlay:Sprite;
		
		private var _outMod:Number = 0;
		private var _inMod:Number = 0;
		
		private var _pixelCutoff:int = 200; // The max size of a pixel.
		
		public static const PIXELATION_SLOWEST:Number = .04;
		public static const PIXELATION_SLOW:Number = .07;
		public static const PIXELATION_MEDIUM:Number = .15;
		public static const PIXELATION_FAST:Number = .25;
		public static const PIXELATION_FASTEST:Number = .35;
		
		public static const PIXEL_TRANSITION_COMPLETE:String = "PIXEL_TRANSITION_COMPLETE";
		public static const PIXEL_PHASE_2:String = "PIXEL_PHASE_2";

		
		/*
		 * Constructor Pixelator
		 * @params:		_source:DisplayObject (display object to start with)
		 * @params: 	_dest:DisplayObject (display object to end with)
		 * 
		 * @returns:	nothing.
		 */
		
		public function Pixelator(_source:DisplayObject, _dest:DisplayObject, _cutoff:int):void {	
			_src = new Sprite(); _dst = new Sprite();
			_pixelCutoff = _cutoff;
			var copyData:BitmapData = new BitmapData(_source.width, _source.height, true, 0);
			copyData.draw(_source);
			_src.addChild(new Bitmap(copyData));
			copyData = new BitmapData(_dest.width, _dest.height, true, 0);
			copyData.draw(_dest);
			_dst.addChild(new Bitmap(copyData));
			_dst.visible = _source.visible = _dest.visible = false;
			_overlay = new Sprite();
			_bitmap = new Bitmap(_bitmapProcess);
			_overlay.addChild(_bitmap);	
			addChild(_src); addChild(_dst); addChild(_overlay);
		}; 
		
		/*
		 * Public method reconfigure
		 * @purpose:	prepares the class for a new transition.
		 * 
		 * @params:		_source:DisplayObject (display object to start with)
		 * @params: 	_dest:DisplayObject (display object to end with)
		 * 
		 * @returns:	nothing.
		 */
		
		public function reconfigure(_source:DisplayObject, _dest:DisplayObject, _cutoff:*):void {	
			removeChild(_overlay);
			_overlay = null;
			_pixelCutoff = _cutoff;
			_src = new Sprite(); _dst = new Sprite();
			var copyData:BitmapData = new BitmapData(_source.width, _source.height, true, 0);
			copyData.draw(_source);
			_src.addChild(new Bitmap(copyData));
			copyData = new BitmapData(_dest.width, _dest.height, true, 0);
			copyData.draw(_dest);
			_dst.addChild(new Bitmap(copyData));
			_dst.visible = _source.visible = _dest.visible = false;
			_overlay = new Sprite();
			_bitmap = new Bitmap(_bitmapProcess);
			_overlay.addChild(_bitmap);	
			addChild(_src); addChild(_dst); addChild(_overlay);
		}; 
		
		/*
		 * Public method startTransition
		 * @params:		_tempo:int (Speed of transition)
		 * 
		 * @returns:	nothing.
		 */		
		
		public function startTransition(_tempo:Number):void {
			if (!_inAction) 
			{
				_inMod = 1 - _tempo;
				_outMod = 1 + _tempo;
				_inAction = true;
				_src.visible = false;
				addEventListener("PIXEL_DONE", pixelateDone);
				addEventListener(Event.ENTER_FRAME, pixelateOut);
			} else {
				trace("Currently already processing a transition.");
			}
		};
		
		private function pixelateIn(e:Event):void {
			_bitmapProcess = new BitmapData(_dst.width/_pixelSize, _dst.height/_pixelSize, true, 0);
			_scaleMatrix = new Matrix();
			_scaleMatrix.scale(1/_pixelSize, 1/_pixelSize);
			_bitmapProcess.draw(_dst, _scaleMatrix);
			_bitmap.bitmapData = _bitmapProcess;
			_bitmap.width = _dst.width;
			_bitmap.height = _dst.height;
			_pixelSize *= _inMod;
			if (_pixelSize <= 1.1) { // 1.1 -> 1.0 is almost an indefinite period of time due to division.
				removeEventListener(Event.ENTER_FRAME, pixelateOut);
				dispatchEvent(new Event("PIXEL_DONE"));
			}			
		};
		
		private function pixelateOut(e:Event):void {
			_bitmapProcess = new BitmapData(_src.width/_pixelSize, _src.height/_pixelSize, true, 0);
			_scaleMatrix = new Matrix();
			_scaleMatrix.scale(1/_pixelSize, 1/_pixelSize);
			_bitmapProcess.draw(_src, _scaleMatrix);
			_bitmap.bitmapData = _bitmapProcess;
			_bitmap.width = _src.width;
			_bitmap.height = _src.height;
			_pixelSize *= _outMod;
			if (_pixelSize >= _pixelCutoff) {
				removeEventListener(Event.ENTER_FRAME, pixelateOut);
				dispatchEvent(new Event(PIXEL_PHASE_2));
				addEventListener(Event.ENTER_FRAME, pixelateIn);
			}			
		};
		private function pixelateDone(e:Event):void {
			trace(this +" has completed its transition");
			disposeLevelOne();
			dispatchEvent(new Event(PIXEL_TRANSITION_COMPLETE));
		};
		
		public function destroy():void { // wipes 
			disposeLevelTwo();
		};
		
		private function disposeLevelOne():void {
			if (_src != null) removeChild(_src);
			if (_dst != null) removeChild(_dst);
			_bitmapProcess.draw(_dst);
			_bitmap.bitmapData = _bitmapProcess;
			_src = null;
			_dst = null;
			_bitmapProcess.dispose();
			_bitmapProcess = null;
			_bitmap = null;
			_scaleMatrix = null;
			_inAction = false;
			removeEventListener(Event.ENTER_FRAME, pixelateIn);
			removeEventListener("PIXEL_DONE", pixelateDone);			
		};
		
		private function disposeLevelTwo():void {
			removeChild(_overlay);
			_overlay = null;
			
		}
	};
};