#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Simple", "Size > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Simple(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Non-Uniform Blur";
	
	newActiveInput(8);
	newInput( 9, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 2, nodeValue_EScroll( "Oversample mode",  0, [ "Empty", "Clamp", "Repeat" ]));
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(17, nodeValue_Surface( "UV Map"     ));
	newInput(18, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 6, nodeValue_Surface( "Mask"       ));
	newInput( 7, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(6, 10); // inputs 10, 11, 
	
	////- =Blur
	newInput( 1, nodeValue_Float(   "Size",   3 )).setHotkey("S").setValidator(VV_min(0)).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput( 3, nodeValue_Surface( "Blur mask" ));
	newInput( 4, nodeValue_Bool(    "Override color",   false, "Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel."));
	newInput( 5, nodeValue_Color(   "Color",            ca_black ));
	newInput(16, nodeValue_Bool(    "Gamma Correction", false    ));
	
	////- =Effect
	newInput(15, nodeValue_Bool(     "Use Gradient", false ));
	newInput(12, nodeValue_Gradient( "Gradient", new gradientObject([ ca_black, ca_white ]) )).setMappable(13);
	// input 17
	
	input_display_list = [ 8, 9, 
		[ "Surfaces", true      ], 0, 17, 18, 6, 7, 10, 11, 
		[ "Blur",     false     ], 1, 3, 4, 5, 16, 
		[ "Effects",  false, 15 ], 12, 13, 14, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {	
		if(!is_surface(_data[0])) return _outSurf;
		var _size	= _data[1];
		var _samp	= getAttribute("oversample");
		var _mask	= _data[3];
		var _isovr  = _data[4];
		var _overc  = _data[5];
		var _msk    = _data[6];
		var _mix    = _data[7];
		var _useGrd = _data[15];
		var _gam    = _data[16];
		
		inputs[5].setVisible(_isovr);
		
		surface_set_shader(_outSurf, sh_blur_simple);
			shader_set_uv(_data[17], _data[18]);
			
			shader_set_i("useGradient", _useGrd);
			shader_set_gradient(_data[12], _data[13], _data[14], inputs[12]);
		
			shader_set_f("dimension",  surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f("size",       _size);
			shader_set_i("sampleMode", _samp);
			shader_set_i("gamma",      _gam);
			
			shader_set_i("overrideColor", _isovr);
			shader_set_color("overColor", _overc);
			
			shader_set_i("useMask",    is_surface(_mask));
			shader_set_surface("mask", _mask);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _msk, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	}
}