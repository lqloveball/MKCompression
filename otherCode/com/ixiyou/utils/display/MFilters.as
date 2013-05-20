package com.ixiyou.utils.display
{
	
	/**滤镜类
	* "Shadow"  阴影滤镜
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	import flash.filters.*
	public class MFilters 
	{
		/**
		 * 灰色
		 * @param 
		 * @return 
		*/
		static public function  gray():ColorMatrixFilter {	
			var gray_Matrix:Array=new Array()
			gray_Matrix =	[0.3086, 0.6094, 0.0820, 0, 0,
							0.3086, 0.6094, 0.0820, 0, 0,
							0.3086, 0.6094, 0.0820, 0, 0,
							0    , 0    , 0    , 1, 0];
			var ColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(gray_Matrix);//亮度
			return ColorMatrix_filter
		}
		/**
		 * 亮度
		 * @param val 取值为-255到255
		 * @return 
		*/
		static public function  brightness(val:Number):ColorMatrixFilter {	
			var Brightness_Matrix:Array=new Array()
			Brightness_Matrix =[1,0,0,0,val,
								0,1,0,0,val,
								0,0,1,0,val,
								0,0,0,1,0];
			var ColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(Brightness_Matrix);//亮度
			return ColorMatrix_filter
		}
		/**
		 * 对比度
		 * @param val 取值为0到10
		 * @return 
		*/
		static public function  contrast(val:Number):ColorMatrixFilter  {
			var contrast_Matrix:Array=new Array()
			contrast_Matrix = [val, 0, 0, 0, (1-val)*128,
								 0, val, 0, 0, (1-val)*128, 
								 0, 0, val, 0, (1-val)*128,
								 0, 0, 0, 1, 0];
			var contrast_filter:ColorMatrixFilter = new ColorMatrixFilter(contrast_Matrix);//亮度
			return contrast_filter
		}
		/**
		 * 反相
		 * @param 
		 * @return 
		*/
		static public function  oppositionHue():ColorMatrixFilter {	
			var gray_Matrix:Array=new Array()
			gray_Matrix =	[-1,  0,  0, 0, 255,
							0 , -1,  0, 0, 255,
							0 ,  0, -1, 0, 255,
							0 ,  0,  0, 1,   0];
			var ColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(gray_Matrix);//亮度
			return ColorMatrix_filter
		}
		/**阈值
		 * 
		 * @param val(取值为-255到255)
		 * @return 
		*/
		static public function  limen(val:Number):ColorMatrixFilter {	
			var gray_Matrix:Array=new Array()
			gray_Matrix =	[0.3086*256,0.6094*256,0.0820*256,0,-256*val,
							0.3086*256,0.6094*256,0.0820*256,0,-256*val,
							0.3086*256,0.6094*256,0.0820*256,0,-256*val,
							0, 0, 0, 1, 0];
			var ColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(gray_Matrix);//亮度
			return ColorMatrix_filter
		}
		/**
		 * 色彩饱和度
		 * @param 取值为0到255
		 * @return 
		*/
		static public function  saturation(val:Number):ColorMatrixFilter {	
			var gray_Matrix:Array=new Array()
			gray_Matrix =	[0.3086*(1-val)+ val, 0.6094*(1-val)    , 0.0820*(1-val)    , 0, 0,
							0.3086*(1-val)   , 0.6094*(1-val) + val, 0.0820*(1-val)    , 0, 0,
							0.3086*(1-val)   , 0.6094*(1-val)    , 0.0820*(1-val) + val, 0, 0,
							0        , 0        , 0        , 1, 0];
			var ColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(gray_Matrix);//亮度
			return ColorMatrix_filter
		}
		/**
		 * 色彩通道
		 * @param RGB均为0-2，A为0-1
		 * @return 
		*/
		static public function  colorChannels(R:Number,G:Number,B:Number,A:Number):ColorMatrixFilter {	
			var gray_Matrix:Array=new Array()
			gray_Matrix =	[R,0,0,0,0,
							0,G,0,0,0,
							0,0,B,0,0,
							0,0,0,A,0];
			var ColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(gray_Matrix);//亮度
			return ColorMatrix_filter
		}
		
		/**
		 * Stroke (描边)
		 * @param 
		 * @return 
		*/
		static public function Stroke(color:Number = 0x000000, alpha:Number = .1, blurX:Number = 2, blurY:Number = 2, strength:Number = 6,
		inner:Boolean = false, knockout:Boolean = false,
		quality:Number = 3
		):BitmapFilter {
			return new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
		}
		/**
		 * 5宽度阴影滤镜
		 * @param	color
		 * @param	alpha
		 * @param	blurX
		 * @param	blurY
		 * @param	strength
		 * @param	inner
		 * @param	knockout
		 * @param	quality
		 * @return
		 */
		static public function getShadowFilter(color:Number = 0x000000,
            alpha:Number = 0.5,
            blurX:Number = 5,
            blurY:Number = 5,
            strength:Number = 2,
            inner:Boolean = false,
            knockout:Boolean = false,
            quality:Number = 3):BitmapFilter {
            return new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
        }
		/**
		* 模糊滤镜
		* @author 
		*/
		static public function getBlurFilter(blurX:uint=5,blurY:uint=5,HIGH:uint=3):BlurFilter {
			return new BlurFilter(blurX,blurY,HIGH);
		}
		
		/**
		 * 发光
		 * @param	color (default = 0xFF0000) — 光晕颜色，采用十六进制格式 0xRRGGBB。默认值为 0xFF0000。
		 * @param	alpha 颜色的 Alpha 透明度值。有效值为 0 到 1。例如，.25 设置透明度值为 25%。
		 * @param	blurX 水平模糊量。有效值为 0 到 255（浮点）。2 的乘方值（如 2、4、8、16 和 32）经过优化，呈现速度比其它值更快。
		 * @param	blurY 垂直模糊量。有效值为 0 到 255（浮点）。2 的乘方值（如 2、4、8、16 和 32）经过优化，呈现速度比其它值更快
		 * @param	strength 印记或跨页的强度。该值越高，压印的颜色越深，而且发光与背景之间的对比度也越强。有效值为 0 到 255。
		 * @param	inner 指定发光是否为内侧发光。
		 * @param	knockout 指定对象是否具有挖空效果。
		 * @param	quality  应用滤镜的次数。使用 BitmapFilterQuality 常量：
		 */
		static public function getGlowFilter(color:Number, alpha:Number = .5,
											blurX:Number = 5, blurY:Number = 5,
											strength:Number = 2, inner:Boolean = false,
											knockout:Boolean = false,
											quality:Number = 3):BitmapFilter 
		{
			   
			return new GlowFilter(color,
							  alpha,
							  blurX,
							  blurY,
							  strength,
							  quality,
							  inner,
							  knockout);
	   }
		
	}
	
}