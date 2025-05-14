#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Bokeh", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key)) / 10); });
	});
#endregion

function Node_Blur_Bokeh(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Lens Blur";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Float("Strength", self, 0.2))
		.setMappable(8);
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Bool("Active", self, true));
		active_index = 4;
	
	newInput(5, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 6, 7
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(8, nodeValueMap("Strength map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 4, 5, 
		["Surfaces", true], 0, 2, 3, 6, 7, 
		["Blur",	false], 1, 8, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_blur_bokeh);
			shader_set_f("dimension", surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f_map("strength", _data[1], _data[8], inputs[1]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[5]);
		
		return _outSurf;
	}
}