function __random2 (_x, _y, _s) {
	random_set_seed((_x + _y) * (_x + _y + 1) / 2 + _y + _s);
    return random(1);
}

function __noise(_x, _y, _seed) {
	var fl_x = floor(_x);
	var fl_y = floor(_y);
	
	var a = __random2(fl_x + 0, fl_y + 0, _seed);
	var b = __random2(fl_x + 1, fl_y + 0, _seed);
	var c = __random2(fl_x + 0, fl_y + 1, _seed);
	var d = __random2(fl_x + 1, fl_y + 1, _seed);
	
	return lerp(lerp(a, b, _x - fl_x), lerp(c, d, _x - fl_x), _y - fl_y);
}

function perlin_noise(_x, _y, _amp, _seed) {
	var res  = 0;
	var maxx = 0;
	var mulp = 0.5;
	
	repeat(_amp) {
		res  += __noise(_x, _y, _seed) * mulp;
		maxx += mulp;
		
		_x /= 2;
		_y /= 2;
		mulp *= 0.5;
	}
	
	return res / maxx;
}