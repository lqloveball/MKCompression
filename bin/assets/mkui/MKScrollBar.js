/**
 * MKScrollBar
 */
(function(window) {
	var MKScrollBar = function(data) {
	    this.init(data);
	};
	MKScrollBar.prototype = new MKUIBase();
	MKScrollBar.prototype.value = 100;
	MKScrollBar.prototype.max = 100;
	MKScrollBar.prototype.min = 0;
	MKScrollBar.prototype.width = 100;
	MKScrollBar.prototype.height = 100;
	
	MKScrollBar.prototype.color = '#ffffff';
	
	MKScrollBar.prototype.type='horizontal';//'vertical';
	
	MKScrollBar.prototype.onChange = null;
	MKScrollBar.prototype.onFinishChange = null;
	
	MKScrollBar.prototype.view;
	MKScrollBar.prototype.init = function(data) {
	    this._setConfing(data, 'value');
	    this._setConfing(data, 'max');
	    this._setConfing(data, 'min');
	    this._setConfing(data, 'onChange'); 
	    this._setConfing(data, 'onFinishChange');
	    
	    this._setConfing(data,'type');
	    this.width=this.type=='horizontal'?100:15;
		this.height=this.type=='horizontal'?15:100;
		
	    this._setConfing(data, 'width');
	    this._setConfing(data, 'height');
	    
	    this.initUI();
	};
	MKScrollBar.prototype.initUI = function() {
	   
	    var scrollBarCss={ 	
	    	//position:'relative',
	    	//float:'none',
    	 	//background:MKColorUitl.hexToCSSRGBA(this.color,0),
    	 	'border-color': MKColorUitl.hexToCSSRGBA(this.color,.5),
    	 	
    	 	width:(this.width-2)+'px',
    	 	height:(this.height-2)+'px',
    	 	padding:'1px',
    	 	
    	 	'border-style':'solid',
    	 	'border-width': '1px'
	    	
    	};
	    
	    var sliderBgCss={
	    	//position:'absolute',
	    	//float:'none',
	    	//top:'0px',
	    	//left:'0px',
        	width:'100%',
        	height:'100%',
        	background:MKColorUitl.hexToCSSRGBA(this.color,.5)
    	 };
	    var sliderCss={
	    	//position:'absolute',
    		//float:'none',
	    	//top:'0px',
	    	//left:'0px',
	    	width:'100%',
	    	height: '100%',
	    	background:MKColorUitl.hexToCSSRGBA(this.color,1)
    	 };
	    var view = $('<div>');
	    this.view = view;
        view.css(scrollBarCss);
        
       
        
        var sliderBg = $('<div>');
        sliderBg.css(sliderBgCss);
        view.append(sliderBg);
        
        var slider = $('<div>').css(sliderCss);
        sliderBg.append(slider);
        
	};
	
    MKScrollBar.prototype.addView = function(view) {

    };
    window.MKScrollBar = MKScrollBar;
}(window));
