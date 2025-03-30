function UUID_generate(length = 32) {
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
}

function irandom_seed(val, seed)            { random_set_seed(floor(seed)); return irandom(val);            }
function irandom_range_seed(from, to, seed) { random_set_seed(floor(seed)); return irandom_range(from, to); }

function seed_random(digits = 6) { return irandom_range(power(10, digits - 1), power(10, digits) - 1); }

function random_seed(val, seed) {
	random_set_seed(floor(seed));
	return lerp(random(val), random(val), frac(seed));
}

function random_range_seed(from, to, seed) {
	random_set_seed(floor(seed));
	return lerp(from, to, lerp(random(1), random(1), frac(seed)));
}

function random1D(seed, startRange = 0, endRange = 1) {
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
}

function __noise(_x) {
    var i = floor(_x);
    var f = frac(_x);
	
    var a = random1D(i);
    var b = random1D(i + 1);

    var u = f * f * (3.0 - 2.0 * f);

    return lerp(a, b, u);
}

function perlin1D(pos, seed, scale = 1, octave = 1, startRange = 0, endRange = 1) {
	var amp = power(2., octave - 1.)  / (power(2., octave) - 1.);
    var n = 0.;
	
	repeat(octave) {
		n += __noise(seed + pos * scale) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	
	return lerp(startRange, endRange, n);
}

function wiggle(_min = 0, _max = 1, _freq = 1, _time = 0, _seed = 0, _octave = 1) { 
	return perlin1D(_time, _seed, _freq, _octave, _min, _max); 
}

function getWiggle(_min = 0, _max = 1, _freq = 1, _time = 0, _seed = 0, startTime = noone, endTime = noone) {
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
}

function wiggleMap(_seed, _freq, _length) constructor {
	seed = _seed;
	freq = _freq;
	len  = _length;
	amp  = 1;
	map  = array_create(_length);
	shf  = 0;
	
	static generate = function() {
		INLINE
		
		for(var i = 0; i < len; i++) map[i] = wiggle(-1, 1, freq, i + shf, seed);
	}
	
	static check = function(_amp, _freq, _seed, _shf = 0) {
		INLINE
		
		amp = _amp;
		if(seed == _seed && freq == _freq && shf == _shf) return;
		
		seed = _seed;
		freq = _freq;
		shf  = _shf;
		generate();
		
		return self;
	}
	
	static get = function(i) { 
		INLINE
		
		if(amp == 0) return 0;
		return map[abs(i) % len] * amp; 
	}
}

function random_gaussian(_mean = 0, _var = 1) {
	var u1 = random(1);
	var u2 = random(1);
	var z  = sqrt(-2 * ln(u1)) * cos(2 * pi * u2);
	return _mean + z * _var;
}