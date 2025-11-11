function Node_Path_Spiral(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Spiral Path";
	setDimension(96, 48);
	
	////- =Path
	
	newInput(0, nodeValue_PathNode("Path"));
	
	////- =Spiral
	
	newInput( 1, nodeValue_Float( "Frequency",  4));
	newInput( 2, nodeValue_Float( "Amplitude",  4));
	newInput( 5, nodeValue_Curve( "Amplitude Over Length",  CURVE_DEF_11));
	
	newInput( 3, nodeValue_Slider(   "Spiral",    .75, [-2,2,.01]));
	newInput( 4, nodeValue_Rotation( "Phase",      0));
	
	// input 6
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 
		["Path",    true], 0,
		["Spiral", false], 1, 2, 5, 3, 4, 
	];
	
	////- Nodes
	
	function _spiralPath(_node) : Path(_node) constructor {
		freq      = 0; 
		amplitude = 0;
		amp_curve = noone;
		spiral    = .75;
		phase     = 0;
		
		p  = new __vec2P();
		p0 = new __vec2P();
		p1 = new __vec2P();
		
		cached_pos = {};
		curr_path  = noone;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
			var hovering = false;
			
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				hovering = hovering || hv;
			}
			
			PathDrawOverlay(self, _x, _y, _s);
			
			return hovering;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()     : 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(i) : 0};
		static getBoundary     = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(i)     : new BoundingBox( 0, 0, 1, 1 )};
		
		static getLength = function(ind = 0) {
			if(!is_path(curr_path)) return 0;
			
			var _fre = freq;
			var _amp = amplitude;
			
			    _fre  = max(1, abs(_fre));
			var _len  = curr_path.getLength(ind);
			    _len *= _fre * sqrt(abs(_amp) + 1 / _fre);
			
			return _len; 
		}
		
		static getAccuLength = function(ind = 0) {
			var _fre = freq;
			var _amp = amplitude;
			
			    _fre = max(1, abs(_fre));
			var _len = is_path(curr_path)? curr_path.getAccuLength(ind) : [];
			var _mul = _fre * sqrt(abs(_amp) + 1 / _fre);
			var _lln = array_create(array_length(_len));
			
			for( var i = 0, n = array_length(_len); i < n; i++ ) 
				_lln[i] = _len[i] * _mul;
			
			return _lln; 
		}
			
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			if(!is_path(curr_path)) return out;
			var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
			if(struct_has(cached_pos, _cKey)) {
				var _p     = cached_pos[$ _cKey];
				out.x      = _p.x;
				out.y      = _p.y;
				out.weight = _p.weight;
				return out;
			}
			
			var _path = curr_path;
			var _fre  = freq;
			var _amp  = amplitude;
			if(amp_curve) _amp *= amp_curve.get(_rat);
			
			var _pha  = phase / 360;
			var _spi  = spiral;
			
			p0 = _path.getPointRatio( clamp(_rat - 0.001, 0, 0.999999), ind, p0 );
			p  = _path.getPointRatio(       _rat,                       ind, p  );
			p1 = _path.getPointRatio( clamp(_rat + 0.001, 0, 0.999999), ind, p1 );
			
			var dir = point_direction(p0.x, p0.y, p1.x, p1.y);
			var prg = (_pha + _rat * _fre) * pi * 2;
			
			var px = p.x;
			var py = p.y;
			
			var prg0 = sin(prg) * _amp;
			var prg1 = cos(prg) * _amp * _spi;
			
			px += lengthdir_x(prg0, dir + 90);
			py += lengthdir_y(prg0, dir + 90);
			
			px += lengthdir_x(prg1, dir);
			py += lengthdir_y(prg1, dir);
			
			out.x = px;
			out.y = py;
			out.weight = p.weight * (.5 + cos(prg) * .5);
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		
		if(!is(_outData, _spiralPath)) 
			_outData = new _spiralPath(self);
		
		_outData.cached_pos = {};
		_outData.curr_path  = _data[0];
		
		_outData.freq      = _data[1];
		_outData.amplitude = _data[2];
		_outData.amp_curve = new curveMap(_data[5], 128);
		
		_outData.spiral    = _data[3];
		_outData.phase     = _data[4];
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_path_spiral, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}