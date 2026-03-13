function nodeValue_Vec2_Path( _name, _value) { return new __NodeValue_Vec2_Path( _name, self, _value); }

function __NodeValue_Vec2_Path(_name, _node, _value) : __NodeValue_Vec2(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.path_anchor);
	// preview_hotkey_spr = THEME.tools_2d_move;
	def_length   = 6;
	anim_presets = [];
	
	////- GET
	
	static onInitWidget = function() {
		editWidget.animated = true;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _keys = animator.getInterpolateKeys(_time);
		
		var _kfr = _keys[0];
		var _kto = _keys[1];
		var _rat = _keys[2];
		
		var _vfr = _kfr.value;
		if(_kto == undefined) return [ _vfr[0], _vfr[1] ];
		
		var _vto = _kto.value;
		if(_rat == 0) return [ _vfr[0], _vfr[1] ];
		if(_rat == 1) return [ _vto[0], _vto[1] ];
		
		var _val = [0,0];
		_val[0]  = lerp(_vfr[0], _vto[0], _rat);
		_val[1]  = lerp(_vfr[1], _vto[1], _rat);
		
		return _val;
	}

	////- DRAW
	
	path_point_drag = undefined;
	path_point_sx   = 0;
	path_point_sy   = 0;
	path_point_mx   = 0;
	path_point_my   = 0;
	
	static drawPath = function(hover, active, _x, _y, _s, _mx, _my) {
		if(!is_anim || value_from != noone || sep_axis) return false;
		
		var allPos = animator.values;
		var pointHover = undefined;
		var pointPos   = undefined;
		var ox, oy, nx, ny;
		
		draw_set_color(COLORS._main_accent);
		
		for( var i = 0, n = array_length(allPos); i < n; i++ ) {
			var val = allPos[i].value;
			var pos = unit.apply(val);
			
			nx = _x + pos[0] * _s;
			ny = _y + pos[1] * _s;
			
			var hv = hover && point_in_circle(_mx, _my, nx, ny, ui(8));
			draw_anchor(0, nx, ny, ui(8 + hv * 4), 1);
			
			if(hv) {
				pointHover = i;
				pointPos   = pos;
			}
			
			if(i) {
				draw_set_alpha(0.5);
				draw_line_dashed(ox, oy, nx, ny);
			}
		
			ox = nx;
			oy = ny;
		}
		draw_set_alpha(1);
		
		if(pointHover != undefined && mouse_lpress(active)) {
			path_point_drag = pointHover;
			path_point_sx   = pointPos[0];
			path_point_sy   = pointPos[1];
			path_point_mx   = _mx;
			path_point_my   = _my;
			
		}
		
		if(path_point_drag != undefined) {
			var vx = path_point_sx + (_mx - path_point_mx) / _s;
			var vy = path_point_sy + (_my - path_point_my) / _s;
			
			var key = allPos[path_point_drag];
			var pos = unit.invApply([vx,vy]);
			
			key.value    = pos;
			UNDO_HOLDING = true;
			node.triggerRender();
			
			if(mouse_lrelease()) {
				path_point_drag = undefined;
				UNDO_HOLDING    = false;
			}
		}
		
		return pointHover != undefined || path_point_drag != undefined;
	}
	
}
