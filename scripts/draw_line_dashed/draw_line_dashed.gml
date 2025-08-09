function draw_line_dashed(x0, y0, x1, y1, th = 1, dash_distance = 8, dash_shift = 0) {
	shader_set(sh_ui_line_dashed);
		shader_set_2( "worldPos",   [x0, y0]);
		shader_set_f( "direction",  degtorad(point_direction(x0, y0, x1, y1)));
		shader_set_f( "dash",       dash_distance);
		shader_set_f( "dashShift",  dash_shift);
		
		draw_line_width(x0, y0, x1, y1, th);
	shader_reset();
}

function draw_line_dashed_color(x0, y0, x1, y1, th, c0, c1, dash_distance = 8, dash_shift = 0) {
	shader_set(sh_ui_line_dashed);
		shader_set_2( "worldPos",   [x0, y0]);
		shader_set_f( "direction",  degtorad(point_direction(x0, y0, x1, y1)));
		shader_set_f( "dash",       dash_distance);
		shader_set_f( "dashShift",  dash_shift);
		
		draw_line_width_color(x0, y0, x1, y1, th, c0, c1);
	shader_reset();
}

function draw_line_dotted(x0, y0, x1, y1, radius, shift, distanceMulp = 1) {
	shader_set(sh_ui_line_dotted);
		shader_set_2( "worldPos",   [x0, y0]);
		shader_set_f( "direction",  degtorad(point_direction(x0, y0, x1, y1)));
		shader_set_f( "dott",       radius * distanceMulp * 4);
		shader_set_f( "dottShift",  shift);
		
		draw_line_width(x0, y0, x1, y1, radius * 2);
	shader_reset();
}