#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Zoom", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Zoom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Zoom Blur";
	
	newActiveInput(8);
	newInput(9, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(17, nodeValue_Surface( "UV Map"     ));
	newInput(18, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 6, nodeValue_Surface( "Mask"       ));
	newInput( 7, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(6, 10);
	newInput( 5, nodeValue_Surface("Blur mask"));
	
	////- =Blur
	newInput(15, nodeValue_EButton( "Mode",         0, [ "Blur", "Step" ] ));
	newInput( 4, nodeValue_EScroll( "Zoom origin",  1, [ "Start", "Middle", "End" ] ));
	newInput( 1, nodeValue_Float(   "Strength",     8     )).setHotkey("S").setMappable(12).setCurvable(19);
	newInput( 2, nodeValue_Vec2(    "Center",     [.5,.5] )).setHotkey("G").setUnitSimple();
	
	////- =Colorize
	newInput(20, nodeValue_EScroll(  "Colorize",     0, [ "None", "Spectral", "Gradient" ] ));
	newInput(21, nodeValue_Gradient( "Gradient",     gra_white     ));
	newInput(22, nodeValue_Float(    "Intensity",    1             ));
	newInput(24, nodeValue_Float(    "Scale",        1             ));
	newInput(23, nodeValue_Slider(   "Shift",        0, [-1,1,.01] ));
	
	////- =Render
	newInput( 3, nodeValue_EScroll( "Oversample mode",  0, [ "Empty", "Clamp", "Repeat" ] ));
	newInput(14, nodeValue_Int(     "Samples",          64    ));
	newInput(13, nodeValue_Bool(    "Gamma Correction", false ));
	newInput(16, nodeValue_Bool(    "Fade",             false ));
	// inputs 25
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 9,
		[ "Surfaces",  true ],  0, 17, 18,  6,  7, 10, 11,  5, 
		[ "Blur",     false ], 15,  4,  1, 12, 19, 2, 
		[ "Colorize", false ], 20, 21, 22, 24, 23, 
		[ "Render",   false ], 14, 13, 16, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _dim = getDimension();
		var pos  = getInputData(2);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, 0, .5));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _sam = getAttribute("oversample");
			
			var _surf   = _data[0];
			var _mask   = _data[5];
			
			var _orig   = _data[ 4];
			var _mode   = _data[15];
			var _strn   = _data[ 1];
			var _strmap = _data[12];
			
			var _sCurveUse = inputs[1].attributes.curved;
			var _sCurve    = _data[17];
			
			var _cent   = _data[ 2];
			var _samp   = _data[14];
			var _gamm   = _data[13];
			var _fade   = _data[16];
			
			var _specUse   = _data[20];
			var _specInt   = _data[22];
			var _specShf   = _data[23];
			var _specSca   = _data[24];
			var _specGrd   = _data[21];
			
			inputs[21].setVisible(_specUse == 2);
		#endregion
		
		var _asiz = [_strn, _strmap, inputs[1]];
		var _args = new blur_zoom_args(_surf, _asiz, _cent[0], _cent[1], _orig, _sam, _samp)
							.setMode(_mode)
							.setFadeDistance(_fade)
							.setGamma(_gamm)
							.setMask(_mask)
							.setSpectral(_specUse, _specInt, _specShf, _specSca, _specGrd)
							.setUVMap(_data[17], _data[18]);
			
		if(_sCurveUse) _args.setSizeCurve(_sCurve);
		
		_outSurf = surface_apply_blur_zoom(_outSurf, _args);
			
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_surf, _outSurf, _data[9]);
		
		return _outSurf;
	}
}