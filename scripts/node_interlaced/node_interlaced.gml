#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Interlaced", "Size > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[8].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Interlaced", "Axis > Toggle",            "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 7].setValue((_n.inputs[ 7].getValue() + 1) % 2); });
		addHotkey("Node_Interlaced", "Invert > Toggle",          "I", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 9].setValue((_n.inputs[ 9].getValue() + 1) % 2); });
		addHotkey("Node_Interlaced", "Loop > Toggle",            "L", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[11].setValue((_n.inputs[11].getValue() + 1) % 2); });
	});
#endregion

function Node_Interlaced(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interlace";
	setCacheManual();
	
	update_on_frame    = true;
	clearCacheOnChange = false;
	
	newActiveInput(1);
	
	////- =Surface
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(2, nodeValue_Surface( "Mask"       ));
	newInput(3, nodeValue_Slider(  "Mix",     1 ));
	newInput(4, nodeValue_Toggle(  "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	__init_mask_modifier(2, 5); // inputs 5, 6
	
	////- =Frame
	newInput(10, nodeValue_Int(  "Delay",  1     ));
	newInput(11, nodeValue_Bool( "Loop",   false ));
	
	////- =Pattern
	newInput(7, nodeValue_Enum_Button( "Axis", 0, [ "X", "Y" ] ));
	newInput(8, nodeValue_Float( "Size",   1     )).setHotkey("S");
	newInput(9, nodeValue_Bool(  "Invert", false ));
	//input 12
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surface",   false], 0, 2, 3, 4, 
		["Frame",     false], 10, 11, 
		["Pattern",   false], 7, 8, 9, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[ 0];
		var _axis = _data[ 7];
		var _size = _data[ 8];
		var _invt = _data[ 9];
		var _back = _data[10];
		var _loop = _data[11];
		
		var _dim  = surface_get_dimension(_surf);
		
		var _fram = CURRENT_FRAME - _back;
		if(_loop) _fram = (_fram + TOTAL_FRAMES) % TOTAL_FRAMES;
		var _prev = getCacheFrameIndex(_array_index, _fram);
			
		surface_set_shader(_outSurf, sh_interlaced);
			shader_set_i("useSurf", is_surface(_prev));
			shader_set_surface("prevFrame", _prev);
			
			shader_set_2("dimension", _dim);
			shader_set_i("axis",      _axis);
			shader_set_i("invert",    _invt);
			shader_set_f("size",      _size);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		cacheCurrentFrameIndex(_array_index, _surf);
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}