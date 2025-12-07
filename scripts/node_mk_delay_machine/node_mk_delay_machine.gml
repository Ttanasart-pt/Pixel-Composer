function Node_MK_Delay_Machine(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Delay Machine";
	setCacheManual();
	
	is_simulation = true;
	
	newInput(0, nodeValue_Surface("Surface"));
	
	newInput(1, nodeValue_Int("Delay Amounts", 4));
	
	newInput(2, nodeValue_Int("Delay Frames", 1));
	
	newInput(3, nodeValue_Palette("Blend over Delay", [ c_white ]));
	
	newInput(4, nodeValue_Curve("Alpha over Delay", CURVE_DEF_11));
	
	newInput(5, nodeValue_Enum_Scroll("Palette Select", 0, [ "Loop", "Pingpong", "Random" ]));
	
	newInput(6, nodeValueSeed());
	
	newInput(7, nodeValue_Enum_Scroll("Overflow", 0, [ "Empty", "Loop", "Hold" ]));
	
	newInput(8, nodeValue_Enum_Scroll("Blend Mode", 0, [ "Normal", "Alpha", "Additive", "Maximum" ]));
	
	newInput(9, nodeValue_Bool("Invert", false));
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		["Delay",	false], 1, 2, 7, 
		["Render",	false], 3, 5, 6, 4, 8, 9, 
	];
	
	surf_indexes = [];
	
	static update = function() {  
		var _surf = getInputData(0);
		var _amo  = getInputData(1);
		var _frm  = getInputData(2);
		var _pal  = getInputData(3);
		var _alpC = getInputData(4);
		var _psel = getInputData(5);
		var _seed = getInputData(6);
		var _over = getInputData(7);
		var _blnd = getInputData(8);
		var _invt = getInputData(9);
		
		inputs[6].setVisible(_psel == 2);
		
		surf_indexes = array_verify(surf_indexes, TOTAL_FRAMES);
		surface_free_safe(array_safe_get_fast(surf_indexes, CURRENT_FRAME));
		surf_indexes[CURRENT_FRAME] = surface_clone(_surf);
		
		random_set_seed(_seed);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _outSurf = outputs[0].getValue();
			_outSurf = surface_verify(_outSurf, _sw, _sh);
		
		var cc, aa;
		var _psiz = array_length(_pal) - 1;
		
		surface_set_shader(_outSurf, sh_sample);
			switch(_blnd) {
				case 0 : BLEND_NORMAL break;
				case 1 : BLEND_ALPHA  break;
				case 2 : BLEND_ADD    break;
				case 3 : BLEND_MAX    break;
			}
			
			for( var i = _amo - 1; i >= 0; i-- ) {
				var _i  = _invt? _amo - 1 - i : i;
				var _ff = CURRENT_FRAME - _i * _frm;
				
				switch(_over) {
					case 1 : _ff = (_ff + TOTAL_FRAMES) % TOTAL_FRAMES; break;
					case 2 : _ff = clamp(_ff, 0, TOTAL_FRAMES); break;
				}
				
				var _s  = array_safe_get_fast(surf_indexes, _ff);
				if(!is_surface(_s)) continue;
				
				switch(_psel) {
					case 0 : cc = array_safe_get(_pal, _i, c_white, ARRAY_OVERFLOW.loop);          break;
					case 1 : cc = array_safe_get(_pal, _i, c_white, ARRAY_OVERFLOW.pingpong);      break;
					case 2 : cc = array_safe_get_fast(_pal, irandom(_psiz), c_white);              break;
				}
				
				aa = eval_curve_x(_alpC, 1 - _i / _amo);
				draw_surface_ext(_s, 0, 0, 1, 1, 0, cc, aa);
			}
			
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
}