function Node_Matrix_Color_Apply(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Color Apply";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Matrix("Matrix", self, new Matrix(3)))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Float("Intensity", self, 1))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8 
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
		
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Effect", 	false], 1, 2, 
	]
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _matx = _data[1];
		var _ints = _data[2];
		
		var _dat  = array_verify(_matx.raw, 9);
		
		surface_set_shader(_outSurf, sh_matrix_color_apply);
		    shader_set_dim("dimension", _surf)
			shader_set_f("matrix",      _dat);
			shader_set_f("intensity",   _ints);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}