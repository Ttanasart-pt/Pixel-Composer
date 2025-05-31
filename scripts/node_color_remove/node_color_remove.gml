#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Color_Remove", "Invert > Toggle",  "I", MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue(!_n.inputs[6].getValue()); });
	});
#endregion

function Node_Color_Remove(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Remove Color";
	
	newActiveInput(5);
	newInput(7, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(3, 8); // inputs 8, 9, 
	
	////- =Remove
	
	newInput(1, nodeValue_Palette( "Colors",    array_clone(DEF_PALETTE)));
	newInput(2, nodeValue_Slider(  "Threshold", .1 )).setMappable(10);
	newInput(6, nodeValue_Bool(    "Invert",    false, "Keep the selected colors and remove the rest."));
	
	// input 11
	
	input_display_list = [ 5, 7, 
		["Surfaces", true], 0, 3, 4, 8, 9, 
		["Remove",	false], 1, 2, 10, 6, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var frm = _data[1];
		
		var _colors = [];
		for(var i = 0; i < array_length(frm); i++)
			array_append(_colors, colToVec4(frm[i]));
		
		surface_set_shader(_outSurf, sh_color_remove);
			shader_set_f("colorFrom",     _colors);
			shader_set_i("colorFrom_amo", array_length(frm));
			shader_set_f_map("treshold",  _data[2], _data[10], inputs[2]);
			shader_set_i("invert",        _data[6]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	}
}