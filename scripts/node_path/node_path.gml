function Node_Path(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Path";
	previewable = false;
	
	inputs[| 0] = nodeValue(0, "Path progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 1] = nodeValue(1, "Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	w = 96;
	min_h = 0;
	
	list_start = ds_list_size(inputs);
	
	function createAnchor(_x, _y) {
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue(index, "Anchor",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ _x, _y, 0, 0, 0, 0 ])
			.setDisplay(VALUE_DISPLAY.vector);
			
		return inputs[| index];
	}
	
	outputs[| 0] = nodeValue(0, "Position out", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ]);
	outputs[| 1] = nodeValue(1, "Path data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, self);
	
	tools = [
		[ "Anchor add / remove (ctrl)",  THEME.path_tools_add ],
		[ "Edit Control point (shift)",   THEME.path_tools_anchor ],
		[ "Rectangle path",   THEME.path_tools_rectangle ],
		[ "Circle path",   THEME.path_tools_circle ],
	];
	
	lengths			= [];
	length_total	= 0;
	
	drag_point    = -1;
	drag_type     = 0;
	drag_point_mx = 0;
	drag_point_my = 0;
	drag_point_sx = 0;
	drag_point_sy = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		var sample = PREF_MAP[? "path_resolution"];
		var loop   = inputs[| 1].getValue();
		var ansize = ds_list_size(inputs) - list_start;

		if(drag_point > -1) {
			var dx = drag_point_sx + (_mx - drag_point_mx) / _s;
			var dy = drag_point_sy + (_my - drag_point_my) / _s;
			
			if(drag_type < 2) {
				var inp = inputs[| list_start + drag_point];
				var anc = inp.getValue();
				if(drag_type == 0) {
					anc[0] = dx;
					anc[1] = dy;
					if(keyboard_check(vk_control)) {
						anc[0] = round(anc[0]);
						anc[1] = round(anc[1]);
					}
				} else if(drag_type == 1) {
					anc[2] = dx - anc[0];
					anc[3] = dy - anc[1];
					anc[4] = -anc[2];
					anc[5] = -anc[3];
					if(keyboard_check(vk_control)) {
						anc[2] = round(anc[2]);
						anc[3] = round(anc[3]);
						anc[4] = round(anc[4]);
						anc[5] = round(anc[5]);
					}
				} else if(drag_type == -1) {
					anc[4] = dx - anc[0];
					anc[5] = dy - anc[1];
					anc[2] = -anc[4];
					anc[3] = -anc[5];
					if(keyboard_check(vk_control)) {
						anc[2] = round(anc[2]);
						anc[3] = round(anc[3]);
						anc[4] = round(anc[4]);
						anc[5] = round(anc[5]);
					}
				} 
			
				inp.setValue(anc);
			} else if(drag_type == 2) {
				var minx = min((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var maxx = max((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var miny = min((_my - _y) / _s, (drag_point_my - _y) / _s);
				var maxy = max((_my - _y) / _s, (drag_point_my - _y) / _s);
				
				var a = [];
				for( var i = 0; i < 4; i++ ) 
					a[i] = inputs[| list_start + i].getValue();
				
				a[0][0] = minx;
				a[0][1] = miny;
				
				a[1][0] = maxx;
				a[1][1] = miny;
				
				a[2][0] = maxx;
				a[2][1] = maxy;
				
				a[3][0] = minx;
				a[3][1] = maxy;
				
				for( var i = 0; i < 4; i++ ) 
					inputs[| list_start + i].setValue(a[i]);
			} else if(drag_type == 3) {
				var minx = min((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var maxx = max((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var miny = min((_my - _y) / _s, (drag_point_my - _y) / _s);
				var maxy = max((_my - _y) / _s, (drag_point_my - _y) / _s);
				
				var a = [];
				for( var i = 0; i < 4; i++ ) 
					a[i] = inputs[| list_start + i].getValue();
				
				a[0][0] = (minx + maxx) / 2;
				a[0][1] = miny;
				a[0][2] = -(maxx - minx) * 0.27614;
				a[0][3] = 0;
				a[0][4] = (maxx - minx) * 0.27614;
				a[0][5] = 0;
				
				a[1][0] = maxx;
				a[1][1] = (miny + maxy) / 2;
				a[1][2] = 0;
				a[1][3] = -(maxy - miny) * 0.27614;
				a[1][4] = 0;
				a[1][5] = (maxy - miny) * 0.27614;
				
				a[2][0] = (minx + maxx) / 2;
				a[2][1] = maxy;
				a[2][2] = (maxx - minx) * 0.27614;
				a[2][3] = 0;
				a[2][4] = -(maxx - minx) * 0.27614;
				a[2][5] = 0;
				
				a[3][0] = minx;
				a[3][1] = (miny + maxy) / 2;
				a[3][2] = 0;
				a[3][3] = (maxy - miny) * 0.27614;
				a[3][4] = 0;
				a[3][5] = -(maxy - miny) * 0.27614;
				
				for( var i = 0; i < 4; i++ ) 
					inputs[| list_start + i].setValue(a[i]);
			}
			
			
			if(mouse_release(mb_left))
				drag_point = -1;
		}

		draw_set_color(COLORS._main_accent);
		for(var i = loop? 0 : 1; i < ansize; i++) {
			var _a0 = 0;
			var _a1 = 0;
			
			if(i) {
				_a0 = inputs[| list_start + i - 1].getValue();
				_a1 = inputs[| list_start + i].getValue();
			} else {
				_a0 = inputs[| list_start + ansize - 1].getValue();
				_a1 = inputs[| list_start + 0].getValue();
			}
			
			var _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
			for(var j = 0; j < sample; j++) {
				p = eval_bezier(j / sample, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
				_nx = _x + p[0] * _s;
				_ny = _y + p[1] * _s;
				
				if(j) draw_line(_ox, _oy, _nx, _ny);
				
				_ox = _nx;
				_oy = _ny;
			}
		}
		
		var anchor_hover = -1;
		var hover_type = 0;
		
		for(var i = 0; i < ansize; i++) {
			var _a = inputs[| list_start + i].getValue();
			var xx = _x + _a[0] * _s;
			var yy = _y + _a[1] * _s;
			var cont = false;
			var _ax0 = 0, _ay0 = 0;
			var _ax1 = 0, _ay1 = 0;
			
			if(_a[2] != 0 || _a[3] != 0 || _a[4] != 0 || _a[5] != 0) {
				_ax0 = _x + (_a[0] + _a[2]) * _s;
				_ay0 = _y + (_a[1] + _a[3]) * _s;
				_ax1 = _x + (_a[0] + _a[4]) * _s;
				_ay1 = _y + (_a[1] + _a[5]) * _s;
				cont = true;
			
				draw_set_color(COLORS.node_path_overlay_control_line);
				draw_line(_ax0, _ay0, xx, yy);
				draw_line(_ax1, _ay1, xx, yy);
				
				draw_sprite_ui_uniform(THEME.anchor_selector, 2, _ax0, _ay0);
				draw_sprite_ui_uniform(THEME.anchor_selector, 2, _ax1, _ay1);
			}
			
			draw_sprite_ui_uniform(THEME.anchor_selector, 0, xx, yy);
			
			if(drag_point == i) {
				draw_sprite_ui_uniform(THEME.anchor_selector, 1, xx, yy);
			} else if(point_in_circle(_mx, _my, xx, yy, 8)) {
				draw_sprite_ui_uniform(THEME.anchor_selector, 1, xx, yy);
				anchor_hover = i;
				hover_type   = 0;
			} else if(cont && point_in_circle(_mx, _my, _ax0, _ay0, 8)) {
				draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax0, _ay0);
				anchor_hover = i;
				hover_type   = 1;
			} else if(cont && point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
				draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax1, _ay1);
				anchor_hover =  i;
				hover_type   = -1;
			}
		}
			
		if(anchor_hover != -1) {
			var _a = inputs[| list_start + anchor_hover].getValue();
			if(keyboard_check(vk_shift) || PANEL_PREVIEW.tool_index == 1) {
				draw_sprite_ui_uniform(THEME.cursor_path_anchor, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					if(_a[2] != 0 || _a[3] != 0 || _a[4] != 0 || _a[5] != 0) {
						_a[2] = 0;
						_a[3] = 0;
						_a[4] = 0;
						_a[5] = 0;
						inputs[| list_start + anchor_hover].setValue(_a);
					} else {
						_a[2] = -8;
						_a[3] = 0;
						_a[4] = 8;
						_a[5] = 0;	
						
						drag_point    = anchor_hover;
						drag_type     = 1;
						drag_point_mx = _mx;
						drag_point_my = _my;
						drag_point_sx = _a[0];
						drag_point_sy = _a[1];
					}
				}
			} else if(keyboard_check(vk_control) || PANEL_PREVIEW.tool_index == 0) {
				draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					ds_list_delete(inputs, list_start + anchor_hover);
					doUpdate();
				}
			} else {
				draw_sprite_ui_uniform(THEME.cursor_path_move, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					drag_point    = anchor_hover;
					drag_type     = hover_type;
					drag_point_mx = _mx;
					drag_point_my = _my;
					drag_point_sx = _a[0];
					drag_point_sy = _a[1];
					
					if(hover_type == 1) {
						drag_point_sx = _a[0] + _a[2];
						drag_point_sy = _a[1] + _a[3];	
					} else if(hover_type == -1) {
						drag_point_sx = _a[0] + _a[4];
						drag_point_sy = _a[1] + _a[5];
					} 
				}
			}
		} else if(keyboard_check(vk_control) || PANEL_PREVIEW.tool_index == 0) {
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				drag_point    = ds_list_size(inputs) - list_start;
				createAnchor((_mx - _x) / _s, (_my - _y) / _s);
				
				drag_type     = -1;
				drag_point_mx = _mx;
				drag_point_my = _my;
				drag_point_sx = (_mx - _x) / _s;
				drag_point_sy = (_my - _y) / _s;
			}
		} else if(PANEL_PREVIEW.tool_index >= 2) {
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				while(ds_list_size(inputs) > list_start)
					ds_list_delete(inputs, list_start);
				
				drag_point    = 0;
				drag_type     = PANEL_PREVIEW.tool_index;
				drag_point_mx = _mx;
				drag_point_my = _my;
				inputs[| 1].setValue(true);
				
				repeat(4)
					createAnchor((_mx - _x) / _s, (_my - _y) / _s);
			}
		}
	}
	
	static updateLength = function() {
		length_total = 0;
		var loop   = inputs[| 1].getValue();
		var ansize = ds_list_size(inputs) - list_start;
		if(ansize < 2) {
			lengths = [];
			return;
		}
		var sample = PREF_MAP[? "path_resolution"];
		
		var con  = loop? ansize : ansize - 1;
		if(array_length(lengths) != con)
			array_resize(lengths, con);
		
		for(var i = 0; i < con; i++) {
			var index_0 = list_start + i;
			var index_1 = list_start + i + 1;
			if(index_1 >= ds_list_size(inputs)) index_1 = list_start;
			
			var _a0 = inputs[| index_0].getValue();
			var _a1 = inputs[| index_1].getValue();
			
			var l = 0;
			
			var _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
			for(var j = 0; j < sample; j++) {
				p = eval_bezier(j / sample, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
				_nx = p[0];
				_ny = p[1];
				
				if(j) l += point_distance(_nx, _ny, _ox, _oy);	
				
				_ox = _nx;
				_oy = _ny;
			}
			
			lengths[i] = l;
			length_total += l;
		}
	}
	
	static getPointRatio = function(_rat) {
		var loop   = inputs[| 1].getValue();
		var ansize = ds_list_size(inputs) - list_start;
		
		if(array_length(lengths) < 1) return [0, 0];
		
		var pix = clamp(_rat, 0, 1) * length_total;
		
		for(var i = 0; i < ansize; i++) {
			if(pix <= lengths[i]) {
				var _a0 = inputs[| list_start + i].getValue();
				var _a1 = inputs[| list_start + safe_mod(i + 1, ansize)].getValue();
				var _t  = pix / lengths[i];
				
				if(!is_array(_a0) || !is_array(_a1))
					return [0, 0];
				return eval_bezier(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
			}
			pix -= lengths[i];
		}
		
		return [0, 0];
	}
	
	static update = function() {
		updateLength();
		var _point = inputs[| 0].getValue();
		var _out = getPointRatio(_point);
		outputs[| 0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_sprite_ext(THEME.node_draw_path, 0, xx + w * _s / 2, yy + 10 + (h - 10) * _s / 2, _s, _s, 0, c_white, 1);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = list_start; i < ds_list_size(_inputs); i++) {
			createAnchor(0, 0).deserialize(_inputs[| i]);
		}
	}
}