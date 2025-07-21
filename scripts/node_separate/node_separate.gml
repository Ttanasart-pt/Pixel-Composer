function Node_Separate(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Separate";
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In"    ));
	newInput(1, nodeValue_Surface( "Separate Mask" ));
	
	////- =Separation
	newInput(2, nodeValue_Slider( "Threshold", .5 ));
	
	newOutput(0, nodeValue_Output( "Surface 0", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Surface 1", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 
		[ "Surfaces",   false ], 0, 1, 
		[ "Separation", false ], 2, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		var _surf = _data[0];
		var _mask = _data[1];
		var _thr  = _data[2];
		
		surface_set_target_ext(0, _outData[0]);
		surface_set_target_ext(1, _outData[1]);
			DRAW_CLEAR
			shader_set(sh_separate);
			shader_set_surface("mask", _mask);
			shader_set_f("threshold",  _thr);
			
			draw_surface_safe(_surf);
			shader_reset();
		surface_reset_target();
		
		return _outData; 
	}
}