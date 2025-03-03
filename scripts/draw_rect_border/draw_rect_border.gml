function draw_rectangle_border(x1, y1, x2, y2, thick) {
	INLINE
	draw_line_width(x1 - thick / 2, y1, x2 + thick / 2, y1, thick);
	draw_line_width(x1 - thick / 2, y2, x2 + thick / 2, y2, thick);
	draw_line_width(x1, y1 - thick / 2, x1, y2 + thick / 2, thick);
	draw_line_width(x2, y1 - thick / 2, x2, y2 + thick / 2, thick);
}

function ui_rect(        x1, y1, x2, y2, color, alpha = 1) { INLINE draw_sprite_stretched_ext(THEME.box_r2, 1, x1, y1, x2 - x1, y2 - y1, color, 1); }
function ui_rect_wh(     x1, y1,  w,  h, color, alpha = 1) { INLINE draw_sprite_stretched_ext(THEME.box_r2, 1, x1, y1, w, h, color, 1);             }
function ui_fill_rect(   x1, y1, x2, y2, color, alpha = 1) { INLINE draw_sprite_stretched_ext(THEME.box_r2, 0, x1, y1, x2 - x1, y2 - y1, color, 1); }
function ui_fill_rect_wh(x1, y1,  w,  h, color, alpha = 1) { INLINE draw_sprite_stretched_ext(THEME.box_r2, 0, x1, y1, w, h, color, 1);             }

function draw_rectangle_points(x0, y0, x1, y1, x2, y2, x3, y3, _out = false) {
	draw_triangle(x0, y0, x1, y1, x2, y2, _out);
	draw_triangle(x1, y1, x2, y2, x3, y3, _out);
}