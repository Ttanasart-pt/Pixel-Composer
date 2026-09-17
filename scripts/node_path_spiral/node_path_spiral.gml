function Node_Path_Spiral(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Spiral Path";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Path
	newInput( 0, nodeValue_Path(  "Path"               ));
	newInput( 6, nodeValue_Range( "Range",       [0,1] ));
	newInput( 7, nodeValue_Bool(  "Clamp Curve", false ));
	newInput( 8, nodeValue_Bool(  "Loop",        false ));
	
	////- =Spiral
	newInput( 1, nodeValue_Float( "Frequency",   4     ));
	newInput( 2, nodeValue_Float( "Amplitude",   4     )).setCurvable( 5, CURVE_DEF_11);
	
	newInput( 3, nodeValue_Slider(   "Spiral",  .75, [-2,2,.01] ));
	newInput( 4, nodeValue_Rotation( "Phase",    0     ));
	
	newInput(12, nodeValue_EButton(  "Direction",    0, [ "Path Normal", "Fixed" ] ));
	newInput(13, nodeValue_Range(    "Angle",       [90,90], true )).setCurvable(14);
	
	////- =Weight
	newInput( 9, nodeValue_Bool(    "Use Weight",  false ));
	newInput(10, nodeValue_EScroll( "Weight Mode",  0, [ "Replace", "Additive", "Multiplicative" ] ));
	newInput(11, nodeValue_Range(   "Range",       [0,1] ));
	// 15
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 
		[ "Path",    true    ],  0,  6,  7,  8, 
		[ "Spiral", false    ],  1,  2,  5,  3,  4, 12, 13, 14, 
		[ "Weight",  true, 9 ], 10, 11, 
	];
	
	////- Nodes
	
	function _spiralPath(_node) : Path(_node) constructor {
		loop  = false;
		range = [ 0,1 ];
		range_clamp = false;
		
		freq      = 0; 
		amplitude = 0;
		amp_curve = noone;
		spiral    = .75;
		phase     = 0;
		
		dirType  = 0;
		dirRange = [0,0];
		dirCurve = undefined;

		wei    = false;
		weiMod = 0;
		weiRng = [0,1];
		
		p  = new __vec2P();
		p0 = new __vec2P();
		p1 = new __vec2P();
		
		cached_pos = {};
		curr_path  = noone;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
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
			
			if(_rat < range[0] || _rat > range[1]) {
				p = _path.getPointRatio(_rat, ind, p);
				out.x = p.x;
				out.y = p.y;
				out.weight = p.weight;
				
				cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
				return out;
			}
			
			var _fre  = freq;
			var _amp  = amplitude;
			if(amp_curve) {
				var _crat = range_clamp? (_rat - range[0]) / (range[1] - range[0]) : _rat;
				_amp *= amp_curve.get(_crat);
			}
			
			var _pha  = phase / 360;
			var _spi  = spiral;
			
			if(loop) {
				p0 = _path.getPointRatio( pfract(_rat - .01), ind, p0 );
				p  = _path.getPointRatio( pfract(_rat      ), ind, p  );
				p1 = _path.getPointRatio( pfract(_rat + .01), ind, p1 );
				
			} else {
				_rat = clamp(_rat, 0., 0.99);
				p0 = _path.getPointRatio( clamp(_rat - .01, 0, .99), ind, p0 );
				p  = _path.getPointRatio( clamp(_rat      , 0, .99), ind, p  );
				p1 = _path.getPointRatio( clamp(_rat + .01, 0, .99), ind, p1 );
				
			}
			
			var dir;
			
			switch(dirType) {
				case 0 :
					if(loop) {
						p0 = _path.getPointRatio( pfract(_rat - .01), ind, p0 );
						p  = _path.getPointRatio( pfract(_rat      ), ind, p  );
						p1 = _path.getPointRatio( pfract(_rat + .01), ind, p1 );
						
					} else {
						_rat = clamp(_rat, 0., 0.99);
						p0 = _path.getPointRatio( clamp(_rat - .01, 0, .99), ind, p0 );
						p  = _path.getPointRatio( clamp(_rat      , 0, .99), ind, p  );
						p1 = _path.getPointRatio( clamp(_rat + .01, 0, .99), ind, p1 );
						
					}
					
					dir = point_direction(p0.x, p0.y, p1.x, p1.y);
					break;
					
				case 1 : 
					if(loop) {
						p = _path.getPointRatio( pfract(_rat), ind, p );
						
					} else {
						_rat = clamp(_rat, 0., 0.99);
						p = _path.getPointRatio( clamp(_rat, 0, .99), ind, p );
						
					}
					
					var t = dirCurve? dirCurve.get(_rat) : _rat;
					dir = lerp(dirRange[0], dirRange[1], t);
					break;
			}
			
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
			out.weight = p.weight;
			
			if(wei) {
				var weiVal = lerp(weiRng[0], weiRng[1], (.5 + cos(prg) * .5));
				
				switch(weiMod) {
					case 0 : out.weight  = weiVal; break;
					case 1 : out.weight += weiVal; break;
					case 2 : out.weight *= weiVal; break;
				}
			}
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _dirType  = _data[12];
			var _dirRange = _data[13];
			var _dirCurve = inputs[13].attributes.curved? new curveMap(_data[14]) : undefined;
			
			inputs[13].setVisible(_dirType == 1);
		#endregion
		
		if(!is(_outData, _spiralPath)) 
			_outData = new _spiralPath(self);
		
		_outData.cached_pos = {};
		_outData.curr_path  = _data[0];
		_outData.loop       = _data[8];
		_outData.range      = _data[6];
		_outData.range_clamp= _data[7];
		
		_outData.freq      = _data[1];
		_outData.amplitude = _data[2];
		_outData.amp_curve = new curveMap(_data[5], 128);
		
		_outData.spiral    = _data[3];
		_outData.phase     = _data[4];
		
		_outData.dirType  = _dirType;
		_outData.dirRange = _dirRange;
		_outData.dirCurve = _dirCurve;
		
		_outData.wei    = _data[ 9];
		_outData.weiMod = _data[10];
		_outData.weiRng = _data[11];
		
		return _outData;
	}
}