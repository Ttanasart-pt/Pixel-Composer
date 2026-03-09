global.DRIVER_TYPES = [ "None", "Linear", "Wiggle", "Sine", "Snap", "Bounce", "Elastic" ];

function KeyDriver() constructor {
	index = 0;
	
	static apply = function(_time, _key = undefined, _keyNext = undefined, _value = undefined, _ratio = .5, _anim = undefined) {}
	
	static build = function(_t) /*=>*/ {
		switch(_t) {
			case "linear"  : return new KeyDriver_Linear();
			case "wiggle"  : return new KeyDriver_Wiggle();
			case "sine"    : return new KeyDriver_Sine();
			case "snap"    : return new KeyDriver_Snap();
			case "bounce"  : return new KeyDriver_Bounce();
			case "elastic" : return new KeyDriver_Elastic();
		}
		
		return undefined;
	}
	
	static serialize   = function()   /*=>*/ {}
	static deserialize = function(_m) /*=>*/ {
		if(has(_m, "type")) { // old driver
			switch(_m.type) {
				case DRIVER_TYPE.linear : return new KeyDriver_Linear(_m.speed);
				case DRIVER_TYPE.wiggle : return new KeyDriver_Wiggle(_m.seed, _m.octave, _m.frequency, _m.amplitude);
				case DRIVER_TYPE.sine :   return new KeyDriver_Sine(_m.frequency, _m.amplitude, _m.phase);
			}
			
			return undefined;
		}
		
		var _d = build(_m.typ);
		return _d == undefined? undefined : _d.deserialize(_m);
	}
}

function KeyDriver_Linear(_speed = 1) : KeyDriver() constructor {
	index = 1;
	speed = _speed;
	
	static apply = function(_time, _key = undefined, _keyNext = undefined, _value = undefined, _ratio = .5, _anim = undefined) {
		var _dt  = _time - _key.time;
		var _val = _value ?? _key.value;
		var _res = _val;
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ )
				_res[i] = _val[i] + _time * speed;
			
		} else
			_res = _val + _time * speed;
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "linear",
			spd : speed,
		};
		
		return _m;
	}
	static deserialize = function(_m) /*=>*/ {
		speed = _m.spd;
		return self;
	}
}

function KeyDriver_Wiggle(_seed = seed_random(6), _octave = 2, _frequency = 4, _amplitude = 1) : KeyDriver() constructor {
	index     = 2;
	seed      = _seed;
	octave    = _octave;
	frequency = _frequency;
	amplitude = _amplitude;
	sep_axis  = false;
	smooth    = 0;
	
	static apply = function(_time, _key = undefined, _keyNext = undefined, _value = undefined, _ratio = .5, _anim = undefined) {
		var _dt  = _time - _key.time;
		var _val = _value ?? _key.value;
		var _res = _val;
		
		var _inf = 1;
		
		if(smooth > 0) {
		    // _inf = 1 - abs(_ratio - .5) / .5;
		    _inf = min(1, 2 * _ratio / smooth, 2 * (1 - _ratio) / smooth);
		    _inf = smoothstep(_inf);
		}
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ ) {
				var w = perlin1D(_time, seed + sep_axis * i, frequency / 10, octave, -1, 1) * amplitude;
				_res[i] = _val[i] + w * _inf;
			}
			
		} else {
			var w = perlin1D(_time, seed, frequency / 10, octave, -1, 1) * amplitude;
			_res = _val + w * _inf;
		}
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "wiggle",
			sed : seed,
			oct : octave,
			fre : frequency,
			amp : amplitude,
			sep : sep_axis,
			smt : smooth, 
		};
		
		return _m;
	}
	static deserialize = function(_m) /*=>*/ {
		seed      = _m.sed;
		octave    = _m.oct;
		frequency = _m.fre;
		amplitude = _m.amp;
		sep_axis  = _m[$ "sep"] ?? sep_axis;
		smooth    = _m[$ "smt"] ?? smooth;
		
		return self;
	}
}

function KeyDriver_Sine(_frequency = 4, _amplitude = 1, _phase = 0) : KeyDriver() constructor {
	index     = 3;
	frequency = _frequency;
	amplitude = _amplitude;
	phase     = _phase;
	smooth    = 0;
	
	static apply = function(_time, _key = undefined, _keyNext = undefined, _value = undefined, _ratio = .5, _anim = undefined) {
		var _dt   = _time - _key.time;
		var _val  = _value ?? _key.value;
		var _res  = _val;
		var _node = _key.anim.node;
		
		var _inf = 1;
		
		if(smooth > 0) {
		    // _inf = 1 - abs(_ratio - .5) / .5;
		    _inf = min(1, 2 * _ratio / smooth, 2 * (1 - _ratio) / smooth);
		    _inf = smoothstep(_inf);
		}
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ ) {
				var w = sin((phase + _time * frequency / _node.project.animator.frames_total) * pi * 2) * amplitude;
				_res[i] = _val[i] + w * _inf;
			}
			
		} else {
			var w = sin((phase + _time * frequency / _node.project.animator.frames_total) * pi * 2) * amplitude;
			_res = _val + w * _inf;
		}
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "sine",
			fre : frequency,
			amp : amplitude,
			phs : phase,
			smt : smooth, 
		};
		
		return _m;
	}
	static deserialize = function(_m) /*=>*/ {
		frequency = _m.fre;
		amplitude = _m.amp;
		phase     = _m.phs;
		smooth    = _m[$ "smt"] ?? smooth;
		
		return self;
	}
}

