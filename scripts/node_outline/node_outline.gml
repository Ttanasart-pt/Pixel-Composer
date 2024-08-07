function Node_Outline(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Outline";
	batch_output = false;
	
	attributes.filter = array_create(9, 1);
	filtering_vl = false;
	
	filter_button = new buttonAnchor(function(ind) {
		if(mouse_press(mb_left))
			filtering_vl = !attributes.filter[ind];
		attributes.filter[ind] = filtering_vl;
		triggerRender();
	});
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue("Width",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY._default, { front_button : filter_button })
		.setValidator(VV_min(0))
		.setMappable(15);
	
	inputs[| 2] = nodeValue("Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 3] = nodeValue("Blend",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0, "Blend outline color with the original color.");
	
	inputs[| 4] = nodeValue("Blend alpha",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(16);
	
	inputs[| 5] = nodeValue_Enum_Button("Position",   self,  1, ["Inside", "Outside"]);
	
	inputs[| 6] = nodeValue("Anti aliasing",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0);
	
	inputs[| 7] = nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ])
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
		
	inputs[| 8] = nodeValue("Start",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Shift outline inside, outside the shape.")
		.setMappable(17);
	
	inputs[| 9] = nodeValue_Surface("Mask", self);
	
	inputs[| 10] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 11] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 11;
	
	inputs[| 12] = nodeValue("Crop border", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	__init_mask_modifier(9); // inputs 13, 14
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 15] = nodeValueMap("Width map", self);
	
	inputs[| 16] = nodeValueMap("Blend alpha map", self);
	
	inputs[| 17] = nodeValueMap("Start map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Outline", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 11, 
		["Surfaces", true], 0, 9, 10, 13, 14, 
		["Outline",	false], 1, 15, 5, 8, 17, 12, 
		["Render",	false], 2, 6,
		["Blend",	 true, 3], 4, 16,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() { #region
		var _wid  = getInputData(1);
		var _side = getInputData(5);
		
		inputs[| 12].setVisible(_side == 0);
		
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
		inputs[| 4].mappableStep();
		inputs[| 8].mappableStep();
		
		filter_button.index = attributes.filter;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var ww = surface_get_width_safe(_data[0]);
		var hh = surface_get_height_safe(_data[0]);
		var cl = _data[2];
		
		var blend = _data[3];
		var side  = _data[5];
		var aa    = _data[6];
		var sam   = struct_try_get(attributes, "oversample");
		var _crop = _data[12];
		
		surface_set_shader(_outSurf, sh_outline);
			shader_set_f("dimension",       ww, hh);
			shader_set_f_map("borderSize",  _data[1], _data[15], inputs[| 1]);
			shader_set_f_map("borderStart", _data[8], _data[17], inputs[| 8]);
			shader_set_color("borderColor", cl);
			
			shader_set_i("side",            side);
			shader_set_i("highRes",         0);
			shader_set_i("is_aa",           aa);
			shader_set_i("outline_only",    _output_index);
			shader_set_i("is_blend",        blend);
			shader_set_f_map("blend_alpha", _data[4], _data[16], inputs[| 4]);
			shader_set_i("sampleMode",      sam);
			shader_set_i("crop_border",     _crop);
			shader_set_i("filter",          attributes.filter);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[9], _data[10]);
		
		return _outSurf;  
	} #endregion
}