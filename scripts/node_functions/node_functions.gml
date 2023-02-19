#macro def_surf_size PREF_MAP[? "default_surface_side"]
#macro def_surf_size2 [PREF_MAP[? "default_surface_side"], PREF_MAP[? "default_surface_side"]]

#region 
	function node_draw_transform_init() {
		drag_type   = -1;
		dragging_sx = 0;
		dragging_sy = 0;
		dragging_mx = 0;
		dragging_my = 0;
		rot_anc_x = 0;
		rot_anc_y = 0;	
	}
	
	function node_draw_transform_box(active, _x, _y, _s, _mx, _my, _snx, _sny, _posInd, _rotInd, _scaInd) {
		var _pos = inputs[| _posInd].getValue();
		var _rot = inputs[| _rotInd].getValue();
		var _sca = inputs[| _scaInd].getValue();
		
		if(drag_type > -1) {
			if(drag_type == 0) {
				var _dx = (_mx - dragging_mx) / _s;
				var _dy = (_my - dragging_my) / _s;
				
				if(key_mod_press(SHIFT)) {
					if(abs(_dx) > abs(_dy) + ui(16))
						_dy = 0;
					else if(abs(_dy) > abs(_dx) + ui(16))
						_dx = 0;
					else {
						_dx = max(_dx, _dy);
						_dy = _dx;
					}
				}
				
				_pos[0] = value_snap(dragging_sx + _dx, _snx);
				_pos[1] = value_snap(dragging_sy + _dy, _sny);
				
				if(inputs[| _posInd].setValue(_pos))
					UNDO_HOLDING = true;
				
				if(inputs[| _posInd].unit.mode == VALUE_UNIT.reference) {
					var p = [ _pos[0], _pos[1] ];
					_pos = inputs[| _posInd].unit.apply(p);
				}
			} else if(drag_type == 1) {
				var aa = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
				var da = angle_difference(dragging_mx, aa);
				
				if(key_mod_press(CTRL)) 
					_rot = round((dragging_sx - da) / 15) * 15;
				else 
					_rot = dragging_sx - da;
			
				if(inputs[| _rotInd].setValue(_rot))
					UNDO_HOLDING = true;	
			} else if(drag_type == 2) {
				var _p = point_rotate(_mx - dragging_mx, _my - dragging_my, 0, 0, -_rot);
				_sca[0] = _p[0] / _s;
				_sca[1] = _p[1] / _s;
				
				if(key_mod_press(SHIFT)) {
					_sca[0] = min(_sca[0], _sca[1]);
					_sca[1] = min(_sca[0], _sca[1]);
				}
				
				if(inputs[| _scaInd].setValue(_sca))
					UNDO_HOLDING = true;	
			}
			
			if(mouse_release(mb_left)) {
				drag_type = -1;
				UNDO_HOLDING = false;
			}
		}
		
		var p0 = point_rotate(-_sca[0], -_sca[1],     0, 0, _rot);
		var p1 = point_rotate( _sca[0], -_sca[1],     0, 0, _rot);
		var p2 = point_rotate(-_sca[0],  _sca[1],     0, 0, _rot);
		var p3 = point_rotate( _sca[0],  _sca[1],     0, 0, _rot);
		var pr = point_rotate(       0, -_sca[1] - 1, 0, 0, _rot);
		
		var pd0x = _x + (p0[0] + _pos[0]) * _s; var pd0y = _y + (p0[1] + _pos[1]) * _s;
		var pd1x = _x + (p1[0] + _pos[0]) * _s; var pd1y = _y + (p1[1] + _pos[1]) * _s;
		var pd2x = _x + (p2[0] + _pos[0]) * _s; var pd2y = _y + (p2[1] + _pos[1]) * _s;
		var pd3x = _x + (p3[0] + _pos[0]) * _s; var pd3y = _y + (p3[1] + _pos[1]) * _s;
		var prx  = _x + (pr[0] + _pos[0]) * _s; var pry  = _y + (pr[1] + _pos[1]) * _s;
		
		var hovering = -1;
		
		if(drag_type == -1) {
			if(point_in_rectangle_points(_mx, _my, pd0x, pd0y, pd1x, pd1y, pd2x, pd2y, pd3x, pd3y)) 
				hovering = 0;
			if(point_in_circle(_mx, _my, prx, pry, 12)) 
				hovering = 1;
			if(point_in_circle(_mx, _my, pd3x, pd3y, 12)) 
				hovering = 2;
		}
		
		draw_set_color(COLORS._main_accent);
		draw_line_width(pd0x, pd0y, pd1x, pd1y, hovering == 0? 2 : 1);
		draw_line_width(pd0x, pd0y, pd2x, pd2y, hovering == 0? 2 : 1);
		draw_line_width(pd3x, pd3y, pd1x, pd1y, hovering == 0? 2 : 1);
		draw_line_width(pd3x, pd3y, pd2x, pd2y, hovering == 0? 2 : 1);
		
		draw_sprite_ui_uniform(THEME.anchor_rotate, hovering == 1,  prx,  pry,,,, _rot);
		draw_sprite_ui_uniform(THEME.anchor_scale,  hovering == 2, pd3x, pd3y,,,, _rot);
		
		if(hovering == -1) return;
		if(drag_type > -1) return;
		
		if(mouse_press(mb_left, active)) {
			drag_type	= hovering;
			if(hovering == 0) {
				dragging_sx = _pos[0];
				dragging_sy = _pos[1];
				dragging_mx = _mx;
				dragging_my = _my;
			} else if(hovering == 1) { //rot
				dragging_sx = _rot;
				rot_anc_x	= _x + _pos[0] * _s;
				rot_anc_y	= _y + _pos[1] * _s;
				dragging_mx = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
			} else if(hovering == 2) { //sca
				dragging_sx = _sca[0];
				dragging_sy = _sca[1];
				dragging_mx	= _x + _pos[0] * _s;
				dragging_my	= _y + _pos[1] * _s;
			}
		}
	}
#endregion