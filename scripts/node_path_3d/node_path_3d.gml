#region
	FN_NODE_TOOL_INVOKE {
		hotkeySimple("Node_Path_3D", "Transform",           "T");
		hotkeySimple("Node_Path_3D", "Anchor add / remove", "A");
		hotkeySimple("Node_Path_3D", "Edit Control point",  "C");
	});
#endregion

enum _ANCHOR3 {
	x,
	y,
	z,
	c1x,
	c1y,
	c1z,
	c2x,
	c2y,
	c2z,
	
	ind,
	amount
}

function __vec3P(_x = 0, _y = _x, _z = _x, _w = 1) : __vec3(_x, _y, _z) constructor {
	weight = _w;
	static clone = function() /*=>*/ {return new __vec3P(x, y, z, weight)};
}

function Node_Path_3D(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "3D Path";
	is_3D = NODE_3D.polygon;
	
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
	
	output_display_list  = [ 1, 0, 2 ];
	path_preview_surface = noone;
	
	setDynamicInput(1, false);
	
	tools = [
		new NodeTool( "Transform", THEME.path_tools_transform ),
		new NodeTool( "Anchor add / remove", THEME.path_tools_add ),
		new NodeTool( "Edit Control point", THEME.path_tools_anchor ),
	];
	
	#region ---- path ----
		path_loop    = false;
		anchors		 = [];
		segments     = [];
		lengths		 = [];
		lengthAccs	 = [];
		lengthTotal	 = 0;
		boundary     = new BoundingBox3D();
		
		cached_pos = ds_map_create();
	#endregion
	
	#region ---- editor ----
		line_hover = -1;
	
		drag_point    = -1;
		drag_points   = [];
		drag_type     = 0;
		drag_point_mx = 0;
		drag_point_my = 0;
		drag_point_mz = 0;
		
		drag_point_sx = 0;
		drag_point_sy = 0;
		drag_point_sz = 0;
		
		drag_plane        = noone;
		drag_plane_origin = new __vec3();
		drag_plane_normal = new __vec3();
		
		transform_type = 0;
		
		transform_minx = 0; transform_miny = 0; transform_minz = 0;
		transform_maxx = 0; transform_maxy = 0; transform_maxz = 0;
		
		transform_cx = 0;   transform_cy = 0;   transform_cz = 0;
		transform_sx = 0;   transform_sy = 0;   transform_sz = 0;
		transform_mx = 0;   transform_my = 0;   transform_mz = 0;
	#endregion
	
	static resetDisplayList = function() {
		recordAction(ACTION_TYPE.var_modify,  self, [ array_clone(input_display_list), "input_display_list" ]);
		
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			array_push(input_display_list, i);
			inputs[i].name = $"Anchor {i - input_fix_len}";
		}
	}
	
	static createNewInput = function(  _x = 0,   _y = 0,   _z = 0, 
									 _dxx = 0, _dxy = 0, _dxz = 0, 
									 _dyx = 0, _dyy = 0, _dyz = 0, rec = true) {
		
		var index = array_length(inputs);
		
		newInput(index, nodeValue_Path_Anchor_3D("Anchor", self, []))
			.setValue([ _x, _y, _z, _dxx, _dxy, _dxz, _dyx, _dyy, _dyz, false ]);
		
		if(!rec) return inputs[index];
		
		recordAction(ACTION_TYPE.array_insert, inputs, [ inputs[index], index, $"add path anchor point {index}" ]);
		resetDisplayList();
		
		return inputs[index];
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 2) {
			var type = getInputData(2);	
			
			     if(type == 0) inputs[0].setDisplay(VALUE_DISPLAY.slider);
			else if(type == 1) inputs[0].setDisplay(VALUE_DISPLAY._default);
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {
		var ansize = array_length(inputs) - input_fix_len;
		var edited = false;
		
		var _qinv  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
	
		var _camera = params.camera;
		var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
		var ray     = _camera.viewPointToWorldRay(_mx, _my);
		
		/////////////////////////////////////////////////////// EDIT ///////////////////////////////////////////////////////
		
		if(drag_point > -1) { 
			var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
			
			var dx = drag_point_sx + mAdj.x - drag_point_mx;
			var dy = drag_point_sy + mAdj.y - drag_point_my;
			var dz = drag_point_sz + mAdj.z - drag_point_mz;
			
			if(drag_type < 2) { // move points
				var inp = inputs[input_fix_len + drag_point];
				var anc = array_clone(inp.getValue());
				
				if(drag_type != 0 && key_mod_down(SHIFT))
					anc[_ANCHOR3.ind] = !anc[_ANCHOR3.ind];
				
				if(drag_type == 0) { //drag anchor point
					anc[_ANCHOR3.x] = dx;
					anc[_ANCHOR3.y] = dy;
					anc[_ANCHOR3.z] = dz;
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR3.x] = round(anc[_ANCHOR3.x]);
						anc[_ANCHOR3.y] = round(anc[_ANCHOR3.y]);
						anc[_ANCHOR3.z] = round(anc[_ANCHOR3.z]);
					}
					
				} else if(drag_type == 1) { //drag control 1
					anc[_ANCHOR3.c1x] = dx - anc[_ANCHOR3.x];
					anc[_ANCHOR3.c1y] = dy - anc[_ANCHOR3.y];
					anc[_ANCHOR3.c1z] = dz - anc[_ANCHOR3.z];
					
					if(!anc[_ANCHOR3.ind]) {
						anc[_ANCHOR3.c2x] = -anc[_ANCHOR3.c1x];
						anc[_ANCHOR3.c2y] = -anc[_ANCHOR3.c1y];
						anc[_ANCHOR3.c2z] = -anc[_ANCHOR3.c1z];
					}
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR3.c1x] = round(anc[_ANCHOR3.c1x]);
						anc[_ANCHOR3.c1y] = round(anc[_ANCHOR3.c1y]);
						anc[_ANCHOR3.c1z] = round(anc[_ANCHOR3.c1z]);
						
						if(!anc[_ANCHOR3.ind]) {
							anc[_ANCHOR3.c2x] = round(anc[_ANCHOR3.c2x]);
							anc[_ANCHOR3.c2y] = round(anc[_ANCHOR3.c2y]);
							anc[_ANCHOR3.c2z] = round(anc[_ANCHOR3.c2z]);
						}
					}
					
				} else if(drag_type == -1) { //drag control 2
					anc[_ANCHOR3.c2x] = dx - anc[_ANCHOR3.x];
					anc[_ANCHOR3.c2y] = dy - anc[_ANCHOR3.y];
					anc[_ANCHOR3.c2z] = dz - anc[_ANCHOR3.z];
					
					if(!anc[_ANCHOR3.ind]) {
						anc[_ANCHOR3.c1x] = -anc[_ANCHOR3.c2x];
						anc[_ANCHOR3.c1y] = -anc[_ANCHOR3.c2y];
						anc[_ANCHOR3.c1z] = -anc[_ANCHOR3.c2z];
					}
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR3.c2x] = round(anc[_ANCHOR3.c2x]);
						anc[_ANCHOR3.c2y] = round(anc[_ANCHOR3.c2y]);
						anc[_ANCHOR3.c2z] = round(anc[_ANCHOR3.c2z]);
						
						if(!anc[_ANCHOR3.ind]) {
							anc[_ANCHOR3.c1x] = round(anc[_ANCHOR3.c1x]);
							anc[_ANCHOR3.c1y] = round(anc[_ANCHOR3.c1y]);
							anc[_ANCHOR3.c1z] = round(anc[_ANCHOR3.c1z]);
						}
					}
				} 
				
				if(inp.setValue(anc))
					edited = true;
			}
			
			if(edited) UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_point = -1;
				RENDER_ALL
				UNDO_HOLDING = false;
			}
		}
		
		/////////////////////////////////////////////////////// DRAW PATH ///////////////////////////////////////////////////////
		
		var _line_hover  = -1;
		var anchor_hover = -1;
		var hover_type   = 0;
		
		var minx =  99999, miny =  99999, minz =  99999;
		var maxx = -99999, maxy = -99999, maxz = -99999;
				
		if(!array_empty(anchors)) {
			draw_set_color(isUsingTool(0)? COLORS._main_icon : COLORS._main_accent);
			
			var _v3 = new __vec3();
			
			for( var i = 0, n = array_length(segments); i < n; i++ ) {
				var _seg = segments[i];
				
				var _px = 0, _py = 0, _pz = 0; 
				var _ox = 0, _oy = 0; 
				var _nx = 0, _ny = 0; 
				var  p  = 0;
					
				for( var j = 0, m = array_length(_seg); j < m; j += 3 ) {
					_v3.x = _seg[j + 0];
					_v3.y = _seg[j + 1];
					_v3.z = _seg[j + 2];
					
					var _posView = _camera.worldPointToViewPoint(_v3);
					_nx = _posView.x;
					_ny = _posView.y;
					
					minx = min(minx, _nx); miny = min(miny, _ny);
					maxx = max(maxx, _nx); maxy = max(maxy, _ny);
					
					if(j) {
						if((key_mod_press(CTRL) || isUsingTool(1)) && distance_to_line(_mx, _my, _ox, _oy, _nx, _ny) < 4)
							_line_hover = i;
						draw_line_width(_ox, _oy, _nx, _ny, 1 + 2 * (line_hover == i));
					}
					
					_ox = _nx;
					_oy = _ny;
				}
			}
			
			if(!isUsingTool(0))
			for(var i = 0; i < ansize; i++) {
				var _a = anchors[i];
				_v3.x  = _a[0];
				_v3.y  = _a[1];
				_v3.z  = _a[2];
				
				_posView = _camera.worldPointToViewPoint(_v3);
				var xx   = _posView.x;
				var yy   = _posView.y;
				var cont = false;
				var _ax0 = 0, _ay0 = 0;
				var _ax1 = 0, _ay1 = 0;
		
				if(array_length(_a) < 6) continue;
				
				if(_a[2] != 0 || _a[3] != 0 || _a[4] != 0 || _a[5] != 0) {
					_v3.x = _a[0] + _a[3];
					_v3.y = _a[1] + _a[4];
					_v3.z = _a[2] + _a[5];
					
					_posView = _camera.worldPointToViewPoint(_v3);
					_ax0  = _posView.x;
					_ay0  = _posView.y;
					
					_v3.x = _a[0] + _a[6];
					_v3.y = _a[1] + _a[7];
					_v3.z = _a[2] + _a[8];
					
					_posView = _camera.worldPointToViewPoint(_v3);
					_ax1  = _posView.x;
					_ay1  = _posView.y;
					
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
					
				} else if(point_in_circle(_mx, _my, xx, yy, 8)) {
					draw_sprite_colored(THEME.anchor_selector, 1, xx, yy);
					anchor_hover = i;
					hover_type   = 0;
					
				} else if(cont && point_in_circle(_mx, _my, _ax0, _ay0, 8)) {
					draw_circle_ui(_ax0, _ay0, 6, 0, COLORS._main_accent);
					anchor_hover = i;
					hover_type   = 1;
					
				} else if(cont && point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
					draw_circle_ui(_ax1, _ay1, 6, 0, COLORS._main_accent);
					anchor_hover =  i;
					hover_type   = -1;
				}
			}
		}
		
		line_hover = _line_hover;
		
		/////////////////////////////////////////////////////// TOOLS ///////////////////////////////////////////////////////
		
		if(anchor_hover != -1) { // no tool, dragging existing point
			var _a = array_clone(getInputData(input_fix_len + anchor_hover));
			if(isUsingTool(2) && hover_type == 0) {
				draw_sprite_ui_uniform(THEME.cursor_path_anchor, 0, _mx + 4, _my + 4);
				
				if(mouse_press(mb_left, active)) {
					
					if(_a[3] != 0 || _a[4] != 0 || _a[5] != 0 || _a[6] != 0 || _a[7] != 0 || _a[8] != 0) {
						_a[3] = 0; _a[4] = 0; _a[5] = 0;
						_a[6] = 0; _a[7] = 0; _a[8] = 0;
						_a[9] = false;
						
						inputs[input_fix_len + anchor_hover].setValue(_a);
						
					} else {
						_a[3] = -8; _a[4] = 0; _a[5] = 0;
						_a[6] =  8; _a[7] = 0; _a[8] = 0;
						_a[9] = false;
						
						drag_point    = anchor_hover;
						drag_type     = 1;
						
						drag_plane_origin = new __vec3(_a[0], _a[1], _a[2]);
						drag_plane_normal = ray.direction.multiply(-1)._normalize();
						drag_plane        = new __plane(drag_plane_origin, drag_plane_normal);
						
						var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
						drag_point_mx = mAdj.x;
						drag_point_my = mAdj.y;
						drag_point_mz = mAdj.z;
						
						drag_point_sx = _a[0];
						drag_point_sy = _a[1];
						drag_point_sz = _a[2];
					}
				}
			} else if(hover_type == 0 && key_mod_press(SHIFT)) { //remove
				draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 4, _my + 4);
				
				if(mouse_press(mb_left, active)) {
					var _indx = input_fix_len + anchor_hover;
					recordAction(ACTION_TYPE.array_delete, inputs, [ inputs[_indx], _indx, "remove path anchor point" ]);
					
					array_delete(inputs, _indx, 1);
					resetDisplayList();
					doUpdate();
				}
			} else {
				draw_sprite_ui_uniform(THEME.cursor_path_move, 0, _mx + 4, _my + 4);
				
				if(mouse_press(mb_left, active)) {
					if(isUsingTool(2)) {
						_a[_ANCHOR3.ind] = true;
						inputs[input_fix_len + anchor_hover].setValue(_a);
					}

					drag_point    = anchor_hover;
					drag_type     = hover_type;
					
					drag_plane_origin = new __vec3(_a[0], _a[1], _a[2]);
					drag_plane_normal = ray.direction.multiply(-1)._normalize();
					drag_plane        = new __plane(drag_plane_origin, drag_plane_normal);
					
					var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
					drag_point_mx = mAdj.x;
					drag_point_my = mAdj.y;
					drag_point_mz = mAdj.z;
					
					drag_point_sx = _a[0];
					drag_point_sy = _a[1];
					drag_point_sz = _a[2];
					
					if(hover_type == 1) {
						drag_point_sx = _a[0] + _a[3];
						drag_point_sy = _a[1] + _a[4];	
						drag_point_sz = _a[2] + _a[5];	
						
					} else if(hover_type == -1) {
						drag_point_sx = _a[0] + _a[6];
						drag_point_sy = _a[1] + _a[7];
						drag_point_sz = _a[2] + _a[8];
					} 
				}
			}
		
		} else if(key_mod_press(CTRL) || isUsingTool(1)) {	// anchor edit
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 4, _my + 4);
			
			if(mouse_press(mb_left, active)) {
				
				drag_plane_origin = new __vec3();
				drag_plane_normal = ray.direction.multiply(-1)._normalize();
				drag_plane        = new __plane(drag_plane_origin, drag_plane_normal);
				var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
				
				var ind = array_length(inputs);
				var anc = createNewInput(mAdj.x, mAdj.y, mAdj.z, 0, 0, 0, 0, 0, 0, false);
				
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
				
				drag_point_mx = mAdj.x;
				drag_point_my = mAdj.y;
				drag_point_mz = mAdj.z;
				
				drag_point_sx = mAdj.x;
				drag_point_sy = mAdj.y;
				drag_point_sz = mAdj.z;
				
				RENDER_ALL
			}
		}
		
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
			
			var l   = 0;
			var _ox = 0, _oy = 0, _oz = 0;
			var _nx = 0, _ny = 0, _nz = 0;
			var p   = 0;
			
			var sg = array_create((sample + 1) * 3);
			
			for(var j = 0; j <= sample; j++) {
				var _t = j / sample;
				
				if(_a0[6] == 0 && _a0[7] == 0 && _a0[8] == 0 && _a1[3] == 0 && _a1[4] == 0 && _a1[5] == 0) {
					_nx = lerp(_a0[0], _a1[0], _t);
					_ny = lerp(_a0[1], _a1[1], _t);
					_nz = lerp(_a0[2], _a1[2], _t);
					
				} else {
					_nx = eval_bezier_n(_t, _a0[0], _a1[0], _a0[0] + _a0[6], _a1[0] + _a1[3]);
					_ny = eval_bezier_n(_t, _a0[1], _a1[1], _a0[1] + _a0[7], _a1[1] + _a1[4]);
					_nz = eval_bezier_n(_t, _a0[2], _a1[2], _a0[2] + _a0[8], _a1[2] + _a1[5]);
					
				}
				
				sg[j * 3 + 0] = _nx;
				sg[j * 3 + 1] = _ny;
				sg[j * 3 + 2] = _nz;
				
				boundary.addPoint(_nx, _ny, _nz);
				if(j) l += point_distance_3d(_nx, _ny, _nz, _ox, _oy, _oz);
				
				_ox = _nx;
				_oy = _ny;
			}
			
			segments[i]   = sg;
			lengths[i]    = l;
			lengthTotal  += l;
			lengthAccs[i] = lengthTotal;
		}
		
		// var minx   = boundary.minx - 8, miny = boundary.miny - 8;
		// var maxx   = boundary.maxx + 8, maxy = boundary.maxy + 8;
		// var rngx   = maxx - minx,   rngy = maxy - miny;
		// var prev_s = 128;
		// var _surf  = surface_create(prev_s, prev_s);
		
		// _surf = surface_verify(_surf, prev_s, prev_s);
		// surface_set_target(_surf);
		// 	DRAW_CLEAR
			
		// 	var ox, oy, nx, ny;
		// 	draw_set_color(c_white);
		// 	for (var i = 0, n = array_length(segments); i < n; i++) {
		// 		var segment = segments[i];
				
		// 		for (var j = 0, m = array_length(segment); j < m; j += 2) {
		// 			nx = (segment[j + 0] - minx) / rngx * prev_s;
		// 			ny = (segment[j + 1] - miny) / rngy * prev_s;
					
		// 			if(j) draw_line_round(ox, oy, nx, ny, 4);
					
		// 			ox = nx;
		// 			oy = ny;
		// 		}
		// 	}
			
		// 	draw_set_color(COLORS._main_accent);
		// 	for (var i = 0, n = array_length(anchors); i < n; i++) {
		// 		var _a0 = anchors[i];
		// 		draw_circle((_a0[0] - minx) / rngx * prev_s, (_a0[1] - miny) / rngy * prev_s, 8, false);
		// 	}
		// surface_reset_target();
		
		// path_preview_surface = surface_verify(path_preview_surface, prev_s, prev_s);
		// surface_set_shader(path_preview_surface, sh_FXAA);
		// 	shader_set_f("dimension",  prev_s, prev_s);
		// 	shader_set_f("cornerDis",  0.5);
		// 	shader_set_f("mixAmo",     1);
			
		// 	draw_surface_safe(_surf);
		// surface_reset_shader();
		
		// surface_free(_surf);
	} 
	
	static getLineCount		= function() /*=>*/ {return 1};
	static getSegmentCount	= function() /*=>*/ {return array_length(lengths)};
	static getBoundary		= function() /*=>*/ {return boundary};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec3P(); else { out.x = 0; out.y = 0; out.z = 0; }
		if(array_empty(lengths)) return out;
		
		var _cKey = _dist;
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.z = _p.z;
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
			
			if(_dist > lengths[i]) {
				_dist -= lengths[i];
				continue;
			}
			
			var _t = _dist / lengths[i];
			
			if(_a0[6] == 0 && _a0[7] == 0 && _a0[8] == 0 && _a1[3] == 0 && _a1[4] == 0 && _a1[5] == 0) {
				out.x = lerp(_a0[0], _a1[0], _t);
				out.y = lerp(_a0[1], _a1[1], _t);
				out.z = lerp(_a0[2], _a1[2], _t);
				
			} else {
				out.x = eval_bezier_n(_t, _a0[0], _a1[0], _a0[0] + _a0[6], _a1[0] + _a1[3]);
				out.y = eval_bezier_n(_t, _a0[1], _a1[1], _a0[1] + _a0[7], _a1[1] + _a1[4]);
				out.z = eval_bezier_n(_t, _a0[2], _a1[2], _a0[2] + _a0[8], _a1[2] + _a1[5]);
				
			}
			
			cached_pos[? _cKey] = new __vec3P(out.x, out.y, out.z);
			return out;
		}
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) {
		var pix = (path_loop? frac(_rat) : clamp(_rat, 0, 0.99)) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	}
	
	static getPointSegment = function(_rat) {
		if(array_empty(lengths)) return new __vec3P();
		
		var loop   = getInputData(1);
		var ansize = array_length(inputs) - input_fix_len;
		
		if(_rat < 0) return new __vec3P(anchors[0][0], anchors[0][1], anchors[0][2]);
		
		_rat = safe_mod(_rat, ansize);
		var _i0 = clamp(floor(_rat), 0, ansize - 1);
		var _i1 = (_i0 + 1) % ansize;
		var _t  = frac(_rat);
		
		if(_i1 >= ansize && !loop) return new __vec3P(anchors[ansize - 1][0], anchors[ansize - 1][1], anchors[ansize - 1][2]);
		
		var _a0 = anchors[_i0];
		var _a1 = anchors[_i1];
		var px, py, pz;
		
		if(_a0[6] == 0 && _a0[7] == 0 && _a0[8] == 0 && _a1[3] == 0 && _a1[4] == 0 && _a1[5] == 0) {
			px = lerp(_a0[0], _a1[0], _t);
			py = lerp(_a0[1], _a1[1], _t);
			pz = lerp(_a0[2], _a1[2], _t);
			
		} else {
			px = eval_bezier_n(_t, _a0[0], _a1[0], _a0[0] + _a0[6], _a1[0] + _a1[3]);
			py = eval_bezier_n(_t, _a0[1], _a1[1], _a0[1] + _a0[7], _a1[1] + _a1[4]);
			pz = eval_bezier_n(_t, _a0[2], _a1[2], _a0[2] + _a0[8], _a1[2] + _a1[5]);
			
		}
			
		return new __vec3P(px, py, pz);
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
			var _anc = array_create(10, 0);
			
			for(var j = 0; j < 10; j++)
				_anc[j] = array_safe_get(_val, j);
				
			if(_rnd) {
				_anc[0] = round(_val[0]);
				_anc[1] = round(_val[1]);
				_anc[2] = round(_val[2]);
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
		draw_sprite_bbox_uniform(s_node_path_3d, 0, bbox);
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
	
}