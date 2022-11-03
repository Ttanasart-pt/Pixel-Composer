function animation_curve_eval(curve, t) {
	var ch = animcurve_get_channel(curve, 0);
	return animcurve_channel_evaluate(ch, t);
}