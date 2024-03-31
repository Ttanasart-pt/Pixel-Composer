function Node_Path_Bridge(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Bridge Path";
	w    = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	input_display_list = [ 0, 
		["Bridge",  false], 1, 2, 
	]
	
	cached_pos = ds_map_create();
	
	#region ---- path ----
		anchors		= [];
		controls	= [];
		lengths		= [];
		lengthAccs	= [];
		boundary    = [];
		lengthTotal	= [];
	
		cached_pos = ds_map_create();
	#endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(0);
		var _smt  = getInputData(2);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _amo = array_length(anchors);
		var ox, oy, nx, ny;
		var _p = new __vec2();
		
		draw_set_color(COLORS._main_icon);
		for( var i = 0, n = _amo; i < n; i++ ) {
			var _a = anchors[i];
			
			if(_smt) {
				var _smp = 1 / 32;
				for( var j = 0; j <= 1; j += _smp ) {
					_p = getPointRatio(j, i, _p);
					
					nx = _x + _p.x * _s;
					ny = _y + _p.y * _s;
							
					if(j > 0) draw_line_width(ox, oy, nx, ny, 3);
							
					ox = nx;
					oy = ny;
				}
			} else {
				for( var j = 0, m = array_length(_a); j < m; j++ ) {
					nx = _x + _a[j][0] * _s;
					ny = _y + _a[j][1] * _s;
					
					if(j) draw_line_width(ox, oy, nx, ny, 3);
					
					ox = nx;
					oy = ny;
				}
			}
		}
	} #endregion
	
	static getLineCount = function() { return getInputData(1); }
	
	static getSegmentCount = function(ind = 0) { return array_safe_length(array_safe_get_fast(anchors, ind)); } 
	
	static getLength       = function(ind = 0) { return array_safe_get_fast(lengths, ind); }
	
	static getAccuLength   = function(ind = 0) { return array_safe_get_fast(lengthAccs, ind); }
	
	static getBoundary     = function(ind = 0) { return array_safe_get_fast(boundary, ind); }
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) { return getPointDistance(clamp(_rat, 0, 1) * getLength(ind), ind, out); }
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{_dist},{ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			return out;
		}
		
		var _smt = getInputData(2);
		var _a   = anchors[ind];
		var _la  = lengthAccs[ind];
		
		if(_dist == 0) {
			var _p = _a[0];
			out.x = _p[0];
			out.y = _p[1];
			
			cached_pos[? _cKey] = out.clone();
			return out;
		}
		
		var _ind = 0;
		var n    = array_length(_la);
		var _d   = _dist;
		
		for(; _ind < n; _ind++ ) {
			if(_d < _la[_ind]) break;
			_d -= _la[_ind];
		}
		
		if(_ind >= n) {
			var _p = _a[_ind];
			out.x = _p[0];
			out.y = _p[1];
			
			cached_pos[? _cKey] = out.clone();
			return out;
		}
		
		var _rat = _d / _la[_ind];
		var p0   = _a[_ind];
		var p1   = _a[_ind + 1];
			
		if(_smt) {
			var _cnt = controls[ind];
			var _c0x = _cnt[_ind][0];
			var _c0y = _cnt[_ind][1];
			var _c1x = _cnt[_ind][2];
			var _c1y = _cnt[_ind][3];
			
			var _p = eval_bezier(_rat, p0[0], p0[1], p1[0], p1[1], _c0x, _c0y, _c1x, _c1y);
			out.x = _p[0];
			out.y = _p[1];
		} else {
			out.x = lerp(p0[0], p1[0], _rat);
			out.y = lerp(p0[1], p1[1], _rat);
		}
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	} #endregion
		
	static update = function() { #region
		ds_map_clear(cached_pos);
		
		var _path = getInputData(0);
		var _amo  = getInputData(1);
		var _smt  = getInputData(2);
		
		if(_path == noone) return;
		
		#region bridge
			var _lines = _path.getLineCount();
			var _p = new __vec2();
			var _rat;
		
			anchors = array_create(_amo);
		
			for( var i = 0; i < _amo; i++ ) {
				var _a = array_create(_lines);
				_rat   = _amo == 1? 0.5 : i / (_amo - 1);
			
				for( var j = 0; j < _lines; j++ ) {
					_p    = _path.getPointRatio(clamp(_rat, 0, 0.999), j, _p);
					_a[j] = [ _p.x, _p.y ];
				}
			
				anchors[i] = _a;
			
				if(_smt) {
					var _cnt = array_create(_lines - 1);
				
					for( var j = 0; j < _lines - 1; j++ ) _cnt[j] = [ 0, 0, 0, 0 ];
				
					_cnt[0]          = [ _a[0][0],          _a[ 0][1],         _a[0][0],          _a[0][1] ];
					_cnt[_lines - 2] = [ _a[_lines - 1][0], _a[_lines - 1][1], _a[_lines - 1][0], _a[_lines - 1][1] ];
				
					for( var j = 1; j < _lines - 1; j++ ) {
						var _a0 = _a[j - 1];
						var _a1 = _a[j];
						var _a2 = _a[j + 1];
					
						var _dr  = point_direction(_a0[0], _a0[1], _a2[0], _a2[1]);
						var _ds0 = point_distance(_a1[0], _a1[1], _a0[0], _a0[1]) / 2;
						var _ds2 = point_distance(_a1[0], _a1[1], _a2[0], _a2[1]) / 2;
					
						var c0x = _a1[0] - lengthdir_x(_ds0, _dr);
						var c0y = _a1[1] - lengthdir_y(_ds0, _dr);
						var c1x = _a1[0] + lengthdir_x(_ds2, _dr);
						var c1y = _a1[1] + lengthdir_y(_ds2, _dr);
					
						_cnt[j - 1][2] = c0x;
						_cnt[j - 1][3] = c0y;
						_cnt[j][0]     = c1x;
						_cnt[j][1]     = c1y;
					}
				
					controls[i] = _cnt;
				
					var _l = 0, _la = [];
					var ox, oy, nx, ny;
				
					for( var j = 0; j < _lines - 1; j++ ) {
						var _a0  = _a[j];
						var _a1  = _a[j + 1];
						var _c0x = _cnt[j][0];
						var _c0y = _cnt[j][1];
						var _c1x = _cnt[j][2];
						var _c1y = _cnt[j][3];
					
						var _smp = 1 / 32;
						var _ll = 0;
					
						for( var k = 0; k < 1; k += _smp ) {
							var _p = eval_bezier(k, _a0[0], _a0[1], _a1[0], _a1[1], _c0x, _c0y, _c1x, _c1y);
							nx = _p[0];
							ny = _p[1];
						
							if(k > 0) _ll += point_distance(ox, oy, nx, ny);
						
							ox = nx;
							oy = ny;
						}
					
						array_push(_la, _ll);
						_l += _ll;
					}
				
					lengths[i]    = _l;
					lengthAccs[i] = _la;
				
				} else {
					var _l = 0, _la = [];
					var ox, oy, nx, ny;
			
					for( var j = 0, m = array_length(_a); j < m; j++ ) {
						nx = _a[j][0];
						ny = _a[j][1];
					
						if(j) {
							var d = point_distance(ox, oy, nx, ny);
							_l += d;
							array_push(_la, _l);
						}
				
						ox = nx;
						oy = ny;
					}
			
					lengths[i]    = _l;
					lengthAccs[i] = _la;
				}
			}
		#endregion
	} #endregion
} 