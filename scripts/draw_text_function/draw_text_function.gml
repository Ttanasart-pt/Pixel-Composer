function draw_text_over(_x, _y, _text) {
	BLEND_OVERRIDE;
	draw_text(_x, _y, _text);
	BLEND_NORMAL;
}

function draw_text_ext_over(_x, _y, _text, _sep, _w) {
	BLEND_OVERRIDE;
	draw_text_ext(_x, _y, _text, _sep, _w);
	BLEND_NORMAL;
}

function draw_text_add(_x, _y, _text) {
	BLEND_ADD;
	draw_text(_x, _y, _text);
	BLEND_NORMAL;
}

function draw_text_ext_add(_x, _y, _text, _sep, _w) {
	BLEND_ADD;
	draw_text_ext(_x, _y, _text, _sep, _w);
	BLEND_NORMAL;
}

function draw_text_bbox(bbox, text) {
	var ss = min(bbox.w / string_width(text), bbox.h / string_height(text));
	    ss = max(0.5, ss);
	
	draw_text_cut(bbox.xc, bbox.yc, text, bbox.w, ss);
}