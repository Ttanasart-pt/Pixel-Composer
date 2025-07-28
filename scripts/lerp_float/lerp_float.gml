function lerp_float(from, to, speed, pre = 0.01) {
	if(fps < 15) return to;

    if(abs(from - to) < pre) return to;
    
    var _rat = 1 - power(1 - 1 / speed, delta_time / 10_000);
    return lerp(from, to, _rat);
}

function lerp_linear(from, to, speed) {
    if(abs(from - to) < speed) return to;
    return from + sign(to - from) * speed;
}

function lerp_angle_direct(from, to, speed) {
	return from + angle_difference(to, from) * speed;
}

function lerp_angle(from, to, speed) {
	if(fps < 15) return to;
	
	var _rat = 1 - power(1 - 1 / speed, delta_time / 10000);
	return from + angle_difference(to, from) * _rat;
}

function lerp_angle_linear(from, to, speed) {
	if(abs(angle_difference(to, from)) < speed) return to;
	
	return from + sign(angle_difference(to, from)) * speed;
}

function lerp_float_angle(from, to, ratio) {
	return from + angle_difference(to, from) * ratio;
}

function lerp_color(from, to, ratio) {
	if(abs(from - to) < 1) return to;
	return merge_color(from, to, ratio);
}

function lerp_invert(val, from, to) { return (val - from) / (to - from); }

function lerp_smooth(_x) { return _x * _x * (3.0 - 2.0 * _x) }

function lerp_d3(_a, _b, _l, _p) {
	_p[0] = lerp(_a[0], _b[0], _l);
	_p[1] = lerp(_a[1], _b[1], _l);
	_p[2] = lerp(_a[2], _b[2], _l);
	return _p;
}