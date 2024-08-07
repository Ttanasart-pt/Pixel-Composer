function Node_Erode(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Erode";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Int("Width", self, 1)
		.setValidator(VV_min(0))
		.setMappable(10);
	
	inputs[| 2] = nodeValue_Bool("Preserve border",self, false);
	
	inputs[| 3] = nodeValue_Bool("Use alpha", self, true);
	
	inputs[| 4] = nodeValue_Surface("Mask", self);
	
	inputs[| 5] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue_Bool("Active", self, true);
		active_index = 6;
	
	inputs[| 7] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(4); // inputs 8, 9, 
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 10] = nodeValue_Surface("Width map", self)
		.setVisible(false, false);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 6, 7,
		["Surfaces", true], 0, 4, 5, 8, 9, 
		["Erode",	false], 1, 10, 2, 3, 
	]
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_erode);
			shader_set_f("dimension", surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f_map("size" , _data[1], _data[10], inputs[| 1]);
			shader_set_i("border"   , _data[2]);
			shader_set_i("alpha"    , _data[3]);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	}
}