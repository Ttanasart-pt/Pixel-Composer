function Node_PB_FX_Shine(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shine";
	
	newInput(0, nodeValue_Surface( "Surface" ));
	newInput(1, nodeValue_Surface( "Mask"    ));
	
	////- =Shine
	newInput(5, nodeValue_Slider(      "Progress",   .5          ));
	newInput(4, nodeValue_Float(       "Shines",     [2,1,1]     )).setDisplay(VALUE_DISPLAY.number_array);
	newInput(6, nodeValue_Float(       "Slope",       1          ));
	newInput(3, nodeValue_Bool(        "Invert Direction", false ));
	newInput(8, nodeValue_Enum_Button( "Axis",  0, [ "X", "Y" ]  ));
	
	////- =Render
	newInput(2, nodeValue_Color(  "Colors",    ca_white ));
	newInput(7, nodeValue_Slider( "Intensity", 1        ));
	// input 9
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 1, 
	    ["Shine",  false], 5, 4, 6, 3, 8, 
	    ["Render", false], 2, 7, 
    ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
	    var _surf = _data[0];
	    var _mask = _data[1];
	    
	    var _color = _data[2];
	    var _inver = _data[3];
	    var _shine = _data[4];
	    var _progr = _data[5];
	    var _slope = _data[6];
	    var _ints  = _data[7];
	    var _invx  = _data[8];
	    
	    surface_set_shader(_outSurf, sh_pb_fx_shine);
	        shader_set_dim("dimension", _surf);
	        
	        shader_set_i("useMask",     is_surface(_mask));
	        shader_set_surface("mask",  _mask);
	        
            shader_set_f("progress",    _progr);
            shader_set_i("side",        _inver);
            shader_set_i("invAxis",     _invx);
            shader_set_f("shines",      _shine);
            shader_set_i("shineAmount", array_length(_shine));
            shader_set_f("shinesWidth", array_sum(_shine));
            shader_set_c("shineColor",  _color);
            shader_set_f("slope",       _slope);
            shader_set_i("straight",    _slope == 0);
            shader_set_f("intensity",   _ints);

	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    return _outSurf; 
	}
}