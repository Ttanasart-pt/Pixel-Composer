function Node_Julia_Set(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Julia";
	
	newInput(0, nodeValue_Dimension());
	
	////- =Surface
	newInput(8, nodeValue_Surface( "UV Map"     ));
	newInput(9, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(7, nodeValue_Surface( "Mask"       ));
	
	////- =Julia
	newInput(1, nodeValue_Vec2(  "C", [ -1, 0 ] )).setUnitSimple();
	newInput(5, nodeValue_Int(   "Max Iteration",     128  ));
	newInput(6, nodeValue_Float( "Diverge Threshold", 4    ));
	
	////- =Transform
	newInput(2, nodeValue_Vec2(     "Position", [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput(4, nodeValue_Rotation( "Rotation",   0     )).setHotkey("R");
	newInput(3, nodeValue_Vec2(     "Scale",     [1,1]  ));
	// input 8
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Surface",    true], 8, 9, 7, 
	    ["Julia",     false], 1, 5, 6, 
	    ["Transform", false], 2, 4, 3, 
    ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
	    var _pos = getInputSingle(2);
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    var _dim = getInputSingle(0);
	    var _px  = _x + _dim[0] / 2 * _s;
	    var _py  = _y + _dim[1] / 2 * _s;
	    InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
	    var _dim = _data[0];
	    var _c   = _data[1];
	    var _pos = _data[2];
	    var _sca = _data[3];
	    var _rot = _data[4];
	    var _itr = _data[5];
	    var _div = _data[6];
	    
	    surface_set_shader(_outSurf, sh_julia_set);
	    	shader_set_uv(_data[8], _data[9]);
	        shader_set_2("dimension", _dim);
	        shader_set_i("iteration", _itr);
	        shader_set_2("juliaC",    _c);
	        shader_set_f("diverge",   _div);
	        
	        shader_set_2("position",  _pos);
	        shader_set_2("scale",     _sca);
	        shader_set_f("rotation",  degtorad(_rot));
	        
	        draw_empty();
	    surface_reset_shader();
	    
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
	    return _outSurf; 
	    
	}
}