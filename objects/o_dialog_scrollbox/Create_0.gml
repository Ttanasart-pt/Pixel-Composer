/// @description init
event_inherited();

#region 
	max_h	 = 640;
	
	font     = f_p0
	align	 = fa_center;
	text_pad = ui(8);
	item_pad = ui(8);
	
	draggable = false;
	destroy_on_click_out = true;
	
	selecting	  = -1;
	scrollbox	  = noone;
	data		  = [];
	initVal		  = 0;
	update_hover  = true;
	
	search_string	= "";
	KEYBOARD_RESET
	tb_search = new textBox(TEXTBOX_INPUT.text, function(s) /*=>*/ { search_string = string(s); filterSearch(); })
					.setFont(f_p2).setAutoUpdate().setEmpty().setAlign(fa_left);
	
	WIDGET_CURRENT  = tb_search;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	function initScroll(scroll) {
		scrollbox	= scroll;
		dialog_w	= max(ui(200), scroll.w);
		data		= scroll.data;
		setSize();
	}
	
	function filterSearch() {
		if(search_string == "") {
			data = scrollbox.data;
			setSize();
			return;
		}
		
		data = [];
		for( var i = 0, n = array_length(scrollbox.data); i < n; i++ ) {
			var val = scrollbox.data[i];
			if(val == -1) continue;
			
			var _txt = is(val, scrollItem)? val.name : val;
			if(string_pos(string_lower(search_string), string_lower(_txt)) > 0)
				array_push(data, val);
		}
		
		setSize();
	}
	
	function setSize() {
		var hght = line_get_height(font) + item_pad;
		var hh	 = ui(16 + 24);
		
		for( var i = 0, n = array_length(data); i < n; i++ )
			hh += data[i] == -1? ui(8) : hght;
		
		dialog_h = min(max_h, hh);
		sc_content.resize(dialog_w, dialog_h - ui(40));
		
		resetPosition();
	}
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var hght = line_get_height(font) + item_pad;
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		var hov  = noone;
		
		if(MOUSE_MOVED) selecting = noone;
		
		for(var i = 0; i < array_length(data); i++) {
			var _val = data[i];
			var _txt = _val, _spr = noone;
			var _tol = false;
			var _act = true;
			var _sub = false;
			var _sca = true;
			
			if(is(_val, scrollItem)) {
				_act = _val.active;
				_txt = _val.name;
				_spr = _val.spr;
				_tol = _val.tooltip != "";
				_sca = _val.spr_scale;
				
			} else {
				_act = !string_starts_with(_txt, "-");
				_sub =  string_starts_with(_txt, ">");
				_txt =  string_trim_start(_txt, ["-", ">", " "]);
			}
			
			if(data[i] == -1) {
				draw_set_color(CDEF.main_mdblack);
				draw_line_width(ui(8), _ly + ui(3), _dw - ui(8), _ly + ui(3), 2);
				_ly += ui(8);
				_h  += ui(8);
				
				continue;
			}
			
			var _yy  = _ly + hght / 2;
			
			if(_act) {
				if(sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, _ly, _dw, _ly + hght - 1)) {
					sc_content.hover_content = true;
					selecting = i;
					hov       = _val;
				}
			
				if(selecting == i) {
					draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
					if(sc_content.active && (mouse_press(mb_left) || KEYBOARD_ENTER)) {
						initVal = array_find(scrollbox.data, _val);
						instance_destroy();
					}
				}
			}
			
			if(_tol) {
				var tx = _dw - ui(12);
				var ty = _yy;
				
				if(point_in_circle(_m[0], _m[1], tx, ty, ui(10))) {
					TOOLTIP = _val.tooltip;
					draw_sprite_ui(THEME.info, 0, tx, ty, .75, .75, 0, COLORS._main_icon, 1);
					
				} else 
					draw_sprite_ui(THEME.info, 0, tx, ty, .75, .75, 0, COLORS._main_icon, 0.75);
			}
			
			if(is_string(_txt)) {
				draw_set_text(font, align, fa_center, _act? COLORS._main_text : COLORS._main_text_sub);
				if(align == fa_center) {
					var _x0 = 0;
					var _x1 = _dw;
					if(_spr != noone) _x0 += hght;
					if(_tol)          _x1 -= hght;
					
					var _xc = (_x0 + _x1) / 2;
					draw_text_add(_xc, _yy, _txt);
					
				} else if(align == fa_left) 
					draw_text_add(text_pad + (_spr != noone) * hght, _yy, _txt);
					
			} else if(sprite_exists(_txt)) {
				draw_sprite_ext(_txt, i, _dw / 2, _yy);
			}
			
			if(_spr) {
				var _ss = _sca? (hght - ui(8)) / sprite_get_height(_val.spr) : 1;
				
				gpu_set_tex_filter(true);
				draw_sprite_uniform(_val.spr, _val.spr_ind, ui(8) + hght / 2, _yy, _ss, _val.spr_blend);
				gpu_set_tex_filter(false);
			}
			
			_ly += hght;
			_h  += hght;
		}
		
		if(update_hover) {
			UNDO_HOLDING = true;
			
			     if(hov != noone) scrollbox.onModify(array_find(scrollbox.data, hov));
			else if(initVal > -1) scrollbox.onModify(initVal);
				
			UNDO_HOLDING = false;
		}
		
		if(sc_content.active) {
			if(KEYBOARD_PRESSED == vk_up) {
				selecting--;
				if(selecting < 0) selecting = array_length(data) - 1;
			}
			
			if(KEYBOARD_PRESSED == vk_down)
				selecting = safe_mod(selecting + 1, array_length(data));
				
			if(keyboard_check_pressed(vk_escape))
				instance_destroy();
		}
		
		return _h;
	});
	
	sc_content.scroll_resize = false;
#endregion
