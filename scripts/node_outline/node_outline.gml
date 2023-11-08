function Node_Outline(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Outline";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Width",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	inputs[| 2] = nodeValue("Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 3] = nodeValue("Blend",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0, "Blend outline color with the original color.");
	
	inputs[| 4] = nodeValue("Blend alpha",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Position",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, ["Inside", "Outside"]);
	
	inputs[| 6] = nodeValue("Anti alising",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0);
	
	inputs[| 7] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
		
	inputs[| 8] = nodeValue("Start",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Shift outline inside, outside the shape.");
	
	inputs[| 9] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 10] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 11] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 11;
	
	inputs[| 12] = nodeValue("Crop border", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Outline", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 11, 
		["Surfaces", true], 0, 9, 10, 
		["Outline",	false], 1, 5, 8, 12, 
		["Render",	false], 2, 3, 4, 6,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() { #region
		var blend = getInputData(3);
		var _side = getInputData(5);
		
		inputs[| 4].setVisible(blend);
		inputs[| 12].setVisible(_side == 0);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var ww = surface_get_width_safe(_data[0]);
		var hh = surface_get_height_safe(_data[0]);
		var wd = _data[1];
		var cl = _data[2];
		
		var blend = _data[3];
		var alpha = _data[4];
		var side  = _data[5];
		var aa    = _data[6];
		var sam   = struct_try_get(attributes, "oversample");
		var bst   = _data[8];
		var _crop = _data[12];
		
		surface_set_shader(_outSurf, sh_outline);
			shader_set_f("dimension", ww, hh);
			shader_set_f("borderStart", bst);
			shader_set_f("borderSize", wd);
			shader_set_color("borderColor", cl);
			
			shader_set_i("side", side);
			shader_set_i("is_aa", aa);
			shader_set_i("outline_only", _output_index);
			shader_set_i("is_blend", blend);
			shader_set_f("blend_alpha", alpha);
			shader_set_i("sampleMode", sam);
			shader_set_i("crop_border", _crop);
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[9], _data[10]);
		
		return _outSurf;  
	} #endregion
}