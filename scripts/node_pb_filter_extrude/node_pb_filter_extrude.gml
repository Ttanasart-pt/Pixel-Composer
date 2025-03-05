function Node_PB_FX_Extrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Extrude";
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_r(  "Angle",       self, 0));
	newInput(2, nodeValue_i(  "Distance",    self, 1));
	
	newInput(3, nodeValue_c(  "Color",       self, cola(c_white)));
	newInput(4, nodeValue_b(  "Clone Color", self, false));
	
	newInput(5, nodeValue_b(  "Highlight",           self, false));
	newInput(6, nodeValue_c(  "Highlight Color",     self, cola(c_white)));
	newInput(7, nodeValue_r(  "Highlight Direction", self, 0));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
	    ["Extrude",    false], 1, 2, 
	    ["Render",     false], 3, 4, 
	    ["Highlight",  false, 5], 7, 6, 
    ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		// inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { 
	    var _surf = _data[0];
	    var _ang  = _data[1];
	    var _dist = _data[2];
	    
	    var _col  = _data[3];
	    var _ccol = _data[4];
	    
	    var _high = _data[5];
	    var _hgcl = _data[6];
	    var _hdir = _data[7];
	    
	    surface_set_shader(_outSurf, sh_pb_fx_extrude);
	        shader_set_dim("dimension",  _surf);
			shader_set_f("angle",        degtorad(_ang));
			shader_set_f("extDistance",  _dist);
			
			shader_set_c("extColor",     _col);
			shader_set_i("cloneColor",   _ccol);
	        
			shader_set_i("highlight",      _high);
	        shader_set_c("highlightColor", _hgcl);
	        shader_set_f("highlightDir",   degtorad(_hdir));
	        
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    return _outSurf; 
	}
}