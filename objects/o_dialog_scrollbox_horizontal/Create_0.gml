/// @description init
event_inherited();

#region 
	max_h	 = 640;
	
	horizon  = true;
	font     = f_p0
	align	 = fa_center;
	text_pad = ui(8);
	item_pad = ui(8);
	widths   = [];
	
	draggable = false;
	destroy_on_click_out = true;
	
	selecting	  = -1;
	scrollbox	  = noone;
	data		  = [];
	initVal		  = 0;
	update_hover  = true;
	
	search_string	= "";
	KEYBOARD_STRING	= "";
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) { 
		search_string = string(str); 
		filterSearch();
	});
	tb_search.font	= f_p2;
	tb_search.color	= COLORS._main_text_sub;
	tb_search.align	= fa_left;
	tb_search.auto_update	= true;
	WIDGET_CURRENT			= tb_search;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	function initScroll(scroll) {
		scrollbox	= scroll;
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
			if(string_pos(string_lower(search_string), string_lower(val)) > 0)
				array_push(data, val);
		}
		
		setSize();
	}
	
	function setSize() {
		
		var _tpad = horizon? text_pad : ui(8);
		var hght  = line_get_height(font) + item_pad;
		var sh    = ui(40);
		
		var ww = 0, tw;
		var hh = 0;
		
		var lw = 0;
		var lh = item_pad;
		var _emp = true;
		
		widths = [];
		
		draw_set_text(font, fa_left, fa_top);
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _val = data[i];
			var  txt = is_instanceof(_val, scrollItem)? _val.name : _val;
			var _spr = is_instanceof(_val, scrollItem) && _val.spr;
			
			if(horizon) {
				if(_val == -1 || i == n - 1) {
					if(_emp) {
						array_push(widths, 0);
					} else {	
						array_push(widths, lw);
						ww += lw;
						hh  = max(hh, lh);
					}
					
					lw = 0;
					lh = item_pad;
					continue;
				}
			} else if(_val == -1) {
				lh += ui(8);
				continue;
			}
			
			_emp = false;
			
			tw  = string_width(txt) + _spr * (hght + _tpad * 2);
			lw  = max(lw, tw + _tpad * 2);
			lh += hght;
		}
		
		if(horizon) {
			dialog_w = max(scrollbox.w, ww) + _tpad * 2;
			dialog_h = min(max_h, sh + hh);
		} else {
			dialog_w = max(scrollbox.w, lw);
			dialog_h = min(max_h, sh + lh);
		}
		
		sc_content.resize(dialog_w - _tpad * 2, dialog_h - ui(40));
		
		resetPosition();
	}
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_get_height(font) + item_pad;
		var _lx  = 0;
		var _ly  = _y;
		var _lw  = 0;
		var _lh  = 0;
		var _h   = 0;
		var _col = 0;
		var hovering  = "";
		var _tpad     = horizon? text_pad : ui(8);
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _dw  = horizon? widths[_col] : sc_content.surface_w;
			var _val = data[i];
			
			if(horizon) {
				if(_val == -1 || i == n -1) {
					_lx += _dw;
					_ly  = _y;
					_col++;
					
					_h   = max(_h, _lh);
					_lh  = 0;
					_lw  = 0;
					
					continue;
				}
				
				if(_dw == 0) continue;
				
			} else if(_val == -1) {
				draw_sprite_stretched(THEME.menu_separator, 0, ui(8), _ly, _dw - ui(16), ui(6));
				_ly += ui(8);
				_lh += ui(8);
				
				continue;
			}
			
			var  txt = is_instanceof(_val, scrollItem)? _val.name : _val;
			var _spr = is_instanceof(_val, scrollItem) && _val.spr;
			var _tol = is_instanceof(_val, scrollItem) && _val.tooltip != "";
			
			var clickable = !string_starts_with(txt, "-");
			var subitem   =  string_starts_with(txt, ">");
			txt = string_trim_start(txt, ["-", ">", " "]);
			
			var _hov = false;
			
			if(clickable) {
				if(sc_content.hover && point_in_rectangle(_m[0], _m[1], _lx, _ly, _lx + _dw, _ly + hght - 1)) {
					_hov = true;
					selecting = i;
					hovering  = data[i];
					
					if(_tol) TOOLTIP = _val.tooltip;
				}
			
				if(selecting == i) {
					draw_sprite_stretched_ext(THEME.textbox, 3, _lx, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
					if(sc_content.active && (mouse_press(mb_left, _hov) || keyboard_check_pressed(vk_enter))) {
						initVal = array_find(scrollbox.data, _val);
						instance_destroy();
					}
				}
			}
				
			align = fa_left;
			
			draw_set_text(font, align, fa_center, subitem? COLORS._main_text_sub : COLORS._main_text);
			if(align == fa_center) {
				var _xc = _spr? hght + (_dw - hght) / 2 : _dw / 2;
				draw_text_add(_lx + _xc, _ly + hght / 2, txt);
				
			} else if(align == fa_left) 
				draw_text_add(_tpad + _lx + _spr * (_tpad * 2 + hght), _ly + hght / 2, txt);
			
			if(_spr) draw_sprite_ext(_val.spr, _val.spr_ind, _lx + ui(8) + hght / 2, _ly + hght / 2, 1, 1, 0, _val.spr_blend, 1);
			
			_ly += hght;
			_lh += hght;
		}
		
		if(!horizon) _h = _lh + ui(8);
		
		if(update_hover) {
			UNDO_HOLDING = true;
				 if(hovering != "") scrollbox.onModify(array_find(scrollbox.data, hovering));
			else if(initVal > -1)   scrollbox.onModify(initVal);
			UNDO_HOLDING = false;
		}
		
		if(sc_content.active) {
			if(keyboard_check_pressed(vk_up)) {
				selecting--;
				if(selecting < 0) selecting = array_length(data) - 1;
			}
			
			if(keyboard_check_pressed(vk_down))
				selecting = safe_mod(selecting + 1, array_length(data));
				
			if(keyboard_check_pressed(vk_escape))
				instance_destroy();
		}
		
		return _h;
	});
#endregion