function KeyDriver_Snap() : KeyDriver() constructor {
	index     = 4;
	snapSize  = 1;
	
	static apply = function(_time, _key = undefined, _keyNext = undefined, _value = undefined, _ratio = .5, _anim = undefined) {
		var _dt   = _time - _key.time;
		var _val  = _value ?? _key.value;
		var _res  = _val;
		var _node = _key.anim.node;
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ )
				_res[i] = value_snap(_val[i], snapSize);
			
		} else
			_res = value_snap(_res, snapSize);
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "snap",
			snp : snapSize,
		};
		
		return _m;
	}
	static deserialize = function(_m) /*=>*/ {
		snapSize = _m.snp;
		
		return self;
	}
}

function KeyDriver_Bounce(_amount = 3, _amplitude = .5, _steepness = 2) : KeyDriver() constructor {
	index     = 5;
	amount    = _amount;
	amplitude = _amplitude;
	steepness = _steepness;
	
	total_amp = 0;
	total_nor = 1;
	
	static init = function() {
		total_amp = 0;
	    var ampp  = 1;
	    for (var i = 0; i < amount; i++) {
	        total_amp += i? ampp : .5;
	        ampp *= amplitude;
	    }
	    total_nor = 1 / total_amp;
	}
	
	static easeOutBounce = function(_x, _ease) {
	    if(_x < .5 * total_nor) {
	    	var _t = _x / (.5 * total_nor);
	    	return 1 - (1 - power(_t, steepness)) * (1 - _ease);
	    }
	    
	    var ampp = 1;
	    var op   = 0;
	    for (var i = 0; i < amount; i++) {
	    	var np = op + (i? ampp : .5) * total_nor;
	    	if(_x >= op && _x < np) {
	    		var _t = (_x - op) / (np - op);
	    		
	    		if(_t < .5) return 1 - (1 - power(1 - _t * 2, steepness)) * (1 - _ease);
	    		return 1 - (1 - power((_t - .5) * 2, steepness)) * (1 - _ease);
	    	} 
	    	
	    	ampp *= amplitude;
	    	op = np;
	    }
	    
	    return 1;
	}
	
	static apply = function(_time, _key = undefined, _keyNext = undefined, _value = undefined, _ratio = .5, _anim = undefined) {
		if(_key == undefined || _keyNext == undefined) return _value;
		
		var _dt   = _time - _key.time;
		var _val  = _value ?? _key.value;
		var _res  = _val;
		var _ease = _anim.interpolate(_key, _keyNext, _ratio);
		
		var _v0 = _key.value;
		var _v1 = _keyNext.value;
		var _t  = easeOutBounce(_ratio, _ease);
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ )
				_res[i] = lerp(_v0[i], _v1[i], _t);
			
		} else
			_res = lerp(_v0, _v1, _t);
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "bounce",
			amo : amount,
			amp : amplitude,
			stp : steepness,
		};
		
		return _m;
	}
	static deserialize = function(_m) /*=>*/ {
		amount    = _m.amo;
		amplitude = _m.amp;
		steepness = _m[$ "stp"] ?? steepness;
		
		init();
		return self;
	}
}

function KeyDriver_Elastic(_amount = 3, _amplitude = .5, _steepness = 2) : KeyDriver() constructor {
	index     = 6;
	amount    = _amount;
	amplitude = _amplitude;
	steepness = _steepness;
	
	total_amp = 0;
	total_nor = 1;
	
	static init = function() {
		total_amp = 0;
	    var ampp  = 1;
	    for (var i = 0; i < amount; i++) {
	        total_amp += i? ampp : .5;
	        ampp *= amplitude;
	    }
	    total_nor = 1 / total_amp;
	}
	
	static easeOutElastic = function(_x, _ease) {
	    if(_x < .5 * total_nor) {
	    	var _t = _x / (.5 * total_nor);
	    	return 1 - (1 - power(_t, steepness)) * (1 - _ease);
	    }
	    
	    var ampp = 1;
	    var op   = 0;
	    for (var i = 0; i < amount; i++) {
	    	var np = op + (i? ampp : .5) * total_nor;
	    	if(_x >= op && _x < np) {
	    		var _t = (_x - op) / (np - op);
	    		var _e = 0;
	    		
	    		if(_t < .5) _e = (1 - power(1 - _t * 2, steepness)) * (1 - _ease);
	    		else        _e = (1 - power((_t - .5) * 2, steepness)) * (1 - _ease);
	    		
	    		return i % 2? 1 + _e : 1 - _e;
	    	} 
	    	
	    	ampp *= amplitude;
	    	op = np;
	    }
	    
	    return 1;
	}
	
	static apply = function(_time, _key = undefined, _keyNext = undefined, _value = undefined, _ratio = .5, _anim = undefined) {
		if(_key == undefined || _keyNext == undefined) return _value;
		
		var _dt   = _time - _key.time;
		var _val  = _value ?? _key.value;
		var _res  = _val;
		var _ease = _anim.interpolate(_key, _keyNext, _ratio);
		
		var _v0 = _key.value;
		var _v1 = _keyNext.value;
		var _t  = easeOutElastic(_ratio, _ease);
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ )
				_res[i] = lerp(_v0[i], _v1[i], _t);
			
		} else
			_res = lerp(_v0, _v1, _t);
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "elastic",
			amo : amount,
			amp : amplitude,
			stp : steepness,
		};
		
		return _m;
	}
	static deserialize = function(_m) /*=>*/ {
		amount    = _m.amo;
		amplitude = _m.amp;
		steepness = _m[$ "stp"] ?? steepness;
		
		init();
		return self;
	}
}
