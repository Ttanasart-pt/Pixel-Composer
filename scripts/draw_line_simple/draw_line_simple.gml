function draw_line_angle(_x, _y, _ang, _len = 9999) {
	var _dx = lengthdir_x(_len, _ang);
	var _dy = lengthdir_y(_len, _ang);
	draw_line(_x - _dx, _y - _dy, _x + _dx, _y + _dy);
}

function draw_line_dashed_angle(_x, _y, _ang, _len = 9999) {
	var _dx = lengthdir_x(_len, _ang);
	var _dy = lengthdir_y(_len, _ang);
	draw_line_dashed(_x - _dx, _y - _dy, _x + _dx, _y + _dy);
}