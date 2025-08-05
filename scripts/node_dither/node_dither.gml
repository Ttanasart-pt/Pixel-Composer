#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Dither", "Pattern > Toggle", "P", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 4); });
		addHotkey("Node_Dither", "Mode > Toggle",    "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue(!_n.inputs[6].getValue()); });
		addHotkey("Node_Dither", "Contrast > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[4].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Dither(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	static dither2 = [  0,  2,
					    3,  1 ];
	static dither4 = [  0,  8,  2, 10,
					   12,  4, 14,  6,
					    3, 11,  1,  9,
					   15,  7, 13,  5];
	static dither8 = [  0, 32,  8, 40,  2, 34, 10, 42, 
					   48, 16, 56, 24, 50, 18, 58, 26,
					   12, 44,  4, 36, 14, 46,  6, 38, 
					   60, 28, 52, 20, 62, 30, 54, 22,
					    3, 35, 11, 43,  1, 33,  9, 41,
					   51, 19, 59, 27, 49, 17, 57, 25,
					   15, 47,  7, 39, 13, 45,  5, 37,
					   63, 31, 55, 23, 61, 29, 53, 21];
	
	name = "Dither";
	
	newActiveInput(9);
	newInput(10, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	newInput(13, nodeValueSeed());
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(7, nodeValue_Surface( "Mask"       ));
	newInput(8, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(7, 11); // inputs 11, 12, 
	
	////- =Pattern
	newInput(2, nodeValue_Enum_Scroll( "Pattern",  0, [ "2 x 2 Bayer", "4 x 4 Bayer", "8 x 8 Bayer", "White Noise", "Custom" ]));
	newInput(3, nodeValue_Surface(     "Dither map" )).setVisible(false);
	
	////- =Dither
	newInput(6, nodeValue_Enum_Button( "Mode",     0, [ "Color", "Alpha" ] ));
	newInput(4, nodeValue_Slider(      "Contrast", 1, [1, 5, 0.1]          )).setHotkey("C");
	newInput(5, nodeValue_Surface(     "Contrast map" ));
	
	////- =Palette
	newInput( 1, nodeValue_Palette( "Palette",     array_clone(DEF_PALETTE) ));
	newInput(14, nodeValue_Bool(    "Use palette", true ));
	newInput(15, nodeValue_ISlider( "Steps",       4, [2, 16, 0.1] ));
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  9, 10, 13, 
		["Surfaces", true], 0,  7,  8, 11, 12, 
		["Pattern",	false], 2,  3, 
		["Dither",	false], 6,  4,  5, 
		["Palette", false, 14], 1, 15, 
	]
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static step = function() {
		var _type    = getInputData(2);
		var _mode    = getInputData(6);
		var _use_pal = getInputData(14);
		
		inputs[3].setVisible(_type == 4, _type == 4);
		inputs[1].setVisible(_mode == 0 && _use_pal);
		inputs[4].setVisible(_mode == 0);
		inputs[5].setVisible(_mode == 0);
		
		inputs[15].setVisible(!_use_pal);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _pal    = _data[1];
		var _typ    = _data[2];
		var _map    = _data[3];
		var _con    = _data[4];
		var _conMap = _data[5];
		var _mode   = _data[6];
		var _seed   = _data[13];
		var _usepal = _data[14];
		var _step   = _data[15];
		
		surface_set_shader(_outSurf, _mode? sh_alpha_hash : sh_dither);
			shader_set_f("dimension", surface_get_dimension(_data[0]));
			
			switch(_typ) {
				case 0 :
					shader_set_i("useMap",		0);
					shader_set_f("ditherSize",	2);
					shader_set_f("dither",		dither2);
					break;
					
				case 1 :
					shader_set_i("useMap",		0);
					shader_set_f("ditherSize",	4);
					shader_set_f("dither",		dither4);
					break;
					
				case 2 :
					shader_set_i("useMap",		0);
					shader_set_f("ditherSize",	8);
					shader_set_f("dither",		dither8);
					break;
					
				case 3 :
					shader_set_i("useMap",		2);
					shader_set_f("seed",	_seed);
					break;
					
				case 4 :
					if(is_surface(_map)) {
						shader_set_i("useMap",		 1);
						shader_set_f("mapDimension", surface_get_dimension(_map));
						shader_set_surface("map",	 _map);
					}
					break;
			}
			
			if(_mode == 0) {
				shader_set_f("contrast",     _con);
				shader_set_i("useConMap",    is_surface(_conMap));
				shader_set_surface("conMap", _conMap);
				
				shader_set_i("usePalette",	 _usepal);
				shader_set_f("palette",		 paletteToArray(_pal));
				shader_set_f("colors",		 _step);
				shader_set_i("keys",		 array_length(_pal));
			}
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf; 
	}
}