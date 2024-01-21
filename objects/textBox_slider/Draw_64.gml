/// @description 
if(tb == noone) exit;

if(slide_da == -1) {
	var _dist = point_distance(slide_dx, slide_dy, mouse_mx, mouse_my);
	var _dirr = point_direction(slide_dx, slide_dy, mouse_mx, mouse_my);
	
	if(_dist > 8) {
		     if(_dirr <  45) slide_da = 0;
		else if(_dirr < 135) slide_da = 1;
		else if(_dirr < 225) slide_da = 0;
		else if(_dirr < 315) slide_da = 1;
		else                 slide_da = 0;
	}
	
	tb = noone;
	exit;
}

tb_de = 1;

MOUSE_BLOCK = true;

if(mouse_check_button_pressed(mb_right)) {
	tb._input_text = string_real(tb.slide_sv);
	tb.apply();
	tb.sliding = false;
	tb.deactivate();
	
	UNDO_HOLDING = false;
	tb = noone;
	exit;
}

var _s = tb.slide_speed;

if(!MOUSE_WRAPPING) {
	var _adx = mouse_mx - slide_dx;
	var _ady = slide_dy - mouse_my;
	
	var sc = 10;
	if(key_mod_press(CTRL)) _s *= sc;
	if(key_mod_press(ALT))  _s /= sc;
	
	var spd = (slide_da? _ady : _adx) * _s;
	    val = value_snap(tb.slide_sv + spd, _s);
	if(tb.slide_int)			val = round(val);
	if(tb.slide_range != noone) val = clamp(val, tb.slide_range[0], tb.slide_range[1]);
	
	var _stp_sz = 50 * _s;
	var _stp_fl = round(val / _stp_sz) * _stp_sz;
	var _stp_md = val - _stp_fl;
	
	draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text);
	
	var _tw = 48;
	for( var i = -2; i <= 2; i++ ) {
		var _v = _stp_fl + i * _stp_sz;
		_tw = max(_tw, string_width(_v) + 24);
	}
	
	var _snp_s = 50 * _s;
	var _snp_v = round(val / _snp_s) * _snp_s;
	if(abs(val - _snp_v) < 5 * _s)
		val = _snp_v;
	
	if(slide_da) {
		var _val_y = slide_dy - (val - tb.slide_sv) / _s;
		
		var _sdw = _tw;
		var _sdh = 256;
		var _sdx = slide_dx - _sdw / 2;
		var _sdy = _val_y   - _sdh / 2;
		
		draw_sprite_stretched_ext(THEME.textbox_number_slider, 0, _sdx, _sdy, _sdw, _sdh, COLORS.panel_inspector_group_bg, 1);
		
		for( var i = -2; i <= 2; i++ ) {
			var _v = _stp_fl + i * _stp_sz;
			
			draw_set_color(_v == tb.slide_sv? COLORS._main_accent : COLORS._main_text);
			draw_set_alpha(0.4 - abs(i) * 0.1);
			draw_text(slide_dx, slide_dy - (_v - tb.slide_sv) / _s, _v);
		}
		
		draw_set_color(val == tb.slide_sv? COLORS._main_accent : COLORS._main_text);
		draw_set_alpha(1);
		draw_text(slide_dx, _val_y, val);
	} else {
		var _val_x = slide_dx + (val - tb.slide_sv) / _s;
		
		var _sdw = 240;
		var _sdh = 48;
		var _sdx = _val_x   - _sdw / 2;
		var _sdy = slide_dy - _sdh / 2;
		
		draw_sprite_stretched_ext(THEME.textbox_number_slider, 0, _sdx, _sdy, _sdw, _sdh, COLORS.panel_inspector_group_bg, 1);
		
		for( var i = -2; i <= 2; i++ ) {
			var _v = _stp_fl + i * _stp_sz;
			
			draw_set_color(_v == tb.slide_sv? COLORS._main_accent : COLORS._main_text);
			draw_set_alpha(0.4 - abs(i) * 0.1);
			draw_text(slide_dx + (_v - tb.slide_sv) / _s, slide_dy, _v);
		}
		
		draw_set_color(val == tb.slide_sv? COLORS._main_accent : COLORS._main_text);
		draw_set_alpha(1);
		draw_text(_val_x, slide_dy, val);
	}
					
	tb._input_text = string_real(val);
	if(tb.apply()) UNDO_HOLDING = true;
}
				
if(MOUSE_WRAPPING) {
	if(slide_da) slide_dy = mouse_my + (val - tb.slide_sv) / _s;
	else         slide_dx = mouse_mx - (val - tb.slide_sv) / _s;
}
				
setMouseWrap();
tb = noone;