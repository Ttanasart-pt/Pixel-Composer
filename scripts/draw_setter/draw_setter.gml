#macro draw_set_color draw_set_color_ext
#macro __draw_set_color draw_set_color

#macro draw_clear draw_clear_ext_override
#macro __draw_clear draw_clear

function draw_set_color_alpha(col, alpha = 1) { draw_set_color(col); draw_set_alpha(alpha); }

function draw_set_color_ext(col) {
	INLINE
	
	__draw_set_color(col);
	if(is_real(col)) return;
	
	var a = _color_get_alpha(col);
	draw_set_alpha(a);
}

function draw_clear_ext_override(col) {
	if(is_real(col)) {
		__draw_clear(col);
		return;
	}
	
	var a = _color_get_alpha(col);
	draw_clear_alpha(col, a);
}

function draw_set_text(font, halign, valign) {
	INLINE
	
	if(argument_count > 3) draw_set_color(argument[3]);
	if(argument_count > 4) draw_set_alpha(argument[4]);
	
	draw_set_font(font);
	draw_set_halign(halign);
	draw_set_valign(valign);
}

function draw_set_align(halign, valign) {
	INLINE
	draw_set_halign(halign); draw_set_valign(valign);
}