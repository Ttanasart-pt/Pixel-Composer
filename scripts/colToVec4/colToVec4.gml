function colToVec4(color, alpha = 1) {
	return [ color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, alpha ];
}

function colaToVec4(color) {
	return [ 
				((color & (0xFF <<  0)) >>  0) / 255, 
				((color & (0xFF <<  8)) >>  8) / 255, 
				((color & (0xFF << 16)) >> 16) / 255, 
				((color & (0xFF << 24)) >> 24) / 255, 
			];
}