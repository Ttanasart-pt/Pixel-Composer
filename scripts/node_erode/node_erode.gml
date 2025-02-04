#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Erode", "Width > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
		addHotkey("Node_Erode", "Preserve Border > Toggle",  "B", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[2].setValue(!_n.inputs[2].getValue()); });
		addHotkey("Node_Erode", "Use Alpha > Toggle",        "A", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[3].setValue(!_n.inputs[3].getValue()); });
	});
#endregion

function Node_Erode(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Erode";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Int("Width", self, 1))
		.setValidator(VV_min(0))
		.setMappable(10);
	
	newInput(2, nodeValue_Bool("Preserve Border",self, false));
	
	newInput(3, nodeValue_Bool("Use Alpha", self, true));
	
	newInput(4, nodeValue_Surface("Mask", self));
	
	newInput(5, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(6, nodeValue_Bool("Active", self, true));
		active_index = 6;
	
	newInput(7, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(4); // inputs 8, 9, 
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(10, nodeValue_Surface("Width map", self))
		.setVisible(false, false);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 6, 7,
		["Surfaces", true], 0, 4, 5, 8, 9, 
		["Erode",	false], 1, 10, 2, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[1].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_erode);
			shader_set_f("dimension", surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f_map("size" , _data[1], _data[10], inputs[1]);
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