function Node_Path_Builder(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Builder";
	setDimension(96, 48);
	
	#region ---- path ----
		path_loop    = false;
		path_amount  = 0;
		anchors		 = [];
		segments     = [];
		lengths		 = [];
		lengthAccs	 = [];
		lengthTotal	 = 0;
		boundary     = new BoundingBox();
	
		cached_pos = ds_map_create();
		
		lines = [];
	#endregion
	
	newInput(0, nodeValue_Float("Point array", []))
		.setVisible(true, true)
		.setArrayDepth(2);
	
	newInput(1, nodeValue_Bool("Loop", false));
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(path_amount == 0) return;
		
		draw_set_color(COLORS._main_accent);
		
		for(var p = 0; p < path_amount; p++)
		for( var i = 0, n = array_length(segments[p]); i < n; i++ ) { 
			var _seg = segments[p][i];
			var _ox  = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
				
			for( var j = 0, m = array_length(_seg); j < m; j += 2 ) {
				_nx = _x + _seg[j + 0] * _s;
				_ny = _y + _seg[j + 1] * _s;
					
				if(j) draw_line_width(_ox, _oy, _nx, _ny, 1);
				
				_ox = _nx;
				_oy = _ny;
			}
		}
	}
	
	static updateLength = function() {
		boundary    = array_create(path_amount);
		segments    = array_create(path_amount);
		lengths     = array_create(path_amount);
		lengthAccs  = array_create(path_amount);
		lengthTotal = array_create(path_amount);
		
		var sample  = PREFERENCES.path_resolution;
		
		for(var p = 0; p < path_amount; p++) {
			var _anchor = anchors[p];
			var ansize  = array_length(_anchor);
			if(ansize < 2) continue;
			
			var con = path_loop? ansize : ansize - 1;
			var _bb = new BoundingBox();
			
			for(var i = 0; i < con; i++) {
				var _a0 = _anchor[(i + 0) % ansize];
				var _a1 = _anchor[(i + 1) % ansize];
				
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
					
					_bb.addPoint(_nx, _ny);
					if(j) l += point_distance(_nx, _ny, _ox, _oy);	
					
					_ox = _nx;
					_oy = _ny;
				}
				
				boundary[p]      = _bb;
				segments[p][i]   = sg;
				lengths[p][i]    = l;
				lengthTotal[p]  += l;
				lengthAccs[p][i] = lengthTotal[p];
			}
		}
	}
	
	static getLineCount		= function()        { return path_amount;                }
	static getSegmentCount	= function(ind = 0) { return array_length(lengths[ind]); }
	static getBoundary		= function(ind = 0) { return boundary[ind];              }
	
	static getLength		= function(ind = 0) { return lengthTotal[ind];           }
	static getAccuLength	= function(ind = 0) { return lengthAccs[ind];            }
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{ind}, {string_format(_dist, 0, 6)}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
			return out;
		}
		
		if(path_loop) _dist = safe_mod(_dist, lengthTotal[ind], MOD_NEG.wrap);
		
		var _anchor = anchors[ind];
		var ansize  = array_length(_anchor);
		if(ansize == 0) return out;
		
		var _a0, _a1;
		var _len = lengths[ind];
		
		for(var i = 0; i < ansize; i++) {
			_a0 = _anchor[(i + 0) % ansize];
			_a1 = _anchor[(i + 1) % ansize];
			
			if(_dist > _len[i]) {
				_dist -= _len[i];
				continue;
			}
			
			var _t = _dist / _len[i];
			
			if(_a0[4] == 0 && _a0[5] == 0 && _a1[2] == 0 && _a1[3] == 0) {
				out.x = lerp(_a0[0], _a1[0], _t);
				out.y = lerp(_a0[1], _a1[1], _t);
			} else {
				out.x = eval_bezier_x(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
				out.y = eval_bezier_y(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
			}
			
			cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
		
		return out;
	}
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		var pix = (path_loop? frac(_rat) : clamp(_rat, 0, 0.99)) * lengthTotal[ind];
		return getPointDistance(pix, ind, out);
	}
	
	static update = function() {
		ds_map_clear(cached_pos);
		
		var _anc    = getInputData(0);
		path_loop   = getInputData(1);
		path_amount = 0;
		
		if(!is_array(_anc)) return;
		
		var _d = array_get_depth(_anc);
		if(_d < 2 || _d > 3) return;
		else if(_d == 2)     _anc = [ _anc ];
		
		path_amount = array_length(_anc);
		anchors     = array_create(path_amount);
		
		for (var i = 0, n = path_amount; i < n; i++) {
			var _anchors = _anc[i];
			
			for (var j = 0, m = array_length(_anchors); j < m; j++) {
				var _a = _anchors[j]; 
				
				for (var k = 0; k < 7; k++) 
					anchors[i][j][k] = array_safe_get(_a, k, 0);
			}
		}
		
		updateLength();
		
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_builder, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}