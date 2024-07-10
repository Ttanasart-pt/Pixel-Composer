function Node_Smear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Smear";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(9);
	
	inputs[| 2] = nodeValue("Direction",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(10);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(3); // inputs 7, 8
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[|  9] = nodeValueMap("Strength map", self);
	
	inputs[| 10] = nodeValueMap("Direction map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "Alpha" ]);
	
	inputs[| 12] = nodeValue("Modulate strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Distance", "Color", "None" ]);
	
	inputs[| 13] = nodeValue("Spread", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range : [ 0, 30, 1 ] });
	
	inputs[| 14] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Smear",	false], 11, 14, 1, 9, 2, 10, 13, 12, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _surf = outputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var ww   = surface_get_width_safe(_surf);
		var hh   = surface_get_height_safe(_surf);
		var _hov = false;
		var  hv  = inputs[| 2].drawOverlay(hover, active, _x + ww / 2 * _s, _y + hh / 2 * _s, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[|  1].mappableStep();
		inputs[|  2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		var _dim = surface_get_dimension(_data[0]);
		
		surface_set_shader(_outSurf, sh_smear);
			shader_set_f("dimension",     _dim);
			shader_set_f("size",          max(_dim[0], _dim[1]));
			
			shader_set_f_map("strength",  _data[ 1], _data[ 9], inputs[|  1]);
			shader_set_f_map("direction", _data[ 2], _data[10], inputs[|  2]);
			shader_set_i("sampleMode",	  struct_try_get(attributes, "oversample"));
			shader_set_i("alpha",	      _data[11]);
			shader_set_i("inv",	    	  _data[14]);
			shader_set_i("modulateStr",   _data[12]);
			shader_set_f("spread",        _data[13]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}