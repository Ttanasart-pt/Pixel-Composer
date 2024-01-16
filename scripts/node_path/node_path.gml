enum _ANCHOR {
	x,
	y,
	c1x,
	c1y,
	c2x,
	c2y,
	
	ind,
}

function Node_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path";
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Sample position from path.")
		.setDisplay(VALUE_DISPLAY.slider);
	
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
	
	setIsDynamicInput(1);
	
	outputs[| 0] = nodeValue("Position out", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	outputs[| 1] = nodeValue("Path data", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
		
	outputs[| 2] = nodeValue("Anchors", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setVisible(false)
		.setArrayDepth(1);
	
	tool_pathDrawer = new NodeTool( "Draw path", THEME.path_tools_draw )	
		.addSetting("Smoothness", VALUE_TYPE.float,   function(val) { tool_pathDrawer.attribute.thres = val; }, "thres", 4)
		.addSetting("Replace",    VALUE_TYPE.boolean, function() { tool_pathDrawer.attribute.create = !tool_pathDrawer.attribute.create; }, "create", true);
	
	tools = [
		new NodeTool( "Transform", THEME.path_tools_transform ),
		new NodeTool( "Anchor add / remove", THEME.path_tools_add ),
		new NodeTool( "Edit Control point", THEME.path_tools_anchor ),
		tool_pathDrawer,
		new NodeTool( "Rectangle path", THEME.path_tools_rectangle ),
		new NodeTool( "Circle path", THEME.path_tools_circle ),
	];
	
	#region ---- path ----
		anchors		= [];
		lengths		= [];
		lengthAccs	= [];
		boundary    = [];
		lengthTotal	= 0;
	
		cached_pos = ds_map_create();
	#endregion
	
	#region ---- editor ----
		drag_point    = -1;
		drag_points   = [];
		drag_type     = 0;
		drag_point_mx = 0;
		drag_point_my = 0;
		drag_point_sx = 0;
		drag_point_sy = 0;
	
		transform_type = 0;
		transform_minx = 0; transform_miny = 0;
		transform_maxx = 0; transform_maxy = 0;
		transform_cx = 0;   transform_cy = 0;
		transform_sx = 0;   transform_sy = 0;
		transform_mx = 0;   transform_my = 0;
	#endregion
	
	static resetDisplayList = function() { #region
		recordAction(ACTION_TYPE.var_modify,  self, [ array_clone(input_display_list), "input_display_list" ]);
		
		input_display_list = [
			["Path",	false], 0, 2, 1, 3, 
			["Anchors",	false], 
		];
		
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i++ ) 
			array_push(input_display_list, i);
	} #endregion
	
	static createNewInput = function(_x = 0, _y = 0, _dxx = 0, _dxy = 0, _dyx = 0, _dyy = 0) { #region
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Anchor",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ _x, _y, _dxx, _dxy, _dyx, _dyy, false ])
			.setDisplay(VALUE_DISPLAY.vector);
		
		recordAction(ACTION_TYPE.list_insert, inputs, [ inputs[| index], index, "add path anchor point" ]);
		resetDisplayList();
		
		return inputs[| index];
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(index == 2) {
			var type = getInputData(2);	
			if(type == 0)
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider);
			else if(type == 1)
				inputs[| 0].setDisplay(VALUE_DISPLAY._default);
		}
	} #endregion
	
	static drawPreview = function(_x, _y, _s) { #region
		
	} #endregion
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var sample = PREFERENCES.path_resolution;
		var loop   = getInputData(1);
		var ansize = ds_list_size(inputs) - input_fix_len;
		var _edited = false;
		
		var pos = outputs[| 0].getValue();
		
		draw_set_color(COLORS._main_accent);
		draw_circle(_x + pos[0] * _s, _y + pos[1] * _s, 4, false);
		
		if(transform_type > 0) { 
			var _transform_minx = transform_minx;
			var _transform_miny = transform_miny;
			var _transform_maxx = transform_maxx;
			var _transform_maxy = transform_maxy;
			
			if(transform_type == 5) {	#region move
				var mx = _mx, my = _my;
				
				if(key_mod_press(SHIFT)) {
					var dirr = point_direction(transform_sx, transform_sy, _mx, _my) + 360;
					var diss = point_distance( transform_sx, transform_sy, _mx, _my);
					var ang  = round((dirr) / 45) * 45;
					mx = transform_sx + lengthdir_x(diss, ang);
					my = transform_sy + lengthdir_y(diss, ang);
				}
				
				var dx = mx - transform_mx;
				var dy = my - transform_my;
				
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var  p = array_clone(getInputData(i));
					p[0] += dx / _s;
					p[1] += dy / _s;
						
					if(inputs[| i].setValue(p))
						_edited = true;
				}
				
				transform_mx = mx;
				transform_my = my;
			#endregion
			} else {					#region scale
				var mx = (_mx - _x) / _s;
				var my = (_my - _y) / _s;
				
				switch(transform_type) {
					case 1 :
						if(key_mod_press(SHIFT)) {
							var _dx = mx - _transform_maxx;
							var _dy = my - _transform_maxy;
							var _dd = max(abs(_dx), abs(_dy));
						
							mx = _transform_maxx + _dd * sign(_dx);
							my = _transform_maxy + _dd * sign(_dy);
						}
						
						transform_minx = mx;
						transform_miny = my;
						
						if(key_mod_press(ALT)) {
							transform_maxx = transform_cx - (mx - transform_cx);
							transform_maxy = transform_cy - (my - transform_cy);
						}
						break;
					case 2 :
						if(key_mod_press(SHIFT)) {
							var _dx = mx - _transform_minx;
							var _dy = my - _transform_maxy;
							var _dd = max(abs(_dx), abs(_dy));
						
							mx = _transform_minx + _dd * sign(_dx);
							my = _transform_maxy + _dd * sign(_dy);
						}
					
						transform_maxx = mx;
						transform_miny = my;
						
						if(key_mod_press(ALT)) {
							transform_minx = transform_cx - (mx - transform_cx);
							transform_maxy = transform_cy - (my - transform_cy);
						}
						break;
					case 3 :
						if(key_mod_press(SHIFT)) {
							var _dx = mx - _transform_maxx;
							var _dy = my - _transform_miny;
							var _dd = max(abs(_dx), abs(_dy));
						
							mx = _transform_maxx + _dd * sign(_dx);
							my = _transform_miny + _dd * sign(_dy);
						}
					
						transform_minx = mx;
						transform_maxy = my;
						
						if(key_mod_press(ALT)) {
							transform_maxx = transform_cx - (mx - transform_cx);
							transform_miny = transform_cy - (my - transform_cy);
						}
						break;
					case 4 :
						if(key_mod_press(SHIFT)) {
							var _dx = mx - _transform_minx;
							var _dy = my - _transform_miny;
							var _dd = max(abs(_dx), abs(_dy));
						
							mx = _transform_minx + _dd * sign(_dx);
							my = _transform_miny + _dd * sign(_dy);
						}
						
						transform_maxx = mx;
						transform_maxy = my;
						
						if(key_mod_press(ALT)) {
							transform_minx = transform_cx - (mx - transform_cx);
							transform_miny = transform_cy - (my - transform_cy);
						}
						break;
				}
				
				var  tr_rx =  transform_maxx -  transform_minx;
				var  tr_ry =  transform_maxy -  transform_miny;
				var _tr_rx = _transform_maxx - _transform_minx;
				var _tr_ry = _transform_maxy - _transform_miny;
				
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var p = array_clone(getInputData(i));
					
					var _p2 = p[_ANCHOR.x] + p[_ANCHOR.c1x];
					var _p3 = p[_ANCHOR.y] + p[_ANCHOR.c1y];
					var _p4 = p[_ANCHOR.x] + p[_ANCHOR.c2x];
					var _p5 = p[_ANCHOR.y] + p[_ANCHOR.c2y];
					
					p[_ANCHOR.x] = transform_minx + (p[_ANCHOR.x] - _transform_minx) / _tr_rx * tr_rx;
					p[_ANCHOR.y] = transform_miny + (p[_ANCHOR.y] - _transform_miny) / _tr_ry * tr_ry;
					
					_p2 = transform_minx + (_p2 - _transform_minx) / _tr_rx * tr_rx;
					_p3 = transform_miny + (_p3 - _transform_miny) / _tr_ry * tr_ry;
					_p4 = transform_minx + (_p4 - _transform_minx) / _tr_rx * tr_rx;
					_p5 = transform_miny + (_p5 - _transform_miny) / _tr_ry * tr_ry;
					
					p[_ANCHOR.c1x] = _p2 - p[_ANCHOR.x];
					p[_ANCHOR.c1y] = _p3 - p[_ANCHOR.y];
					p[_ANCHOR.c2x] = _p4 - p[_ANCHOR.x];
					p[_ANCHOR.c2y] = _p5 - p[_ANCHOR.y];
					
					if(inputs[| i].setValue(p))
						_edited = true;
				}
			#endregion
			}
			
			if(_edited)
				UNDO_HOLDING = true;
				
			if(mouse_release(mb_left)) {
				transform_type = 0;
				RENDER_ALL
				UNDO_HOLDING = false;
			}
		} else if(drag_point > -1) { 
			var dx = value_snap(drag_point_sx + (_mx - drag_point_mx) / _s, _snx);
			var dy = value_snap(drag_point_sy + (_my - drag_point_my) / _s, _sny);
			
			if(drag_type < 2) {				#region move points
				var inp = inputs[| input_fix_len + drag_point];
				var anc = array_clone(inp.getValue());
				
				if(drag_type != 0 && SHIFT == KEYBOARD_STATUS.down)
					anc[_ANCHOR.ind] = !anc[_ANCHOR.ind];
				
				if(drag_type == 0) { //drag anchor point
					anc[_ANCHOR.x] = dx;
					anc[_ANCHOR.y] = dy;
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR.x] = round(anc[0]);
						anc[_ANCHOR.y] = round(anc[1]);
					}
				} else if(drag_type == 1) { //drag control 1
					anc[_ANCHOR.c1x] = dx - anc[_ANCHOR.x];
					anc[_ANCHOR.c1y] = dy - anc[_ANCHOR.y];
					
					if(!anc[_ANCHOR.ind]) {
						anc[_ANCHOR.c2x] = -anc[_ANCHOR.c1x];
						anc[_ANCHOR.c2y] = -anc[_ANCHOR.c1y];
					}
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR.c1x] = round(anc[_ANCHOR.c1x]);
						anc[_ANCHOR.c1y] = round(anc[_ANCHOR.c1y]);
						
						if(!anc[_ANCHOR.ind]) {
							anc[_ANCHOR.c2x] = round(anc[_ANCHOR.c2x]);
							anc[_ANCHOR.c2y] = round(anc[_ANCHOR.c2y]);
						}
					}
				} else if(drag_type == -1) { //drag control 2
					anc[_ANCHOR.c2x] = dx - anc[_ANCHOR.x];
					anc[_ANCHOR.c2y] = dy - anc[_ANCHOR.y];
					
					if(!anc[_ANCHOR.ind]) {
						anc[_ANCHOR.c1x] = -anc[4];
						anc[_ANCHOR.c1y] = -anc[5];
					}
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR.c2x] = round(anc[_ANCHOR.c2x]);
						anc[_ANCHOR.c2y] = round(anc[_ANCHOR.c2y]);
						
						if(!anc[_ANCHOR.ind]) {
							anc[_ANCHOR.c1x] = round(anc[_ANCHOR.c1x]);
							anc[_ANCHOR.c1y] = round(anc[_ANCHOR.c1y]);
						}
					}
				} 
				
				if(inp.setValue(anc))
					_edited = true;
			#endregion
			} else if(drag_type == 2) {		#region pen tools
				var ox, oy, nx, ny;
				var pxx = (_mx - _x) / _s;
				var pxy = (_my - _y) / _s;
				
				draw_set_color(COLORS._main_accent);
				for( var i = 0, n = array_length(drag_points); i < n; i++ ) {
					var _p  = drag_points[i];
					nx = _x + _p[_ANCHOR.x] * _s;
					ny = _y + _p[_ANCHOR.y] * _s;
					
					if(i) draw_line(ox, oy, nx, ny);
					
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
							
							var d0  = point_direction(_p0[_ANCHOR.x], _p0[_ANCHOR.y],  _p[_ANCHOR.x],  _p[_ANCHOR.y]);
							var d1  = point_direction( _p[_ANCHOR.x],  _p[_ANCHOR.y], _p1[_ANCHOR.x], _p1[_ANCHOR.y]);
							
							var dd  = d0 + angle_difference(d1, d0) / 2;
							var ds0 = point_distance(_p0[_ANCHOR.x], _p0[_ANCHOR.y],  _p[_ANCHOR.x],  _p[_ANCHOR.y]);
							var ds1 = point_distance( _p[_ANCHOR.x],  _p[_ANCHOR.y], _p1[_ANCHOR.x], _p1[_ANCHOR.y]);
							
							dxx = lengthdir_x(ds0 / 3, dd + 180);
							dxy = lengthdir_y(ds0 / 3, dd + 180);
							dyx = lengthdir_x(ds1 / 3, dd);
							dyy = lengthdir_y(ds1 / 3, dd);
						}
						
						anc = [ _p[_ANCHOR.x], _p[_ANCHOR.y], dxx, dxy, dyx, dyy ];
						if(input_fix_len + i >= ds_list_size(inputs))
							createNewInput(_p[_ANCHOR.x], _p[_ANCHOR.y], dxx, dxy, dyx, dyy);
						else 
							inputs[| input_fix_len + i].setValue(anc);
					}
					
					if(!replace) {
						for(; i < asize; i++ )
							inputs[| input_fix_len + i].setValue(anc);
					}
				}
			#endregion
			} else if(drag_type == 3) {		#region draw rectangle
				var minx = min((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var maxx = max((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var miny = min((_my - _y) / _s, (drag_point_my - _y) / _s);
				var maxy = max((_my - _y) / _s, (drag_point_my - _y) / _s);
				
				minx = value_snap(minx, _snx);
				maxx = value_snap(maxx, _snx);
				miny = value_snap(miny, _sny);
				maxy = value_snap(maxy, _sny);
				
				if(key_mod_press(SHIFT)) {
					var _n = max(maxx - minx, maxy - miny);
					maxx = minx + _n;
					maxy = miny + _n;
				}
				
				var a = [];
				for( var i = 0; i < 4; i++ ) 
					a[i] = array_clone(getInputData(input_fix_len + i));
				
				a[0][_ANCHOR.x] = minx;
				a[0][_ANCHOR.y] = miny;
				
				a[1][_ANCHOR.x] = maxx;
				a[1][_ANCHOR.y] = miny;
				
				a[2][_ANCHOR.x] = maxx;
				a[2][_ANCHOR.y] = maxy;
				
				a[3][_ANCHOR.x] = minx;
				a[3][_ANCHOR.y] = maxy;
				
				for( var i = 0; i < 4; i++ ) {
					if(inputs[| input_fix_len + i].setValue(a[i]))
						_edited = true;
				}
			#endregion
			} else if(drag_type == 4) {		#region draw circle
				var minx = min((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var maxx = max((_mx - _x) / _s, (drag_point_mx - _x) / _s);
				var miny = min((_my - _y) / _s, (drag_point_my - _y) / _s);
				var maxy = max((_my - _y) / _s, (drag_point_my - _y) / _s);
				
				minx = value_snap(minx, _snx);
				maxx = value_snap(maxx, _snx);
				miny = value_snap(miny, _sny);
				maxy = value_snap(maxy, _sny);
				
				if(key_mod_press(SHIFT)) {
					var _n = max(maxx - minx, maxy - miny);
					maxx = minx + _n;
					maxy = miny + _n;
				}
				
				var a = [];
				for( var i = 0; i < 4; i++ ) 
					a[i] = array_clone(getInputData(input_fix_len + i));
				
				a[0][_ANCHOR.x  ] = (minx + maxx) / 2;
				a[0][_ANCHOR.y  ] = miny;
				a[0][_ANCHOR.c1x] = -(maxx - minx) * 0.27614;
				a[0][_ANCHOR.c1y] = 0;
				a[0][_ANCHOR.c2x] = (maxx - minx) * 0.27614;
				a[0][_ANCHOR.c2y] = 0;
				
				a[1][_ANCHOR.x  ] = maxx;
				a[1][_ANCHOR.y  ] = (miny + maxy) / 2;
				a[1][_ANCHOR.c1x] = 0;
				a[1][_ANCHOR.c1y] = -(maxy - miny) * 0.27614;
				a[1][_ANCHOR.c2x] = 0;
				a[1][_ANCHOR.c2y] = (maxy - miny) * 0.27614;
				
				a[2][_ANCHOR.x  ] = (minx + maxx) / 2;
				a[2][_ANCHOR.y  ] = maxy;
				a[2][_ANCHOR.c1x] = (maxx - minx) * 0.27614;
				a[2][_ANCHOR.c1y] = 0;
				a[2][_ANCHOR.c2x] = -(maxx - minx) * 0.27614;
				a[2][_ANCHOR.c2y] = 0;
				
				a[3][_ANCHOR.x  ] = minx;
				a[3][_ANCHOR.y  ] = (miny + maxy) / 2;
				a[3][_ANCHOR.c1x] = 0;
				a[3][_ANCHOR.c1y] = (maxy - miny) * 0.27614;
				a[3][_ANCHOR.c2x] = 0;
				a[3][_ANCHOR.c2y] = -(maxy - miny) * 0.27614;
				
				for( var i = 0; i < 4; i++ ) {
					if(inputs[| input_fix_len + i].setValue(a[i]))
						_edited = true;
				}
			#endregion
			}
			
			if(_edited) UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_point = -1;
				RENDER_ALL
				UNDO_HOLDING = false;
			}
		}
		
		#region check line hover
			var line_hover = -1;
			var points = [];
			var _a0, _a1;
		
			var minx =  99999, miny =  99999;
			var maxx = -99999, maxy = -99999;
		
			for(var i = loop? 0 : 1; i < ansize; i++) {
				if(i) {
					_a0 = getInputData(input_fix_len + i - 1);
					_a1 = getInputData(input_fix_len + i);
				} else {
					_a0 = getInputData(input_fix_len + ansize - 1);
					_a1 = getInputData(input_fix_len + 0);
				}
					
				var _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0, pnt = [];
				for(var j = 0; j < sample; j++) {
					if(array_length(_a0) < 6) continue;
			
					p = eval_bezier(j / (sample - 1), _a0[_ANCHOR.x], _a0[_ANCHOR.y], 
													  _a1[_ANCHOR.x], _a1[_ANCHOR.y], 
													  _a0[_ANCHOR.x] + _a0[_ANCHOR.c2x], _a0[_ANCHOR.y] + _a0[_ANCHOR.c2y], 
													  _a1[_ANCHOR.x] + _a1[_ANCHOR.c1x], _a1[_ANCHOR.y] + _a1[_ANCHOR.c1y]);
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
		#endregion
		#region draw path
			draw_set_color(isUsingTool(0)? c_white : COLORS._main_accent);
			var ind = 0;
			for(var i = loop? 0 : 1; i < ansize; i++) {
				for(var j = 0; j < sample; j++) {
					_nx = points[ind][j][_ANCHOR.x];
					_ny = points[ind][j][_ANCHOR.y];
				
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
				var _a = getInputData(input_fix_len + i);
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
				
					draw_sprite_colored(THEME.anchor_selector, 2, _ax0, _ay0);
					draw_sprite_colored(THEME.anchor_selector, 2, _ax1, _ay1);
				}
			
				draw_sprite_colored(THEME.anchor_selector, 0, xx, yy);
			
				if(drag_point == i) {
					draw_sprite_colored(THEME.anchor_selector, 1, xx, yy);
				} else if(point_in_circle(_mx, _my, xx, yy, 8)) {
					draw_sprite_colored(THEME.anchor_selector, 1, xx, yy);
					anchor_hover = i;
					hover_type   = 0;
				} else if(cont && point_in_circle(_mx, _my, _ax0, _ay0, 8)) {
					draw_sprite_colored(THEME.anchor_selector, 0, _ax0, _ay0);
					anchor_hover = i;
					hover_type   = 1;
				} else if(cont && point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
					draw_sprite_colored(THEME.anchor_selector, 0, _ax1, _ay1);
					anchor_hover =  i;
					hover_type   = -1;
				}
			}
		#endregion
		
		if(isUsingTool(0)) {								#region transform tools
			var hov = 0;
				 if(point_in_circle(_mx, _my, minx, miny, 8)) hov = 1;
			else if(point_in_circle(_mx, _my, maxx, miny, 8)) hov = 2;
			else if(point_in_circle(_mx, _my, minx, maxy, 8)) hov = 3;
			else if(point_in_circle(_mx, _my, maxx, maxy, 8)) hov = 4;
			else if(point_in_rectangle(_mx, _my, minx, miny, maxx, maxy)) hov = 5;
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle_border(minx, miny, maxx, maxy, 1 + (hov == 5));
			
			draw_sprite_colored(THEME.anchor_selector, hov == 1, minx, miny);
			draw_sprite_colored(THEME.anchor_selector, hov == 2, maxx, miny);
			draw_sprite_colored(THEME.anchor_selector, hov == 3, minx, maxy);
			draw_sprite_colored(THEME.anchor_selector, hov == 4, maxx, maxy);
			
			if(hov && mouse_press(mb_left, active)) {
				transform_type = hov;
				transform_minx = (minx - _x) / _s;	transform_maxx = (maxx - _x) / _s;
				transform_miny = (miny - _y) / _s;	transform_maxy = (maxy - _y) / _s;
				transform_mx   = _mx;				transform_my   = _my;
				transform_sx   = _mx;				transform_sy   = _my;
				
				transform_cx   = (transform_minx + transform_maxx) / 2; 
				transform_cy   = (transform_miny + transform_maxy) / 2;
			}
		#endregion
		} else if(isUsingTool(3)) {							#region pen tools
			draw_sprite_ui_uniform(THEME.path_tools_draw, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				var replace = tool_pathDrawer.attribute.create;
				if(replace) {
					while(ds_list_size(inputs) > input_fix_len)
						ds_list_delete(inputs, input_fix_len);
					resetDisplayList();
				}
				
				drag_point    = 0;
				drag_type     = 2;
				drag_points   = [ [ (_mx - _x) / _s, (_my - _y) / _s ] ];
				drag_point_mx = (_mx - _x) / _s;
				drag_point_my = (_my - _y) / _s;
			}
		#endregion
		} else if(isUsingTool(4) || isUsingTool(5)) {		#region shape tools
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				while(ds_list_size(inputs) > input_fix_len)
					ds_list_delete(inputs, input_fix_len);
				resetDisplayList();
				
				drag_point    = 0;
				drag_type     = isUsingTool(4)? 3 : 4;
				drag_point_mx = _mx;
				drag_point_my = _my;
				inputs[| 1].setValue(true);
				
				repeat(4)
					createNewInput(value_snap((_mx - _x) / _s, _snx), value_snap((_my - _y) / _s, _sny));
			}
		#endregion
		} else if(anchor_hover != -1) {						#region no tool, dragging existing point
			var _a = array_clone(getInputData(input_fix_len + anchor_hover));
			if(isUsingTool(2) && hover_type == 0) {
				draw_sprite_ui_uniform(THEME.cursor_path_anchor, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					if(_a[2] != 0 || _a[3] != 0 || _a[4] != 0 || _a[5] != 0) {
						_a[2] = 0;
						_a[3] = 0;
						_a[4] = 0;
						_a[5] = 0;
						_a[6] = false;
						inputs[| input_fix_len + anchor_hover].setValue(_a);
					} else {
						_a[2] = -8;
						_a[3] = 0;
						_a[4] = 8;
						_a[5] = 0;	
						_a[6] = false;
						
						drag_point    = anchor_hover;
						drag_type     = 1;
						drag_point_mx = _mx;
						drag_point_my = _my;
						drag_point_sx = _a[0];
						drag_point_sy = _a[1];
					}
				}
			} else if(hover_type == 0 && key_mod_press(SHIFT)) { //remove
				draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					recordAction(ACTION_TYPE.list_delete, inputs, [ inputs[| input_fix_len + anchor_hover], input_fix_len + anchor_hover, "remove path anchor point" ]);
		
					ds_list_delete(inputs, input_fix_len + anchor_hover);
					resetDisplayList();
					doUpdate();
				}
			} else {
				draw_sprite_ui_uniform(THEME.cursor_path_move, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					if(isUsingTool(2)) {
						_a[_ANCHOR.ind] = true;
						inputs[| input_fix_len + anchor_hover].setValue(_a);
					}
						
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
		#endregion
		} else if(key_mod_press(CTRL) || isUsingTool(1)) {	#region anchor edit
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				var anc = createNewInput(value_snap((_mx - _x) / _s, _snx), value_snap((_my - _y) / _s, _sny));
				UNDO_HOLDING = true;
				
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
				
				RENDER_ALL
			}
		#endregion
		}
	} #endregion
	
	static updateLength = function() { #region
		boundary    = new BoundingBox();
		lengthTotal = 0;
		var loop    = getInputData(1);
		var rond    = getInputData(3);
		if(!is_real(rond)) rond = false;
		var ansize  = ds_list_size(inputs) - input_fix_len;
		if(ansize < 2) {
			lengths = [];
			anchors = [];
			return;
		}
		var sample = PREFERENCES.path_resolution;
		
		var con = loop? ansize : ansize - 1;
		lengths	   = [];
		lengthAccs = [];
		anchors    = array_create(ansize);
		
		for(var i = 0; i < con; i++) {
			var index_0 = input_fix_len + i;
			var index_1 = input_fix_len + i + 1;
			if(index_1 >= ds_list_size(inputs)) index_1 = input_fix_len;
			
			var _a0 = array_clone(getInputData(index_0));
			var _a1 = array_clone(getInputData(index_1));
			
			if(rond) {
				_a0[0] = round(_a0[0]);	
				_a0[1] = round(_a0[1]);
				_a1[0] = round(_a1[0]);	
				_a1[1] = round(_a1[1]);
			}
			
			anchors[i + 0] = array_clone(_a0);
			anchors[i + 1] = array_clone(_a1);
			
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
	} #endregion
	
	static getLineCount		= function() { return 1; }
	static getSegmentCount	= function() { return array_length(lengths); }
	static getBoundary		= function() { return boundary; }
	
	static getLength		= function() { return lengthTotal; }
	static getAccuLength	= function() { return lengthAccs; }
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) { #region
		if(ds_map_exists(cached_pos, _dist))
			return cached_pos[? _dist].clone();
		
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var loop   = getInputData(1);
		var rond   = getInputData(3);
		if(!is_real(rond)) rond = false;
		
		if(loop) _dist = safe_mod(_dist, lengthTotal, MOD_NEG.wrap);
		var _oDist = _dist;
		
		var ansize = array_length(lengths);
		var amo    = ds_list_size(inputs) - input_fix_len;
		
		if(ansize == 0) return out;
		
		var _a0, _a1;
		
		for(var i = 0; i < ansize; i++) {
			_a0 = array_clone(anchors[safe_mod(i + 0, amo)]);
			_a1 = array_clone(anchors[safe_mod(i + 1, amo)]);
			
			if(!is_array(_a0) || !is_array(_a1))
				return out;
			
			if(rond) {
				_a0[0] = round(_a0[0]);	
				_a0[1] = round(_a0[1]);
				_a1[0] = round(_a1[0]);	
				_a1[1] = round(_a1[1]);
			} 
			
			if(_dist > lengths[i]) {
				_dist -= lengths[i];
				continue;
			}
			
			var _t = _dist / lengths[i];
			var _p     = eval_bezier(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
			out.x = _p[0];
			out.y = _p[1];
			
			cached_pos[? _oDist] = out.clone();
			return out;
		}
		
		return out;
	} #endregion
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { #region
		var pix = frac(_rat) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	} #endregion
	
	static getPointSegment = function(_rat) { #region
		var loop   = getInputData(1);
		var rond   = getInputData(3);
		if(!is_real(rond)) rond = false;
		
		var ansize = array_length(lengths);
		var amo    = ds_list_size(inputs) - input_fix_len;
		
		if(amo < 1) return new __vec2(0, 0);
		if(_rat < 0) {
			var _p0 = getInputData(input_fix_len);
			if(rond)
				return new __vec2(round(_p0[0]), round(_p0[1]));
			return new __vec2(_p0[0], _p0[1]);
		}
		
		_rat = safe_mod(_rat, ansize);
		var _i0 = clamp(floor(_rat), 0, amo - 1);
		var _t  = frac(_rat);
		var _i1 = _i0 + 1;
		
		if(_i1 >= amo) {
			if(!loop) {
				var _p1 = getInputData(ds_list_size(inputs) - 1)
				if(rond)
					return new __vec2(round(_p1[0]), round(_p1[1]));
				return new __vec2(_p1[0], _p1[1]);
			}
			
			_i1 = 0; 
		}
		
		var _a0 = array_clone(getInputData(input_fix_len + _i0));
		var _a1 = array_clone(getInputData(input_fix_len + _i1));
		
		if(rond) {
			_a0[0] = round(_a0[0]);	_a0[1] = round(_a0[1]);
			_a1[0] = round(_a1[0]);	_a1[1] = round(_a1[1]);
		}
		
		var p = eval_bezier(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
		return new __vec2(p[0], p[1]);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		ds_map_clear(cached_pos);
		updateLength();
		
		var _rat = getInputData(0);
		var _typ = getInputData(2);
		var _rnd = getInputData(3);
		
		var anchors = [];
		for(var i = input_fix_len; i < ds_list_size(inputs); i++) {
			var _anc = array_clone(getInputData(i));
			
			if(_rnd) {
				_anc[0] = round(_anc[0]);
				_anc[1] = round(_anc[2]);
			}
			
			array_push(anchors, _anc);
		}
		outputs[| 2].setValue(anchors);
		
		if(is_array(_rat)) {
			var _out = array_create(array_length(_rat));
			
			for( var i = 0, n = array_length(_rat); i < n; i++ ) {
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
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}