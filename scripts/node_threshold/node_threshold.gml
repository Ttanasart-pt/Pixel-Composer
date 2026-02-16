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
	newInput( 2, nodeValue_Slider(      "Threshold",       .5     )).setHotkey("B").setInternalName("Brightness Threshold").setMappable(13);
	newInput( 3, nodeValue_Slider(      "Smoothness",       0     )).setInternalName("Brightness Smoothness").setCurvable(21);
	newInput(16, nodeValue_Int(         "Adaptive Radius",  4     ));
	newInput(17, nodeValue_Bool(        "Invert",           false )).setInternalName("Brightness Invert");
	newInput(20, nodeValue_Bool(        "Multiply",         false ));
	newInput(19, nodeValue_Bool(        "Apply to Alpha",   false ));
	
	////- =Alpha
	newInput( 7, nodeValue_Bool(   "Alpha",       false ));
	newInput( 8, nodeValue_Slider( "Threshold",  .5     )).setHotkey("A").setInternalName("Alpha Threshold").setMappable(14);
	newInput( 9, nodeValue_Slider( "Smoothness",  0     )).setInternalName("Alpha Smoothness").setCurvable(22);
	newInput(18, nodeValue_Bool(   "Invert",      false )).setInternalName("Alpha Invert");
	// input 23
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 10, 
		["Surfaces",   true    ],  0,  4,  5, 11, 12, 
		["Brightness", true, 1 ], 15,  2, 13,  3, 21, 16, 17, 20, 19, 
		["Alpha",      true, 7 ],  8, 14,  9, 22, 18, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _b = current_data[1];
		var _a = current_data[7];
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		if(_b) InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _cy - ui(16), _s, _mx, _my, 0, _dim[0]));
		if(_a) InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, _x, _cy + ui(16), _s, _mx, _my, 0, _dim[0]));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf       = _data[0];
			
			var _bright     = _data[ 1];
			var _brightThr  = _data[ 2];
			var _brightSmt  = _data[ 3];
			var _brightCrv  = _data[21];
			
			var _alph       = _data[ 7];
			var _alphThr    = _data[ 8];
			var _alphSmt    = _data[ 9];
			var _alphCrv    = _data[22];
			
			var _algo       = _data[15];
			var _adap_size  = _data[16]; _adap_size = min(_adap_size, 32);
			
			var _brightInv  = _data[17];
			var _alhpaInv   = _data[18];
			var _brightAlp  = _data[19];
			var _brightMulp = _data[20];
			
			inputs[16].setVisible(_algo == 1);
		#endregion
		
		var _shader = sh_threshold;
		if(_algo == 1) _shader = sh_threshold_adaptive;
		
		surface_set_shader(_outSurf, _shader);
			shader_set_dim(, _surf);
			
			shader_set_i("bright",			    _bright);
			shader_set_i("brightInvert",        _brightInv);
			shader_set_f_map("brightThreshold", _brightThr, _data[13], inputs[2]);
			shader_set_f("brightSmooth",	    _brightSmt);
			shader_set_curve("brightSmooth",	_brightCrv, inputs[3]);
			
			shader_set_f("adaptiveRadius",	    _adap_size);
			shader_set_f("gaussianCoeff",	    __gaussian_get_kernel(_adap_size));
			shader_set_i("brightAlpha",		    _brightAlp);
			shader_set_i("brightMulp",		    _brightMulp);
			
			shader_set_i("alpha",			    _alph);
			shader_set_i("alphaInvert",			_alhpaInv);
			shader_set_f_map("alphaThreshold",  _alphThr, _data[14], inputs[8]);
			shader_set_f("alphaSmooth",		    _alphSmt);
			shader_set_curve("alphaSmooth",	    _alphCrv, inputs[9]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	}
}
