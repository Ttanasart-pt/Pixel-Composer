function draw_rectangle_width(x0, y0, x1, y1, th = 1) {
	draw_line_width(x0 - th / 2, y0, x1 + th / 2, y0, th);
	draw_line_width(x0 - th / 2, y1, x1 + th / 2, y1, th);
	
	draw_line_width(x0, y0 - th / 2, x0, y1 + th / 2, th);
	draw_line_width(x1, y0 - th / 2, x1, y1 + th / 2, th);
}

function draw_rectangle_dashed(x0, y0, x1, y1, th = 1, dash = 8, shift = 0) {
	shader_set(sh_ui_line_dashed);
		shader_set_2( "worldPos",   [x0, y0]);
		shader_set_f( "dash",       dash);
		shader_set_f( "dashShift",  shift);
		
		shader_set_f( "direction",  degtorad(0));
		draw_line_width(x0 - th / 2, y0, x1 + th / 2, y0, th);
		draw_line_width(x0 - th / 2, y1, x1 + th / 2, y1, th);
		
		shader_set_f( "direction",  degtorad(90));
		draw_line_width(x0, y0 - th / 2, x0, y1 + th / 2, th);
		draw_line_width(x1, y0 - th / 2, x1, y1 + th / 2, th);
	shader_reset();
}

function draw_rectangle_dashed_bg(x0, y0, x1, y1, th = 1, dash = 8, shift = 0, _bg = c_black, _fg = c_white) {
	draw_set_color(_bg);
	draw_line_width(x0 - th / 2, y0, x1 + th / 2, y0, th);
	draw_line_width(x0 - th / 2, y1, x1 + th / 2, y1, th);
	
	draw_line_width(x0, y0 - th / 2, x0, y1 + th / 2, th);
	draw_line_width(x1, y0 - th / 2, x1, y1 + th / 2, th);
	
	draw_set_color(_fg);
	shader_set(sh_ui_line_dashed);
		shader_set_2( "worldPos",   [x0, y0]);
		shader_set_f( "dash",       dash);
		shader_set_f( "dashShift",  shift);
		
		shader_set_f( "direction",  degtorad(0));
		draw_line_width(x0 - th / 2, y0, x1 + th / 2, y0, th);
		
		shader_set_f( "direction",  degtorad(180));
		draw_line_width(x0 - th / 2, y1, x1 + th / 2, y1, th);
		
		shader_set_f( "direction",  degtorad(90));
		draw_line_width(x0, y0 - th / 2, x0, y1 + th / 2, th);
		
		shader_set_f( "direction",  degtorad(270));
		draw_line_width(x1, y0 - th / 2, x1, y1 + th / 2, th);
	shader_reset();
}
