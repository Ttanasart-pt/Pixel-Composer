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
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(14, nodeValue_Surface( "UV Map"     ));
	newInput(15, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 2, nodeValue_Surface( "Mask"       ));
	newInput( 3, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(2, 6); // inputs 6, 7
	
	////- =Blur
	newInput( 1, nodeValue_Float( "Strength",     .2   )).setHotkey("S").setMappable(8).setCurvable(21);
	newInput( 9, nodeValue_Int(   "Iteration",     512 ));
	
	////- =Colorize
	newInput(16, nodeValue_EScroll(  "Colorize",     0, [ "None", "Spectral", "Gradient" ] ));
	newInput(17, nodeValue_Gradient( "Gradient",     gra_white     ));
	newInput(18, nodeValue_Float(    "Intensity",    1             ));
	newInput(19, nodeValue_Float(    "Scale",        1             ));
	newInput(20, nodeValue_Slider(   "Shift",        0, [-1,1,.01] ));
	
	////- =Processing
	newInput(10, nodeValue_Float( "Contrast",      150 ));
	newInput(11, nodeValue_Float( "Contrast Factor", 9 ));
	newInput(12, nodeValue_Float( "Smoothness",      2 ));
	newInput(13, nodeValue_Float( "Rotation",        1 ));
	// input 21
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 5, 
		[ "Surfaces",    true ],  0, 14, 15,  2,  3,  6,  7, 
		[ "Blur",       false ],  1,  8, 21,  9, 
		// [ "Colorize",   false ], 16, 17, 18, 19, 20, 
		[ "Processing", false ], 10, 11, 12, 13, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[0];
			var _itr  = _data[9];
			
			var _cont = _data[10];
			var _cfac = _data[11];
			var _smot = _data[12];
			var _rota = _data[13];
			
			var _specUse = _data[16];
			var _specGrd = _data[17];
			var _specInt = _data[18];
			var _specSca = _data[19];
			var _specShf = _data[20];
			
			inputs[17].setVisible(_specUse == 2);
		#endregion
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _dim  = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_blur_bokeh);
			shader_set_uv(_data[14], _data[15]);
			shader_set_2( "dimension", _dim );
		
			shader_set_i( "sampleMode", getAttribute("oversample"));
			shader_set_f_map( "strength", _data[1], _data[8], inputs[1], _data[21]);
			
			shader_set_f( "iteration",      _itr  );
			shader_set_f( "contrast",       _cont );
			shader_set_f( "contrastFactor", max(_cfac, 1) );
			shader_set_f( "smooth",         _smot );
			shader_set_f( "rotation",       _rota );
			
			shader_set_i("spectralUse",        _specUse);
			shader_set_f("spectralIntensity",  _specInt);
			shader_set_f("spectralScale",      _specSca);
			shader_set_f("spectralShift",      _specShf);
			_specGrd.shader_submit();
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_surf, _outSurf, _data[5]);
		
		return _outSurf;
	}
}