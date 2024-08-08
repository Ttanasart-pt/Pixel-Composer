function Node_Path_Smooth(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Smooth Path";
	setDimension(96, 48);;
	
	inputs[0] = nodeValue_Bool("Loop", self, false)
		.rejectArray();
	
	inputs[1] = nodeValue_Bool("Round anchor", self, false)
		.rejectArray();
	
	inputs[2] = nodeValue_Float("Smoothness", self, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range : [ 1, 5, 0.01 ] } );
	
	outputs[0] = nodeValue_Output("Path data", self, VALUE_TYPE.pathnode, self);
	
	input_display_list = [
		["Path",	false], 0, 1, 2, 
		["Anchors",	false], 
	];
	
	setDynamicInput(1, false);
	
	tools = [
		new NodeTool( "Anchor add / remove", THEME.path_tools_add ),
	];
	
	#region ---- path ----
		anchors		= [];
		controls    = [];
		segments    = [];
		lengths		= [];
		lengthAccs	= [];
		lengthTotal	= 0;
		boundary    = new BoundingBox();
		
		cached_pos = ds_map_create();
	#endregion
	
	#region ---- editor ----
		line_hover = noone;
	#endregion
	
	static resetDisplayList = function() { #region
		recordAction(ACTION_TYPE.var_modify,  self, [ array_clone(input_display_list), "input_display_list" ]);
		
		input_display_list = [
			["Path",	false], 0, 1, 2, 
			["Anchors",	false], 
		];
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			array_push(input_display_list, i);
			inputs[i].name = $"Anchor {i - input_fix_len}";
		}
	} #endregion
	
	static createNewInput = function(_x = 0, _y = 0) { #region
		var index = array_length(inputs);
		
		inputs[index] = nodeValue_Vector("Anchor",  self, [ _x, _y ]);
		
		recordAction(ACTION_TYPE.list_insert, inputs, [ inputs[index], index, "add path anchor point" ]);
		resetDisplayList();
		
		return inputs[index];
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var sample = PREFERENCES.path_resolution;
		var ansize = array_length(inputs) - input_fix_len;
		var loop   = getInputData(0);
		var rond   = getInputData(1);
		
		var _line_hover   = -1;
		var _anchor_hover = -1;
		
		if(!array_empty(anchors)) {
			draw_set_color(COLORS._main_accent);
			
			for( var i = 0, n = array_length(segments); i < n; i++ ) { #region draw path
				var _seg = segments[i];
				var _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
					
				for( var j = 0, m = array_length(_seg); j < m; j += 2 ) {
					_nx = _x + _seg[j + 0] * _s;
					_ny = _y + _seg[j + 1] * _s;
						
					if(j) {
						if((key_mod_press(CTRL) || isUsingTool(0)) && distance_to_line(_mx, _my, _ox, _oy, _nx, _ny) < 4)
							_line_hover = i;
						draw_line_width(_ox, _oy, _nx, _ny, 1 + 2 * (line_hover == i));
					}
					
					_ox = _nx;
					_oy = _ny;
				}
			} #endregion
			
			#region draw anchor
				var _act = active && !isUsingTool(0);
				
				for(var i = input_fix_len; i < array_length(inputs); i++) {
					var a = inputs[i].drawOverlay(hover, _act, _x, _y, _s, _mx, _my, _snx, _sny);
					_act &= !a;
					if(a) _anchor_hover = i;
				}
			#endregion
		}
		
		line_hover = _line_hover;
		
		if(key_mod_press(CTRL) || isUsingTool(0)) {	#region anchor edit
			draw_sprite_ui_uniform(_anchor_hover == -1? THEME.cursor_path_add : THEME.cursor_path_remove, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				if(_anchor_hover == -1) {
					var anc = createNewInput(value_snap((_mx - _x) / _s, _snx), value_snap((_my - _y) / _s, _sny));
					UNDO_HOLDING = true;
				
					if(_line_hover != -1) {
						array_remove(inputs, anc);
						array_insert(inputs, input_fix_len + _line_hover + 1, anc);
					}
				} else {
					recordAction(ACTION_TYPE.list_delete, inputs, [ inputs[input_fix_len + _anchor_hover], input_fix_len + _anchor_hover, "remove path anchor point" ]);
					array_delete(inputs, input_fix_len + _anchor_hover, 1);
					resetDisplayList();
				}
				
				RENDER_ALL
			}
		#endregion
		}
	} #endregion
	
	static updateLength = function() { #region
		var loop    = getInputData(0);
		
		segments    = [];
		lengths	    = [];
		lengthAccs  = [];
		lengthTotal = 0;
		boundary    = new BoundingBox();
		
		var sample  = PREFERENCES.path_resolution;
		var ansize  = array_length(inputs) - input_fix_len;
		if(ansize < 2) return;
		
		var con = loop? ansize : ansize - 1;
		
		for(var i = 0; i < con; i++) {
			var _a0 = anchors[ (i + 0) % ansize];
			var _a1 = anchors[ (i + 1) % ansize];
			var _c0 = controls[(i + 0) % ansize];
			var _c1 = controls[(i + 1) % ansize];
			
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
	} #endregion
	
	static getLineCount		= function() { return 1; }
	static getSegmentCount	= function() { return array_length(lengths); }
	static getBoundary		= function() { return boundary; }
	
	static getLength		= function() { return lengthTotal; }
	static getAccuLength	= function() { return lengthAccs; }
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		if(array_empty(lengths)) return out;
		
		var _cKey = _dist;
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			return out;
		}
		
		var loop = getInputData(1);
		if(loop) _dist = safe_mod(_dist, lengthTotal, MOD_NEG.wrap);
		
		var ansize = array_length(inputs) - input_fix_len;
		if(ansize == 0) return out;
		
		for(var i = 0; i < ansize; i++) {
			var _a0 = anchors[ (i + 0) % ansize];
			var _a1 = anchors[ (i + 1) % ansize];
			var _c0 = controls[(i + 0) % ansize];
			var _c1 = controls[(i + 1) % ansize];
			
			if(_dist > lengths[i]) {
				_dist -= lengths[i];
				continue;
			}
			
			var _t = _dist / lengths[i];
			
			if(_c0[2] == 0 && _c0[3] == 0 && _c1[0] == 0 && _c1[1] == 0) {
				out.x = lerp(_a0[0], _a1[0], _t);
				out.y = lerp(_a0[1], _a1[1], _t);
			} else {
				out.x = eval_bezier_x(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _c0[2], _a0[1] + _c0[3], _a1[0] + _c1[0], _a1[1] + _c1[1]);
				out.y = eval_bezier_y(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _c0[2], _a0[1] + _c0[3], _a1[0] + _c1[0], _a1[1] + _c1[1]);
			}
			
			cached_pos[? _cKey] = out.clone();
			return out;
		}
		
		return out;
	} #endregion
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { #region
		var pix = frac(_rat) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		ds_map_clear(cached_pos);
		
		var loop = getInputData(0);
		var rond = getInputData(1);
		var smot = getInputData(2);
		
		var _a = [];
		for(var i = input_fix_len; i < array_length(inputs); i++) {
			var _anc = array_clone(getInputData(i));
			
			if(rond) {
				_anc[0] = round(_anc[0]);
				_anc[1] = round(_anc[1]);
			}
			
			array_push(_a, _anc);
		}
		
		var amo  = array_length(_a);
		anchors  = _a;
		controls = array_create(amo);
		
		if(amo == 2) { 
			controls = [
				[ 0, 0, 0, 0 ],
				[ 0, 0, 0, 0 ],
			];
		} else {
			for( var i = 0, n = amo; i < n; i++ ) {
				var _a0 = array_safe_get_fast(anchors, (i - 1 + amo) % n, [ 0, 0 ]);
				var _a1 = array_safe_get_fast(anchors, (i     + amo) % n, [ 0, 0 ]);
				var _a2 = array_safe_get_fast(anchors, (i + 1 + amo) % n, [ 0, 0 ]);
				
				var _dr  = point_direction(_a0[0], _a0[1], _a2[0], _a2[1]);
				var _ds0 = point_distance(_a1[0], _a1[1], _a0[0], _a0[1]) / smot;
				var _ds2 = point_distance(_a1[0], _a1[1], _a2[0], _a2[1]) / smot;
			
				controls[i] = [ -lengthdir_x(_ds0, _dr), -lengthdir_y(_ds0, _dr), 
				                 lengthdir_x(_ds2, _dr),  lengthdir_y(_ds2, _dr) ];
			}
			
			if(!loop && amo) {
				controls[0]       = [ 0, 0, 0, 0 ];
				controls[amo - 1] = [ 0, 0, 0, 0 ];
			}
		}
		
		updateLength();
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}