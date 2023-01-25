function draw_text_add(_x, _y, _text) {
	BLEND_OVERRIDE
	draw_text(_x, _y, _text);
	BLEND_NORMAL
}

function draw_text_ext_add(_x, _y, _text, _sep, _w) {
	BLEND_OVERRIDE
	draw_text_ext(_x, _y, _text, _sep, _w);
	BLEND_NORMAL
}