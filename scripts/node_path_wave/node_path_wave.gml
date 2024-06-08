function Node_Path_Wave(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Wave Path";
	setDimension(96, 48);;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 2] = nodeValue("Amplitude", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 3] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 4] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 5].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 6] = nodeValue("Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Wiggle Amplitude", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -2, 2 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 8] = nodeValue("Wiggle Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 8);
	
	inputs[| 9] = nodeValue("Amplitude over length", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	input_display_list = [ 5, 
		["Path",	 true], 0,
		["Wave",	false], 1, 2, 9, 3, 4, 
		["Wiggle",	 true, 6], 7, 8, 
	];
	
	path = 0;
	fre  = 0; 
	amp  = 0;
	shf  = 0;
	smt  = 0;
	seed = 0;
	
	wig  = 0
	wigs = 0
	wigf = 0
		
	wig_map   = noone;
	amp_curve = noone;
	p0 = new __vec2();
	p  = new __vec2();
	p1 = new __vec2();
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_icon);
		
		var _amo = getLineCount();
		
		for( var i = 0; i < _amo; i++ ) {
			var _len = getLength(i);
			var _stp = 1 / clamp(_len * _s, 1, 64);
			var ox, oy, nx, ny;
			var _p = new __vec2();
			
			for( var j = 0; j < 1; j += _stp ) {
				_p = getPointRatio(j, i, _p);
				nx = _x + _p.x * _s;
				ny = _y + _p.y * _s;
				
				if(j > 0) draw_line_width(ox, oy, nx, ny, 3);
				
				ox = nx;
				oy = ny;
			}
		}
	} #endregion
	
	static getLineCount = function() { #region
		return struct_has(path, "getLineCount")? path.getLineCount() : 1; 
	} #endregion
	
	static getSegmentCount = function(ind = 0) { #region
		return struct_has(path, "getSegmentCount")? path.getSegmentCount(ind) : 0; 
	} #endregion
	
	static getLength = function(ind = 0) { #region
		var _fre  = fre ; _fre = max(_fre[0], _fre[1]);
		var _amo  = amp ; _amo = max(_amo[0], _amo[1]);
		
		    _fre  = max(1, abs(_fre));
		var _len  = struct_has(path, "getLength")? path.getLength(ind) : 0;
		    _len *= _fre * sqrt(abs(_amo) + 1 / _fre);
		
		return _len; 
	} #endregion
	
	static getAccuLength = function(ind = 0) { #region
		var _fre  = fre ; _fre = max(_fre[0], _fre[1]);
		var _amo  = amp ; _amo = max(_amo[0], _amo[1]);
		
		    _fre  = max(1, abs(_fre));
		var _len  = struct_has(path, "getAccuLength")? path.getAccuLength(ind) : [];
		var _mul  = _fre * sqrt(abs(_amo) + 1 / _fre);
		
		for( var i = 0, n = array_length(_len); i < n; i++ ) 
			_len[i] *= _mul;
		
		return _len; 
	} #endregion
		
	static getPointRatio = function(_rat, ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{_rat},{ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			return out;
		}
		
		var _path = path;
		var _fre  = fre ; 
		var _amp  = amp ;
		var _shf  = shf ;
		var _smt  = smt ;
		var _seed = seed + ind;
					
		var _wig  = wig ;
		var _wigs = wigs;
		var _wigf = wigf;
		
		_amp   = random_range_seed(_amp[0], _amp[1], _seed + ind);
		_shf   = random_range_seed(_shf[0], _shf[1], _seed + 1 + ind);
		_fre   = random_range_seed(_fre[0], _fre[1], _seed + 2 + ind);
		
		_fre = max(0.01, abs(_fre));
		var _t = _shf + _rat * _fre;
		
		if(_wig) {
			var _w = wiggle(_wigs[0], _wigs[1], _wigf, _t, _seed);
			_amp += _w;
		}
		
		if(is_array(_path)) {
			_path = array_safe_get_fast(_path, ind);
			ind = 0;
		}
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return out;
		
		p0 = _path.getPointRatio(clamp(_rat - 0.001, 0, 0.999999), ind, p0);
		p  = _path.getPointRatio(_rat, ind, p);
		p1 = _path.getPointRatio(clamp(_rat + 0.001, 0, 0.999999), ind, p1);
		
		var dir = point_direction(p0.x, p0.y, p1.x, p1.y) + 90;
		var prg;
		
		if(_smt) prg = cos(_t * pi * 2);
		else	 prg = (abs(frac(_t) * 2 - 1) - 0.5) * 2;
		
		if(amp_curve) prg *= amp_curve.get(_rat);
		
		out.x = p.x + lengthdir_x(_amp * prg, dir);
		out.y = p.y + lengthdir_y(_amp * prg, dir);
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static getBoundary = function(ind = 0) { #region
		return struct_has(path, "getBoundary")? path.getBoundary(ind) : new BoundingBox( 0, 0, 1, 1 ); 
	} #endregion
	
	static update = function() { #region
		ds_map_clear(cached_pos);
		path = getInputData(0);
		fre  = getInputData(1); 
		amp  = getInputData(2);
		shf  = getInputData(3);
		smt  = getInputData(4);
		seed = getInputData(5);
	
		wig  = getInputData(6);
		wigs = getInputData(7);
		wigf = getInputData(8);
		
		var _ampc = getInputData(9);
		
		amp_curve = new curveMap(_ampc, 128);
		
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_wave, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}