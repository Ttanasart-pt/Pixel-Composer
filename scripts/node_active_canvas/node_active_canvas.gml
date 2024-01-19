function Node_Active_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Active Canvas";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 6] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 8] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone );
	
	input_display_list = [ 0,
		[ "Brush transform",  false ], 7, 2, 3, 4,
		[ "Brush properties", false ], 1, 5, 8, 
	];
	
	brush_prev = noone;
	brush_next_dist = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() { #region
		
	} #endregion
	
	static brush_draw_surface = function(_surf, _x, _y, _sx, _sy, _rot, _clr, _alp) { #region
		INLINE
		
		var _bsw = surface_get_width_safe(_surf);
		var _bsh = surface_get_height_safe(_surf);
		var _p = point_rotate(-_bsw * _sx / 2, -_bsh * _sy / 2, 0, 0, _rot);
		draw_surface_ext_safe(_surf, _x + _p[0], _y + _p[1], _sx, _sy, _rot, _clr, _alp);
	} #endregion
	
	static update = function() { #region
		var _surf = outputs[| 0].getValue();
		
		var _dim   = getInputData(0);
		var _bsurf = getInputData(1);
		var _bpos  = getInputData(2);
		var _brot  = getInputData(3);
		var _bsca  = getInputData(4);
		var _bcol  = getInputData(5);
		var _balp  = _color_get_alpha(_bcol);
		var _bact  = getInputData(7);
		var _bdst  = getInputData(8);
		
		_surf = surface_verify(_surf, _dim[0], _dim[1]);
		var _bdense = _bdst[0] == _bdst[1] && _bdst[0] == 1;
		
		outputs[| 0].setValue(_surf);
		
		surface_set_target(_surf);
			if(IS_FIRST_FRAME) DRAW_CLEAR
			
			if(_bact) {
				if(!is_surface(_bsurf)) {
					if(IS_FIRST_FRAME || brush_prev == noone)
						draw_point_color(_bpos[0] - 1, _bpos[1] - 1, _bcol);
					else
						draw_line_color(brush_prev[2][0] - 1, brush_prev[2][1] - 1, _bpos[0] - 1, _bpos[1] - 1, brush_prev[5], _bcol);
				} else {
					BLEND_ALPHA
					
					if(IS_FIRST_FRAME || brush_prev == noone) {
						brush_draw_surface(_bsurf, _bpos[0], _bpos[1], _bsca[0], _bsca[1], _brot, _bcol, _balp);
					} else {
						var _x0 = brush_prev[2][0];
						var _y0 = brush_prev[2][1];
						var diss = point_distance(_x0, _y0, _bpos[0], _bpos[1]);
						var dirr = point_direction(_x0, _y0, _bpos[0], _bpos[1]);
						
						var st_x  = lengthdir_x(1, dirr);
						var st_y  = lengthdir_y(1, dirr);
						
						var _draw = !brush_prev[7];
						var _i    = _draw? 0 : brush_next_dist;
						var _dst  = diss;
						
						if(_i < diss) {
							while(_i < diss) {
								var _px = _x0 + st_x * _i;
								var _py = _y0 + st_y * _i;
								
								brush_draw_surface(_bsurf, _px, _py, _bsca[0], _bsca[1], _brot, _bcol, _balp);
				
								brush_next_dist = random_range(_bdst[0], _bdst[1]);
								_i   += brush_next_dist;
								_dst -= brush_next_dist;
							}
			
							brush_next_dist -= _dst;
						} else 
							brush_next_dist -= diss;
			
						if(_bdense) brush_draw_surface(_bsurf, _bpos[0], _bpos[1], _bsca[0], _bsca[1], _brot, _bcol, _balp);
					}
					BLEND_NORMAL
				}
			}
		surface_reset_target();
		
		for( var i = 0, n = array_length(inputs_data); i < n; i++ )
			brush_prev[i] = variable_clone(inputs_data[i], 1);
	} #endregion
}