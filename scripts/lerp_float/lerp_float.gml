function lerp_float(from, to, speed, pre = 0.01) {
	if(fps < 15) return to;

    if(abs(from - to) < pre) return to;
    return from + (to - from) * (1 - power(1 - 1 / speed, delta_time / 1000000 * game_get_speed(gamespeed_fps)));
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
	return from + angle_difference(to, from) * (1 - power(1 - 1 / speed, delta_time / 1000000 * game_get_speed(gamespeed_fps)));
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