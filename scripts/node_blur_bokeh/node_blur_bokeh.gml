#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Bokeh", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Bokeh(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Lens Blur";
	
	newActiveInput(4);
	newInput(5, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(2, nodeValue_Surface( "Mask"       ));
	newInput(3, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(2, 6); // inputs 6, 7
	
	////- =Blur
	newInput(1, nodeValue_Float( "Strength", .2   )).setHotkey("S").setMappable(8);
	newInput(9, nodeValue_Int(   "Iteration", 512 ));
	// input 10
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 5, 
		[ "Surfaces",  true ], 0, 2, 3, 6, 7, 
		[ "Blur",     false ], 1, 8, 9, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _itr  = _data[9];
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _dim  = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_blur_bokeh);
			shader_set_i("sampleMode", getAttribute("oversample"));
			shader_set_f_map( "strength", _data[1], _data[8], inputs[1]);
			shader_set_2( "dimension", _dim );
			shader_set_f( "iteration", _itr );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_surf, _outSurf, _data[5]);
		
		return _outSurf;
	}
}