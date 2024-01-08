function colToVec4(color, alpha = 1) {
	var a = is_int64(color)? _color_get_alpha(color) : alpha;
	return [ _color_get_red(color), _color_get_green(color), _color_get_blue(color), a ];
}

function colaToVec4(color) {
	return [ 
				((color & (0xFF <<  0)) >>  0) / 255, 
				((color & (0xFF <<  8)) >>  8) / 255, 
				((color & (0xFF << 16)) >> 16) / 255, 
				((color & (0xFF << 24)) >> 24) / 255, 
			];
}