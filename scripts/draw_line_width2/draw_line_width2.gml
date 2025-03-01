function draw_line_width2(x0, y0, x1, y1, w0, w1, cap = false, c0 = noone, c1 = noone) {
	var aa = point_direction(x0, y0, x1, y1) + 90;
	var _x0 = x0 + lengthdir_x(w0 / 2, aa);
	var _y0 = y0 + lengthdir_y(w0 / 2, aa);
	var _x1 = x0 + lengthdir_x(w0 / 2, aa + 180);
	var _y1 = y0 + lengthdir_y(w0 / 2, aa + 180);
	var _x2 = x1 + lengthdir_x(w1 / 2, aa);
	var _y2 = y1 + lengthdir_y(w1 / 2, aa);
	var _x3 = x1 + lengthdir_x(w1 / 2, aa + 180);
	var _y3 = y1 + lengthdir_y(w1 / 2, aa + 180);
	
	c0 = c0 == noone? draw_get_color() : c0;
	c1 = c1 == noone? draw_get_color() : c1;
	
	draw_primitive_begin(pr_trianglestrip);
		draw_vertex_color(_x0, _y0, c0, 1);
		draw_vertex_color(_x1, _y1, c0, 1);
		draw_vertex_color(_x2, _y2, c1, 1);
		draw_vertex_color(_x3, _y3, c1, 1);
	draw_primitive_end();
	
	if(cap && w0 / 2 - 1 > 0) {
		draw_set_color(c0); draw_circle(x0 - 1, y0 - 1, w0 / 2 - 1, 0);
		draw_set_color(c1); draw_circle(x1 - 1, y1 - 1, w1 / 2 - 1, 0);
	}
}

function draw_line_width2_angle(x0, y0, x1, y1, w0, w1, a0 = 0, a1 = 0, _oc = c_white, _nc = c_white) {
	var _d0x = lengthdir_x(w0 / 2, a0);
	var _d0y = lengthdir_y(w0 / 2, a0);	
	var _d1x = lengthdir_x(w1 / 2, a1);
	var _d1y = lengthdir_y(w1 / 2, a1);
	
	var _x0 = x0 + _d0x;
	var _y0 = y0 + _d0y;
	var _x1 = x1 + _d1x;
	var _y1 = y1 + _d1y;
	
	//draw_set_color(c_red);
	draw_vertex_color( x0,  y0, _oc, 1);
	draw_vertex_color( x1,  y1, _nc, 1);
	draw_vertex_color(_x0, _y0, _oc, 1);
	draw_vertex_color(_x1, _y1, _nc, 1);
	
	var _x0 = x0 - _d0x;
	var _y0 = y0 - _d0y;
	var _x1 = x1 - _d1x;
	var _y1 = y1 - _d1y;
	
	//draw_set_color(c_blue);
	draw_vertex_color( x0,  y0, _oc, 1);
	draw_vertex_color( x1,  y1, _nc, 1);
	draw_vertex_color(_x0, _y0, _oc, 1);
	draw_vertex_color(_x1, _y1, _nc, 1);
}

function draw_line_width2_angle_width(x0, y0, x1, y1, w0, w1, a0 = 0, a1 = 0, _oc = c_white, _nc = c_white) {
	var _d0x = lengthdir_x(w0 / 2, a0);
	var _d0y = lengthdir_y(w0 / 2, a0);	
	var _d1x = lengthdir_x(w1 / 2, a1);
	var _d1y = lengthdir_y(w1 / 2, a1);
	
	var _x0 = x0 + _d0x;
	var _y0 = y0 + _d0y;
	var _x1 = x1 + _d1x;
	var _y1 = y1 + _d1y;
	
	//draw_set_color(c_red);
	draw_vertex_color( x0,  y0, _oc, 1);
	draw_vertex_color( x1,  y1, _nc, 1);
	draw_vertex_color(_x0, _y0, 0, 1);
	draw_vertex_color(_x1, _y1, 0, 1);
	
	var _x0 = x0 - _d0x;
	var _y0 = y0 - _d0y;
	var _x1 = x1 - _d1x;
	var _y1 = y1 - _d1y;
	
	//draw_set_color(c_blue);
	draw_vertex_color( x0,  y0, _oc, 1);
	draw_vertex_color( x1,  y1, _nc, 1);
	draw_vertex_color(_x0, _y0, c_black, 1);
	draw_vertex_color(_x1, _y1, c_black, 1);
}

function draw_line_cap_T(x0, y0, x1, y1, cap = 4) {
	draw_line(x0, y0, x1, y1);
	
	var _dir = point_direction(x0, y0, x1, y1);
	var _dx  = lengthdir_x(cap, _dir + 90);
	var _dy  = lengthdir_y(cap, _dir + 90);
	
	draw_line(x0 - _dx, y0 - _dy, x0 + _dx, y0 + _dy);
	draw_line(x1 - _dx, y1 - _dy, x1 + _dx, y1 + _dy);
}