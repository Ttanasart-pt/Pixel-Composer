#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Directional", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Directional(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Directional Blur";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In"));
	newInput(3, nodeValue_Surface( "Mask"));
	newInput(4, nodeValue_Slider(  "Mix", 1));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- Blur
	
	newInput( 1, nodeValue_Float(    "Strength", 4)).setMappable(9);
	newInput( 9, nodeValueMap(       "Strength map",     self));
	newInput( 2, nodeValue_Rotation( "Direction", 0)).setMappable(10);
	newInput(10, nodeValueMap(       "Direction map",    self));
	newInput(11, nodeValue_Bool(     "Single Direction", false));
	newInput(13, nodeValue_Bool(     "Fade Distance", false));
	newInput(12, nodeValue_Bool(     "Gamma Correction", false));
	
	// inputs 14
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Blur",	false], 1, 9, 2, 10, 11, 13, 12, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return w_hovering;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x + ww / 2 * _s, _y + hh / 2 * _s, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
		var _surf = _data[ 0];
		var _strn = _data[ 1];
		var _dirc = _data[ 2];
		var _sing = _data[11];
		var _gamm = _data[12];
		var _fade = _data[13];
		
		var _args = new blur_directional_args(_surf, [_strn, _data[9], inputs[1]], [_dirc, _data[10], inputs[2]])
						.setSingleDirect(_sing)
						.setGamma(_gamm)
						.setFadeDistance(_fade)
						.setSampleMode(getAttribute("oversample"))
		
		_outSurf  = surface_apply_blur_directional(_outSurf, _args);
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}