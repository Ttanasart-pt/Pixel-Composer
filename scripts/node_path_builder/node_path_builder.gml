function Node_Path_Builder(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Builder";
	setDimension(96, 48);;
	
	#region ---- path ----
		path_loop    = false;
		anchors		 = [];
		segments     = [];
		lengths		 = [];
		lengthAccs	 = [];
		lengthTotal	 = 0;
		boundary     = new BoundingBox();
	
		cached_pos = ds_map_create();
		
		lines = [];
	#endregion
	
	inputs[| 0] = nodeValue("Point array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setVisible(true, true)
		.setArrayDepth(2);
	
	inputs[| 1] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		draw_set_color(COLORS._main_accent);
		
		if(!array_empty(anchors)) {
			draw_set_color(COLORS._main_accent);
			
			for( var i = 0, n = array_length(segments); i < n; i++ ) { #region draw path
				var _seg = segments[i];
				var _ox  = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
					
				for( var j = 0, m = array_length(_seg); j < m; j++ ) {
					_nx = _x + _seg[j][0] * _s;
					_ny = _y + _seg[j][1] * _s;
						
					if(j) draw_line_width(_ox, _oy, _nx, _ny, 1);
					
					_ox = _nx;
					_oy = _ny;
				}
			} #endregion
			
			#region draw anchor
				for(var i = 0; i < array_length(anchors); i++) {
					var _a   = anchors[i];
					var xx   = _x + _a[0] * _s;
					var yy   = _y + _a[1] * _s;
					
					draw_sprite_colored(THEME.anchor_selector, 0, xx, yy);
				}
			#endregion
		}
		
		if(inputs[| 0].value_from != noone)
			inputs[| 0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static updateLength = function() { #region
		boundary     = new BoundingBox();
		segments     = [];
		lengths      = [];
		lengthAccs   = [];
		lengthTotal  = 0;
		
		var _index  = 0;
		var sample  = PREFERENCES.path_resolution;
		var ansize  = array_length(anchors);
		if(ansize < 2) return;
		
		var con = path_loop? ansize : ansize - 1;
		
		for(var i = 0; i < con; i++) {
			var _a0 = anchors[(i + 0) % ansize];
			var _a1 = anchors[(i + 1) % ansize];
			
			var l = 0, _ox = 0, _oy = 0, _nx = 0, _ny = 0, p = 0;
			var sg = array_create(sample);
			
			for(var j = 0; j <= sample; j++) {
				p = eval_bezier(j / sample, _a0[0],  _a0[1], _a1[0],  _a1[1], 
				                            _a0[0] + _a0[4], _a0[1] + _a0[5], 
											_a1[0] + _a1[2], _a1[1] + _a1[3]);
				sg[j] = p;
				_nx   = p[0];
				_ny   = p[1];
				
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
		
		var ansize = ds_list_size(inputs) - input_fix_len;
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
			var _p = eval_bezier(_t, _a0[0], _a0[1], _a1[0], _a1[1], _a0[0] + _a0[4], _a0[1] + _a0[5], _a1[0] + _a1[2], _a1[1] + _a1[3]);
			out.x  = _p[0];
			out.y  = _p[1];
			
			cached_pos[? _cKey] = out.clone();
			return out;
		}
		
		return out;
	} #endregion
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { #region
		var pix = (path_loop? frac(_rat) : clamp(_rat, 0, 0.99)) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	} #endregion
	
	static update = function() { #region
		ds_map_clear(cached_pos);
		
		var _anc  = getInputData(0);
		path_loop = getInputData(1);
		
		anchors   = array_create(array_length(_anc));
		
		for (var i = 0, n = array_length(_anc); i < n; i++) {
			var _a = _anc[i];
			
			for(var j = 0; j < 7; j++)
				anchors[i][j] = array_safe_get(_a, j, 0);
		}
		
		updateLength();
		
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_builder, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}