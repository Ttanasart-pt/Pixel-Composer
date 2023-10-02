function UUID_generate(length = 32) { #region
	randomize();
	static str =   "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	static month = "JFRAMJYASOND" 
	
	var _id = "";
	_id += string_char_at(str, current_year % string_length(str) + 1);	//1
	_id += string_char_at(month, current_month);						//1
	_id += string_char_at(str, current_day);							//1
	_id += string_char_at(str, current_hour);							//1
	_id += string_char_at(str, current_minute);							//1
	_id += string_char_at(str, current_second);							//1
	_id += string_lead_zero(current_time, 6);							//6
	
	repeat(length - string_length(_id)) _id += string_char_at(str, irandom_range(1, string_length(str)));
	return _id;
} #endregion

function irandom_seed(val, seed) { #region
	random_set_seed(floor(seed));
	return irandom(val);
} #endregion

function irandom_range_seed(from, to, seed) { #region
	random_set_seed(floor(seed));
	return irandom_range(from, to);
} #endregion

function random_seed(val, seed) { #region
	random_set_seed(floor(seed));
	var _s0 = random(val);
	
	random_set_seed(floor(seed) + 1);
	var _s1 = random(val);
	
	return lerp(_s0, _s1, frac(seed));
} #endregion

function random_range_seed(from, to, seed) { #region
	random_set_seed(floor(seed));
	var _s0 = random_range(from, to);
	
	random_set_seed(floor(seed) + 1);
	var _s1 = random_range(from, to);
	
	return lerp(_s0, _s1, frac(seed));
} #endregion

function random1D(seed, startRange = 0, endRange = 1) { #region
	if(startRange == endRange) return startRange;
	
	var _f = frac(seed);
	if(_f == 0) {
		random_set_seed(PROJECT.seed + seed);
		return random_range(startRange, endRange);
	}
	
	random_set_seed(PROJECT.seed + floor(seed));
	var f1 = random_range(startRange, endRange);
	
	random_set_seed(PROJECT.seed + floor(seed) + 1);
	var f2 = random_range(startRange, endRange);
	
	return lerp(f1, f2, _f);
} #endregion

function perlin1D(seed, scale = 1, octave = 1, startRange = 0, endRange = 1) { #region
	var amp = power(2., octave - 1.)  / (power(2., octave) - 1.);
	var val = 0;
	
	repeat(octave) {
		val = random1D(seed * scale) * amp;
		scale *= 2;
		amp /= 2;
	}
	
	return lerp(startRange, endRange, val);
} #endregion

function wiggle(_min = 0, _max = 1, _freq = 1, _time = 0, _seed = 0, _octave = 1) { #region
	_freq = max(1, _freq);
	
	var sdMin = floor(_time / _freq) * _freq;
	var sdMax = sdMin + _freq;
	
	var _x0 = perlin1D(PROJECT.seed + _seed + sdMin, 1, _octave);
	var _x1 = perlin1D(PROJECT.seed + _seed + sdMax, 1, _octave);
	
	var t = (_time - sdMin) / (sdMax - sdMin);
	t = -(cos(pi * t) - 1) / 2;
	var _lrp = lerp(_x0, _x1, t);
	return lerp(_min, _max, _lrp);
} #endregion

function getWiggle(_min = 0, _max = 1, _freq = 1, _time = 0, _seed = 0, startTime = noone, endTime = noone) { #region
	_freq = max(1, _freq);
	
	var sdMin = floor(_time / _freq) * _freq;
	var sdMax = sdMin + _freq;
	if(endTime) //Clip at ending
		sdMax = min(endTime, sdMax);
	
	var _x0 = (startTime != noone && sdMin <= startTime)?   0.5 : random1D(PROJECT.seed + _seed + sdMin);
	var _x1 = (endTime != noone && sdMax >= endTime)?		0.5 : random1D(PROJECT.seed + _seed + sdMax);
	
	var t = (_time - sdMin) / (sdMax - sdMin);
	t = -(cos(pi * t) - 1) / 2;
	var _lrp = lerp(_x0, _x1, t);
	return lerp(_min, _max, _lrp);
} #endregion

function wiggleMap(_seed, _freq, _length) constructor { #region
	seed = _seed;
	freq = _freq;
	len  = _length;
	amp  = 1;
	map  = array_create(_length);
	
	static generate = function() {
		gml_pragma("forceinline");
		
		for(var i = 0; i < len; i++) map[i] = wiggle(-1, 1, freq, i, seed);
	}
	
	static check = function(_amp, _freq, _seed) {
		gml_pragma("forceinline");
		
		amp = _amp;
		if(seed == _seed && freq == _freq) return;
		
		//print($"Check {seed}:{_seed}, {freq}:{_freq} ({irandom(999999)})");
		seed = _seed;
		freq = _freq;
		generate();
	}
	
	static get = function(i) { 
		gml_pragma("forceinline");
		
		if(amp == 0) return 0;
		return map[abs(i) % len] * amp; 
	}
} #endregion