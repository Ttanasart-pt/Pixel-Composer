function Node_Onion_Skin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Onion Skin";
	use_cache   = CACHE_USE.manual;
	clearCacheOnChange = false;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Slider_Range("Range", self, [-1, 1], { range: [ -16, 16, 0.1 ] }));
	
	newInput(2, nodeValue_Float("Alpha", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(3, nodeValue_Color("Color pre", self, cola(c_red)))
	
	newInput(4, nodeValue_Color("Color post", self, cola(c_blue)))
	
	newInput(5, nodeValue_Int("Step", self, 1))
	
	newInput(6, nodeValue_Bool("On top", self, true, "Render current frame on top of all frames."))
	
	newOutput(0, nodeValue_Output("Output", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surface", false], 0, 1, 5,  
		["Render",  false], 2, 3, 4, 6, 
	];
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() { clearCache(); }
	
	static update = function() { 
		if(!inputs[0].value_from) return;
		
		var _surf = getInputData(0);
		var _rang = getInputData(1);
		
		var _alph = getInputData(2);
		var _cpre = getInputData(3);
		var _cpos = getInputData(4);
		
		var _step = getInputData(5);
		var _top  = getInputData(6);
		cacheCurrentFrame(_surf);
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
		outputs[0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var fr = CURRENT_FRAME;
			var st = min(_rang[0], _rang[1]);
			var ed = max(_rang[0], _rang[1]);
			
			st = sign(st) * floor(abs(st) / _step) * _step;
			ed = sign(ed) * floor(abs(ed) / _step) * _step;
			
			st += fr;
			ed += fr;
			
			for( var i = st; i <= ed; i += _step ) {
				var surf = getCacheFrame(i);
				if(!is_surface(surf)) continue;
				
				var aa = power(_alph, abs(i - fr));
				var cc = c_white;
				if(i < fr)		cc = _cpre;
				else if(i > fr) cc = _cpos;
				
				draw_surface_ext_safe(surf, 0, 0, 1, 1, 0, cc, aa);
			}
			
			if(_top) draw_surface_safe(_surf);
		surface_reset_target();
	}
}