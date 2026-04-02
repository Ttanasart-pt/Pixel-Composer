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

function draw_line_infinite(x0, y0, x1, y1) {
	var xx0 = x0 - (x1 - x0) * 10000;
	var xx1 = x1 - (x0 - x1) * 10000;
	var yy0 = y0 - (y1 - y0) * 10000;
	var yy1 = y1 - (y0 - y1) * 10000;
	
	draw_line(xx0, yy0, xx1, yy1);
}

function draw_line_width_infinite(x0, y0, x1, y1, w = 1) {
	var xx0 = x0 - (x1 - x0) * 10000;
	var xx1 = x1 - (x0 - x1) * 10000;
	var yy0 = y0 - (y1 - y0) * 10000;
	var yy1 = y1 - (y0 - y1) * 10000;
	
	draw_line_width(xx0, yy0, xx1, yy1, w);
}