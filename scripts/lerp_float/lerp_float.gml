/// @description lerp_float
/// @param from
/// @param to
/// @param speed
/// @param *precision
function lerp_float(from, to, speed) {
	if(fps < 15) return to;
    var pre = argument_count > 3? argument[3] : 0.01;

    if(abs(from - to) < pre)
        return to;
    else
        return from + (to - from) / speed * delta_time/15000;
}

function lerp_linear(from, to, speed) {
	if(fps < 15) return to;
    if(abs(from - to) < speed)
        return to;
    else
        return from + sign(to - from) * speed;
}

function lerp_angle(from, to, speed) {
	if(fps < 15) return to;
	return from + angle_difference(to, from) / speed * delta_time/15000;
}

function lerp_angle_linear(from, to, speed) {
	if(fps < 15) return to;
	if(abs(angle_difference(to, from)) < speed) return to;
	
	return from + sign(angle_difference(to, from)) * speed;
}