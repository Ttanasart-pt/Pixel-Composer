function Node_MK_Delay_Machine(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Delay Machine";
	use_cache = CACHE_USE.manual;
	
	is_simulation = true;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Int("Delay Amounts", self, 4));
	
	newInput(2, nodeValue_Int("Delay Frames", self, 1));
	
	newInput(3, nodeValue_Palette("Blend over Delay", self, [ c_white ]));
	
	newInput(4, nodeValue("Alpha over Delay", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11));
	
	newInput(5, nodeValue_Enum_Scroll("Palette Select", self, 0, [ "Loop", "Pingpong", "Random" ]));
	
	newInput(6, nodeValue_Int("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[6].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	outputs[0] = nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0,
		["Delay",	false], 1, 2, 
		["Render",	false], 3, 5, 6, 4, 
	];
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static step = function() {  
		var _psel = getInputData(5);
		
		inputs[6].setVisible(_psel == 2);
	}
	
	static update = function() {  
		var _surf = getInputData(0);
		var _amo  = getInputData(1);
		var _frm  = getInputData(2);
		var _pal  = getInputData(3);
		var _alpC = getInputData(4);
		var _psel = getInputData(5);
		var _seed = getInputData(6);
		
		cacheCurrentFrame(_surf);
		
		random_set_seed(_seed);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _outSurf = outputs[0].getValue();
			_outSurf = surface_verify(_outSurf, _sw, _sh);
		
		var cc, aa;
		var _psiz = array_length(_pal) - 1;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			for( var i = _amo - 1; i >= 0; i-- ) {
				var _ff = CURRENT_FRAME - i * _frm;
				var _s  = array_safe_get_fast(cached_output, _ff);
				if(!is_surface(_s)) continue;
				
				switch(_psel) {
					case 0 : cc = array_safe_get(_pal, i, c_white, ARRAY_OVERFLOW.loop);          break;
					case 1 : cc = array_safe_get(_pal, i, c_white, ARRAY_OVERFLOW.pingpong);      break;
					case 2 : cc = array_safe_get_fast(_pal, irandom(_psiz), c_white);             break;
				}
				
				aa = eval_curve_x(_alpC, 1 - i / _amo);
				
				draw_surface_ext(_s, 0, 0, 1, 1, 0, cc, aa);
			}
		surface_reset_target();
		
		outputs[0].setValue(_outSurf);
	}
}