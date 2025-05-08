function Node_Julia_Set(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Julia";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("C", self, [ -1, 0 ]))
	    .setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Vec2("Position", self, [ 0, 0 ]))
	
	newInput(3, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
	
	newInput(4, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(5, nodeValue_Int("Max Iteration", self, 128));
	
	newInput(6, nodeValue_Float("Diverge Threshold", self, 4));
	
	newInput(7, nodeValue_Surface("Mask", self));
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 7, 
	    ["Julia",     false], 1, 5, 6, 
	    ["Transform", false], 2, 3, 4, 
    ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	    var _pos = current_data[2];
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    var _dim = current_data[0];
	    var _px  = _x + _dim[0] / 2 * _s;
	    var _py  = _y + _dim[1] / 2 * _s;
	    InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    return w_hovering;
	}
	
	static step = function() {
	    
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { 
	    var _dim = _data[0];
	    var _c   = _data[1];
	    var _pos = _data[2];
	    var _sca = _data[3];
	    var _rot = _data[4];
	    var _itr = _data[5];
	    var _div = _data[6];
	    
	    surface_set_shader(_outSurf, sh_julia_set);
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