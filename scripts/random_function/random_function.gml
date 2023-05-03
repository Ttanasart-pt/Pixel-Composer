function irandom_seed(val, seed) {
	random_set_seed(floor(seed));
	return irandom(val);
}

function irandom_range_seed(from, to, seed) {
	random_set_seed(floor(seed));
	return irandom_range(from, to);
}

function random_seed(val, seed) {
	random_set_seed(floor(seed));
	var _s0 = random(val);
	
	random_set_seed(floor(seed) + 1);
	var _s1 = random(val);
	
	return lerp(_s0, _s1, frac(seed));
}

function random_range_seed(from, to, seed) {
	random_set_seed(floor(seed));
	var _s0 = random_range(from, to);
	
	random_set_seed(floor(seed) + 1);
	var _s1 = random_range(from, to);
	
	return lerp(_s0, _s1, frac(seed));
}

function random1D(seed, startRange = 0, endRange = 1) {
	if(startRange == endRange) return startRange;
	
	var _f = frac(seed);
	if(_f == 0) {
		random_set_seed(GLOBAL_SEED + seed);
		return random_range(startRange, endRange);
	}
	
	random_set_seed(GLOBAL_SEED + floor(seed));
	var f1 = random_range(startRange, endRange);
	
	random_set_seed(GLOBAL_SEED + floor(seed) + 1);
	var f2 = random_range(startRange, endRange);
	
	return lerp(f1, f2, _f);
}

function perlin1D(seed, scale = 1, octave = 1, startRange = 0, endRange = 1) {
	var amp = power(2., octave - 1.)  / (power(2., octave) - 1.);
	var val = 0;
	
	repeat(octave) {
		val = sin(seed * scale) * amp;
		scale *= 2;
		amp /= 2;
	}
	
	return lerp(startRange, endRange, val);
}

function getWiggle(_min, _max, _freq, _time, seed_shift = 0, startTime = noone, endTime = noone) {
	_freq = max(1, _freq);
	
	var sdMin = floor(_time / _freq) * _freq;
	var sdMax = sdMin + _freq;
	if(endTime) //Clip at ending
		sdMax = min(endTime, sdMax);
	
	var _x0 = (startTime != noone && sdMin <= startTime)?   0.5 : random1D(GLOBAL_SEED + seed_shift + sdMin);
	var _x1 = (endTime != noone && sdMax >= endTime)?		0.5 : random1D(GLOBAL_SEED + seed_shift + sdMax);
	
	var t = (_time - sdMin) / (sdMax - sdMin);
	t = -(cos(pi * t) - 1) / 2;
	var _lrp = lerp(_x0, _x1, t);
	return lerp(_min, _max, _lrp);
}

function generateUUID() {
	randomize();
	var uuid;
	do {
		uuid = irandom(1000000000);
	} until(!ds_map_exists(NODE_MAP, uuid))
	return uuid;
}

function UUID_generate() {
	var _id = "";
	repeat(16)
		_id += chr(choose(irandom_range(48, 57), irandom_range(65, 90), irandom_range(97, 122)));
	return _id;
}