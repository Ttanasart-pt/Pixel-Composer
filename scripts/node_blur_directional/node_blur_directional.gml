function Node_Blur_Directional(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Directional Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.1, 0.001] });
	
	inputs[| 2] = nodeValue("Direction",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	input_display_list = [ 5, 
		["Surfaces", true], 0, 3, 4, 
		["Blur",	false], 1, 2,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _surf = outputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		inputs[| 2].drawOverlay(active, _x + ww / 2 * _s, _y + hh / 2 * _s, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _str  = _data[1];
		var _dir  = _data[2];
		var _mask = _data[3];
		var _mix  = _data[4];
		
		surface_set_shader(_outSurf, sh_blur_directional);
			shader_set_f("size", max(surface_get_width_safe(_data[0]), surface_get_height_safe( _data[1])));
			shader_set_f("strength", _str);
			shader_set_f("direction", _dir + 90);
			shader_set_i("sampleMode",	struct_try_get(attributes, "oversample"));
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		
		return _outSurf;
	} #endregion
}