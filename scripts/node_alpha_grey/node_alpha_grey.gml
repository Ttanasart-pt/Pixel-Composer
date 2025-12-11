function Node_Alpha_Grey(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Alpha to Grey";
	
	newActiveInput(1);
	
	////- Surfaces
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- Effect
	newInput(2, nodeValue_Curve( "Curve", CURVE_DEF_01 ));
	// 3
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		[ "Surfaces", false ], 0, 
		[ "Effect",   false ], 2, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[0];
			
			var _curv = _data[0];
		#endregion
		
		surface_set_shader(_outSurf, sh_alpha_grey);
			shader_set_curve("modulate", _curv);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}