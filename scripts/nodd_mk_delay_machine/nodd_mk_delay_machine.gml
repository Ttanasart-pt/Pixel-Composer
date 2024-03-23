function Node_MK_Delay_Machine(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Delay Machine";
	use_cache = CACHE_USE.manual;
	
	is_simulation = true;
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Delay Amounts", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 2] = nodeValue("Delay Frames", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[| 3] = nodeValue("Blend over Delay", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_white ])
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 4] = nodeValue("Alpha over Delay", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0,
		["Delay",	false], 1, 2, 
		["Render",	false], 3, 4, 
	];
	
	static update = function() {  
		var _surf = getInputData(0);
		var _amo  = getInputData(1);
		var _frm  = getInputData(2);
		var _pal  = getInputData(3);
		var _alpC = getInputData(4);
		
		cacheCurrentFrame(_surf);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _outSurf = outputs[| 0].getValue();
			_outSurf = surface_verify(_outSurf, _sw, _sh);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			for( var i = _amo - 1; i >= 0; i-- ) {
				var _ff = CURRENT_FRAME - i * _frm;
				var _s  = array_safe_get(cached_output, _ff);
				if(!is_surface(_s)) continue;
				
				var cc = array_safe_get(_pal, i, c_white, ARRAY_OVERFLOW.loop);
				var aa = eval_curve_x(_alpC, 1 - i / _amo);
				
				draw_surface_ext(_s, 0, 0, 1, 1, 0, cc, aa);
			}
		surface_reset_target();
		
		outputs[| 0].setValue(_outSurf);
	}
}