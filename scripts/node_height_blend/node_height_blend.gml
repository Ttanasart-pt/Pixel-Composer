function Node_Blend_Height(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Height";
	
	newInput(0, nodeValue_Surface( "Background" ));
	newInput(1, nodeValue_Surface( "Foreground" ));
	
	newInput(4, nodeValue_Enum_Scroll( "Mode",    0, [ "Union", "Intersect" ]  ));
	newInput(3, nodeValue_Enum_Scroll( "Type",    1, [ "Exponent", "Root", "Sigmoid", "Quadratic", "Cubic", "Circular" ]  ));
	newInput(2, nodeValue_Slider(      "Factor", .5  ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		["Surfaces", false], 0, 1,
		["Blend",    false], 4, 3, 2,  
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _bg = _data[0];
		var _fg = _data[1];
		
		var _mode   = _data[4];
		var _type   = _data[3];
		var _factor = _data[2];
		
		surface_set_shader(_outSurf, sh_height_blend);
			shader_set_surface("bg", _bg);
			shader_set_surface("fg", _fg);
			
			shader_set_i("mode",     _mode);
			shader_set_i("type",     _type);
			shader_set_f("factor",   _factor);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}