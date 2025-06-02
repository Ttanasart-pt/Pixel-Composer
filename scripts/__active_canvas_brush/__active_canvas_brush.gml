function activeBrush_DrawState() constructor {
	active = false;
	
	x = 0;
	y = 0;
	
	angle = 0;
	
	sx = 0;
	sy = 0;
	
	blend = c_white;
	alpha = 1;
	
	temp_surface       = [];
	temp_surface_index = 0;
	
	static setSurface   = function(_sArr, _sInd = 0) { temp_surface = _sArr; temp_surface_index = _sInd; return self; }
	static applySurface = function() { draw_surface_blend(temp_surface[temp_surface_index], temp_surface[!temp_surface_index]); return self; }
}

function activeBrush() constructor {
	
	
	static draw = function(_state, _x, _y, _r, _sx, _sy, _clr, _surf) {
		var _alp = _color_get_alpha(_clr);
		var _tmp = _state.temp_surface;
		var _sid = _state.temp_surface_index;
		
		surface_set_shader(temp_surface[_sid], noone, true, BLEND.over);
			draw_set_alpha(_alp);
			if(!_state.active) {
				draw_point_color(_x, _y, _clr);
				
			} else {
				var _pv_x = _state.x;
				var _pv_y = _state.y;
				var _pv_c = _state.blend;
				
				draw_line_color(_pv_x - 1, _pv_y - 1, _x - 1, _y - 1, _pv_c, _clr);
			}
			draw_set_alpha(1);
		surface_reset_target();
		
		_state.active = true;
		_state.x      = _x;
		_state.y      = _y;
		_state.angle  = _r;
		_state.sx     = _sx;
		_state.sy     = _sy;
		
		_state.blend  = _clr;
		_state.alpha  = _alp;
		
		_state.temp_surface_index = !_sid;
		
		return _state;
	}
}