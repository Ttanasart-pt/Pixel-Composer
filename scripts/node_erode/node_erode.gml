#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Erode", "Width > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Erode", "Preserve Border > Toggle",  "B", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue(!_n.inputs[2].getValue()); });
		addHotkey("Node_Erode", "Use Alpha > Toggle",        "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue(!_n.inputs[3].getValue()); });
	});
#endregion

function Node_Erode(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Erode";
	
	newActiveInput(6);
	newInput(7, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(4, nodeValue_Surface( "Mask"       ));
	newInput(5, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(4, 8); // inputs 8, 9, 
	
	////- =Erode
	newInput(1, nodeValue_Int(  "Width", 1)).setHotkey("S").setValidator(VV_min(0)).setMappable(10);
	newInput(2, nodeValue_Bool( "Preserve Border", false ));
	newInput(3, nodeValue_Bool( "Use Alpha",        true ));
	
	// input 11
	
	input_display_list = [ 6, 7,
		["Surfaces", true], 0, 4, 5, 8, 9, 
		["Erode",	false], 1, 10, 2, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
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