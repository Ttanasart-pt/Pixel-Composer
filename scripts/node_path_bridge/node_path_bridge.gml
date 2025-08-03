function Node_Path_Bridge(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Bridge Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode( "Path" ));
	newInput(4, nodeValueSeed());
	
	////- =Bridge
	
	newInput(3, nodeValue_Enum_Scroll( "Distribution", 0, [ "Uniform", "Random" ] ));
	newInput(1, nodeValue_Int(  "Amount", 4     ));
	newInput(2, nodeValue_Bool( "Smooth", false ));
	
	// inputs 5
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()});
	
	input_display_list = [ 0, 4, 
		["Bridge",  false], 3, 1, 2, 
	]
	
	////- Nodes
	
	cached_pos  = {};
	curr_path   = noone;
	curr_amount = noone;
	curr_smooth = noone;
	curr_type   = 0;
	
	#region ---- path ----
		anchors		= [];
		controls	= [];
		lengths		= [];
		lengthAccs	= [];
		boundary    = [];
		lengthTotal	= [];
	#endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
		if(curr_path && struct_has(curr_path, "drawOverlay")) 
			curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _amo = array_length(anchors);
		var ox, oy, nx, ny;
		var _p = new __vec2P();
		
		draw_set_color(COLORS._main_icon);
		for( var i = 0, n = _amo; i < n; i++ ) {
			var _a = anchors[i];
			
			if(curr_smooth) {
				var _smp = 1 / 32;
				for( var j = 0; j <= 1; j += _smp ) {
					_p = getPointRatio(j, i, _p);
					
					nx = _x + _p.x * _s;
					ny = _y + _p.y * _s;
							
					if(j > 0) draw_line(ox, oy, nx, ny);
							
					ox = nx;
					oy = ny;
				}
			} else {
				for( var j = 0, m = array_length(_a); j < m; j++ ) {
					nx = _x + _a[j][0] * _s;
					ny = _y + _a[j][1] * _s;
					
					if(j) draw_line(ox, oy, nx, ny);
					
					ox = nx;
					oy = ny;
				}
			}
		}
	}
	
	static getLineCount    = function(   ) /*=>*/ {return getInputData(1)};
	static getSegmentCount = function(i=0) /*=>*/ {return array_safe_length(array_safe_get_fast(anchors, i))}; 
	static getLength       = function(i=0) /*=>*/ {return array_safe_get_fast( lengths,    i )};
	static getAccuLength   = function(i=0) /*=>*/ {return array_safe_get_fast( lengthAccs, i )};
	static getBoundary     = function(i=0) /*=>*/ {return array_safe_get_fast( boundary,   i )};
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) { return getPointDistance(clamp(_rat, 0, 1) * getLength(ind), ind, out); }
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{string_format(_dist, 0, 6)},{ind}";
		
		var _a   = anchors[ind];
		var _la  = lengthAccs[ind];
		
		if(_dist == 0) {
			var _p = _a[0];
			out.x  = _p[0];
			out.y  = _p[1];
			out.weight = _p[2];
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
		
		var _ind = 0;
		var n    = array_length(_la);
		
		for(; _ind < n; _ind++ ) if(_dist < _la[_ind]) break;
		
		if(_ind >= n) {
			var _p = _a[_ind];
			out.x = _p[0];
			out.y = _p[1];
			out.weight = _p[2];
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
		
		var _d   = _ind == 0? _dist : _dist - _la[_ind - 1];
		var _rat = _d / (_la[_ind] - (_ind == 0? 0 : _la[_ind - 1]));
		var p0   = _a[_ind];
		var p1   = _a[_ind + 1];
		
		if(curr_smooth) {
			var _cnt = controls[ind];
			var _c0x = _cnt[_ind][0];
			var _c0y = _cnt[_ind][1];
			var _c1x = _cnt[_ind][2];
			var _c1y = _cnt[_ind][3];
			
			out.x = eval_bezier_x(_rat, p0[0], p0[1], p1[0], p1[1], _c0x, _c0y, _c1x, _c1y);
			out.y = eval_bezier_y(_rat, p0[0], p0[1], p1[0], p1[1], _c0x, _c0y, _c1x, _c1y);
			out.weight = lerp(p0[2], p1[2], _rat);
			
		} else {
			out.x = lerp(p0[0], p1[0], _rat);
			out.y = lerp(p0[1], p1[1], _rat);
			out.weight = lerp(p0[2], p1[2], _rat);
		}
		
		cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
		
		return out;
	}
		
	static update = function() {
		cached_pos  = {};
		curr_path   = getInputData(0);
		var seed    = getInputData(4);
		
		curr_type   = getInputData(3);
		curr_amount = getInputData(1);
		curr_smooth = getInputData(2);
		
		if(!is_path(curr_path)) return;
		
		var _lines = curr_path.getLineCount();
		var _p = new __vec2P();
		var _rat, _a;
		
		anchors    = array_create(curr_amount);
		lengths    = array_create(curr_amount);
		lengthAccs = array_create(curr_amount);
				
		random_set_seed(seed);
				
		for( var i = 0; i < curr_amount; i++ ) {
			_a   = array_create(_lines);
			
			switch(curr_type) {
				case 0  : _rat = curr_amount == 1? 0.5 : i / (curr_amount - 1); break;
				case 1  : _rat = random(1); break;
				default : _rat = 0;
			}
			
			for( var j = 0; j < _lines; j++ ) {
				_p    = curr_path.getPointRatio(clamp(_rat, 0, 0.999), j, _p);
				_a[j] = [ _p.x, _p.y, _p.weight ];
			}
			
			anchors[i] = _a;
		
			if(curr_smooth) {
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
						nx = eval_bezier_x(k, _a0[0], _a0[1], _a1[0], _a1[1], _c0x, _c0y, _c1x, _c1y);
						ny = eval_bezier_y(k, _a0[0], _a0[1], _a1[0], _a1[1], _c0x, _c0y, _c1x, _c1y);
						
						if(k > 0) _ll += point_distance(ox, oy, nx, ny);
					
						ox = nx;
						oy = ny;
					}
				
					_l += _ll;
					array_push(_la, _l);
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
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_path_bridge, 0, bbox);
	}
} 