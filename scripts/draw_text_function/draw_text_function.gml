function draw_text_over(_x, _y, _text, scale = 1) {
	BLEND_ALPHA_MULP;
	draw_text_transformed(_x, _y, _text, scale, scale, 0);
	BLEND_NORMAL;
}

function draw_text_ext_over(_x, _y, _text, _sep, _w, scale = 1) {
	BLEND_ALPHA_MULP;
	draw_text_ext_transformed(_x, _y, _text, _sep, _w, scale, scale, 0);
	BLEND_NORMAL;
}

function draw_text_add(_x, _y, _text, scale = 1) {
	BLEND_ALPHA_MULP;
	draw_text_transformed(_x, _y, _text, scale, scale, 0);
	BLEND_NORMAL;
}

function draw_text_ext_add(_x, _y, _text, _sep, _w, scale = 1) {
	BLEND_ALPHA_MULP;
	draw_text_ext_transformed(_x, _y, _text, _sep, _w, scale, scale, 0);
	BLEND_NORMAL;
}

function draw_text_bbox(bbox, text) {
	var ss = min(bbox.w / string_width(text), bbox.h / string_height(text));
	    ss = max(0.5, ss);
	
	draw_text_cut(bbox.xc, bbox.yc, text, bbox.w, ss);
}