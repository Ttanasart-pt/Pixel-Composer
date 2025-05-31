function Node_Lovify(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Lovify";
	color = CDEF.red;
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValueSeed());
	
	newInput(2, nodeValue_Slider("Density", 0.5 ));
	
	newInput(3, nodeValue_Slider("Distribution", 0.1 ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces", false], 0, 
		["Love",	 false], 2, 3, 
	];
	
	attribute_surface_depth();
		
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _seed = _data[1];
		var _dens = _data[2];
		var _dist = _data[3];
		var _dim  = surface_get_dimension(_surf);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		random_set_seed(_seed);
		
		var amo  = (_dim[0] * _dim[1]) / 8 * _dens;
		var sprs = [ s_lovify_heart_6 ];
		var sde  = max(_dim[0], _dim[1]);
		var hmax = 12;
		
		if(sde > 16) { sprs[1] = s_lovify_heart_8;  hmax = 16; }
		if(sde > 20) { sprs[2] = s_lovify_heart_10; hmax = 20; }
		if(sde > 24) { sprs[3] = s_lovify_heart_12; hmax = 24; }
		if(sde > 32) { sprs[4] = s_lovify_heart_16; hmax = 32; }
		
		var maxS = min(4, ceil(sde / hmax / 4));
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			shader_set(sh_lovify);
			draw_surface_safe(_surf);
			shader_reset();
			
			repeat(amo) {
				var _r = power(random_seed(1, _seed++), _dist) * 0.75;
				var _a = random_seed(360, _seed++);
				
				var _x = lengthdir_x(_r, _a) + 0.5;
				var _y = lengthdir_y(_r, _a) + 0.5;
				
				_x *= _dim[0];
				_y *= _dim[1];
				
				var ss = irandom_range_seed(1, maxS, _seed++);
				draw_sprite_ext(sprs[irandom(array_length(sprs) - 1)], 0, _x, _y, ss, ss, 0, c_white, 1);
			}
		surface_reset_target();
		
		return _outSurf;
	}
}