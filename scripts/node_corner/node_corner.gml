#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Corner", "Radius > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Corner(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Round Corner";
	
	newActiveInput(4);
	newInput(5, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(2, nodeValue_Surface( "Mask"       ));
	newInput(3, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(2, 6); // inputs 6, 7
	
	////- =Corner
	newInput(1, nodeValue_ISlider( "Radius",     2, [1, 16, 0.1] )).setMappable(9);
	newInput(8, nodeValue_Slider(  "Threshold", .5 )).setHotkey("T").setMappable(10);
	// 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 5, 
		[ "Surfaces", true ], 0, 2, 3, 6, 7, 
		[ "Corner",	 false ], 1, 9, 8, 10, 
	]
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = array_create(2);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 90, _dim[0] / 16));
		InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny,  0, _dim[0] /  2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _rad  = _data[1];
		var _thr  = _data[8];
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		var _dim = [ _sw, _sh ];
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh); 
			surface_clear(temp_surface[i]);
		}
		
		surface_set_shader(temp_surface[0], sh_corner_coord);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var _itr = max(_sw, _sh) / 4;
		var _bg  = 1;
		
		repeat(_itr) {
			surface_set_shader(temp_surface[_bg], sh_corner_iterate);
				shader_set_2("dimension", _dim);
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
			_bg = !_bg;
		}
		
		var _sam = getAttribute("oversample");
		
		surface_set_shader(_outSurf, sh_corner_apply);
			shader_set_2(       "dimension",  _dim );
			shader_set_f_map(   "radius",     _rad, _data[ 9], inputs[1] );
			shader_set_f_map(   "threshold",  _thr, _data[10], inputs[8] );
			shader_set_surface( "original",   _surf);
			shader_set_i(       "sampleMode", _sam );
			
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_surf, _outSurf, _data[5]);
		
		return _outSurf;
	}
}