function Node_PB_FX_Highlight(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Highlight";
	
	newInput(0, nodeValue_Surface("Surface"));
	
	newInput(1, nodeValue_Int(  "Width", [ 0, 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.padding).setInternalName("Highlight Width");
	newInput(2, nodeValue_Color(  "Color Left", ca_white)).setInternalName("Corner Color");
	newInput(3, nodeValue_Color(  "Color Right", ca_white)).setInternalName("Corner Color");
	newInput(4, nodeValue_Color(  "Color Top", ca_white)).setInternalName("Corner Color");
	newInput(5, nodeValue_Color(  "Color Bottom", ca_white)).setInternalName("Corner Color");
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
	    ["Hightlight", false], 1, 2, 3, 4, 5, 
    ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
	    var _surf = _data[0];
	    var _wd   = _data[1];
	    var _cl   = _data[2];
	    var _cr   = _data[3];
	    var _ct   = _data[4];
	    var _cb   = _data[5];
	    
	    surface_set_shader(_outSurf, sh_pb_fx_hightlight);
	        shader_set_dim("dimension",     _surf);
			shader_set_4("highlight_width", _wd);
			shader_set_c("highlight_l",     _cl);
			shader_set_c("highlight_r",     _cr);
			shader_set_c("highlight_t",     _ct);
			shader_set_c("highlight_b",     _cb);
	        
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    return _outSurf; 
	}
}