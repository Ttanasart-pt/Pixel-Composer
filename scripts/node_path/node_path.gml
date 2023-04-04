function Node_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Sample position from path.")
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 1] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Progress mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Entire line", "Segment"])
		.rejectArray();
	
	inputs[| 3] = nodeValue("Round anchor", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.rejectArray();
	
	input_display_list = [
		["Path",	false], 0, 2, 1, 3, 
		["Anchors",	false], 
	];
	
	input_fix_len = ds_list_size(inputs);
	input_display_list_len = array_length(input_display_list);
	
	function createAnchor(_x, _y, _dxx = 0, _dxy = 0, _dyx = 0, _dyy = 0) {
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Anchor",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ _x, _y, _dxx, _dxy, _dyx, _dyy ])
			.setDisplay(VALUE_DISPLAY.vector);
		array_push(input_display_list, index);
		
		return inputs[| index];
	}
	
	outputs[| 0] = nodeValue("Position out", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	outputs[| 1] = nodeValue("Path data", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
		
	outputs[| 2] = nodeValue("Anchors", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	tool_pathDrawer = new NodeTool( "Draw path", THEME.path_tools_draw )	
		.addSetting("Smoothness", VALUE_TYPE.float,   function(val) { tool_pathDrawer.attribute.thres = val; }, "thres", 4)
		.addSetting("Replace",    VALUE_TYPE.boolean, function() { tool_pathDrawer.attribute.create = !tool_pathDrawer.attribute.create; }, "create", true);
	
	tools = [
		new NodeTool( "Transform", THEME.path_tools_transform ),
		new NodeTool( "Anchor add / remove (+ Shift)", THEME.path_tools_add ),
		new NodeTool( "Edit Control point", THEME.path_tools_anchor ),
		tool_pathDrawer,
		new NodeTool( "Rectangle path", THEME.path_tools_rectangle ),
		new NodeTool( "Circle path", THEME.path_tools_circle ),
	];
	
	anchors		= [];
	lengths		= [];
	lengthAccs	= [];
	boundary    = [];
	lengthTotal	= 0;
	
	drag_point    = -1;
	drag_points   = [];
	drag_type     = 0;
	drag_point_mx = 0;
	drag_point_my = 0;
	drag_point_sx = 0;
	drag_point_sy = 0;
	
	transform_type = 0;
	transform_minx = 0;
	transform_miny = 0;
	transform_maxx = 0;
	transform_maxy = 0;
	transform_mx = 0;
	transform_my = 0;
	
	static onValueUpdate = function(index = 0) {
		if(index == 2) {
			var type = inputs[| 2].getValue();	
			if(type == 0)
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
			else if(type == 1)
				inputs[| 0].setDisplay(VALUE_DISPLAY._default);
		}
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var sample = PREF_MAP[? "path_resolution"];
		var loop   = inputs[| 1].getValue();
		var ansize = ds_list_size(inputs) - input_fix_len;
		
		if(transform_type > 0) {
			var dx = _mx - transform_mx;
			var dy = _my - transform_my;
			
			var _transform_minx = transform_minx;
			var _transform_miny = transform_miny;
			var _transform_maxx = transform_maxx;
			var _transform_maxy = transform_maxy;
			
			if(transform_type == 1) {
				transform_minx += dx / _s;
				transform_miny += dy / _s;
			} else if(transform_type == 2) {
				transform_maxx += dx / _s;
				transform_miny += dy / _s;
			} else if(transform_type == 3) {
				transform_minx += dx / _s;
				transform_maxy += dy / _s;
			} else if(transform_type == 4) {
				transform_maxx += dx / _s;
				transform_maxy += dy / _s;
			} else if(transform_type == 5) {
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var p = inputs[| i].getValue();
					
					p[0] += dx / _s;
					p[1] += dy / _s;
					
					inputs[| i].setValue(p);
				}
			}
			
			if(transform_type != 5) {
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var p = inputs[| i].getValue();
					
					p[0] = transform_minx + (p[0] - _transform_minx) / (_transform_maxx - _transform_minx) * (transform_maxx - transform_minx);
					p[1] = transform_miny + (p[1] - _transform_miny) / (_transform_maxy - _transform_miny) * (transform_maxy - transform_miny);
					
					inputs[| i].setValue(p);
				}
			}
			
			transform_mx = _mx;
			transform_my = _my;
				
			if(mouse_release(mb_left)) {
				transform_type = 0;
				UPDATE |= RENDER_TYPE.full;
			}
		} else if(drag_point > -1) {
			var dx = value_snap(drag_point_sx + (_mx - drag_point_mx) / _s, _snx);
			var dy = value_snap(drag_point_sy + (_my - drag_point_my) / _s, _sny);
		
			if(drag_type < 2) {
				var inp = inputs[| input_fix_len + drag_point];
				var anc = inp.getValue();
				if(drag_type == 0) { //drag point
					anc[0] = dx;
					anc[1] = dy;
					if(key_mod_press(CTRL)) {
						anc[0] = round(anc[0]);
						anc[1] = round(anc[1]);
					}
				} else if(drag_type == 1) { //drag control 1
					anc[2] = dx - anc[0];
					anc[3] = dy - anc[1];
					
					if(!key_mod_press(SHIFT)) {
						anc[4] = -anc[2];
						anc[5] = -anc[3];
					}
					
					if(key_mod_press(CTRL)) {
						anc[2] = round(anc[2]);
						anc[3] = round(anc[3]);
						
						if(key_mod_press(SHIFT)) {
							anc[4] = round(anc[4]);
							anc[5] = round(anc[5]);
						}
					}
				} else if(drag_type == -1) { //drag control 2
					anc[4] = dx - anc[0];
					anc[5] = dy - anc[1];
					
					if(!key_mod_press(SHIFT)) {
						anc[2] = -anc[4];
						anc[3] = -anc[5];
					}
					
					if(key_mod_press(CTRL)) {
						anc[2] = round(anc[2]);
						anc[3] = round(anc[3]);
						
						if(!key_mod_press(SHIFT)) {
							anc[4] = round(anc[4]);
							anc[5] = round(anc[5]);
						}
					}
				} 
				
				inp.setValue(anc);
			} else if(drag_type == 2) {
				var ox, oy, nx, ny;
				var pxx = (_mx - _x) / _s;
				var pxy = (_my - _y) / _s;
				
				draw_set_color(COLORS._main_accent);
				for( var i = 0; i < array_length(drag_points); i++ ) {
					var _p  = drag_points[i];
					nx = _x + _p[0] * _s;
					ny = _y + _p[1] * _s;
					
					if(i) 
						draw_line(ox, oy, nx, ny);
					
					ox = nx;
					oy = ny;
				}
				
				if(point_distance(drag_point_mx, drag_point_my, pxx, pxy) > 4 / _s) {
					array_push(drag_points, [ pxx, pxy ]);
					
					drag_point_mx = pxx;
					drag_point_my = pxy;
				}
				
				if(mouse_release(mb_left)) {
					var amo		= array_length(drag_points);
					var _p      = 0;
					var points	= [];
					var thres   = tool_pathDrawer.attribute.thres;
					var replace = tool_pathDrawer.attribute.create;
					var asize   = ds_list_size(inputs) - input_fix_len;
					
					for( var i = 0; i < amo; i++ ) {
						var pT = drag_points[i];
						
						if(i == 0 || i == amo - 1) {
							array_push(points, i);
							continue;
						}
						
						var maxT = 0;
						var pF   = drag_points[_p];
						
						for( var j = _p; j < i; j++ ) {
							var pP = drag_points[j];
							
							maxT = max(maxT, distance_to_line(pP[0], pP[1], pF[0], pF[1], pT[0], pT[1]));
						}
						
						if(maxT >= thres) {
							array_push(points, i);
							_p = i;
						}
					}
					
					var amo = array_length(points);
					if(!replace) amo = min(amo, asize);
					
					var i   = 0;
					var anc = [];
					
					for( i = 0; i < amo; i++ ) {
						var  ind = replace? i : clamp(i / amo * array_length(points), 0, array_length(points) - 1);
						var _ind = points[ind];
						var _p   = drag_points[_ind];
						var dxx  = 0;
						var dxy  = 0;
						var dyx  = 0;
						var dyy  = 0;
						
						if(i > 0 && i < amo - 1) {
							var _p0 = drag_points[points[i - 1]];
							var _p1 = drag_points[points[i + 1]];
							
							var d0  = point_direction(_p0[0], _p0[1], _p[0], _p[1]);
							var d1  = point_direction(_p[0], _p[1], _p1[0], _p1[1]);
							
							var dd  = d0 + angle_difference(d1, d0) / 2;
							var ds0 = point_distance(_p0[0], _p0[1], _p[0], _p[1]);
							var ds1 = point_distance(_p[0], _p[1], _p1[0], _p1[1]);
							
							dxx = lengthdir_x(ds0 / 3, dd + 180);
							dxy = lengthdir_y(ds0 / 3, dd + 180);
							dyx = lengthdir_x(ds1 / 3, dd);
							dyy = lengthdir_y(ds1 / 3, dd);
						}
						
						anc = [_p[0], _p[1], dxx, dxy, dyx, dyy];
						if(input_fix_len + i >= ds_list_size(inputs))
							createAnchor(_p[0], _p[1], dxx, dxy, dyx, dyy);
						else 
							inputs[| input_fix_len + i].setValue(anc);
					}
					
					if(!replace) {
						for(; i < asize; i++ ) {
							inputs[| input_fix_len + i].setValue(anc);
						}
					}
				}
			} else if(drag_type == 3) {
				var minx = min((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var maxx = max((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var miny = min((_my - _y) / _s, (drag_point_my - _y) / _s);
				var maxy = max((_my - _y) / _s, (drag_point_my - _y) / _s);
				
				minx = value_snap(minx, _snx);
				maxx = value_snap(maxx, _snx);
				miny = value_snap(miny, _sny);
				maxy = value_snap(maxy, _sny);
				
				if(key_mod_press(SHIFT)) {
					var n = max(maxx - minx, maxy - miny);
					maxx = minx + n;
					maxy = miny + n;
				}
				
				var a = [];
				for( var i = 0; i < 4; i++ ) 
					a[i] = inputs[| input_fix_len + i].getValue();
				
				a[0][0] = minx;
				a[0][1] = miny;
				
				a[1][0] = maxx;
				a[1][1] = miny;
				
				a[2][0] = maxx;
				a[2][1] = maxy;
				
				a[3][0] = minx;
				a[3][1] = maxy;
				
				for( var i = 0; i < 4; i++ ) 
					inputs[| input_fix_len + i].setValue(a[i]);
			} else if(drag_type == 4) {
				var minx = min((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var maxx = max((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var miny = min((_my - _y) / _s, (drag_point_my - _y) / _s);
				var maxy = max((_my - _y) / _s, (drag_point_my - _y) / _s);
				
				minx = value_snap(minx, _snx);
				maxx = value_snap(maxx, _snx);
				miny = value_snap(miny, _sny);
				maxy = value_snap(maxy, _sny);
				
				if(key_mod_press(SHIFT)) {
					var n = max(maxx - minx, maxy - miny);
					maxx = minx + n;
					maxy = miny + n;
				}
				
				var a = [];
				for( var i = 0; i < 4; i++ ) 
					a[i] = inputs[| input_fix_len + i].getValue();
				
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
					inputs[| input_fix_len + i].setValue(a[i]);
			}
			
			if(mouse_release(mb_left)) {
				drag_point = -1;
				UPDATE |= RENDER_TYPE.full;
			}
		}
		
		var line_hover = -1;
		var points = [];
		var _a0, _a1;
		
		var minx = 99999, miny = 99999;
		var maxx = 0	, maxy = 0;
		
		for(var i = loop? 0 : 1; i < ansize; i++) {
			if(i) {
				_a0 = inputs[| input_fix_len + i - 1].getValue();
				_a1 = inputs[| input_fix_len + i].getValue();
			} else {
				_a0 = inputs[| input_fix_len + ansize - 1].getValue();
				_a1 = inputs[| input_fix_len + 0].getValue();
			}
			
			var _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0, pnt = [];
			for(var j = 0; j < sample; j++) {
				if(array_length(_a0) < 6) continue;
			
				p = eval_bezier(j / (sample - 1), _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
				_nx = _x + p[0] * _s;
				_ny = _y + p[1] * _s;
				
				minx = min(minx, _nx); miny = min(miny, _ny);
				maxx = max(maxx, _nx); maxy = max(maxy, _ny);
				array_push(pnt, [ _nx, _ny ]);
				
				if(j && (key_mod_press(CTRL) || isUsingTool(1)) && distance_to_line(_mx, _my, _ox, _oy, _nx, _ny) < 4)
					line_hover = i;
				
				_ox = _nx;
				_oy = _ny;
			}
			
			array_push(points, pnt);
		}
		
		draw_set_color(isUsingTool(0)? c_white : COLORS._main_accent);
		var ind = 0;
		for(var i = loop? 0 : 1; i < ansize; i++) {
			for(var j = 0; j < sample; j++) {
				_nx = points[ind][j][0];
				_ny = points[ind][j][1];
				
				if(j) draw_line_width(_ox, _oy, _nx, _ny, 1 + 2 * (line_hover == i));
				
				_ox = _nx;
				_oy = _ny;
			}
			
			ind++;
		}
		
		var anchor_hover = -1;
		var hover_type = 0;
		
		if(!isUsingTool(0))
		for(var i = 0; i < ansize; i++) {
			var _a = inputs[| input_fix_len + i].getValue();
			var xx = _x + _a[0] * _s;
			var yy = _y + _a[1] * _s;
			var cont = false;
			var _ax0 = 0, _ay0 = 0;
			var _ax1 = 0, _ay1 = 0;
			
			if(array_length(_a) < 6) continue;
			
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
		
		if(isUsingTool(0)) {
			var hov = 0;
				 if(point_in_circle(_mx, _my, minx, miny, 8)) hov = 1;
			else if(point_in_circle(_mx, _my, maxx, miny, 8)) hov = 2;
			else if(point_in_circle(_mx, _my, minx, maxy, 8)) hov = 3;
			else if(point_in_circle(_mx, _my, maxx, maxy, 8)) hov = 4;
			else if(point_in_rectangle(_mx, _my, minx, miny, maxx, maxy)) hov = 5;
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle_border(minx, miny, maxx, maxy, 1 + (hov == 5));
			
			draw_sprite_ui_uniform(THEME.anchor_selector, hov == 1, minx, miny);
			draw_sprite_ui_uniform(THEME.anchor_selector, hov == 2, maxx, miny);
			draw_sprite_ui_uniform(THEME.anchor_selector, hov == 3, minx, maxy);
			draw_sprite_ui_uniform(THEME.anchor_selector, hov == 4, maxx, maxy);
			
			if(hov && mouse_press(mb_left, active)) {
				transform_type = hov;
				transform_minx = (minx - _x) / _s;
				transform_maxx = (maxx - _x) / _s;
				transform_miny = (miny - _y) / _s;
				transform_maxy = (maxy - _y) / _s;
				transform_mx   = _mx;
				transform_my   = _my;
			}
		} else if(isUsingTool(3)) {
			draw_sprite_ui_uniform(THEME.path_tools_draw, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				var replace = tool_pathDrawer.attribute.create;
				if(replace) {
					while(ds_list_size(inputs) > input_fix_len)
						ds_list_delete(inputs, input_fix_len);
					array_resize(input_display_list, input_display_list_len);
				}
				
				drag_point    = 0;
				drag_type     = 2;
				drag_points   = [ [ (_mx - _x) / _s, (_my - _y) / _s ] ];
				drag_point_mx = (_mx - _x) / _s;
				drag_point_my = (_my - _y) / _s;
			}
		} else if(isUsingTool(4) || isUsingTool(5)) {
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				while(ds_list_size(inputs) > input_fix_len)
					ds_list_delete(inputs, input_fix_len);
				array_resize(input_display_list, input_display_list_len);
				
				drag_point    = 0;
				drag_type     = isUsingTool(4)? 3 : 4;
				drag_point_mx = _mx;
				drag_point_my = _my;
				inputs[| 1].setValue(true);
				
				repeat(4)
					createAnchor(value_snap((_mx - _x) / _s, _snx), value_snap((_my - _y) / _s, _sny));
			}
		} else if(anchor_hover != -1) {
			var _a = inputs[| input_fix_len + anchor_hover].getValue();
			if(isUsingTool(2)) {
				draw_sprite_ui_uniform(THEME.cursor_path_anchor, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					if(_a[2] != 0 || _a[3] != 0 || _a[4] != 0 || _a[5] != 0) {
						_a[2] = 0;
						_a[3] = 0;
						_a[4] = 0;
						_a[5] = 0;
						inputs[| input_fix_len + anchor_hover].setValue(_a);
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
			} else if(hover_type == 0 && key_mod_press(SHIFT)) {
				draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					ds_list_delete(inputs, input_fix_len + anchor_hover);
					array_remove(input_display_list, input_fix_len + anchor_hover);
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
		} else if(key_mod_press(CTRL) || isUsingTool(1)) {
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				var anc = createAnchor(value_snap((_mx - _x) / _s, _snx), value_snap((_my - _y) / _s, _sny));
				
				if(line_hover == -1) {
					drag_point = ds_list_size(inputs) - input_fix_len - 1;
				} else {
					ds_list_remove(inputs, anc);
					ds_list_insert(inputs, input_fix_len + line_hover, anc);
					drag_point = line_hover;	
				}
				
				drag_type     = -1;
				drag_point_mx = _mx;
				drag_point_my = _my;
				drag_point_sx = (_mx - _x) / _s;
				drag_point_sy = (_my - _y) / _s;
				
				UPDATE |= RENDER_TYPE.full;
			}
		}
	}
	
	static updateLength = function() {
		boundary    = new BoundingBox();
		lengthTotal = 0;
		var loop    = inputs[| 1].getValue();
		var rond    = inputs[| 3].getValue();
		var ansize  = ds_list_size(inputs) - input_fix_len;
		if(ansize < 2) {
			lengths = [];
			anchors = [];
			return;
		}
		var sample = PREF_MAP[? "path_resolution"];
		
		var con  = loop? ansize : ansize - 1;
		lengths		= [];
		lengthAccs	= [];
		array_resize(anchors, ansize);
		
		for(var i = 0; i < con; i++) {
			var index_0 = input_fix_len + i;
			var index_1 = input_fix_len + i + 1;
			if(index_1 >= ds_list_size(inputs)) index_1 = input_fix_len;
			
			var _a0 = inputs[| index_0].getValue();
			var _a1 = inputs[| index_1].getValue();
			anchors[i + 0] = _a0;
			anchors[i + 1] = _a1;
			
			if(rond) {
				_a0[0] = round(_a0[0]);	_a0[1] = round(_a0[1]);
				_a1[0] = round(_a1[0]);	_a1[1] = round(_a1[1]);
			}
			
			var l = 0, _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
			for(var j = 0; j < sample; j++) {
				p = eval_bezier(j / sample, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
				_nx = p[0];
				_ny = p[1];
				
				boundary.addPoint(_nx, _ny);
				if(j) l += point_distance(_nx, _ny, _ox, _oy);	
				
				_ox = _nx;
				_oy = _ny;
			}
			
			lengths[i]    = l;
			lengthTotal  += l;
			lengthAccs[i] = lengthTotal;
		}
	}
	
	static getLineCount		= function() { return 1; }
	static getSegmentCount	= function() { return array_length(lengths); }
	static getBoundary		= function() { return boundary; }
	
	static getLength		= function() { return lengthTotal; }
	static getSegmentLength	= function() { return lengths; }
	static getAccuLength	= function() { return lengthAccs; }
	
	static getPointDistance = function(_dist) {
		var loop   = inputs[| 1].getValue();
		var rond   = inputs[| 3].getValue();
		var ansize = array_length(lengths);
		var amo    = ds_list_size(inputs) - input_fix_len;
		
		if(ansize == 0) return new Point();
		
		var _a0, _a1;
		
		for(var i = 0; i < ansize; i++) {
			_a0 = anchors[safe_mod(i + 0, amo)];
			_a1 = anchors[safe_mod(i + 1, amo)];
			
			if(rond) {
				_a0[0] = round(_a0[0]);	_a0[1] = round(_a0[1]);
				_a1[0] = round(_a1[0]);	_a1[1] = round(_a1[1]);
			}
			
			if(_dist > lengths[i]) {
				_dist -= lengths[i];
				continue;
			}
			
			var _t = _dist / lengths[i];
			
			if(!is_array(_a0) || !is_array(_a1))
				return new Point();
			
			var _p = eval_bezier(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
			return new Point(_p);
		}
		
		return new Point();
	}
	
	static getPointRatio = function(_rat) {
		var pix = frac(_rat) * lengthTotal;
		return getPointDistance(pix);
	}
	
	static getPointSegment = function(_rat) {
		var loop   = inputs[| 1].getValue();
		var rond   = inputs[| 3].getValue();
		var ansize = array_length(lengths);
		var amo    = ds_list_size(inputs) - input_fix_len;
		
		if(amo < 1) return new Point(0, 0);
		if(_rat < 0) {
			var _p0 = inputs[| input_fix_len].getValue();
			if(rond)
				return new Point(round(_p0[0]), round(_p0[1]));
			return new Point(_p0[0], _p0[1]);
		}
		
		_rat = safe_mod(_rat, ansize);
		var _i0 = clamp(floor(_rat), 0, amo - 1);
		var _t  = frac(_rat);
		var _i1 = _i0 + 1;
		
		if(_i1 >= amo) {
			if(!loop) {
				var _p1 = inputs[| ds_list_size(inputs) - 1].getValue()
				if(rond)
					return new Point(round(_p1[0]), round(_p1[1]));
				return new Point(_p1[0], _p1[1]);
			}
			
			_i1 = 0; 
		}
		
		var _a0 = inputs[| input_fix_len + _i0].getValue();
		var _a1 = inputs[| input_fix_len + _i1].getValue();
		
		if(rond) {
			_a0[0] = round(_a0[0]);	_a0[1] = round(_a0[1]);
			_a1[0] = round(_a1[0]);	_a1[1] = round(_a1[1]);
		}
		
		var p = eval_bezier(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
		return new Point(p[0], p[1]);
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		updateLength();
		
		var _rat = inputs[| 0].getValue();
		var _typ = inputs[| 2].getValue();
		
		var anchors = [];
		for(var i = input_fix_len; i < ds_list_size(inputs); i++)
			array_push(anchors, inputs[| i].getValue());
		outputs[| 2].setValue(anchors);
		
		if(is_array(_rat)) {
			var _out = array_create(array_length(_rat));
			
			for( var i = 0; i < array_length(_rat); i++ ) {
				if(_typ == 0)		_out[i] = getPointRatio(_rat[i]);
				else if(_typ == 1)	_out[i] = getPointSegment(_rat[i]);
			}
			
			outputs[| 0].setValue(_out);
		} else {
			var _out = [0, 0];
			
			if(_typ == 0)		_out = getPointRatio(_rat);
			else if(_typ == 1)	_out = getPointSegment(_rat);
			
			outputs[| 0].setValue(_out.toArray());
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		if(LOADING_VERSION < 1380 && !CLONING)
			ds_list_insert(_inputs, 3, noone);
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i++)
			createAnchor(0, 0);
	}
}