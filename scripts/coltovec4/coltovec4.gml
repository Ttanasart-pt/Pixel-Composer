function colToVec4(color, alpha = 1) {
	return [ color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, alpha ];
}