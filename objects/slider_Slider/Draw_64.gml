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

draw_sprite_stretched_ext(THEME.textbox, 3, x, _y,     w, _h_top, COLORS._main_icon, 0.9);
draw_sprite_stretched_ext(THEME.textbox, 3, x,  y + h, w, _h_bot, COLORS._main_icon, 0.9);
//draw_sprite_stretched_ext(THEME.textbox, 3, x,  y, w,  h, c_white,           0.9);
draw_sprite_stretched_ext(THEME.textbox, 1, x, _y, w, _h, c_white,           1.0);

var _mulp = text.slide_int? 10 : 1;
if(key_mod_press(CTRL) && !text.slide_snap) _mulp *= 10;
if(key_mod_press(ALT))                      _mulp /= 10;

if(anim == 0) {
	draw_set_text(f_p4, fa_center, fa_bottom, text.slider_mulp == 1? COLORS._main_text_accent : COLORS._main_icon);
	draw_text(x + w / 2, y, string(10 * _mulp));
	
	if(text.slider_mulp >=  1) {
		draw_set_color(text.slider_mulp == 2? COLORS._main_text_accent : COLORS._main_icon);
		draw_text(x + w / 2, y - ui(18), string(100 * _mulp));
	}
	
	draw_set_text(f_p4, fa_center, fa_top, text.slider_mulp == -1? COLORS._main_text_accent : COLORS._main_icon);
	draw_text(x + w / 2, y + h, string(0.1 * _mulp));
	
	if(text.slider_mulp <= -1) {
		draw_set_color(text.slider_mulp == -2? COLORS._main_text_accent : COLORS._main_icon);
		draw_text(x + w / 2, y + h + ui(18), string(0.01 * _mulp));
	}
}