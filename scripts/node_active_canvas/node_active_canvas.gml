function Node_Active_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Active Canvas";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Surface("Texture", self));
	
	newInput(2, nodeValue_Vec2("Position", self, [ 0, 0 ] ));
	
	newInput(3, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(4, nodeValue_Vec2("Scale", self, [ 1, 1 ] ));
	
	newInput(5, nodeValue_Color("Color", self, ca_white ));
	
	newInput(6, nodeValue_Float("Alpha", self, 1 ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Bool("Active", self, true ));
	
	newInput(8, nodeValue_Range("Distance", self, [ 1, 1 ] , { linked : true }));
	
	newOutput(0, nodeValue_Output("Output", self, VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0,
		[ "Brush transform",  false ], 7, 2, 3, 4,
		[ "Brush properties", false ], 1, 5, 8, 
	];
	
	brush_prev = noone;
	brush_next_dist = 0;
	
	temp_surface = [ 0, 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var hv = inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny); OVERLAY_HV
	}
	
	static brush_draw_surface = function(_bg, _surf, _x, _y, _sx, _sy, _rot, _clr, _alp) {
		var _bsw = surface_get_width_safe(_surf);
		var _bsh = surface_get_height_safe(_surf);
		var _p = point_rotate(-_bsw * _sx / 2, -_bsh * _sy / 2, 0, 0, _rot);
		draw_surface_blend_ext(_bg, _surf, _x + _p[0], _y + _p[1], _sx, _sy, _rot, _clr, _alp);
	}
	
	static update = function() {
		var _surf = outputs[0].getValue();
		
		var _dim   = getInputData(0);
		var _bsurf = getInputData(1);
		var _bpos  = getInputData(2);
		var _brot  = getInputData(3);
		var _bsca  = getInputData(4);
		var _bcol  = getInputData(5);
		var _balp  = _color_get_alpha(_bcol);
		var _bact  = getInputData(7);
		var _bdst  = getInputData(8);
		
		_surf           = surface_verify(_surf, _dim[0], _dim[1]);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		blend_temp_surface = temp_surface[2];
		
		var _bdense = _bdst[0] == _bdst[1] && _bdst[0] == 1;
		_bdst[0] = max(0.01, _bdst[0]);
		_bdst[1] = max(0.01, _bdst[1]);
		
		outputs[0].setValue(_surf);
		if(!_bact) return;
		
		var bg = 0;
		
		surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
			if(!IS_FIRST_FRAME) draw_surface_safe(_surf);
		surface_reset_shader();
		bg = !bg;
		
		var _f = IS_FIRST_FRAME || brush_prev == noone;
		
		if(!is_surface(_bsurf)) {
			surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
			draw_set_alpha(_balp);
				if(_f) draw_point_color(_bpos[0] - 1, _bpos[1] - 1, _bcol);
				else   draw_line_color(brush_prev[2][0] - 1, brush_prev[2][1] - 1, _bpos[0] - 1, _bpos[1] - 1, brush_prev[5], _bcol);
			draw_set_alpha(1);
			surface_reset_target();
			bg = !bg;
			
			surface_set_shader(_surf, noone, true, BLEND.over);
				draw_surface_blend(temp_surface[bg], temp_surface[!bg]);
			surface_reset_target();
			
		} else {
			if(_f) {
				surface_set_shader(_surf, noone, true, BLEND.over);
					brush_draw_surface(temp_surface[!bg], _bsurf, _bpos[0], _bpos[1], _bsca[0], _bsca[1], _brot, _bcol, _balp);
				surface_reset_target();
				bg = !bg;
				
			} else {
				var _x0  = brush_prev[2][0];
				var _y0  = brush_prev[2][1];
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
							
						surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
							brush_draw_surface(temp_surface[!bg], _bsurf, _px, _py, _bsca[0], _bsca[1], _brot, _bcol, _balp);
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
						brush_draw_surface(temp_surface[!bg], _bsurf, _bpos[0], _bpos[1], _bsca[0], _bsca[1], _brot, _bcol, _balp);
					surface_reset_target();
					bg = !bg;
				}
				
				surface_set_shader(_surf, noone, true, BLEND.over);
					draw_surface(temp_surface[!bg], 0, 0);
				surface_reset_target();
			}
			
		}
		
		for( var i = 0, n = array_length(inputs_data); i < n; i++ )
			brush_prev[i] = variable_clone(inputs_data[i], 1);
	}
}