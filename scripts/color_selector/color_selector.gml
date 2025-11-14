globalvar DROPPER_DROPPING, DROPPER_SURFACE;
DROPPER_DROPPING = false;
DROPPER_SURFACE  = noone;

function colorSelector(_onApply = noone) constructor {
	onApply = _onApply;
	
	focus = noone;
	hover = noone;
	
	#region color
		current_color  = c_white;
		current_colors = noone;
		
		hue = 1;
		sat = 0;
		val = 0;
	#endregion
	
	#region interaction
		area_dragging = false;
		side_dragging = false;
		mix_dragging  = false;
		
		dropper_active = false;
		dropper_close  = true;
		dropper_color  = c_white;
		interactable   = true;
	#endregion
	
	#region display
		disp_mode     = 0;
		draw_selector = true;
	
		palette = PROJECT.attributes.palette;
		discretize_pal = true;
		
		tt_view = new tooltipSelector("Display Type", [ "Hue", "Value" ]);
		tt_barr = new tooltipSelector("Slider Type",  [ "Smooth", "Quantized" ]);
		tt_rang = new tooltipSelector("Slider Range", [ "All", "Around" ]);
	#endregion
	
	#region surfaces
		content_surface = noone;
		side_surface    = noone;
		textbox_surface = noone;
		mix_surface     = noone;
		mixing_colors   = noone;
	#endregion
	
	#region data
		slot_amount     = 7;
		slot_spacing    = 32;
		value_dragging  = noone;
		
		tb_quantize = textBox_Number(function(n) /*=>*/ { slot_spacing = clamp(round(n), 1, 64); }).setFont(f_p4);
		tb_slotamo  = textBox_Number(function(n) /*=>*/ { slot_amount  = clamp(round(n), 3, 15); }).setFont(f_p4);
	#endregion
	
	#region widgets
		tb_hue = slider(0, 255, 1, function(v) /*=>*/ { if(!interactable) return; hue = clamp(v, 0, 255); setHSV(); });
		tb_sat = slider(0, 255, 1, function(v) /*=>*/ { if(!interactable) return; sat = clamp(v, 0, 255); setHSV(); });
		tb_val = slider(0, 255, 1, function(v) /*=>*/ { if(!interactable) return; val = clamp(v, 0, 255); setHSV(); });
		
		tb_red = slider(0, 255, 1, function(v) /*=>*/ {
			if(!interactable) return;
			
			var r = clamp(v, 0, 255);
			var g = color_get_g(current_color);
			var b = color_get_b(current_color);
			var a = color_get_a(current_color);
			
			current_color = make_color_rgba(r, g, b, a);
			resetHSV();
		});
		
		tb_grn = slider(0, 255, 1, function(v) /*=>*/ {
			if(!interactable) return;
			
			var r = color_get_r(current_color);
			var g = clamp(v, 0, 255);
			var b = color_get_b(current_color);
			var a = color_get_a(current_color);
			
			current_color = make_color_rgba(r, g, b, a);
			resetHSV();
		});
		
		tb_blu = slider(0, 255, 1, function(v) /*=>*/ {
			if(!interactable) return;
			
			var r = color_get_r(current_color);
			var g = color_get_g(current_color);
			var b = clamp(v, 0, 255);
			var a = color_get_a(current_color);
			
			current_color = make_color_rgba(r, g, b, a);
			resetHSV();
		});
		
		tb_alp = slider(0, 255, 1, function(v) /*=>*/ {
			if(!interactable) return;
			current_color = _cola(current_color, clamp(v, 0, 255));
			resetHSV();
		});
		
		tb_hex = textBox_Text(function(str) /*=>*/ {
			if(!interactable || str == "") return;
			if(string_char_at(str, 1) == "#") str = string_replace(str, "#", "");
			
			var _r = string_hexadecimal(string_copy(str, 1, 2));
			var _g = string_hexadecimal(string_copy(str, 3, 2));
			var _b = string_hexadecimal(string_copy(str, 5, 2));
			var _a = string_length(str) > 6? string_hexadecimal(string_copy(str, 7, 2)) : 255;
			
			current_color = make_color_rgba(_r, _g, _b, _a);
			resetHSV();
		});
		
		tbs = [ tb_hue, tb_sat, tb_val, tb_red, tb_grn, tb_blu, tb_alp ];
		for( var i = 0, n = array_length(tbs); i < n; i++ )
			tbs[i].setFont(f_p3).setSlideType(1);
	#endregion
	
	function resetHSV(_apply = true) {
		hue = color_get_hue(current_color);
		sat = color_get_saturation(current_color);
		val = color_get_value(current_color);
		
		if(_apply && onApply != noone) onApply(int64(current_color));
	}
	
	function setHSV(_apply = true) {
		if(!interactable) return;
		
		var _alpha    = color_get_alpha(current_color);
		current_color = make_color_hsva(hue, sat, val, _alpha);
		
		if(_apply && onApply != noone) {
			onApply(int64(current_color));
			UNDO_HOLDING = true;
		}
	}
	
	function setColor(color, _apply = true) {
		current_color = color;
		resetHSV(_apply);
	}
	
	function setMixColor(_cto) {
		mixing_colors   = {
			from:  current_color,
			to:    _cto,
			ratio: 0, 
		};
	}
	
	function colorPicker() {
		if(!dropper_active) return;
		dropper_color = int64(cola(draw_getpixel(mouse_mx, mouse_my)));
		MOUSE_BLOCK   = true;
		DROPPER_DROPPING = true;
	}
	
	function drawValueBox(_label, _type, dtx, dty, tb, _range = [0,255], _int = true) {
		var wdw = ui(40);
		var wdx = dtx + ui(24 + 160) - wdw;
		var wdh = ui(27);
			
		var bgw = ui(160 - 4) - wdw;
		var bgh = wdh - ui(8);
		var bgx = dtx + ui(20);
			
		textbox_surface = surface_verify(textbox_surface, bgw, bgh);
		surface_set_shader(textbox_surface);
			draw_sprite_stretched_ext(THEME.box_r2, 0, 0, 0, bgw, bgh, c_white, 1);
		surface_reset_shader();
		
		draw_set_text(f_p2b, fa_left, fa_center, COLORS._main_text_sub);
		draw_text(dtx, dty + wdh / 2, _label);
		
		var r = color_get_r(current_color);
		var g = color_get_g(current_color);
		var b = color_get_b(current_color);
		var a = color_get_a(current_color);
	
		var defv = 0;
		switch(_type) {
			case 0 : defv = hue; break;
			case 1 : defv = sat; break;
			case 2 : defv = val; break;
			
			case 3 : defv = r; break;
			case 4 : defv = g; break;
			case 5 : defv = b; break;
			
			case 6 : defv = color_oklch(current_color)[0]; break;
			case 7 : defv = color_oklch(current_color)[1]; break;
			case 8 : defv = color_oklch(current_color)[2]; break;
			
			case 99 : defv = a; break;
		}
		
		defv = clamp(defv, _range[0], _range[1]);
		var _val = _int? round(defv) : defv;
		tb.draw(wdx, dty, wdw, wdh, _int? round(_val) : _val, mouse_ui);
		
		var sp = slot_spacing / 256 * (_range[1] + 1); 
		if(_type == 0) sp /= 2;
		sp = min(sp, _int? round(_range[1] / slot_amount) : _range[1] / slot_amount);
		
		var _wid = sp * 3;
		
		if(PREFERENCES.color_selector_slider_type == 0) {
			var _range_s = defv;
			var _range_e = defv;
			
			switch(PREFERENCES.color_selector_range_type) {
				case 0 : 
					_range_s = _range[0];
					_range_e = _range[1];
					break;
					
				case 1 : 
					_range_s = defv - _wid;
					_range_e = defv + _wid;
					
					if(_range_s < _range[0]) {
						_range_s = _range[0];
						_range_e = _wid * 2;
						
					} else if(_range_e > _range[1]) {
						_range_s = _range[1] - _wid * 2;
						_range_e = _range[1];
					}
					break;
					
			}
			
			_range_s /= _range[1] - _range[0];
			_range_e /= _range[1] - _range[0];
			
			shader_set(sh_color_selector_tb); 
				shader_set_i("type",  _type); 
				shader_set_2("range", [_range_s, _range_e]); 
				draw_surface(textbox_surface, bgx, dty+ui(4)); 
			shader_reset();
			
			draw_sprite_stretched_add(THEME.box_r2, 1, bgx, dty + ui(4), bgw, bgh, c_white, .2);
			
			var _vv = (_val / _range[1] - _range_s) / (_range_e - _range_s);
			var _bx = bgx + bgw * _vv;
			var _cc = COLORS._main_icon;
			
			var _hovBar = interactable && hover && point_in_rectangle(mouse_mx, mouse_my, bgx, dty, bgx + bgw, dty + wdh);
			if(_hovBar) {
				_cc = COLORS._main_icon_light;
				
				if(value_dragging == noone && mouse_lpress(focus))
					value_dragging = _type;
			}
			
			if(value_dragging == _type) {
				_cc = COLORS._main_accent;
				var v = clamp((mouse_mx - bgx) / bgw, 0, 1) * _range[1];
				if(_int) v = round(v);
				
				switch(_type) {
					case 0 : hue = clamp(v, _range[0], _range[1]); setHSV(); break;
					case 1 : sat = clamp(v, _range[0], _range[1]); setHSV(); break;
					case 2 : val = clamp(v, _range[0], _range[1]); setHSV(); break;
					
					case 3 : current_color = make_color_rgba(v, g, b, a); resetHSV(); break;
					case 4 : current_color = make_color_rgba(r, v, b, a); resetHSV(); break;
					case 5 : current_color = make_color_rgba(r, g, v, a); resetHSV(); break;
					
					case 6 : 
						var _lch = color_oklch(current_color); _lch[0] = v;
						current_color = make_color_oklch(_lch, a / 255); 
						resetHSV(); 
						break;
					case 7 : 
						var _lch = color_oklch(current_color); _lch[1] = v;
						current_color = make_color_oklch(_lch, a / 255); 
						resetHSV(); 
						break;
					case 8 : 
						var _lch = color_oklch(current_color); _lch[2] = v;
						current_color = make_color_oklch(_lch, a / 255); 
						resetHSV(); 
						break;
						
					case 99 : current_color = _cola(current_color, v);    resetHSV(); break;
				}
				
				if(mouse_lrelease()) value_dragging = noone;
			}
		
			draw_set_color(CDEF.main_black); draw_line_round(_bx, dty,       _bx, dty + wdh,       ui(7));
			draw_set_color(_cc);             draw_line_round(_bx, dty+ui(2), _bx, dty + wdh-ui(2), ui(3));
			
		} else if(PREFERENCES.color_selector_slider_type == 1) {
			var _amo = slot_amount;
			
			var aw = bgw / _amo;
			var ah = bgh;
			
			var ax = bgx;
			var ay = dty + ui(4);
			
			var cInd = (_amo - 1) / 2;
			var inS  = floor(defv / sp);
			var inE  = ceil((_range[1] - defv) / sp);
			
			if(inS < cInd) cInd = inS;
			else if(inE < cInd) cInd = _amo - inE - 1;
						
			for( var i = 0; i < _amo; i++ ) {
				var cc = c_white;
				var v  = 0;
				
				switch(PREFERENCES.color_selector_range_type) {
					case 0 : 
						v = i / (_amo - 1) * (_range[1] + 1);
						if(abs(defv - v) <= (_range[1] + 1) / 2 / (_amo - 1)) cInd = i;
						break;
						
					case 1 : v = defv + (i - cInd) * sp; break;
				}
				
				v = clamp(v, _range[0], _range[1]);
				
				switch(_type) {
					case 0 : cc = make_color_hsva(  v, sat, val, a); break;
					case 1 : cc = make_color_hsva(hue,   v, val, a); break;
					case 2 : cc = make_color_hsva(hue, sat,   v, a); break;
					
					case 3 : cc = make_color_rgba(v, g, b, a); break;
					case 4 : cc = make_color_rgba(r, v, b, a); break;
					case 5 : cc = make_color_rgba(r, g, v, a); break;
					
					case 6 : 
						var _lch = color_oklch(current_color); _lch[0] = v;
						cc = make_color_oklch(_lch, a / 255); 
						break;
					case 7 : 
						var _lch = color_oklch(current_color); _lch[1] = v;
						cc = make_color_oklch(_lch, a / 255); 
						break;
					case 8 : 
						var _lch = color_oklch(current_color); _lch[2] = v;
						cc = make_color_oklch(_lch, a / 255); 
						break;
						
					case 99 : cc = make_color_rgba(r, g, b, v); break;
				}
				
				var _i = 0;
				if(i == 0)      _i = 2;
				if(i == _amo-1) _i = 3;
				
				draw_sprite_stretched_ext(THEME.palette_mask, _i, ax, ay, aw, ah, cc, _color_get_alpha(cc));
				
				var _hovBar = interactable && hover && point_in_rectangle(mouse_mx, mouse_my, ax, ay, ax + aw, ay + ah);
				if(_hovBar) {
					if((PREFERENCES.color_selector_range_type == 0 && mouse_lclick(focus)) || (PREFERENCES.color_selector_range_type == 1 && mouse_lpress(focus))) setColor(cc);
				}
				
				ax += aw;
			}
			
			draw_sprite_stretched_add(THEME.palette_mask_outline, 1, bgx, ay, bgw, ah, c_white, .3);
			
			var cx = bgx + aw * cInd;
			draw_sprite_stretched_ext(THEME.palette_mask,         1, cx - ui(2), ay - ui(2), aw + ui(4), ah + ui(4), current_color);
			draw_sprite_stretched_add(THEME.palette_mask_outline, 1, cx - ui(2), ay - ui(2), aw + ui(4), ah + ui(4), c_white, .5);
			
		}
	}
	
	static drawDropper = function(instance) {
		if(mouse_check_button_pressed(mb_left)) {
			setColor(dropper_color);
			dropper_active = false;
			MOUSE_BLOCK    = true;
			if(dropper_close) instance_destroy(instance);
			return;
		}
		
		if(keyboard_check_pressed(vk_escape)) {
			dropper_active = false;
			MOUSE_BLOCK    = true;
			if(dropper_close) instance_destroy(instance);
			return;
		}
		
		if((dropper_active && mouse_check_button_pressed(mb_right)) || keyboard_check_released(vk_alt)) 
			instance_destroy(instance);
		
		if(is_surface(APP_SURF)) {
			var _x  = mouse_mx;
			var _y  = mouse_my;
			var _ss = 4;
			var _x0 = _x - _ss, _y0 = _y - _ss;
			var _x1 = _x + _ss, _y1 = _y + _ss;
			var _sc = ui(16);
			
			var _ww = (_ss * 2 + 1) * _sc;
			var _vx = _x + ui(32);        if(_vx + _ww > WIN_W - ui(16)) _vx = _x - ui(32) - _ww;
			var _vy = _y - ui(32) - _ww;  if(_vy < ui(16)) _vy = _y + ui(32);
			
			DROPPER_SURFACE = surface_verify(DROPPER_SURFACE, _ww, _ww);
			surface_set_target(DROPPER_SURFACE);
				DRAW_CLEAR
				
				gpu_set_colorwriteenable(0, 0, 0, 1);
				draw_set_color(c_white);
				draw_circle_prec(_ww / 2, _ww / 2, _ww / 2, false, 32);
				
				gpu_set_colorwriteenable(1, 1, 1, 0);
				draw_surface_part_ext(APP_SURF, _x0, _y0, _x1 - _x0 + 1, _y1 - _y0 + 1, 0, 0, _sc, _sc, c_white, 1);
				
				draw_set_color(COLORS._main_icon);
				draw_set_alpha(.2);
				
				var _amo = _ss * 2 + 1;
				for( var i = 0; i < _amo; i++ ) {
					draw_line(i * _sc, 0, i * _sc, _ww);
					draw_line(0, i * _sc, _ww, i * _sc);
				}
				
				draw_set_alpha(1);
				draw_set_color(COLORS._main_accent);
				draw_rectangle(_ss * _sc, _ss * _sc, _ss * _sc + _sc - 1, _ss * _sc + _sc - 1, true);
				
				gpu_set_colorwriteenable(1, 1, 1, 1);
			surface_reset_target();
			
			draw_surface(DROPPER_SURFACE, _vx, _vy);
			draw_circle_ui(_vx + _ww / 2 + 1, _vy + _ww / 2 + 1, _ww / 2 + 2, .025, COLORS._main_icon_light, 1);
			draw_circle_ui(_vx + _ww / 2 + 1, _vy + _ww / 2 + 1, _ww / 2 + 2, .010, COLORS._main_icon, 1);
		}
	}
	
	static draw = function(_x, _y, _focus, _hover) {
		var cont_x = _x + ui(8);
		var cont_y = _y + ui(8);
		
		var cont_w = ui(256);
		var cont_h = ui(256);
		
		focus = _focus;
		hover = _hover;
		
		if(mixing_colors != noone) {
			var mix_x = _x + ui(8);
			var mix_y = _y + ui(8);
			var mix_w = ui(296)
			var mix_h = ui(24);
			
			cont_y += mix_h + ui(24);
			cont_h -= mix_h + ui(24);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, mix_x - ui(8), mix_y - ui(8), mix_w + ui(16), mix_h + ui(16));
			
			var _ccx = mix_x;
			var _ccy = mix_y;
			draw_sprite_stretched_ext(THEME.box_r2, 0, _ccx, _ccy, mix_h, mix_h, mixing_colors.from);
			draw_sprite_stretched_add(THEME.box_r2, 1, _ccx, _ccy, mix_h, mix_h, c_white, 0.2);
			
			var _ccx = mix_x + mix_w - mix_h;
			var _ccy = mix_y;
			draw_sprite_stretched_ext(THEME.box_r2, 0, _ccx, _ccy, mix_h, mix_h, mixing_colors.to);
			draw_sprite_stretched_add(THEME.box_r2, 1, _ccx, _ccy, mix_h, mix_h, c_white, 0.2);
			
			var gra_x = mix_x + mix_h + ui(8);
			var gra_y = mix_y + ui(4);
			var gra_w = mix_w - mix_h * 2 - ui(16);
			var gra_h = mix_h - ui(8);
			
			mix_surface = surface_verify(mix_surface, gra_w,  gra_h);
			surface_set_target(mix_surface);
				DRAW_CLEAR
				
				draw_sprite_stretched(THEME.box_r2, 0, 0, 0, gra_w, gra_h);
				gpu_set_colorwriteenable(1, 1, 1, 0);
				shader_set(sh_color_selector_mix);
					shader_set_i("mode", disp_mode);
					shader_set_c("from", mixing_colors.from);
					shader_set_c("to",   mixing_colors.to);
					
					draw_empty();
				shader_reset();
				gpu_set_colorwriteenable(1, 1, 1, 1);
				
			surface_reset_target();
			
			draw_surface(mix_surface, gra_x, gra_y);
			draw_sprite_stretched_add(THEME.box_r2, 1, gra_x, gra_y, gra_w, gra_h, c_white, 0.2);
			
			var sel_p = mixing_colors.ratio * gra_w;
			var sel_x = gra_x + sel_p;
			var sel_y = gra_y + gra_h / 2;
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, sel_x - ui(4), sel_y - mix_h / 2, ui(8), mix_h, current_color, 1);
			draw_sprite_stretched_add(THEME.box_r2, 1, sel_x - ui(4), sel_y - mix_h / 2, ui(8), mix_h, c_white, 0.75);
			
			if(mouse_press(mb_left, interactable && focus)) {
				if(point_in_rectangle(mouse_mx, mouse_my, gra_x, gra_y, gra_x + gra_w, gra_y + gra_h))
					mix_dragging = true;
			}
			
			if(mix_dragging) {
				var _prg = clamp((mouse_mx - gra_x) / gra_w, 0, 1);
				mixing_colors.ratio = _prg;
				
				current_color = merge_color(mixing_colors.from, mixing_colors.to, mixing_colors.ratio);
				current_color = cola(current_color, 1);
				setColor(current_color);
				
				if(mouse_release(mb_left)) {
					mix_dragging  = false;
					mixing_colors = noone;
				}
			}
		}
		
		var sel_sw = cont_w / 256;
		var sel_sh = cont_h / 256;
		
		var sel_x = cont_x + ui(280);
		var sel_y = cont_y;
		var sel_w = ui(16);
		var sel_h = cont_h;
		var discr = NODE_COLOR_SHOW_PALETTE && discretize_pal;
		
		#region content
			content_surface = surface_verify(content_surface, cont_w, cont_h);
			surface_set_target(content_surface);			
				DRAW_CLEAR
				
				draw_sprite_stretched(THEME.box_r2, 0, 0, 0, cont_w, cont_h);
				gpu_set_colorwriteenable(1, 1, 1, 0);
				shader_set(sh_color_select_content);
					shader_set_i("mode", disp_mode);
					shader_set_f("hue",  hue / 256);
					shader_set_f("sat",  sat / 256);
					shader_set_f("val",  val / 256);
					
					shader_set_i("discretize",	  discr);
					shader_set_palette(palette);
					
					draw_empty();
				shader_reset();
				gpu_set_colorwriteenable(1, 1, 1, 1);
			surface_reset_target();
			
			side_surface = surface_verify(side_surface,    sel_w,  sel_h);
			surface_set_target(side_surface);
				DRAW_CLEAR
				
				draw_sprite_stretched(THEME.box_r2, 0, 0, 0, sel_w, sel_h);
				gpu_set_colorwriteenable(1, 1, 1, 0);
				shader_set(sh_color_select_side);
					shader_set_i("mode", disp_mode);
					shader_set_f("hue",  hue / 256);
					shader_set_f("sat",  sat / 256);
					shader_set_f("val",  val / 256);
					
					shader_set_i("discretize", discr);
					shader_set_palette(palette);
					
					draw_empty();
				shader_reset();
				gpu_set_colorwriteenable(1, 1, 1, 1);
				
			surface_reset_target();
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, cont_x - ui(8), cont_y - ui(8), cont_w + ui(16), cont_h + ui(16));
			draw_sprite_stretched(THEME.ui_panel_bg, 1, sel_x  - ui(8), sel_y  - ui(8), sel_w  + ui(16), sel_h  + ui(16));
			
			draw_surface(content_surface, cont_x, cont_y);
			draw_surface(side_surface,    sel_x,  sel_y);
			
			draw_sprite_stretched_add(THEME.box_r2, 1, cont_x, cont_y, cont_w, cont_h, c_white, 0.2);
			draw_sprite_stretched_add(THEME.box_r2, 1, sel_x,  sel_y,  sel_w,  sel_h,  c_white, 0.2);
		#endregion
	
		#region control
			var _cs = ui(12);
			var _p2 = _cs / 2;
			var _p  = _p2 / 2;
			var _sc;
			
			var _cx = disp_mode == 0? cont_x + sel_sw * (      sat) - _p2 : cont_x + sel_sw * (      hue) - _p2;
			var _cy = disp_mode == 0? cont_y + sel_sh * (256 - val) - _p2 : cont_y + sel_sh * (256 - sat) - _p2;
			
			var _sw = _p2 + sel_w;
			var _sh = _cs;
			var _sx = sel_x - _p;
			var _sy = (disp_mode == 0? sel_y + sel_sh * (hue) : sel_y + sel_sh * (256 - val)) - _sh / 2;
			
			if(discr) _sc = current_color;
			else      _sc = disp_mode == 0? make_color_hsv(hue, 255, 255) : make_color_hsv(hue, 255, val);
			
			if(current_colors != noone) {
				var _csz = ui(8);
				var _ssx = sel_x + sel_w / 2 - _csz / 2;
				
				BLEND_ADD
				for (var i = 0, n = array_length(current_colors); i < n; i++) {
					var _cc  = current_colors[i];
					var _cch = round(color_get_hue(_cc));
					var _ccs = round(color_get_saturation(_cc));
					var _ccv = round(color_get_value(_cc));
					
					var _csy = disp_mode == 0? cont_y + sel_sh * (_cch) : cont_y + sel_sh * (256 - _ccv);
					
					draw_sprite_stretched_ext(THEME.box_r2, 1, _ssx, _csy - _csz / 2, _csz, _csz, c_white, 0.75);
					
					var _sel  = 1 - abs(disp_mode == 0? _cch - hue : _ccv - val) / 32;
					
					if(_sel <= 0) continue;
					var _ccx  = disp_mode == 0? cont_x + sel_sw * (      _ccs) : cont_x + sel_sw * (      _cch);
					var _ccy  = disp_mode == 0? cont_y + sel_sh * (256 - _ccv) : cont_y + sel_sh * (256 - _ccs);
					var _cszz = _sel == 1? ui(16) : lerp(ui(6), ui(12), _sel);
					var _caa  = _sel == 1? 1 : lerp(0.25, 0.75, _sel);
					
					draw_sprite_stretched_ext(THEME.box_r2, 1, _ccx - _cszz / 2, _ccy - _cszz / 2, _cszz, _cszz, c_white, _caa);
				}
				BLEND_NORMAL
				
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx - 1, _sy - 1, _sw + 2, _sh + 2, c_black, 0.5);
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx, _sy, _sw, _sh, _sc, 1);
				
			} else {
				draw_sprite_stretched_ext(THEME.box_r2, 0, _cx - 1, _cy - 1, _cs + 2, _cs + 2, c_black, 0.5);
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx - 1, _sy - 1, _sw + 2, _sh + 2, c_black, 0.5);
				
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx, _sy, _sw, _sh, _sc, 1);
				draw_sprite_stretched_ext(THEME.box_r2, 0, _cx, _cy, _cs, _cs, current_color, 1);
				
				draw_sprite_stretched_add(THEME.box_r2, 1, _sx, _sy, _sw, _sh, c_white, 0.75);
				draw_sprite_stretched_add(THEME.box_r2, 1, _cx, _cy, _cs, _cs, c_white, 0.75);
			}
			
			if(mouse_press(mb_left, interactable && focus)) {
				if(point_in_rectangle(mouse_mx, mouse_my, sel_x, sel_y, sel_x + ui(16), sel_y + cont_h))
					side_dragging = true;
					
				else if(point_in_rectangle(mouse_mx, mouse_my, cont_x, cont_y, cont_x + cont_w, cont_y + cont_h))
					area_dragging = true;
			}
			
			if(side_dragging) {
				var _my = clamp((mouse_my - sel_y) / sel_sh, 0, 256);
				
				     if(disp_mode == 0) hue = _my;
				else if(disp_mode == 1) val = 256 - _my;
				
				setHSV();
				
				if(discr) {
					current_color = disp_mode == 0? surface_getpixel(content_surface, sat, 256 - val) : 
													surface_getpixel(content_surface, hue, 256 - sat);
					current_color = cola(current_color, 1);
					
					if(onApply != noone) {
						onApply(current_color);
						UNDO_HOLDING = true;
					}
				}
				
				if(mouse_release(mb_left)) {
					side_dragging = false;
					UNDO_HOLDING  = false;
				}
			}
		
			if(area_dragging) {
				var _mx = clamp((mouse_mx - cont_x) / sel_sw, 0, 256);
				var _my = clamp((mouse_my - cont_y) / sel_sh, 0, 256);
				
				if(disp_mode == 0) {
					sat = _mx;
					val = 256 - _my;
					
				} else if(disp_mode == 1) {
					hue = _mx;
					sat = 256 - _my;	
				}
				
				setHSV();
				
				if(discr) {
					current_color = disp_mode == 0? surface_getpixel(content_surface, sat, 256 - val) : 
													surface_getpixel(content_surface, hue, 256 - sat);
					current_color = cola(current_color, 1);
					
					if(onApply != noone) {
						onApply(current_color);
						UNDO_HOLDING = true;
					}
				}
				
				if(mouse_release(mb_left)) {
					area_dragging = false;
					UNDO_HOLDING  = false;
				}
			}
		#endregion
		
		#region register
			for( var i = 0, n = array_length(tbs); i < n; i++ ) {
				tbs[i].register();
				tbs[i].setFocusHover(focus, hover);
			}
			
			tb_hex.register();
			tb_hex.setFocusHover(focus, hover);
		#endregion
		
		#region data
			var tx = sel_x + ui(36);
			var ty = _y;
			var x1 = tx + ui(188);
			var th = ui(24);
			var bb = THEME.button_hide;
			
			draw_set_color(CDEF.main_dkblack);
			draw_line_round(tx, ty + th + ui(4), x1, ty + th + ui(4), ui(2));
			
			var ic = THEME.color_selector_view;
			if(buttonInstant_Pad(bb, tx, ty, th, th, mouse_ui, hover, focus, tt_view, ic, disp_mode, c_white, 1, ui(6)) == 2)
				disp_mode = (disp_mode + 1) % 2;
			tt_view.index = disp_mode;
			tx += th + ui(4);
			
			var ic = THEME.color_selector_slide;
			var ii = PREFERENCES.color_selector_slider_type;
			if(buttonInstant_Pad(bb, tx, ty, th, th, mouse_ui, hover, focus, tt_barr, ic, ii, COLORS._main_icon, 1, ui(6)) == 2)
				PREFERENCES.color_selector_slider_type = (PREFERENCES.color_selector_slider_type + 1) % 2;
			tt_barr.index = PREFERENCES.color_selector_slider_type;
			tx += th + ui(4);
			
			var ic = THEME.color_selector_range;
			var ii = PREFERENCES.color_selector_range_type;
			if(buttonInstant_Pad(bb, tx, ty, th, th, mouse_ui, hover, focus, tt_rang, ic, ii, COLORS._main_icon, 1, ui(6)) == 2)
				PREFERENCES.color_selector_range_type = (PREFERENCES.color_selector_range_type + 1) % 2;
			tt_rang.index = PREFERENCES.color_selector_range_type;
			tx += th + ui(4);
			
			var _qw = ui(32);
			var _qx = x1 - _qw;
			
			if(PREFERENCES.color_selector_range_type == 1) {
				tb_quantize.setFocusHover(focus, hover);
				tb_quantize.draw(_qx, ty, _qw, th, slot_spacing, mouse_ui);
				_qx -= _qw + ui(4);
			}
			
			if(PREFERENCES.color_selector_slider_type == 1) {
				tb_slotamo.setFocusHover(focus, hover);
				tb_slotamo.draw(_qx, ty, _qw, th, slot_amount, mouse_ui);
				_qx -= _qw + ui(4);
			}
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			var dtx = sel_x + ui(40);
			var dty = ty + th + ui(12);
			var txh = ui(32);
			
			shader_set(sh_color_selector_tb);
				shader_set_f("hue",   hue / 255);
				shader_set_f("sat",   sat / 255);
				shader_set_f("val",   val / 255);
				shader_set_f("red",   _color_get_r(current_color));
				shader_set_f("green", _color_get_g(current_color));
				shader_set_f("blue",  _color_get_b(current_color));
			shader_reset();
			
			drawValueBox("H", 0, dtx, dty + txh*0, tb_hue);
			drawValueBox("S", 1, dtx, dty + txh*1, tb_sat);
			drawValueBox("V", 2, dtx, dty + txh*2, tb_val);
			
			// drawValueBox("L", 6, dtx, dty + txh*0, tb_hue, [0, 1],  false);
			// drawValueBox("C", 7, dtx, dty + txh*1, tb_sat, [0, 1],  false);
			// drawValueBox("H", 8, dtx, dty + txh*2, tb_val, [0, 43], false);
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			dty = dty + txh*3 + ui(8);
			
			drawValueBox("R", 3, dtx, dty + txh*0, tb_red);
			drawValueBox("G", 4, dtx, dty + txh*1, tb_grn);
			drawValueBox("B", 5, dtx, dty + txh*2, tb_blu);
			
			drawValueBox("A", 99, dtx, dty + txh*3, tb_alp);
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			tb_hex.draw(sel_x - ui(128), cont_y + cont_h + ui(24), ui(108), TEXTBOX_HEIGHT, color_get_hex(current_color),  mouse_ui);
		#endregion
		
		var cx = cont_x + ui(16);
		var cy = cont_y + cont_h + ui(40);
		var aa = _color_get_alpha(current_color);
		
		draw_sprite_stretched_ext(THEME.color_picker_box, 0, cx - ui(20), cy - ui(20), ui(40), ui(40), COLORS._main_icon_dark, 1);
		draw_sprite_stretched_ext(THEME.color_picker_box, 1, cx - ui(18), cy - ui(18), ui(36), ui(36), current_color, aa);
		
		cx += ui(48);
		if(interactable)
		if(buttonInstant(THEME.button_hide_fill, cx - ui(18), cy - ui(18), ui(36), ui(36), mouse_ui, focus, hover, "", THEME.color_picker_dropper, 0, c_white) == 2)
			dropper_active = true;
	}
	
	static free = function() {
		surface_free_safe(content_surface);
		surface_free_safe(side_surface);
		surface_free_safe(textbox_surface);
	}
}