if(anim == 0) {
	anim_prog = lerp_float(anim_prog, 1, 5);
	
} else if(anim == 1) {
	anim_prog = lerp_float(anim_prog, 0, 5);
	if(anim_prog == 0) instance_destroy();
}

var _h_top = clamp( text.slider_mulp + 1, 1, 2) * ui(18) * anim_prog;
var _h_bot = clamp(-text.slider_mulp + 1, 1, 2) * ui(18) * anim_prog;
var _y = y - _h_top;
var _h = h + _h_top + _h_bot;

draw_sprite_stretched_ext(THEME.textbox, 3, x, _y, w, _h, COLORS._main_icon, 1);
draw_sprite_stretched_ext(THEME.textbox, 3, x,  y, w,  h, c_white, 1);
draw_sprite_stretched_ext(THEME.textbox, 1, x, _y, w, _h, c_white, 1);

if(anim == 0) {
	draw_set_text(f_p4, fa_center, fa_bottom, text.slider_mulp == 1? COLORS._main_text_accent : COLORS._main_icon);
	draw_text(x + w / 2, y, "x10");
	
	if(text.slider_mulp >=  1) {
		draw_set_color(text.slider_mulp == 2? COLORS._main_text_accent : COLORS._main_icon);
		draw_text(x + w / 2, y - ui(18), "x100");
	}
	
	draw_set_text(f_p4, fa_center, fa_top, text.slider_mulp == -1? COLORS._main_text_accent : COLORS._main_icon);
	draw_text(x + w / 2, y + h, "x0.1");
	
	if(text.slider_mulp <= -1) {
		draw_set_color(text.slider_mulp == -2? COLORS._main_text_accent : COLORS._main_icon);
		draw_text(x + w / 2, y + h + ui(18), "x0.01");
	}
}

BLEND_ALPHA
	draw_surface_safe(text.text_surface, x + text.padding, y);
BLEND_NORMAL