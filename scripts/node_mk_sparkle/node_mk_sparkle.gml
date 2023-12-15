enum MKSPARK_DRAW {
	dot,
	trail
}

function Node_MK_Sparkle(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Sparkle";
	dimension_index = -1;
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 1] = nodeValue("Sparkle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 
			[ 0,  0, 2, MKSPARK_DRAW.trail, BLEND.add,       0 ], 
			[ 0, -1, 1, MKSPARK_DRAW.trail, BLEND.subtract,  0 ], 
			[ 1,  0, 2, MKSPARK_DRAW.trail, BLEND.add,      -2 ], 
			[ 1, -1, 2, MKSPARK_DRAW.trail, BLEND.subtract, -2 ], 
		])
		.setArrayDepth(2);
	
	inputs[| 2] = nodeValue("Start frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	sparkleEditor = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _sprk = inputs[| 1].getValue();
		var h     = array_length(_sprk) * 32 + 16;
		
		return h;
	}); #endregion
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 2, 
		sparkleEditor
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ noone, noone ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _size = _data[0];
		var _sprk = _data[1];
		var _frme = _data[2];
		
		if(array_empty(_sprk)) return _outSurf;
		
		var _s = _size * 2 + 1;
		
		_outSurf        = surface_verify(_outSurf,        _s, _s);
		temp_surface[0] = surface_verify(temp_surface[0], _s, _s);
		temp_surface[1] = surface_verify(temp_surface[1], _s, _s);
		
		var _s0 = temp_surface[0];
		var _s1 = temp_surface[1];
		var _fr = CURRENT_FRAME - _frme + 1;
		
		surface_set_target(_s0);
			DRAW_CLEAR
			
			draw_set_color(c_white);
			
			for( var i = 0, n = array_length(_sprk); i < n; i++ ) {
				var _sk = _sprk[i];
				var sy  = _size + _sk[0];
				var sx  = _size + _sk[1];
				var sp  = _sk[2];
				var ff  = _fr + _sk[5];
				
				if(ff < 0) continue;
				
				switch(_sk[4]) {
					case BLEND.add      : BLEND_ADD;      break;
					case BLEND.subtract : BLEND_SUBTRACT; break;
				}
				
				switch(_sk[3]) {
					case MKSPARK_DRAW.dot   : draw_point(sx + ff * sp, sy); break;
					case MKSPARK_DRAW.trail : draw_line(sx - 1, sy, sx - 1 + ff * sp, sy); break;
				}
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_s1);
			DRAW_CLEAR
		
			draw_surface_ext(_s0, 0,  0, 1,  1, 0, c_white, 1);
			draw_surface_ext(_s0, 0, _s, 1, -1, 0, c_white, 1);
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_surface_ext(_s1,  0,  0, 1, 1,   0, c_white, 1);
			draw_surface_ext(_s1,  0, _s, 1, 1,  90, c_white, 1);
			draw_surface_ext(_s1, _s, _s, 1, 1, 180, c_white, 1);
			draw_surface_ext(_s1, _s,  0, 1, 1, 270, c_white, 1);
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}