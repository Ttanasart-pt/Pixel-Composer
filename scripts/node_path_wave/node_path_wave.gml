function Node_Path_Wave(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Wave Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Range("Frequency", self, [ 4, 4 ], { linked : true }));
	
	newInput(2, nodeValue_Range("Amplitude", self, [ 4, 4 ], { linked : true }));
	
	newInput(3, nodeValue_Range("Shift", self, [ 0, 0 ], { linked : true }));
	
	newInput(4, nodeValue_Enum_Button("Mode", self, 0, [ "Zigzag", "Sine", "Square" ]));
	
	newInput(5, nodeValueSeed(self));
	
	newInput(6, nodeValue_Bool("Wiggle", self, false));
	
	newInput(7, nodeValue_Range("Wiggle Amplitude", self, [ -2, 2 ]));
	
	newInput(8, nodeValue_Float("Wiggle Frequency", self, 8));
	
	newInput(9, nodeValue_Curve("Amplitude over length", self, CURVE_DEF_11));
	
	newInput(10, nodeValue_Enum_Button("Post Fn", self, 0, [ "None", "Absolute", "Clamp" ]));
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 5, 
		["Path",	 true], 0,
		["Wave",	false], 1, 2, 9, 3, 4, 10, 
		["Wiggle",	 true, 6], 7, 8, 
	];
	
	function _wavePath() constructor {
		fre  = 0; 
		amp  = 0;
		shf  = 0;
		seed = 0;
		mode = 0;
		post = 0;
		
		wig  = 0
		wigs = 0
		wigf = 0
			
		wig_map   = noone;
		amp_curve = noone;
		p  = new __vec2P();
		p0 = new __vec2P();
		p1 = new __vec2P();
		
		cached_pos = {};
		curr_path  = noone;
		is_path    = false;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
			if(curr_path && struct_has(curr_path, "drawOverlay")) 
				curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
			draw_set_color(COLORS._main_icon);
			var _amo = getLineCount();
			for( var i = 0; i < _amo; i++ ) {
				var _len = getLength(i);
				var _stp = 1 / clamp(_len * _s, 1, 64);
				
				var ox, oy, nx, ny;
				
				for( var j = 0; j < 1; j += _stp ) {
					p = getPointRatio(j, i, p);
					nx = _x + p.x * _s;
					ny = _y + p.y * _s;
					
					if(j > 0) draw_line_width(ox, oy, nx, ny, 1);
					
					ox = nx;
					oy = ny;
				}
			}
		}
		
		static getLineCount    = function(   ) /*=>*/ {return is_path? curr_path.getLineCount()     : 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path? curr_path.getSegmentCount(i) : 0};
		static getBoundary     = function(i=0) /*=>*/ {return is_path? curr_path.getBoundary(i)     : new BoundingBox( 0, 0, 1, 1 )};
		
		static getLength = function(ind = 0) {
			if(!is_path) return 0;
			
			var _fre  = fre; _fre = max(_fre[0], _fre[1]);
			var _amo  = amp; _amo = max(_amo[0], _amo[1]);
			
			    _fre  = max(1, abs(_fre));
			var _len  = curr_path.getLength(ind);
			    _len *= _fre * sqrt(abs(_amo) + 1 / _fre);
			
			return _len; 
		}
		
		static getAccuLength = function(ind = 0) {
			var _fre  = fre; _fre = max(_fre[0], _fre[1]);
			var _amo  = amp; _amo = max(_amo[0], _amo[1]);
			
			    _fre  = max(1, abs(_fre));
			var _len  = is_path? curr_path.getAccuLength(ind) : [];
			var _mul  = _fre * sqrt(abs(_amo) + 1 / _fre);
			
			for( var i = 0, n = array_length(_len); i < n; i++ ) 
				_len[i] *= _mul;
			
			return _len; 
		}
			
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			if(!is_path) return out;
			var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
			if(struct_has(cached_pos, _cKey)) {
				var _p = cached_pos[$ _cKey];
				out.x = _p.x;
				out.y = _p.y;
				out.weight = _p.weight;
				return out;
			}
			
			var _path = curr_path;
			var _fre  = fre; 
			var _amp  = amp;
			var _shf  = shf;
			var _seed = seed + ind;
						
			var _wig  = wig;
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
			
			p0 = _path.getPointRatio(clamp(_rat - 0.001, 0, 0.999999), ind, p0);
			p  = _path.getPointRatio(_rat, ind, p);
			p1 = _path.getPointRatio(clamp(_rat + 0.001, 0, 0.999999), ind, p1);
			
			var dir = point_direction(p0.x, p0.y, p1.x, p1.y) + 90;
			var prg;
			
			switch(mode) {
				case 0 : prg = (abs(frac(_t) * 2 - 1) - 0.5) * 2; break;
				case 1 : prg = cos(_t * pi * 2);                  break;
				case 2 : prg = (frac(_t) > .5) * 2 - 1;           break;
			}
			
			switch(post) {
				case 0 : break;
				case 1 : prg = abs(prg);    break;
				case 2 : prg = max(prg, 0); break;
			}
			
			if(amp_curve) prg *= amp_curve.get(_rat);
			
			out.x = p.x + lengthdir_x(_amp * prg, dir);
			out.y = p.y + lengthdir_y(_amp * prg, dir);
			out.weight = p.weight;
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getSingleValue(0, preview_index, true);
		if(struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) { 
		
		if(!is(_outData, _wavePath)) 
			_outData = new _wavePath();
		
		_outData.cached_pos = {};
		_outData.curr_path  = _data[0];
		_outData.is_path    = struct_has(_outData.curr_path, "getPointRatio");
		
		_outData.fre  = _data[1];
		_outData.amp  = _data[2];
		_outData.shf  = _data[3];
		_outData.mode = _data[4];
		_outData.seed = _data[5];
		
		_outData.wig  = _data[6];
		_outData.wigs = _data[7];
		_outData.wigf = _data[8];
		_outData.amp_curve = new curveMap(_data[9], 128);
		
		_outData.post = _data[10];
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_wave, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}