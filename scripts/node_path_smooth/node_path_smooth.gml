#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Path_Smooth", "Anchor add / remove", "A");
	});
#endregion

function Node_Path_Smooth(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Smooth Path";
	setDimension(96, 48);
	
	////- =Path
	newInput( 0, nodeValue_Bool(   "Loop",         false )).rejectArray();
	newInput( 1, nodeValue_Bool(   "Round anchor", false )).rejectArray();
	newInput( 2, nodeValue_Slider( "Smoothness",   3, [ 1, 5, 0.01 ] ));
	// 3
	
	newOutput(0, nodeValue_Output("Path data", VALUE_TYPE.pathnode, self));
	
	input_display_list = [
		[ "Path",    false ], 0, 1, 2, 
		[ "Anchors", false ], 
	];
	
	setDynamicInput(1, false);
	
	////- Data
	
	tools = [
		new NodeTool( "Anchor add / remove", THEME.path_tools_add ),
	];
	
	#region ---- path ----
		anchors		= [];
		anchorSize  = 1;
		controls    = [];
		segments    = [];
		lengths		= [];
		lengthAccs	= [];
		lengthTotal	= 0;
		boundary    = new BoundingBox();
		loop        = false;
		
		cached_pos  = ds_map_create();
		 path_preview_surface = noone;
		_path_preview_surface = noone;
	#endregion
	
	#region ---- editor ----
		line_hover = noone;
	#endregion
	
	static resetDisplayList = function() {
		recordAction(ACTION_TYPE.var_modify,  self, [ array_clone(input_display_list), "input_display_list" ])
			.setRef(self);
		
		input_display_list = [
			["Path",	false], 0, 1, 2, 
			["Anchors",	false], 
		];
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			array_push(input_display_list, i);
			inputs[i].name = $"Anchor {i - input_fix_len}";
		}
	}
	
	function createNewInput(index = array_length(inputs), _x = 0, _y = 0) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Vec2("Anchor", [ _x, _y ]));
		
		recordAction(ACTION_TYPE.array_insert, inputs, [ inputs[index], index, "add path anchor point" ])
			.setRef(self);
		resetDisplayList();
		
		return inputs[index];
	}
	
	////- Path
	
	static updateLength = function() {
		segments    = [];
		lengths	    = [];
		lengthAccs  = [];
		lengthTotal = 0;
		boundary    = new BoundingBox();
		
		var sample  = PREFERENCES.path_resolution;
		if(anchorSize < 2) return;
		
		var con = loop? anchorSize : anchorSize - 1;
		
		for(var i = 0; i < con; i++) {
			var _a0 = anchors[ (i + 0) % anchorSize];
			var _a1 = anchors[ (i + 1) % anchorSize];
			var _c0 = controls[(i + 0) % anchorSize];
			var _c1 = controls[(i + 1) % anchorSize];
			
			var l = 0, _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
			var sg = array_create(sample * 2);
			
			for(var j = 0; j < sample; j++) {
				
				if(_c0[2] == 0 && _c0[3] == 0 && _c1[0] == 0 && _c1[1] == 0) {
					_nx = lerp(_a0[0], _a1[0], j / sample);
					_ny = lerp(_a0[1], _a1[1], j / sample);
				} else {
					_nx = eval_bezier_x(j / sample, _a0[0],  _a0[1], _a1[0],  _a1[1], _a0[0] + _c0[2], _a0[1] + _c0[3], _a1[0] + _c1[0], _a1[1] + _c1[1]);
					_ny = eval_bezier_y(j / sample, _a0[0],  _a0[1], _a1[0],  _a1[1], _a0[0] + _c0[2], _a0[1] + _c0[3], _a1[0] + _c1[0], _a1[1] + _c1[1]);
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
		
		// Surface generate
		
		var pad    = min(8, abs(boundary.maxx - boundary.minx) * 0.1, abs(boundary.maxy - boundary.miny) * 0.1);
		var minx   = boundary.minx - pad, miny = boundary.miny - pad;
		var maxx   = boundary.maxx + pad, maxy = boundary.maxy + pad;
		var rngx   = maxx - minx,   rngy = maxy - miny;
		var prev_s = 128;
		
		_path_preview_surface = surface_verify(_path_preview_surface, prev_s, prev_s);
		surface_set_target(_path_preview_surface);
			DRAW_CLEAR
			
			var ox, oy, nx, ny;
			draw_set_color(c_white);
			for (var i = 0, n = array_length(segments); i < n; i++) {
				var segment = segments[i];
				
				for (var j = 0, m = array_length(segment); j < m; j += 2) {
					nx = (segment[j + 0] - minx) / rngx * prev_s;
					ny = (segment[j + 1] - miny) / rngy * prev_s;
					
					if(j) draw_line_round(ox, oy, nx, ny, 4);
					
					ox = nx;
					oy = ny;
				}
			}
			
			draw_set_color(COLORS._main_accent);
			for (var i = 0, n = array_length(anchors); i < n; i++) {
				var _a0 = anchors[i];
				draw_circle((_a0[0] - minx) / rngx * prev_s, (_a0[1] - miny) / rngy * prev_s, 8, false);
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
	
	static getLineCount		= function() /*=>*/ {return 1};
	static getSegmentCount	= function() /*=>*/ {return array_length(lengths)};
	static getBoundary		= function() /*=>*/ {return boundary};
	
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		if(array_empty(lengths)) return out;
		
		var _cKey = _dist;
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
			return out;
		}
		
		if(loop) _dist = safe_mod(_dist, lengthTotal, MOD_NEG.wrap);
		
		if(anchorSize == 0) return out;
		
		for(var i = 0; i < anchorSize; i++) {
			var _a0 = anchors[ (i + 0) % anchorSize];
			var _a1 = anchors[ (i + 1) % anchorSize];
			var _c0 = controls[(i + 0) % anchorSize];
			var _c1 = controls[(i + 1) % anchorSize];
			
			if(_dist > lengths[i]) {
				_dist -= lengths[i];
				continue;
			}
			
			var _t = _dist / lengths[i];
			
			if(_c0[2] == 0 && _c0[3] == 0 && _c1[0] == 0 && _c1[1] == 0) {
				out.x = lerp(_a0[0], _a1[0], _t);
				out.y = lerp(_a0[1], _a1[1], _t);
				
			} else {
				out.x = eval_bezier_x(_t, _a0[0],          _a0[1], 
				                          _a1[0],          _a1[1], 
				                          _a0[0] + _c0[2], _a0[1] + _c0[3], 
				                          _a1[0] + _c1[0], _a1[1] + _c1[1]);
				                          
				out.y = eval_bezier_y(_t, _a0[0],          _a0[1], 
				                          _a1[0],          _a1[1], 
				                          _a0[0] + _c0[2], _a0[1] + _c0[3], 
				                          _a1[0] + _c1[0], _a1[1] + _c1[1]);
			}
			
			cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) {
		return getPointDistance(frac(_rat) * lengthTotal, _ind, out);
	}
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var sample = PREFERENCES.path_resolution;
		var rond   = getInputData(1);
		var hovering = false;
		
		var _line_hover   = -1;
		var _anchor_hover = -1;
		
		if(!array_empty(anchors)) {
			draw_set_color(COLORS._main_accent);
			
			var _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
			
			for( var i = 0, n = array_length(segments); i < n; i++ ) { // draw path
				var _seg = segments[i];
					
				for( var j = 0, m = array_length(_seg); j < m; j += 2 ) {
					_nx = _x + _seg[j + 0] * _s;
					_ny = _y + _seg[j + 1] * _s;
						
					if(i || j) {
						if((key_mod_press(CTRL) || isUsingTool(0)) && distance_to_line(_mx, _my, _ox, _oy, _nx, _ny) < 4)
							_line_hover = i;
						draw_line_width(_ox, _oy, _nx, _ny, 1 + 2 * (line_hover == i));
					}
					
					_ox = _nx;
					_oy = _ny;
				}
			}
			
			var _act = active && !isUsingTool(0);
			
			for(var i = input_fix_len; i < array_length(inputs); i++) {
				var hv = InputDrawOverlay(inputs[i].drawOverlay(hover, _act, _x, _y, _s, _mx, _my));
				if(hv) _anchor_hover = i;
			}
		}
		
		line_hover = _line_hover;
		
		if(key_mod_press(CTRL) || isUsingTool(0)) {	// anchor edit
			CURSOR_SPRITE = _anchor_hover == -1? THEME.cursor_add : THEME.cursor_remove;
			hovering = true;
			
			if(mouse_press(mb_left, active)) {
				if(_anchor_hover == -1) {
					var anc = createNewInput(, PANEL_PREVIEW.snapX((_mx - _x) / _s), PANEL_PREVIEW.snapY((_my - _y) / _s));
					UNDO_HOLDING = true;
				
					if(_line_hover != -1) {
						array_remove(inputs, anc);
						array_insert(inputs, input_fix_len + _line_hover + 1, anc);
					}
					
				} else {
					recordAction(ACTION_TYPE.array_delete, inputs, [ inputs[_anchor_hover], _anchor_hover, "remove path anchor point" ])
						.setRef(self);
					array_delete(inputs, _anchor_hover, 1);
					resetDisplayList();
				}
				
				RENDER_ALL
			}
		}
		
		return hovering || w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		
		loop = getInputData(0);
		var rond = getInputData(1);
		var smot = getInputData(2);
		
		var _a = [];
		for(var i = input_fix_len, n = array_length(inputs); i < n; i++) {
			var _dat = getInputData(i);
			var _dep = array_get_depth(_dat);
			
			if(_dep == 1)
				array_push(_a, [ _dat[0], _dat[1] ]);
				
			else if(_dep == 2) {
				for( var j = 0, m = array_length(_dat); j < m; j++ ) 
					array_push(_a, [ _dat[j][0], _dat[j][1] ]);
			}
		}
		
		anchorSize = array_length(_a);
		anchors    = _a;
		controls   = array_create(anchorSize);
		
		if(rond) 
		for( var i = 0; i < anchorSize; i++ ) {
			_a[i][0] = round(_a[i][0]);
			_a[i][1] = round(_a[i][1]);
		}
		
		if(anchorSize == 2) { 
			controls = [
				[ 0, 0, 0, 0 ],
				[ 0, 0, 0, 0 ],
			];
		} else {
			for( var i = 0, n = anchorSize; i < n; i++ ) {
				var _a0 = array_safe_get_fast(anchors, (i - 1 + anchorSize) % n, [ 0, 0 ]);
				var _a1 = array_safe_get_fast(anchors, (i     + anchorSize) % n, [ 0, 0 ]);
				var _a2 = array_safe_get_fast(anchors, (i + 1 + anchorSize) % n, [ 0, 0 ]);
				
				var _dr  = point_direction(_a0[0], _a0[1], _a2[0], _a2[1]);
				var _ds0 = point_distance(_a1[0], _a1[1], _a0[0], _a0[1]) / smot;
				var _ds2 = point_distance(_a1[0], _a1[1], _a2[0], _a2[1]) / smot;
			
				controls[i] = [ -lengthdir_x(_ds0, _dr), -lengthdir_y(_ds0, _dr), 
				                 lengthdir_x(_ds2, _dr),  lengthdir_y(_ds2, _dr) ];
			}
			
			if(!loop && anchorSize) {
				controls[0] = [ 0, 0, 0, 0 ];
				controls[anchorSize - 1] = [ 0, 0, 0, 0 ];
			}
		}
		
		updateLength();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		gpu_set_tex_filter(true);
		draw_surface_bbox(path_preview_surface, bbox);
		gpu_set_tex_filter(false);
	}
	
	static onCleanUp = function() {
		surface_free(_path_preview_surface);
		surface_free( path_preview_surface);
	}
	
}