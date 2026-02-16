#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Directional", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Directional(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Directional Blur";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(14, nodeValue_Surface( "UV Map"     ));
	newInput(15, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- =Blur
	newInput( 1, nodeValue_Float(    "Strength",         8     )).setUnitSimple(false).setHotkey("S").setMappable(9).setCurvable(16);
	newInput( 2, nodeValue_Rotation( "Direction",        0     )).setHotkey("R").setMappable(10);
	newInput(11, nodeValue_Bool(     "Single Direction", false ));
	newInput(13, nodeValue_Bool(     "Fade Distance",    false ));
	
	////- =Colorize
	newInput(18, nodeValue_EScroll(  "Colorize",     0, [ "None", "Spectral", "Gradient" ] ));
	newInput(21, nodeValue_Gradient( "Gradient",     gra_white     ));
	newInput(19, nodeValue_Float(    "Intensity",    1             ));
	newInput(22, nodeValue_Float(    "Scale",        1             ));
	newInput(20, nodeValue_Slider(   "Shift",        0, [-1,1,.01] ));
	
	////- =Processing
	newInput(17, nodeValue_Float(    "Resolution",       1     ));
	newInput(12, nodeValue_Bool(     "Gamma Correction", false ));
	// inputs 23
	
	input_display_list = [ 5, 6, 
		[ "Surfaces",    true ],  0, 14, 15,  3,  4,  7,  8, 
		[ "Blur",       false ],  1,  9, 16,  2, 10, 11, 13, 
		[ "Colorize",   false ], 18, 21, 19, 22, 20, 
		[ "Processing", false ], 17, 12, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return w_hovering;
			_surf = _surf[preview_index];
		}
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			var _strn = _data[ 1];
			var _dirc = _data[ 2];
			
			var _sing = _data[11];
			var _fade = _data[13];
			var _reso = _data[17];
			var _gamm = _data[12];
			
			var _sCurveUse = inputs[1].attributes.curved;
			var _sCurve    = _data[16];
			
			var _specUse   = _data[18];
			var _specGrd   = _data[21];
			var _specInt   = _data[19];
			var _specSca   = _data[22];
			var _specShf   = _data[20];
			
			inputs[21].setVisible(_specUse == 2);
		#endregion
		
		var _asiz = [_strn, _data[ 9], inputs[1]];
		var _adir = [_dirc, _data[10], inputs[2]];
		var _args = new blur_directional_args(_surf, _asiz, _adir)
						.setResolution(_reso)
						.setSingleDirect(_sing)
						.setGamma(_gamm)
						.setFadeDistance(_fade)
						.setSampleMode(getAttribute("oversample"))
						.setUVMap(_data[14], _data[15])
						.setSpectral(_specUse, _specInt, _specShf, _specSca, _specGrd);
		
		if(_sCurveUse) _args.setSizeCurve(_sCurve);
		
		_outSurf  = surface_apply_blur_directional(_outSurf, _args);
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}