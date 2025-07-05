function Node_Active_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Active Canvas";
	
	newInput( 0, nodeValue_Dimension());
	newInput(12, nodeValueSeed());
	
	////- =Brush
	
	newActiveInput(7);
	
	////- =Brush Position
	
	newInput( 2, nodeValue_Vec2(  "Position",        [0,0] ));
	newInput(13, nodeValue_Range( "Position Jitter", [0,0] ));
	newInput( 8, nodeValue_Range( "Distance", [1,1], { linked : true } ));
	
	////- =Brush Rotation
	
	newInput( 3, nodeValue_Rotation( "Base Rotation",       0     ));
	newInput( 9, nodeValue_Bool(     "Rotate by Direction", false ));
	newInput(10, nodeValue_Rotation( "Direction Shift",     0     ));
	newInput(11, nodeValue_Range(    "Rotation Jitter",    [0,0]  ));
	
	////- =Brush Scale
	
	newInput( 4, nodeValue_Vec2(  "Scale",        [1,1] ));
	newInput(14, nodeValue_Range( "Scale Jitter", [0,0] ));
	
	////- =Brush Render
	
	newInput( 1, nodeValue_Surface(    "Texture"));
	newInput( 5, nodeValue_Color(      "Color",        ca_white ));
	/**/ newInput(6, nodeValue_Slider( "Alpha",        1 ))
	newInput(15, nodeValue_Gradient(   "Color Jitter", new gradientObject(c_white) ));
	
	// input 16
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0, 12, 
		[ "Brush",            false ], 7,
		[ "Brush Position",   false ], 2, 13,  8, 
		[ "Brush Rotation",   false ], 3,  9, 10, 11,
		[ "Brush Scale",      false ], 4, 14, 
		[ "Brush Properties", false ], 1,  5, 15, 
	];
	
	////- Nodes
		
	brush_prev = {
		active : false,
		pos    : [0,0],
		rot    : 0,
		sca    : [1,1],
		
		blend  : c_white,
		alpha  : 1,
	};
	brush_next_dist = 0;
	
	temp_surface = [ noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _bpos = getInputData(2);
		var _brot = brush_prev.rot;
		
		var _bx = _x + _bpos[0] * _s;
		var _by = _y + _bpos[1] * _s;
		
		var _rx = lengthdir_x(ui(20), _brot);
		var _ry = lengthdir_y(ui(20), _brot);
		
		draw_set_color(COLORS._main_accent);
		draw_line(_bx - _rx, _by - _ry, _bx + _rx, _by + _ry);
		draw_circle(_bx, _by, ui(4), false);
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
	}
	
	static brush_draw_surface = function(_bg, _surf, _x, _y, _sx, _sy, _rot, _clr, _alp) {
		var _bsw = surface_get_width_safe(_surf);
		var _bsh = surface_get_height_safe(_surf);
		var _p = point_rotate(-_bsw * _sx / 2, -_bsh * _sy / 2, 0, 0, _rot);
		draw_surface_blend_ext(_bg, _surf, _x + _p[0], _y + _p[1], _sx, _sy, _rot, _clr, _alp);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _surf     = outputs[0].getValue();
			
			var _seed     = getInputData(12); random_set_seed(_seed + frame);
			var _dim      = getInputData(0);
			
			var _bact     = getInputData(7);
			
			var _bpos     = getInputData( 2);
			var _bposJit  = getInputData(13);
			var _bdst     = getInputData(8);
			
			var _brot     = getInputData( 3);
			var _brotDir  = getInputData( 9);
			var _bdirShf  = getInputData(10);
			var _brotJit  = getInputData(11);
			
			var _bsca     = getInputData( 4);
			var _bscaJit  = getInputData(14);
			
			var _bsurf    = getInputData(1);
			var _bcol     = getInputData(5);
			var _bcolJit  = getInputData(15);
			
		#endregion
		
		#region surface
			_surf = surface_verify(_surf, _dim[0], _dim[1]);
			for( var i = 0, n = array_length(temp_surface); i < n; i++ )
				temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
			blend_temp_surface = temp_surface[2];
			outputs[0].setValue(_surf);
			
			if(!_bact) { brush_prev.active = false; return; }
		#endregion
		
		#region data prep
			var _bdense = _bdst[0] == _bdst[1] && _bdst[0] == 1;
			_bdst[0] = max(0.01, _bdst[0]);
			_bdst[1] = max(0.01, _bdst[1]);
			var bg = 0;
			
			surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
				if(!IS_FIRST_FRAME) draw_surface_safe(_surf);
			surface_reset_shader();
			bg = !bg;
			
			var _f = IS_FIRST_FRAME || !brush_prev.active;
			
			// position
			var _bposDraw    = [_bpos[0], _bpos[1]];
			var _bposJitDist = random_range(_bposJit[0], _bposJit[1]);
			var _bposJitDirr = random(360);
			
			_bposDraw[0] += lengthdir_x(_bposJitDist, _bposJitDirr);
			_bposDraw[1] += lengthdir_y(_bposJitDist, _bposJitDirr);
			
			// rotation
			var _brotDraw = _brot;
			if(_brotDir && !_f) _brotDraw = point_direction(brush_prev.pos[0], brush_prev.pos[1], _bposDraw[0], _bposDraw[1]) + _bdirShf;
			_brotDraw += random_range(_brotJit[0], _brotJit[1]);
			
			// scale
			var _bscaDraw = [_bsca[0], _bsca[1]];
			var _bscaJitA = random_range(_bscaJit[0], _bscaJit[1]);
			
			_bscaDraw[0] += _bscaJitA;
			_bscaDraw[1] += _bscaJitA;
			
			// color
			var _bcolDraw = _bcol;
			var _boclJitc = _bcolJit.eval(random(1));
			    _bcolDraw = colorMultiply(_bcolDraw, _boclJitc);
			
			var _balp     = _color_get_alpha(_bcolDraw);
		#endregion
		
		if(!is_surface(_bsurf)) {
			surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
			draw_set_alpha(_balp);
				if(_f) draw_point_color(_bposDraw[0] - 1, _bposDraw[1] - 1, _bcolDraw);
				else   draw_line_color(brush_prev.pos[0] - 1, brush_prev.pos[1] - 1, _bposDraw[0] - 1, _bposDraw[1] - 1, brush_prev.blend, _bcolDraw);
			draw_set_alpha(1);
			surface_reset_target();
			bg = !bg;
			
			surface_set_shader(_surf, noone, true, BLEND.over);
				draw_surface_blend(temp_surface[bg], temp_surface[!bg]);
			surface_reset_target();
			
		} else {
			if(_f) {
				surface_set_shader(_surf, noone, true, BLEND.over);
					brush_draw_surface(temp_surface[!bg], _bsurf, _bposDraw[0], _bposDraw[1], _bscaDraw[0], _bscaDraw[1], _brotDraw, _bcolDraw, _balp);
				surface_reset_target();
				bg = !bg;
				
			} else {
				var _x0  = brush_prev.pos[0];
				var _y0  = brush_prev.pos[1];
				var diss = point_distance(_x0, _y0, _bposDraw[0], _bposDraw[1]);
				var dirr = point_direction(_x0, _y0, _bposDraw[0], _bposDraw[1]);
					
				var st_x  = lengthdir_x(1, dirr);
				var st_y  = lengthdir_y(1, dirr);
					
				var _draw = !brush_prev.active;
				var _i    = _draw? 0 : brush_next_dist;
				var _dst  = diss;
				
				if(_i < diss) {
					while(_i < diss) {
						var _px = _x0 + st_x * _i;
						var _py = _y0 + st_y * _i;
							
						surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
							brush_draw_surface(temp_surface[!bg], _bsurf, _px, _py, _bscaDraw[0], _bscaDraw[1], _brotDraw, _bcolDraw, _balp);
						surface_reset_target();
						bg = !bg;
						
						brush_next_dist = random_range(_bdst[0], _bdst[1]);
						_i   += brush_next_dist;
						_dst -= brush_next_dist;
					}
		
					brush_next_dist -= _dst;
				} else 
					brush_next_dist -= diss;
		
				if(_bdense) {
					surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
						brush_draw_surface(temp_surface[!bg], _bsurf, _bposDraw[0], _bposDraw[1], _bscaDraw[0], _bscaDraw[1], _brotDraw, _bcolDraw, _balp);
					surface_reset_target();
					bg = !bg;
				}
				
				surface_set_shader(_surf, noone, true, BLEND.over);
					draw_surface(temp_surface[!bg], 0, 0);
				surface_reset_target();
			}
		}
		
		brush_prev.active = true;
		brush_prev.pos[0] = _bposDraw[0];
		brush_prev.pos[1] = _bposDraw[1];
		brush_prev.rot    = _brotDraw;
		brush_prev.sca[0] = _bscaDraw[0];
		brush_prev.sca[1] = _bscaDraw[1];
		
		brush_prev.blend  = _bcolDraw;
		brush_prev.alpha  = _balp;
	}
}