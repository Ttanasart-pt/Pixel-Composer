function Node_Combine_RGB(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RGB Combine";
	dimension_index = -1;
	
	newInput(0, nodeValue_Surface("Red",   self));
	newInput(1, nodeValue_Surface("Green", self));
	newInput(2, nodeValue_Surface("Blue",  self));
	newInput(3, nodeValue_Surface("Alpha", self));
	
	newInput(4, nodeValue_Enum_Scroll("Sampling type", self,  0, ["Channel value", "Greyscale"]));
	
	newInput(5, nodeValue_Float("Base value", self, 0, "Set value to the unconnected color channels."))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(6);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(6, nodeValueMap("Base value", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(7, nodeValue_Bool("Array Input", self, false));
	
	newInput(8, nodeValue_Surface("RGBA Array", self, []))
		.setArrayDepth(1);
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Sampling",	false], 4, 5, 6, 
		["Surfaces",	 true], 7, 0, 1, 2, 3, 8, 
	]
	
	attribute_surface_depth();
	
	static step = function() { #region
		inputs[5].mappableStep();
		
		var _arr = getInputData(7);
		
		inputs[0].setVisible(!_arr, !_arr);
		inputs[1].setVisible(!_arr, !_arr);
		inputs[2].setVisible(!_arr, !_arr);
		inputs[3].setVisible(!_arr, !_arr);
		
		inputs[8].setVisible(_arr, _arr);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _arr  = _data[7];
		
		var _r    = _arr? array_safe_get_fast(_data[8], 0) : _data[0];
		var _g    = _arr? array_safe_get_fast(_data[8], 1) : _data[1];
		var _b    = _arr? array_safe_get_fast(_data[8], 2) : _data[2];
		var _a    = _arr? array_safe_get_fast(_data[8], 3) : _data[3];
		
		var _baseS = is_surface(_r)? _r : (is_surface(_g)? _g : _b);
		if(!is_surface(_baseS)) return _outSurf;
		
		var _ww = surface_get_width_safe(_baseS);
		var _hh = surface_get_height_safe(_baseS);
		
		_outSurf = surface_verify(_outSurf, _ww, _hh);
		
		surface_set_shader(_outSurf, sh_combine_rgb);
			
			shader_set_surface("samplerR", _r);
			shader_set_surface("samplerG", _g);
			shader_set_surface("samplerB", _b);
			shader_set_surface("samplerA", _a);
				
			shader_set_i("useR", is_surface(_r));
			shader_set_i("useG", is_surface(_g));
			shader_set_i("useB", is_surface(_b));
			shader_set_i("useA", is_surface(_a));
			
			shader_set_i("mode",     !_data[4]);
			shader_set_f_map("base", _data[5], _data[6], inputs[5]);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _ww, _hh);
			
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}