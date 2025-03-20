#region
	FN_NODE_TOOL_INVOKE {
		hotkeySimple("Node_Path", "Transform",           "T");
		hotkeySimple("Node_Path", "Anchor add / remove", "A");
		hotkeySimple("Node_Path", "Edit Control point",  "C");
		hotkeySimple("Node_Path", "Draw path",           "B");
		hotkeySimple("Node_Path", "Rectangle path",      "N");
		hotkeySimple("Node_Path", "Circle path",         "M");
		hotkeySimple("Node_Path", "Weight edit",         "W");
	});
#endregion

enum _ANCHOR {
	x,
	y,
	c1x,
	c1y,
	c2x,
	c2y,
	
	ind,
	amount
}

function __vec2P(_x = 0, _y = _x, _w = 1) : __vec2(_x, _y) constructor {
	weight = _w;
	static clone = function() /*=>*/ {return new __vec2P(x, y, weight)};
	static toString = function() { return $"[__vec2P] ({x}, {y} | {weight})"; }
}

function Node_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path";
	preview_channel = 1;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Float("Path progress", self, 0, "Sample position from path."))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(1, nodeValue_Bool("Loop", self, false))
		.rejectArray();
	
	newInput(2, nodeValue_Enum_Scroll("Progress mode", self,  0, ["Entire line", "Segment"]))
		.rejectArray();
	
	newInput(3, nodeValue_Bool("Round anchor", self, false))
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Position out", self, VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
		
	newOutput(1, nodeValue_Output("Path data", self, VALUE_TYPE.pathnode, self));
		
	newOutput(2, nodeValue_Output("Anchors", self, VALUE_TYPE.float, []))
		.setVisible(false)
		.setArrayDepth(1);
	
	input_display_list = [
		["Path",		false], 1, 3, 
		["Sampling",	false], 0, 2, 
		["Anchors",		false], 
	];
	
	output_display_list   = [ 1, 0, 2 ];
	_path_preview_surface = noone;
	path_preview_surface  = noone;
	
	setDynamicInput(1, false);
	
	tool_pathDrawer = new NodeTool( "Draw path", THEME.path_tools_draw )	
		.addSetting("Smoothness", VALUE_TYPE.float,   function(val) /*=>*/ { tool_pathDrawer.attribute.thres = val; }, "thres", 4)
		.addSetting("Replace",    VALUE_TYPE.boolean, function(   ) /*=>*/ { tool_pathDrawer.attribute.create = !tool_pathDrawer.attribute.create; }, "create", true);
	
	tools = [
		new NodeTool( "Transform",           THEME.path_tools_transform ),
		new NodeTool( "Anchor add / remove", THEME.path_tools_add ),
		new NodeTool( "Edit Control point",  THEME.path_tools_anchor ),
		tool_pathDrawer,
		new NodeTool( "Rectangle path", THEME.path_tools_rectangle ),
		new NodeTool( "Circle path",    THEME.path_tools_circle ),
		new NodeTool( "Weight edit",    THEME.path_tools_weight_edit ),
	];
	
	#region ---- path ----
		path_loop    = false;
		anchors		 = [];
		segments     = [];
		lengths		 = [];
		lengthAccs	 = [];
		lengthRatio  = [];
		lengthTotal	 = 0;
		weightRatio  = array_create(100 + 1);
		boundary     = new BoundingBox();
		
		cached_pos = ds_map_create();
		
		attributes.weight = [ [ 0, 1 ], [ 100, 1 ] ];
	#endregion
	
	#region ---- editor ----
		line_hover   = -1;
		weight_hover = -1;
	
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
		
		weight_drag    = noone;
		weight_drag_sx = 0;
		weight_drag_sy = 0;
		weight_drag_mx = 0;
		weight_drag_my = 0;
	#endregion
	
	static resetDisplayList = function() {
		recordAction(ACTION_TYPE.var_modify,  self, [ array_clone(input_display_list), "input_display_list" ]);
		
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			array_push(input_display_list, i);
			inputs[i].name = $"Anchor {i - input_fix_len}";
		}
	}
	
	static newAnchor = function(_x = 0, _y = 0, _dxx = 0, _dxy = 0, _dyx = 0, _dyy = 0) { return [ _x, _y, _dxx, _dxy, _dyx, _dyy, 0 ]; }
	
	static createNewInput = function(_x = 0, _y = 0, _dxx = 0, _dxy = 0, _dyx = 0, _dyy = 0, rec = true) {
		var index = array_length(inputs);
		
		newInput(index, nodeValue_Path_Anchor("Anchor", self, []))
			.setValue(newAnchor( _x, _y, _dxx, _dxy, _dyx, _dyy ));
		
		if(rec) {
			recordAction(ACTION_TYPE.array_insert, inputs, [ inputs[index], index, $"add path anchor point {index}" ]);
			resetDisplayList();
		}
		
		return inputs[index];
	}
	
	static onValueUpdate = function(index = 0) {
		if(index != 2) return;
		
		var type = getInputData(2);	
		inputs[0].setDisplay(type == 0? VALUE_DISPLAY.slider : VALUE_DISPLAY._default);
	}
	
	static drawPreview = function(_x, _y, _s) {}
 
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var ansize = array_length(inputs) - input_fix_len;
		var edited = false;
		var _tooln = getUsingToolName();
		
		var pos = outputs[0].getValue();
		var p/*:_ANCHOR*/;
		
		if(_tooln == "") {
			draw_set_color(COLORS._main_accent);
			draw_circle(_x + pos[0] * _s, _y + pos[1] * _s, 4, false);
		}
		
		//////////////////////////////////////////////////////// EDITING ////////////////////////////////////////////////////////
		
		if(transform_type > 0) { 
			var _transform_minx = transform_minx;
			var _transform_miny = transform_miny;
			var _transform_maxx = transform_maxx;
			var _transform_maxy = transform_maxy;
			
			if(transform_type == 5) { // move
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
				
				for( var i = input_fix_len; i < array_length(inputs); i++ ) {
					p    = array_clone(getInputData(i));
					p[@_ANCHOR.x] += dx / _s;
					p[@_ANCHOR.y] += dy / _s;
						
					if(inputs[i].setValue(p))
						edited = true;
				}
				
				transform_mx = mx;
				transform_my = my;
			
			} else { // scale
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
				
				for( var i = input_fix_len; i < array_length(inputs); i++ ) {
					var p = array_clone(getInputData(i));
					
					var _p2 = p[_ANCHOR.x] + p[_ANCHOR.c1x];
					var _p3 = p[_ANCHOR.y] + p[_ANCHOR.c1y];
					var _p4 = p[_ANCHOR.x] + p[_ANCHOR.c2x];
					var _p5 = p[_ANCHOR.y] + p[_ANCHOR.c2y];
					
					p[@_ANCHOR.x] = transform_minx + (p[_ANCHOR.x] - _transform_minx) / _tr_rx * tr_rx;
					p[@_ANCHOR.y] = transform_miny + (p[_ANCHOR.y] - _transform_miny) / _tr_ry * tr_ry;
					
					_p2 = transform_minx + (_p2 - _transform_minx) / _tr_rx * tr_rx;
					_p3 = transform_miny + (_p3 - _transform_miny) / _tr_ry * tr_ry;
					_p4 = transform_minx + (_p4 - _transform_minx) / _tr_rx * tr_rx;
					_p5 = transform_miny + (_p5 - _transform_miny) / _tr_ry * tr_ry;
					
					p[@_ANCHOR.c1x] = _p2 - p[_ANCHOR.x];
					p[@_ANCHOR.c1y] = _p3 - p[_ANCHOR.y];
					p[@_ANCHOR.c2x] = _p4 - p[_ANCHOR.x];
					p[@_ANCHOR.c2y] = _p5 - p[_ANCHOR.y];
					
					if(inputs[i].setValue(p))
						edited = true;
				}
			}
			
			if(edited) UNDO_HOLDING = true;
				
			if(mouse_release(mb_left)) {
				transform_type = 0;
				UNDO_HOLDING   = false;
				RENDER_ALL
			}
			
		} else if(drag_point > -1) { 
			var dx = value_snap(drag_point_sx + (_mx - drag_point_mx) / _s, _snx);
			var dy = value_snap(drag_point_sy + (_my - drag_point_my) / _s, _sny);
			
			switch(drag_type) {
				case  0 :
				case  1 :
				case -1 :
					var inp = inputs[input_fix_len + drag_point];
					var rnd = key_mod_press(CTRL);
					var anc/*:_ANCHOR*/ = array_clone(inp.getValue());
					
					if(drag_type == 0) { //drag anchor point
						anc[@_ANCHOR.x] = dx;
						anc[@_ANCHOR.y] = dy;
						
						if(rnd) {
							anc[@_ANCHOR.x] = round(anc[_ANCHOR.x]);
							anc[@_ANCHOR.y] = round(anc[_ANCHOR.y]);
						}
						
					} else if(drag_type == 1) { //drag control 1
						anc[@_ANCHOR.c1x] = dx - anc[_ANCHOR.x];
						anc[@_ANCHOR.c1y] = dy - anc[_ANCHOR.y];
						
						if(anc[_ANCHOR.ind] == 0) {
							anc[@_ANCHOR.c2x] = -anc[_ANCHOR.c1x];
							anc[@_ANCHOR.c2y] = -anc[_ANCHOR.c1y];
							
						} else if(anc[_ANCHOR.ind] == 1) {
							var _dir = point_direction(0, 0, anc[_ANCHOR.c1x], anc[_ANCHOR.c1y]);
							var _dis = point_distance(0, 0, anc[_ANCHOR.c2x], anc[_ANCHOR.c2y]);
							
							anc[@_ANCHOR.c2x] = lengthdir_x(_dis, _dir + 180);
							anc[@_ANCHOR.c2y] = lengthdir_y(_dis, _dir + 180);
						}
						
						if(rnd) {
							anc[@_ANCHOR.c1x] = round(anc[_ANCHOR.c1x]);
							anc[@_ANCHOR.c1y] = round(anc[_ANCHOR.c1y]);
							
							if(anc[_ANCHOR.ind] < 2) {
								anc[@_ANCHOR.c2x] = round(anc[_ANCHOR.c2x]);
								anc[@_ANCHOR.c2y] = round(anc[_ANCHOR.c2y]);
							}
						}
						
					} else if(drag_type == -1) { //drag control 2
						anc[@_ANCHOR.c2x] = dx - anc[_ANCHOR.x];
						anc[@_ANCHOR.c2y] = dy - anc[_ANCHOR.y];
						
						if(anc[_ANCHOR.ind] == 0) {
							anc[@_ANCHOR.c1x] = -anc[_ANCHOR.c2x];
							anc[@_ANCHOR.c1y] = -anc[_ANCHOR.c2y];
							
						} else if(anc[_ANCHOR.ind] == 1) {
							var _dir = point_direction(0, 0, anc[_ANCHOR.c2x], anc[_ANCHOR.c2y]);
							var _dis = point_distance(0, 0, anc[_ANCHOR.c1x], anc[_ANCHOR.c1y]);
							
							anc[@_ANCHOR.c1x] = lengthdir_x(_dis, _dir + 180);
							anc[@_ANCHOR.c1y] = lengthdir_y(_dis, _dir + 180);
						}
						
						if(rnd) {
							anc[@_ANCHOR.c2x] = round(anc[_ANCHOR.c2x]);
							anc[@_ANCHOR.c2y] = round(anc[_ANCHOR.c2y]);
							
							if(anc[_ANCHOR.ind] < 2) {
								anc[@_ANCHOR.c1x] = round(anc[_ANCHOR.c1x]);
								anc[@_ANCHOR.c1y] = round(anc[_ANCHOR.c1y]);
							}
						}
					} 
					
					if(inp.setValue(anc))
						edited = true;
					break;
					
				case 2 :
					var ox, oy, nx, ny;
					var pxx = (_mx - _x) / _s;
					var pxy = (_my - _y) / _s;
					
					draw_set_color(COLORS._main_accent);
					for( var i = 0, n = array_length(drag_points); i < n; i++ ) {
						var _p/*:_ANCHOR*/ = drag_points[i];
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
						var asize   = array_length(inputs) - input_fix_len;
						
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
								var _p0/*:_ANCHOR*/ = drag_points[points[i - 1]];
								var _p1/*:_ANCHOR*/ = drag_points[points[i + 1]];
								
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
							if(input_fix_len + i >= array_length(inputs))
								createNewInput(_p[_ANCHOR.x], _p[_ANCHOR.y], dxx, dxy, dyx, dyy);
							else 
								inputs[input_fix_len + i].setValue(anc);
						}
						
						if(!replace) {
							for(; i < asize; i++ )
								inputs[input_fix_len + i].setValue(anc);
						}
					}
				
					break;
				
				case 3 :
				case 4 :
					var minx = min((_mx - _x) / _s, (drag_point_mx - _x) / _s);
					var maxx = max((_mx - _x) / _s, (drag_point_mx - _x) / _s);
					var miny = min((_my - _y) / _s, (drag_point_my - _y) / _s);
					var maxy = max((_my - _y) / _s, (drag_point_my - _y) / _s);
					
					minx = value_snap(minx, _snx);
					maxx = value_snap(maxx, _snx);
					miny = value_snap(miny, _sny);
					maxy = value_snap(maxy, _sny);
					
					if(key_mod_press(ALT)) {
						var _ccx = (drag_point_mx - _x) / _s;
						var _ccy = (drag_point_my - _y) / _s;
						
						var _ww  = (maxx - minx) / 2;
						var _hh  = (maxy - miny) / 2;
						
						if(key_mod_press(SHIFT)) {
							var _n = max(_ww, _hh);
							_ww = _n;
							_hh = _n;
						}
						
						minx = _ccx - _ww;
						maxx = _ccx + _ww;
						
						miny = _ccy - _hh;
						maxy = _ccy + _hh;
						
					} else if(key_mod_press(SHIFT)) {
						var _n = max(maxx - minx, maxy - miny);
						maxx = minx + _n;
						maxy = miny + _n;
					}
					
					if(drag_type == 3) {
						edited |= inputs[input_fix_len + 0].setValue(newAnchor(minx, miny));
						edited |= inputs[input_fix_len + 1].setValue(newAnchor(maxx, miny));
						edited |= inputs[input_fix_len + 2].setValue(newAnchor(maxx, maxy));
						edited |= inputs[input_fix_len + 3].setValue(newAnchor(minx, maxy));
						
					} else if(drag_type == 4) {
							
						var _cnx = (maxx + minx) / 2;
						var _cny = (maxy + miny) / 2;
						var _ccx = (maxx - minx) * 0.27614;
						var _ccy = (maxy - miny) * 0.27614;
						
						edited |= inputs[input_fix_len + 0].setValue(newAnchor( _cnx, miny, -_ccx,     0,  _ccx,     0));
						edited |= inputs[input_fix_len + 1].setValue(newAnchor( maxx, _cny,     0, -_ccy,     0,  _ccy));
						edited |= inputs[input_fix_len + 2].setValue(newAnchor( _cnx, maxy,  _ccx,     0, -_ccx,     0));
						edited |= inputs[input_fix_len + 3].setValue(newAnchor( minx, _cny,     0,  _ccy,     0, -_ccy));
						
					}
					break;
				
			}
			
			if(edited) UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_point = -1;
				RENDER_ALL
				UNDO_HOLDING = false;
			}
			
		} else if(weight_drag != noone) {
			
			var _mmx = weight_drag_sx + (_mx - weight_drag_mx);
			var _mmy = weight_drag_sy + (_my - weight_drag_my);
			
			var _dis = point_distance(weight_drag_sx, weight_drag_sy, _mmx, _mmy) / _s;
			attributes.weight[weight_drag][1] = _dis;
			if(path_loop && weight_drag == 0) attributes.weight[array_length(attributes.weight) - 1][1] = _dis;
			
			updateLength();
			
			if(mouse_release(mb_left)) {
				weight_drag = noone;
				triggerRender();
				UNDO_HOLDING = false;
			}
			
		}
		
		/////////////////////////////////////////////////////// DRAW PATH ///////////////////////////////////////////////////////
		
		var _line_hover   = -1;
		var _weight_hover = -1;
		var _closet_dist  = undefined;
		var _point_hover  = noone;
		var _point_ratio  = 0;
		
		var anchor_hover = -1;
		var hover_type   = 0;
		
		var points = [];
		var _a0, _a1;
		
		var minx =  99999, miny =  99999;
		var maxx = -99999, maxy = -99999;
				
		if(_tooln == "Rectangle path" || _tooln == "Circle path") {
			draw_set_color(COLORS._main_icon);
			
			if(drag_point > -1) { 
				var minx = min(_mx, drag_point_mx);
				var maxx = max(_mx, drag_point_mx);
				var miny = min(_my, drag_point_my);
				var maxy = max(_my, drag_point_my);
				
				if(key_mod_press(ALT)) {
					var _ccx = drag_point_mx;
					var _ccy = drag_point_my;
					
					var _ww  = (maxx - minx) / 2;
					var _hh  = (maxy - miny) / 2;
					
					if(key_mod_press(SHIFT)) {
						var _n = max(_ww, _hh);
						_ww = _n;
						_hh = _n;
					}
					
					minx = _ccx - _ww;
					maxx = _ccx + _ww;
					
					miny = _ccy - _hh;
					maxy = _ccy + _hh;
					
					draw_set_alpha(0.75);
					draw_line(_ccx, 0, _ccx, WIN_H);
					draw_line(0, _ccy, WIN_W, _ccy);
					draw_set_alpha(1);
					
				} else if(key_mod_press(SHIFT)) {
					var _n = max(maxx - minx, maxy - miny);
					maxx = minx + _n;
					maxy = miny + _n;
				}
				
				draw_set_alpha(0.5);
				draw_line(minx, 0, minx, WIN_H);
				draw_line(0, miny, WIN_W, miny);
				
				draw_line(maxx, 0, maxx, WIN_H);
				draw_line(0, maxy, WIN_W, maxy);
				draw_set_alpha(1);
				
			} else {
				draw_set_alpha(0.5);
				draw_line(_mx, 0, _mx, WIN_H);
				draw_line(0, _my, WIN_W, _my);
				draw_set_alpha(1);
			}
			
		}
				
		if(!array_empty(anchors)) {
			draw_set_color(_tooln == "Transform"? COLORS._main_icon : COLORS._main_accent);
			
			var draw_w = _tooln == "Weight edit";
			var _ox = 0, _oy = 0, _ow = 0;
			var _nx = 0, _ny = 0, _nw = 0;
			
			var _ow1x = 0, _ow1y = 0, _ow2x = 0, _ow2y = 0;
			var _nw1x = 0, _nw1y = 0, _nw2x = 0, _nw2y = 0;
			
			for( var i = 0, n = array_length(segments); i < n; i++ ) { // draw path
				var _seg = segments[i];
				var  p  = 0;
				
				var _amo   = array_length(_seg);
				var _rat_s = lengthRatio[i];
				var _rat_e = lengthRatio[i + 1];
				var _wdir  = point_direction(_seg[0], _seg[1], _seg[2], _seg[3]);
				
				for( var j = 0; j < _amo; j += 2 ) {
					_nx = _x + _seg[j + 0] * _s;
					_ny = _y + _seg[j + 1] * _s;
					
					minx = min(minx, _nx); maxx = max(maxx, _nx);
					miny = min(miny, _ny); maxy = max(maxy, _ny);
					
					var _rat = round(lerp(_rat_s, _rat_e, j / _amo) * 100);
					
					if(draw_w) {
						_nw = array_safe_get_fast(weightRatio, _rat);
						
						if(j) _wdir = point_direction(_ox, _oy, _nx, _ny);
						_nw1x = _nx + lengthdir_x(_nw, _wdir + 90);
						_nw1y = _ny + lengthdir_y(_nw, _wdir + 90);
						_nw2x = _nx + lengthdir_x(_nw, _wdir - 90);
						_nw2y = _ny + lengthdir_y(_nw, _wdir - 90);
						
						if(i == 0 && j == 0) {
							draw_set_color(COLORS._main_icon);
							draw_line(_nx, _ny, _nw1x, _nw1y);
							draw_line(_nx, _ny, _nw2x, _nw2y);
						}
					}
					
					if(i || j) {
						if(hover) {
							var _p = point_to_line(_mx, _my, _ox, _oy, _nx, _ny);
							var _d = point_distance(_mx, _my, _p[0], _p[1]);
							
							if(_d < 16 && (_closet_dist == undefined || _d < _closet_dist)) {
								_closet_dist = _d;
								_point_hover = _p;
								_point_ratio = _rat;
							}
							
							if(_d < 4) _line_hover = i;
						}
						
						if(draw_w) {
							draw_set_color(COLORS._main_accent);
							draw_line(_ox, _oy, _nx, _ny);
							
							draw_set_color(COLORS._main_icon);
							draw_line(_ow1x, _ow1y, _nw1x, _nw1y);
							draw_line(_ow2x, _ow2y, _nw2x, _nw2y);
							
							if(i == n - 1 && j + 2 >= _amo) {
								draw_set_color(COLORS._main_icon);
								draw_line(_nx, _ny, _nw1x, _nw1y);
								draw_line(_nx, _ny, _nw2x, _nw2y);
							}
							
						} else 
							draw_line_width(_ox, _oy, _nx, _ny, 1 + (line_hover == i));
					}
				
					_ox = _nx;
					_oy = _ny;
					
					_ow   = _nw;
					_ow1x = _nw1x;
					_ow1y = _nw1y;
					_ow2x = _nw2x;
					_ow2y = _nw2y;
				}
			}
			
			var _showAnchor = hover != -1;
			switch(_tooln) {
				case "Transform" : 
				case "Weight edit" : 
					_showAnchor = false;
					break;
			}
			
			if(_showAnchor)
			for(var i = 0; i < ansize; i++) { // draw anchor
				var _a   = anchors[i];
				var xx   = _x + _a[0] * _s;
				var yy   = _y + _a[1] * _s;
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
					
					draw_circle_ui(_ax0, _ay0, 4, 0, COLORS._main_accent);
					draw_circle_ui(_ax1, _ay1, 4, 0, COLORS._main_accent);
				}
				
				draw_sprite_colored(THEME.anchor_selector, 0, xx, yy);
				draw_set_text(f_p1, fa_left, fa_bottom, COLORS._main_accent);
				draw_text(xx + ui(4), yy - ui(4), inputs[input_fix_len + i].name);
				
				if(drag_point == i) {
					draw_sprite_colored(THEME.anchor_selector, 1, xx, yy);
					
				} else if(hover && point_in_circle(_mx, _my, xx, yy, 8)) {
					draw_sprite_colored(THEME.anchor_selector, 1, xx, yy);
					anchor_hover = i;
					hover_type   = 0;
					
				} else if(cont && hover && point_in_circle(_mx, _my, _ax0, _ay0, 8)) {
					draw_circle_ui(_ax0, _ay0, 6, 0, COLORS._main_accent);
					anchor_hover = i;
					hover_type   = 1;
					
				} else if(cont && hover && point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
					draw_circle_ui(_ax1, _ay1, 6, 0, COLORS._main_accent);
					anchor_hover =  i;
					hover_type   = -1;
				}
			}
			
			if(_tooln == "Weight edit") {
				var _w  = attributes.weight;
				var _wd = 12;
				
				for( var i = 0, n = array_length(_w); i < n; i++ ) {
					var _wg   = _w[i];
					var _wrat = _wg[0];
					var _wp   = getPointDistance(_wrat / 100 * lengthTotal);
					
					var _wx = _x + _wp.x * _s;
					var _wy = _y + _wp.y * _s;
					var _pd = point_distance(_mx, _my, _wx, _wy);
					
					if(_pd < _wd) {
						_weight_hover = i;
						_wd = _pd;
					}
					
					var _sel = weight_hover == i || weight_drag == i;
					draw_set_color(_sel? COLORS._main_accent : COLORS._main_icon_light);
					draw_circle(_wx, _wy, _sel? 5 : 3, false);
					
				}
			}
		}
		
		if(hover == -1) return false;
		line_hover   = _line_hover;
		weight_hover = _weight_hover;
		
		/////////////////////////////////////////////////////// TOOLS ///////////////////////////////////////////////////////
		
		switch(_tooln) {
			case "Transform" :
				var hov = 0;
					 if(hover && point_in_circle(_mx, _my, minx, miny, 8)) hov = 1;
				else if(hover && point_in_circle(_mx, _my, maxx, miny, 8)) hov = 2;
				else if(hover && point_in_circle(_mx, _my, minx, maxy, 8)) hov = 3;
				else if(hover && point_in_circle(_mx, _my, maxx, maxy, 8)) hov = 4;
				else if(hover && point_in_rectangle(_mx, _my, minx, miny, maxx, maxy)) hov = 5;
				
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
				break;
				
			case "Anchor add / remove" :
				
				if(anchor_hover != -1 && hover_type == 0) { //remove
					draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 4, _my + 4);
					
					if(mouse_press(mb_left, active)) {
						var _indx = input_fix_len + anchor_hover;
						recordAction(ACTION_TYPE.array_delete, inputs, [ inputs[_indx], _indx, "remove path anchor point" ]);
						
						array_delete(inputs, _indx, 1);
						resetDisplayList();
						doUpdate();
					} 
					
				} else {
					draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 4, _my + 4);
				
					if(mouse_press(mb_left, active)) {
						var ind = array_length(inputs);
						var anc = createNewInput(value_snap((_mx - _x) / _s, _snx), value_snap((_my - _y) / _s, _sny), 0, 0, 0, 0, false);
						
						if(_line_hover == -1) {
							drag_point = array_length(inputs) - input_fix_len - 1;
							
						} else {
							array_remove(inputs, anc);
							array_insert(inputs, input_fix_len + _line_hover + 1, anc);
							drag_point = _line_hover + 1;
							ind = input_fix_len + _line_hover + 1;
						}
						
						recordAction(ACTION_TYPE.array_insert, inputs, [ inputs[ind], ind, $"add path anchor point {ind}" ]);
						resetDisplayList();
						UNDO_HOLDING = true;
						
						drag_type     = -1;
						drag_point_mx = _mx;
						drag_point_my = _my;
						drag_point_sx = (_mx - _x) / _s;
						drag_point_sy = (_my - _y) / _s;
						
						RENDER_ALL
					}
				}
				
				break;
			
			case "Draw path" :
				draw_sprite_ui_uniform(THEME.path_tools_draw, 0, _mx + 16, _my + 16);
				
				if(mouse_press(mb_left, active)) {
					var replace = tool_pathDrawer.attribute.create;
					if(replace) {
						while(array_length(inputs) > input_fix_len)
							array_delete(inputs, input_fix_len, 1);
						resetDisplayList();
					}
					
					drag_point    = 0;
					drag_type     = 2;
					drag_points   = [ [ (_mx - _x) / _s, (_my - _y) / _s ] ];
					drag_point_mx = (_mx - _x) / _s;
					drag_point_my = (_my - _y) / _s;
				}
				break;
				
			case "Rectangle path" : 
			case "Circle path" :
				draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 4, _my + 4);
			
				if(mouse_press(mb_left, active)) {
					while(array_length(inputs) > input_fix_len)
						array_delete(inputs, input_fix_len, 1);
					resetDisplayList();
					
					drag_point    = 0;
					drag_type     = isUsingTool(4)? 3 : 4;
					drag_point_mx = _mx;
					drag_point_my = _my;
					inputs[1].setValue(true);
					
					repeat(4)
						createNewInput(value_snap((_mx - _x) / _s, _snx), value_snap((_my - _y) / _s, _sny));
				}
				break;
				
			case "Weight edit" : 
				if(_point_hover != noone) {
					
					if(_weight_hover == -1) {
						draw_set_color(COLORS._main_accent);
						draw_circle(_point_hover[0], _point_hover[1], 4, false);
						
					} else if(_weight_hover != -1 && key_mod_press(SHIFT)) {
						draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 4, _my + 4);
						
						if(mouse_press(mb_left, active)) {
							if(_weight_hover == 0 || _weight_hover == array_length(attributes.weight) - 1) 
								attributes.weight[_weight_hover][0] = 1;
							else 
								array_delete(attributes.weight, _weight_hover, 1);
							triggerRender();
						}
						break;
					}
					
					if(mouse_press(mb_left, active)) {
						if(array_empty(attributes.weight)) attributes.weight = [ [ 0, 1 ], [ 100, 1 ] ];
						var _w = attributes.weight;
						
						if(_weight_hover != -1) {
							weight_drag = _weight_hover;
						} else {
							for( var i = 0, n = array_length(_w) - 1; i < n; i++ ) {
								if(_point_ratio > _w[i + 1][0]) continue;
								
								array_insert(_w, i + 1, [ _point_ratio, 1 ]);
								weight_drag = i + 1;
								break;
							}
						}
						
						weight_drag_sx = _point_hover[0];
						weight_drag_sy = _point_hover[1];
						weight_drag_mx = _mx;
						weight_drag_my = _my;
						
					}
				}
				break;
				
			default :
				if(anchor_hover == -1) break;
				
				var _a/*:_ANCHOR*/ = array_clone(getInputData(input_fix_len + anchor_hover));
				
				if(hover_type == 0 && _tooln == "Edit Control point") { // add / remove anchor point
					draw_sprite_ui_uniform(THEME.cursor_path_anchor, 0, _mx + 4, _my + 4);
					
					if(mouse_press(mb_left, active)) {
						if(_a[_ANCHOR.c1x] != 0 || _a[_ANCHOR.c1y] != 0 || _a[_ANCHOR.c2x] != 0 || _a[_ANCHOR.c2y] != 0) {
							_a[@_ANCHOR.c1x] = 0;
							_a[@_ANCHOR.c1y] = 0;
							_a[@_ANCHOR.c2x] = 0;
							_a[@_ANCHOR.c2y] = 0;
							_a[@_ANCHOR.ind] = 0;
							inputs[input_fix_len + anchor_hover].setValue(_a);
							
						} else {
							_a[@_ANCHOR.c1x] = -8;
							_a[@_ANCHOR.c1y] = 0;
							_a[@_ANCHOR.c2x] = 8;
							_a[@_ANCHOR.c2y] = 0;	
							_a[@_ANCHOR.ind] = 0;
							
							drag_point    = anchor_hover;
							drag_type     = 1;
							drag_point_mx = _mx;
							drag_point_my = _my;
							drag_point_sx = _a[_ANCHOR.x];
							drag_point_sy = _a[_ANCHOR.y];
						}
					}
					
				} else if(hover_type == 0 && key_mod_press(SHIFT)) { // remove
					draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 4, _my + 4);
					
					if(mouse_press(mb_left, active)) {
						var _indx = input_fix_len + anchor_hover;
						recordAction(ACTION_TYPE.array_delete, inputs, [ inputs[_indx], _indx, "remove path anchor point" ]);
						
						array_delete(inputs, _indx, 1);
						resetDisplayList();
						doUpdate();
					}
					
				} else {
					var _spr = THEME.cursor_path_move;
					if(_tooln == "Edit Control point")
						_spr = key_mod_press(SHIFT)? THEME.cursor_path_anchor_detach : THEME.cursor_path_anchor_unmirror;
					
					draw_sprite_ui_uniform(_spr, 0, _mx + 4, _my + 4);
					
					if(mouse_press(mb_left, active)) {
						if(_tooln == "Edit Control point") {
							_a[@_ANCHOR.ind] = key_mod_press(SHIFT)? 2 : 1;
							inputs[input_fix_len + anchor_hover].setValue(_a);
						}
							
						drag_point    = anchor_hover;
						drag_type     = hover_type;
						drag_point_mx = _mx;
						drag_point_my = _my;
						drag_point_sx = _a[_ANCHOR.x];
						drag_point_sy = _a[_ANCHOR.y];
						
						if(hover_type == 1) {
							drag_point_sx = _a[_ANCHOR.x] + _a[_ANCHOR.c1x];
							drag_point_sy = _a[_ANCHOR.y] + _a[_ANCHOR.c1y];	
							
						} else if(hover_type == -1) {
							drag_point_sx = _a[_ANCHOR.x] + _a[_ANCHOR.c2x];
							drag_point_sy = _a[_ANCHOR.y] + _a[_ANCHOR.c2y];
						} 
					}
				}
				break;
		}
		
		return true;
	}
	
	static updateLength = function() {
		boundary     = new BoundingBox();
		segments     = [];
		lengths      = [];
		lengthAccs   = [];
		lengthTotal  = 0;
		
		var _index  = 0;
		var sample  = PREFERENCES.path_resolution;
		var ansize  = array_length(inputs) - input_fix_len;
		if(ansize < 2) return;
		
		var con = path_loop? ansize : ansize - 1;
		
		for(var i = 0; i < con; i++) {
			var _a0 = anchors[(i + 0) % ansize];
			var _a1 = anchors[(i + 1) % ansize];
			
			var l = 0, _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
			var sg = array_create((sample + 1) * 2);
			
			for(var j = 0; j <= sample; j++) {
				
				if(_a0[4] == 0 && _a0[5] == 0 && _a1[2] == 0 && _a1[3] == 0) {
					_nx = lerp(_a0[0], _a1[0], j / sample);
					_ny = lerp(_a0[1], _a1[1], j / sample);
					
				} else {
					_nx = eval_bezier_x(j / sample, _a0[0],  _a0[1], _a1[0],  _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
					_ny = eval_bezier_y(j / sample, _a0[0],  _a0[1], _a1[0],  _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
				}
				
				sg[j * 2 + 0] = _nx;
				sg[j * 2 + 1] = _ny;
				
				boundary.addPoint(_nx, _ny);
				if(j) l += point_distance(_nx, _ny, _ox, _oy);	
				
				_ox = _nx;
				_oy = _ny;
			}
			
			segments[i]   = sg;
			lengths[i]    = l;
			lengthTotal  += l;
			lengthAccs[i] = lengthTotal;
		}
		
		lengthRatio    = array_create(ansize + 1);
		lengthRatio[0] = 0;
		for( var i = 0; i < con; i++ )
			lengthRatio[i + 1] = lengthAccs[i] / lengthTotal;
		
		var _w = attributes.weight;
		
		     if(array_empty(_w))       weightRatio = array_map(weightRatio, function(i) /*=>*/ {return 1});
		else if(array_length(_w) == 1) weightRatio = array_map(weightRatio, function(i) /*=>*/ {return attributes.weight[0][1]});
		else {
			var _wi   = 0;
			var _wamo = array_length(_w);
			var _amo  = 100;
			
			var _wf = _w[_wi + 0];
			var _wt = _w[_wi + 1];
			
			for( var i = 0; i <= _amo; i++ ) {
				if(i < _amo && i == _wt[0]) {
					_wi++;
					_wf = _w[(_wi + 0) % _wamo];
					_wt = _w[(_wi + 1) % _wamo];
				}
				
				weightRatio[i] = lerp(_wf[1], _wt[1], lerp_smooth((i - _wf[0]) / (_wt[0] - _wf[0])));
			}
		}
		
		// Surface generate
		
		var pad  = min(8, abs(boundary.maxx - boundary.minx) * 0.1, abs(boundary.maxy - boundary.miny) * 0.1);
		var minx = boundary.minx - pad, maxx = boundary.maxx + pad;
		var cx   = (minx + maxx) / 2;
		
		var miny = boundary.miny - pad, maxy = boundary.maxy + pad;
		var cy   = (miny + maxy) / 2;
		
		var rng  = max(maxx - minx, maxy - miny);
		
		var x0 = cx - rng / 2, x1 = cx + rng / 2;
		var y0 = cy - rng / 2, y1 = cy + rng / 2;
		
		var prev_s = 128;
		
		_path_preview_surface = surface_verify(_path_preview_surface, prev_s, prev_s);
		surface_set_target(_path_preview_surface);
			DRAW_CLEAR
			
			var ox, oy, nx, ny;
			draw_set_color(c_white);
			for (var i = 0, n = array_length(segments); i < n; i++) {
				var segment = segments[i];
				
				for (var j = 0, m = array_length(segment); j < m; j += 2) {
					nx = (segment[j + 0] - x0) / rng * prev_s;
					ny = (segment[j + 1] - y0) / rng * prev_s;
					
					if(j) draw_line_round(ox, oy, nx, ny, 4);
					
					ox = nx;
					oy = ny;
				}
			}
			
			draw_set_color(COLORS._main_accent);
			for (var i = 0, n = array_length(anchors); i < n; i++) {
				var _a0 = anchors[i];
				draw_circle((_a0[0] - x0) / rng * prev_s, (_a0[1] - y0) / rng * prev_s, 8, false);
			}
		surface_reset_target();
		
		path_preview_surface = surface_verify(path_preview_surface, prev_s, prev_s);
		surface_set_shader(path_preview_surface, sh_FXAA);
			shader_set_f("dimension",  prev_s, prev_s);
			shader_set_f("cornerDis",  0.5);
			shader_set_f("mixAmo",     1);
			
			draw_surface_safe(_path_preview_surface);
		surface_reset_shader();
	}
	
	static getLineCount		= function() { return 1; }
	static getSegmentCount	= function() { return array_length(lengths); }
	static getBoundary		= function() { return boundary; }
	
	static getLength		= function() { return lengthTotal; }
	static getAccuLength	= function() { return lengthAccs; }
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		if(array_empty(lengths)) return out;
		
		out.weight = 1;
		var _cKey  = _dist;
		
		if(ds_map_exists(cached_pos, _cKey)) {
			var _cachep = cached_pos[? _cKey];
			out.x = _cachep.x;
			out.y = _cachep.y;
			out.weight = _cachep.weight;
			return out;
		}
		
		var loop = getInputData(1);
		if(loop) _dist = safe_mod(_dist, lengthTotal, MOD_NEG.wrap);
		
		var ansize = array_length(inputs) - input_fix_len;
		if(ansize == 0) return out;
		
		var _a0, _a1;
		
		for(var i = 0; i < ansize; i++) {
			_a0 = anchors[(i + 0) % ansize];
			_a1 = anchors[(i + 1) % ansize];
			
			var _l = array_safe_get(lengths, i, 0, ARRAY_OVERFLOW.clamp);
			if(_dist > _l) {
				_dist -= _l;
				continue;
			}
			
			var _t   = _l == 0? 0 : _dist / _l;
			var _rat = lerp(lengthRatio[i], lengthRatio[i + 1], _t) * 100;
			var _nw  = array_get_decimal(weightRatio, _rat);
			
			if(_a0[4] == 0 && _a0[5] == 0 && _a1[2] == 0 && _a1[3] == 0) {
				out.x = lerp(_a0[0], _a1[0], _t);
				out.y = lerp(_a0[1], _a1[1], _t);
				
			} else {
				out.x = eval_bezier_x(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
				out.y = eval_bezier_y(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
			}
			
			out.weight = _nw;
			
			cached_pos[? _cKey] = new __vec2P(out.x, out.y, _nw);
			return out;
		}
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) {
		var pix = (path_loop? frac(_rat) : clamp(_rat, 0, 0.99)) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	}
	
	static getPointSegment = function(_rat) {
		if(array_empty(lengths)) return new __vec2P();
		
		var loop   = getInputData(1);
		var ansize = array_length(inputs) - input_fix_len;
		
		if(_rat < 0) return new __vec2P(anchors[0][0], anchors[0][1]);
		
		_rat = safe_mod(_rat, ansize);
		var _i0 = clamp(floor(_rat), 0, ansize - 1);
		var _i1 = (_i0 + 1) % ansize;
		var _t  = frac(_rat);
		
		if(_i1 >= ansize && !loop) return new __vec2P(anchors[ansize - 1][0], anchors[ansize - 1][1]);
		
		var _a0 = anchors[_i0];
		var _a1 = anchors[_i1];
		var px, py;
		
		if(_a0[4] == 0 && _a0[5] == 0 && _a1[2] == 0 && _a1[3] == 0) {
			px = lerp(_a0[0], _a1[0], _t);
			py = lerp(_a0[1], _a1[1], _t);
		} else {
			px = eval_bezier_x(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
			py = eval_bezier_y(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
		}
			
		return new __vec2P(px, py);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		
		var _rat  = getInputData(0);
		path_loop = getInputData(1);
		var _typ  = getInputData(2);
		var _rnd  = getInputData(3);
		
		var _a = [];
		for(var i = input_fix_len; i < array_length(inputs); i++) {
			var _val = getInputData(i);
			var _anc = array_create(7, 0);
			
			for(var j = 0; j < 7; j++)
				_anc[j] = array_safe_get(_val, j);
				
			if(_rnd) {
				_anc[0] = round(_val[0]);
				_anc[1] = round(_val[1]);
			}
			
			array_push(_a, _anc);
		}
		
		anchors = _a;
		outputs[2].setValue(_a);
		
		updateLength();
		
		if(is_array(_rat)) {
			var _out = array_create(array_length(_rat));
			
			for( var i = 0, n = array_length(_rat); i < n; i++ ) {
				if(_typ == 0)		_out[i] = getPointRatio(_rat[i]);
				else if(_typ == 1)	_out[i] = getPointSegment(_rat[i]);
			}
			
			outputs[0].setValue(_out);
		} else {
			var _out = [0, 0];
			
			if(_typ == 0)		_out = getPointRatio(_rat);
			else if(_typ == 1)	_out = getPointSegment(_rat);
			
			outputs[0].setValue(_out.toArray());
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(array_empty(segments)) {
			draw_sprite_fit(s_node_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
			
		} else {
			gpu_set_tex_filter(true);
			draw_surface_bbox(path_preview_surface, bbox);
			gpu_set_tex_filter(false);
		}
	}
	
	static getPreviewBoundingBox = function() { return BBOX().fromBoundingBox(boundary); }
	
	static onCleanUp = function() {
		surface_free(_path_preview_surface);
		surface_free( path_preview_surface);
	}
	
}