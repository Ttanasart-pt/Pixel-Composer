function random2D (_x, _y, _s) {
	random_set_seed((_x + _y) * (_x + _y + 1) / 2 + _y + _s);
    return random(1);
}

function noise2D(_x, _y, _seed) {
	var fl_x = floor(_x);
	var fl_y = floor(_y);
	
	var a = random2D(fl_x + 0, fl_y + 0, _seed);
	var b = random2D(fl_x + 1, fl_y + 0, _seed);
	var c = random2D(fl_x + 0, fl_y + 1, _seed);
	var d = random2D(fl_x + 1, fl_y + 1, _seed);
	
	return lerp(lerp(a, b, _x - fl_x), 
				lerp(c, d, _x - fl_x), _y - fl_y);
}

function perlin_noise(_x, _y, _amp, _seed) {
	var res  = 0;
	var amp = power(2., _amp - 1.) / (power(2., _amp) - 1.);
	
	repeat(_amp) {
		res += noise2D(_x, _y, _seed) * amp;
		
		_x /= 2;
		_y /= 2;
		amp *= 0.5;
	}
	
	return res;
}