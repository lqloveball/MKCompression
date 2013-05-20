/**
 * MKUIUitl
 */
(function(window) {
	var MKColorUitl = function() {};
	//--------------色彩 Hex----------------------------
	MKColorUitl.cutHex=function (h) {return (h.charAt(0)=="#") ? h.substring(1,7):h;};
	MKColorUitl.hexToRGB=function(h){
		h = "0x" + MKColorUitl.cutHex(h).substr(1);
		return parseInt(h);
	};
	MKColorUitl.hexToR= function (h) {
		h = "0x" + MKColorUitl.cutHex(h);
		return (parseInt(h) >>16) & 0xFF;
	};
	MKColorUitl.hexToG= function (h) {
		return (parseInt("0x" + MKColorUitl.cutHex(h)) >>8) &0xFF;
	};
	MKColorUitl.hexToB= function (h) {
		return (parseInt("0x" + MKColorUitl.cutHex(h))&0xFF);
	};
	MKColorUitl.hexToCSSRGB=function(hex) {
		var r = MKColorUitl.hexToR(hex);
	    var g = MKColorUitl.hexToG(hex);
	    var b = MKColorUitl.hexToB(hex);
	    var rgba = "rgb(" + r + ", " + g + ", " + b + ")";
	    return rgba;
	};
	MKColorUitl.hexToCSSRGBA=function(hex,alpha) {
		if(alpha==undefined)alpha=1;
		alpha = (alpha < 0) ? 0 : alpha;
		alpha = (alpha > 1) ? 1 : alpha;
	    var r = MKColorUitl.hexToR(hex);
	    var g = MKColorUitl.hexToG(hex);
	    var b = MKColorUitl.hexToB(hex);
	    var rgba = "rgba(" + r + ", " + g + ", " + b + ", " + (alpha).toString() + ")";
	    return rgba;
	};
	//--------------色彩 RGB----------------------------
	MKColorUitl.rgb2Hex=function (rgb){ 
		if(typeof(rgb)!='number')rgb=Number(rgb);
		return '#'+rgb.toString(16);
	};
	MKColorUitl.rgbToR= function (rgb) {
		return ((rgb >> 16) & 0xFF);
	};
	MKColorUitl.rgbToG= function (rgb) {
		return ((rgb >> 8) & 0xFF);
	};
	MKColorUitl.rgbToB= function (rgb) {
		return ((rgb) & 0xFF);
	};
	//---------------色彩调节------------------
	/**
	 * 调节颜色亮度  
	 * @param color 颜色 0xff00ff
	 * @param brite 亮度 -255到255 
	 * @param type 默认 color 可选 hex
	 * @returns
	 */
	MKColorUitl.colorBrightness=function(color,brite,type){
		var r = Math.max(Math.min(((color >> 16) & 0xFF) + brite, 255), 0);
		var g = Math.max(Math.min(((color >> 8) & 0xFF) + brite, 255), 0);
		var b = Math.max(Math.min((color & 0xFF) + brite, 255), 0);
		if(type=='hex')return MKColorUitl.rgb2Hex((r << 16) | (g << 8) | b);
		else return (r << 16) | (g << 8) | b;
	};
	/**
	 * 颜色深浅
	 * @param color 
	 * @param value 0-1 深到浅;
	 * @param type 默认 color 可选 hex
	 */
	MKColorUitl.colorDeepen=function(color,value,type) {
		value = (value < 0) ? 0 : value;
		value = (value > 1) ? 1 : value;
		var r = ((color >> 16) & 0xFF) * value;
		var g = ((color >> 8) & 0xFF) * value;
		var b = (color & 0xFF) * value;
		if(type=='hex')return MKColorUitl.rgb2Hex((r << 16) | (g << 8) | b);
		else return (r << 16) | (g << 8) | b;
	};
	//-----------------色彩转换 HSB---------------------
	MKColorUitl.colorToRGB=function (color) {
		var r = (color >> 16) & 0xFF;
		var g = (color >> 8) & 0xFF;
		var b = color & 0xFF;
		var rgb={r:r,g:g,b:b};
		return rgb;
	};
	/**
	 * 颜色转HSB  色彩范围hues (0-360) 饱和度saturation (0-100) 亮度brightness(0到100)
	 * @param 
	 * @return 
	*/
	MKColorUitl.colorToHsb=function(color) {
		var rgb = color;
		var _r = (rgb >> 16) & 0xFF;
		var _g = (rgb >> 8) & 0xFF;
		var _b = (rgb) & 0xFF;
		var hsb = {h:0,s:0,b:0};
		var low = Math.min(_r, Math.min(_g, _b));
		var high = Math.max(_r,Math.max(_g, _b));
		hsb.b = high*100/255;
		var diff = high-low;
		if (diff) {
			hsb.s = Math.round(100*(diff/high));
			if (_r == high) {
				hsb.h = Math.round(((_g-_b)/diff)*60);
			} else if (_g == high) {
				hsb.h = Math.round((2+(_b-_r)/diff)*60);
			} else {
				hsb.h = Math.round((4+(_r-_g)/diff)*60);
			}
			if (hsb.h>360) {
				hsb.h -= 360;
			} else if (hsb.h<0) {
				hsb.h += 360;
			}
		} else {
			hsb.h= hsb.s=0;
		}
		return hsb;
	};
	MKColorUitl.hsbToColor=function(hsb) {
		var _r = 0;
		var _g = 0;
		var _b = 0;
		hsb.s *= 2.55;
		hsb.b *= 2.55;
		if (!hsb.h && !hsb.s) {
			_r = _g = _b = hsb.b;
		} else {
			var diff = (hsb.b*hsb.s)/255;
			var low = hsb.b-diff;
			if (hsb.h>300 || hsb.h<=60) {
				_r = hsb.b;
				if(hsb.h > 300){
					_g = Math.round(low);
					hsb.h = (hsb.h-360)/60;
					_b = -Math.round(hsb.h*diff - low);
				}else{
					_b = Math.round(low);
					hsb.h = hsb.h/60;
					_g = Math.round(hsb.h*diff + low);
				}
			} else if (hsb.h>60 && hsb.h<180) {
				_g = hsb.b;
				if (hsb.h<120) {
					_b = Math.round(low);
					hsb.h = (hsb.h/60-2)*diff;
					_r = Math.round(low-hsb.h);
				} else {
					_r = Math.round(low);
					hsb.h = (hsb.h/60-2)*diff;
					_b = Math.round(low+hsb.h);
				}
			} else {
				_b = hsb.b;
				if (hsb.h<240) {
					_r = Math.round(low);
					hsb.h = (hsb.h/60-4)*diff;
					_g = Math.round(low-hsb.h);
				} else {
					_g = Math.round(low);
					hsb.h = (hsb.h/60-4)*diff;
					_r = Math.round(low+hsb.h);
				}
			}
			return (_r << 16) | (_g << 8) | _b;
		}
	};
	//trace(MKColorUitl.hexToCSSRGB('#ffff00'));
	window.MKColorUitl = MKColorUitl;
}(window));