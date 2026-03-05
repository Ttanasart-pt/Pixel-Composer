function KeyDriver() constructor {
	index = 0;
	
	static apply = function(_time, _key, _val = undefined) {}
	
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
		
		switch(_m.typ) {
			case "linear" : return new KeyDriver_Linear().deserialize(_m);
			case "wiggle" : return new KeyDriver_Wiggle().deserialize(_m);
			case "sine"   : return new KeyDriver_Sine().deserialize(_m);
		}
		
		return undefined;
	}
}

function KeyDriver_Linear(_speed = 1) : KeyDriver() constructor {
	index = 1;
	speed = _speed;
	
	static apply = function(_time, _key, _value = undefined, _intp = 0) {
		var _dt  = _time - _key.time;
		var _val = _value == undefined? _key.value : _value;
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
	
	static apply = function(_time, _key, _value = undefined, _intp = 0) {
		var _dt  = _time - _key.time;
		var _val = _value == undefined? _key.value : _value;
		var _res = _val;
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ )
				_res[i] = _val[i] + perlin1D(_time, seed + index, frequency / 10, octave, -1, 1) * amplitude;
			
		} else
			_res = _val + perlin1D(_time, seed, frequency / 10, octave, -1, 1) * amplitude;
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "wiggle",
			sed : seed,
			oct : octave,
			fre : frequency,
			amp : amplitude,
		};
		
		return _m;
	}
	
	static deserialize = function(_m) /*=>*/ {
		seed      = _m.sed;
		octave    = _m.oct;
		frequency = _m.fre;
		amplitude = _m.amp;
		return self;
	}
}

function KeyDriver_Sine(_frequency = 4, _amplitude = 1, _phase = 0) : KeyDriver() constructor {
	index     = 3;
	frequency = _frequency;
	amplitude = _amplitude;
	phase     = _phase;
	
	static apply = function(_time, _key, _value = undefined, _intp = 0) {
		var _dt   = _time - _key.time;
		var _val  = _value == undefined? _key.value : _value;
		var _res  = _val;
		var _node = _key.anim.node;
		
		if(is_array(_val)) {
			_res = array_create(array_length(_val));
			
			for( var i = 0, n = array_length(_val); i < n; i++ ) {
				var w = sin((phase + _time * frequency / _node.project.animator.frames_total) * pi * 2) * amplitude;
				_res[i] = _val[i] + w;
			}
			
		} else {
			var w = sin((phase + _time * frequency / _node.project.animator.frames_total) * pi * 2) * amplitude;
			_res = _val + w;
		}
		
		return _res;
	}
	
	static serialize   = function()   /*=>*/ {
		var _m = {
			typ : "sine",
			fre : frequency,
			amp : amplitude,
			phs : phase,
		};
		
		return _m;
	}
	
	static deserialize = function(_m) /*=>*/ {
		frequency = _m.fre;
		amplitude = _m.amp;
		phase     = _m.phs;
		return self;
	}
}