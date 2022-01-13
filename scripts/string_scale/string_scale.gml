function string_scale(str, w, h) {
	var ww	= string_width(str);
	var hh	= string_height(str);
	return min(w / ww, h / hh);
}