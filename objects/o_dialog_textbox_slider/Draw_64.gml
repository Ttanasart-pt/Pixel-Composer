/// @description 
if(tb == noone) exit;

if(!MOUSE_WRAPPING) {
	var _adx = mouse_mx - slide_dx;
	var _ady = slide_dy - mouse_my;
	
		 if(slide_da == -1 && abs(_ady - _adx) > 8) slide_da = abs(_adx) > abs(_ady);
	else if(slide_da ==  0 && abs(_ady) > abs(_adx) + 8 && abs(mouse_my - slide_dy) > 64) slide_da = 1;
	else if(slide_da ==  1 && abs(_adx) > abs(_ady) + 8 && abs(mouse_mx - slide_dx) > 64) slide_da = 0;
	
	var _s = tb.slide_speed;
	if(key_mod_press(CTRL)) _s *= 10;
	if(key_mod_press(ALT))  _s /= 10;
	
	var spd  = (slide_da? _ady : _adx) * _s;
	var _val = value_snap(tb.slide_sv + spd, _s);
	
	draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text);
	
	var _stp_sz = 50 * _s;
	var _stp_fl = round(_val / _stp_sz) * _stp_sz;
	var _stp_md = _val - _stp_fl;
	
	var _tw = 48;
	for( var i = -2; i <= 2; i++ ) {
		var _v = _stp_fl + i * _stp_sz;
		_tw = max(_tw, string_width(_v) + 16);
	}
	
	var _snp_s = 50 * _s;
	var _snp_v = round(_val / _snp_s) * _snp_s;
	if(abs(_val - _snp_v) < 5 * _s)
		_val = _snp_v;
	
	if(slide_da) {
		var _sdw = _tw;
		var _sdh = 256;
		var _sdx = slide_dx - _sdw / 2;
		var _sdy = mouse_my - _sdh / 2;
		
		draw_sprite_stretched_ext(THEME.textbox_number_slider, 0, _sdx, _sdy, _sdw, _sdh, COLORS.panel_inspector_group_bg, 1);
		
		for( var i = -2; i <= 2; i++ ) {
			var _v = _stp_fl + i * _stp_sz;
			
			draw_set_alpha(0.4 - abs(i) * 0.1);
			draw_text(slide_dx, slide_dy - (_v - tb.slide_sv) / _s, _v);
		}
		
		draw_set_alpha(1);
		draw_text(slide_dx, slide_dy - (_val - tb.slide_sv) / _s, _val);
	} else {
		var _sdw = 240;
		var _sdh = 48;
		var _sdx = mouse_mx - _sdw / 2;
		var _sdy = slide_dy - _sdh / 2;
		
		draw_sprite_stretched_ext(THEME.textbox_number_slider, 0, _sdx, _sdy, _sdw, _sdh, COLORS.panel_inspector_group_bg, 1);
		
		for( var i = -2; i <= 2; i++ ) {
			var _v = _stp_fl + i * _stp_sz;
			
			draw_set_alpha(0.4 - abs(i) * 0.1);
			draw_text(slide_dx + (_v - tb.slide_sv) / _s, slide_dy, _v);
		}
		
		draw_set_alpha(1);
		draw_text(slide_dx + (_val - tb.slide_sv) / _s, slide_dy, _val);
	}
					
	tb._input_text = string_real(_val);
	if(tb.apply()) UNDO_HOLDING = true;
}
				
if(MOUSE_WRAPPING) {
	slide_dx = mouse_mx;
	slide_dy = mouse_my;
}
				
setMouseWrap();
tb = noone;