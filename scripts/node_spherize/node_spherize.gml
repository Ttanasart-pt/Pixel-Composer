#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Spherize", "Oversample Mode > Toggle", "O", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 3); });
	});
#endregion

function Node_Spherize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Spherize";
	
	newActiveInput(7);
	newInput(8, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	/* UNUSED */ newInput( 4, nodeValue_Enum_Scroll("Oversample Mode",  0, [ "Empty", "Clamp", "Repeat" ]));
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 5, nodeValue_Surface( "Mask"       ));
	newInput( 6, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- =Spherize
	newInput( 1, nodeValue_Vec2(     "Center",    [.5,.5] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, UNIT_REF);
	newInput(15, nodeValue_Vec2(     "Position",  [0,0]  )).setHotkey("P").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, UNIT_REF);
	newInput(14, nodeValue_Rotation( "Rotation",   0     )).setHotkey("R");
	newInput( 2, nodeValue_Slider(   "Strength",   1     )).setHotkey("S").setMappable(11);
	newInput( 3, nodeValue_Slider(   "Radius",    .2     )).setMappable(12);
	newInput(13, nodeValue_Slider(   "Trim Edge",  0     ));
	
	////- =Rendering
	newInput(16, nodeValue_Vec2( "Texture Offset", [0,0]  ));
	newInput(17, nodeValue_Vec2( "Texture Scale",  [1,1]  ));
	// input 17
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 8, 
		[ "Surfaces",   true ], 0, 5, 6, 9, 10, 
		[ "Spherize",  false ], 1, 15, 14, 2, 11, 3, 12, 13, 
		[ "Rendering", false ], 16, 17, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	attributes.oversample  = 3;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[ 1];
		var rot  = current_data[14];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[15].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, rot, _dim[0]/2, 2));
		InputDrawOverlay(inputs[14].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	
	static processData = function(_outSurf, _data, _array_index) {
		var _samp = getAttribute("oversample");
		
		var _surf = _data[0];
		
		var _cent = _data[ 1];
		var _posi = _data[15];
		var _trim = _data[13];
		var _rota = _data[14];
		
		var _uoff = _data[16];
		var _usca = _data[17];
		
		surface_set_shader(_outSurf, sh_spherize);
		shader_set_interpolation(_surf);
			shader_set_dim("dimension",  _surf);
			shader_set_i("sampleMode",   _samp);
			shader_set_2("center",       _cent);
			shader_set_2("position",     _posi);
			shader_set_f("rotation",     degtorad(_rota));
			shader_set_f("trim",         _trim);
			
			shader_set_2("uvoffset",     _uoff);
			shader_set_2("uvscale",      _usca);
			
			shader_set_f_map("strength", _data[2], _data[11], inputs[2]);
			shader_set_f_map("radius",   _data[3], _data[12], inputs[3]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_surf, _outSurf, _data[8]);
		
		return _outSurf;
	}
}