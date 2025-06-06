#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Threshold", "Brightness > Toggle", "B", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue(!_n.inputs[1].getValue()); });
		addHotkey("Node_Threshold", "Alpha > Toggle",      "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[7].setValue(!_n.inputs[7].getValue()); });
	});
#endregion

function Node_Threshold(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Threshold";
	
	newActiveInput(6);
	newInput(10, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 4, nodeValue_Surface( "Mask"       ));
	newInput( 5, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(4, 11); // inputs 11, 12
	
	////- =Brightness
	
	newInput( 1, nodeValue_Bool(        "Brightness",       false ));
	newInput(15, nodeValue_Enum_Scroll( "Algorithm",        0, [ "Simple", "Adaptive mean" ] ));
	newInput( 2, nodeValue_Slider(      "Threshold",       .5     )).setInternalName("Brightness Threshold").setMappable(13);
	newInput( 3, nodeValue_Slider(      "Smoothness",       0     )).setInternalName("Brightness Smoothness");
	newInput(16, nodeValue_Int(         "Adaptive Radius",  4     ));
	newInput(17, nodeValue_Bool(        "Invert",           false )).setInternalName("Brightness Invert");
	newInput(19, nodeValue_Bool(        "Apply to Alpha",   false ));
	
	////- =Alpha
	
	newInput( 7, nodeValue_Bool(   "Alpha",       false ));
	newInput( 8, nodeValue_Slider( "Threshold",  .5     )).setInternalName("Alpha Threshold").setMappable(14);
	newInput( 9, nodeValue_Slider( "Smoothness",  0     )).setInternalName("Alpha Smoothness");
	newInput(18, nodeValue_Bool(   "Invert",      false )).setInternalName("Alpha Invert");
	
	// input 20
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 10, 
		["Surfaces",   true    ], 0, 4, 5, 11, 12, 
		["Brightness", true, 1 ], 15, 2, 13, 3, 16, 17, 19, 
		["Alpha",      true, 7 ], 8, 14, 9, 18, 
	];
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		
		var _surf = _data[0];
		
		var _bright    = _data[1];
		var _brightThr = _data[2];
		var _brightSmt = _data[3];
		
		var _alph    = _data[7];
		var _alphThr = _data[8];
		var _alphSmt = _data[9];
		
		var _algo      = _data[15];
		var _adap_size = _data[16]; _adap_size = min(_adap_size, 32);
		
		var _brightInv = _data[17];
		var _alhpaInv  = _data[18];
		var _brightAlp = _data[19];
		
		inputs[16].setVisible(_algo == 1);
		
		var _shader = sh_threshold;
		if(_algo == 1) _shader = sh_threshold_adaptive;
		
		surface_set_shader(_outSurf, _shader);
			shader_set_dim(, _surf);
			
			shader_set_i("bright",			    _bright);
			shader_set_i("brightInvert",        _brightInv);
			shader_set_f_map("brightThreshold", _brightThr, _data[13], inputs[2]);
			shader_set_f("brightSmooth",	    _brightSmt);
			shader_set_f("adaptiveRadius",	    _adap_size);
			shader_set_f("gaussianCoeff",	    __gaussian_get_kernel(_adap_size));
			shader_set_i("brightAlpha",		    _brightAlp);
			
			shader_set_i("alpha",			    _alph);
			shader_set_i("alphaInvert",			_alhpaInv);
			shader_set_f_map("alphaThreshold",  _alphThr, _data[14], inputs[8]);
			shader_set_f("alphaSmooth",		    _alphSmt);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	}
}
