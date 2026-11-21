#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Corner", "Radius > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Corner(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Round Corner";
	
	newActiveInput(4);
	newInput( 5, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput( 2, nodeValue_Surface( "Mask"       ));
	newInput( 3, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(2, 6); // inputs 6, 7
	
	////- =Region
	newInput(12, nodeValue_EScroll( "Region Type", 0, [ "BW Island", "Color" ] ));
	newInput(13, nodeValue_Slider(  "Threshold",  .1 ));
	
	////- =Corner
	newInput( 1, nodeValue_ISlider( "Radius",     2, [1, 16, 0.1] )).setMappable(9).setPieMenu();
	newInput( 8, nodeValue_Slider(  "Threshold", .5 )).setHotkey("T").setMappable(10).setPieMenu();
	
	////- =Render
	newInput(11, nodeValue_Bool(  "Transparent", false ));
	// 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  4,  5, 
		[ "Surfaces", true ],  0,  2,  3,  6,  7, 
		[ "Region",	 false ], 12, 13, 
		[ "Corner",	 false ],  1,  9,  8, 10, 
		[ "Render",	 false ], 11, 
	]
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = array_create(2);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, 90, _dim[0] / 16));
		drawOverlayInput(inputs[8].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my,  0, _dim[0] /  2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			
			var _reg  = _data[12];
			var _cthr = _data[13];
			
			var _rad  = _data[ 1];
			var _thr  = _data[ 8];
			
			var _alph = _data[11];
			
			inputs[13].setVisible(_reg == 1);
		#endregion
		
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
		
		shader_set(sh_corner_iterate);
			shader_set_i( "sampleMode", getAttribute("oversample"));
			shader_set_2( "dimension",    _dim  );
		
			shader_set_i( "regionType",   _reg  );
			shader_set_f( "threshold",    _cthr );
			
			shader_set_s( "baseSurface",  _surf );
		shader_reset();		
		
		repeat(_itr) {
			surface_set_shader(temp_surface[_bg], sh_corner_iterate);
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
			_bg = !_bg;
		}
		
		surface_set_shader(_outSurf, sh_corner_apply);
			shader_set_i( "sampleMode", getAttribute("oversample"));
			
			shader_set_2( "dimension",    _dim  );
			shader_set_m( "radius",       _rad, _data[ 9], inputs[1] );
			shader_set_m( "threshold",    _thr, _data[10], inputs[8] );
			shader_set_s( "original",     _surf );
			shader_set_i( "transparent",  _alph );
			
			shader_set_i( "regionType",   _reg  );
			shader_set_f( "cthreshold",   _cthr );
			
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[2], _data[3], inputs[2]);
		_outSurf = channel_apply(_surf, _outSurf, _data[5]);
		
		return _outSurf;
	}
}