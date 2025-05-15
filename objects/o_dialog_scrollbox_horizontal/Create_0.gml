/// @description init
event_inherited();

#region 
	max_w	 = ui(640);
	max_h	 = ui(640);
	
	horizon  = true;
	font     = f_p0
	align	 = fa_center;
	text_pad = ui(8);
	item_pad = ui(8);
	minWidth = 0;
	widths   = [];
	heights  = [];
	
	minHeight = 0;
	
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
					.setFont(f_p2)
					.setAutoUpdate();
					
	tb_search.align	= fa_left;
	WIDGET_CURRENT	= tb_search;
	
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
			
			var _txt = is(val, scrollItem)? val.name : val;
			if(string_pos(string_lower(search_string), string_lower(_txt)) > 0)
				array_push(data, val);
		}
		
		setSize();
	}
	
	function setSize() {
		
		var _hori = horizon && search_string == "";
		var _tpad = _hori? text_pad : ui(8);
		var hght  = line_get_height(font) + item_pad;
		var sh    = ui(40);
		
		var ww = 0, tw;
		var hh = 0;
		
		var lw = 0;
		var lh = 0;
		var _emp = true;
		
		widths  = [];
		heights = [];
		
		draw_set_text(font, fa_left, fa_top);
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _val = data[i];
			var  txt = is(_val, scrollItem)? _val.name : _val;
			var _spr = is(_val, scrollItem) && _val.spr;
			
			if(_hori) {
				if(_val == -1) {
					if(_emp) {
						array_push(widths,  0);
						array_push(heights, 0);
						
					} else {	
						lw = max(minWidth,  lw);
						array_push(widths,  lw);
						array_push(heights, lh);
						
						ww += lw;
						hh  = max(hh, lh);
					}
					
					lw = 0;
					lh = 0;
					continue;
				}
			} else if(_val == -1) {
				lh += ui(8);
				continue;
			}
			
			_emp = false;
			
			tw     = string_width(txt) + _spr * (hght + _tpad) + _tpad * 2;
			lw     = max(lw, tw);
			lh    += hght;
		}
		
		lw = max(minWidth, lw);
		
		array_push(widths,  _emp? 0 : lw);
		array_push(heights, _emp? 0 : lh);
		ww += lw;
		hh  = max(hh, lh);
		
		if(_hori) {
			dialog_w = max(scrollbox.w, ww) + _tpad * 2;
			dialog_h = min(max_h, sh + hh + ui(8));
			
		} else {
			dialog_w = max(scrollbox.w, lw);
			dialog_h = min(max_h, sh + lh + ui(8));
		}
		
		if(_hori && (dialog_w >= max_w || dialog_w / dialog_h > 2)) {
			var wwCur = 0;
			minHeight = max(hh, sqrt(ww * hh));
			
			var lwMin = 0;
			var lhMin = 0;
			var lhMax = 0;
			
			for( var i = 0, n = array_length(heights); i < n; i++ ) {
				var _w = widths[i];
				var _h = heights[i];
				
				if(lhMin + _h > minHeight) {
					wwCur += lwMin;
					lwMin = 0;
					lhMin = 0;
					
				} else {
					_h += ui(8);
				}
				
				lwMin = max(lwMin, _w);
				lhMin += _h;
				lhMax = max(lhMax, lhMin);
			}
			
			wwCur += lwMin;
			dialog_w = wwCur + _tpad * 2 + ui(12);
			dialog_h = max(sh + lhMax + ui(8), hh);
		}
		
		sc_content.resize(dialog_w - _tpad * 2, dialog_h - ui(40));
		
		resetPosition();
	}
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var hght = line_get_height(font) + item_pad;
		var _lx  = 0;
		var _ly  = _y;
		var _lw  = 0;
		var _lh  = 0;
		var _h   = 0;
		var _col = 0;
		var hovering  = "";
		var _hori     = horizon && search_string == "";
		var _tpad     = _hori? text_pad : ui(8);
		
		var _ww = sc_content.surface_w;
		var _hh = sc_content.surface_h;
		var _dw = 0;
		
		if(MOUSE_MOVED) selecting = noone;
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _val = data[i];
			_dw  = max(_dw, _hori? widths[_col] : _ww);
			
			if(_hori) {
				if(_val == -1) {
					_col++;
					var _ch = heights[_col];
					
					if(_lh + _ch > minHeight) {
						_lx += _dw;
						_ly  = _y;
						
						_h   = max(_h, _lh);
						_dw  = 0;
						_lh  = 0;
						_lw  = 0;
						
					} else {
						draw_set_color(CDEF.main_mdblack);
						draw_line_width(_lx + ui(8), _ly + ui(4), _lx + _dw - ui(8), _ly + ui(4), ui(2));
						
						_ly += ui(8);
						_lh += ui(8);
					}
					continue;
				}
				
				if(_dw == 0) continue;
				
			} else if(_val == -1) {
				draw_set_color(CDEF.main_mdblack);
				draw_line_width(ui(8), _ly + ui(3), _dw - ui(8), _ly + ui(3), ui(2));
				
				_ly += ui(8);
				_lh += ui(8);
				continue;
			}
			
			var _txt = _val, _spr = noone, _tol = false, _act = true, _sub = false;
			
			if(is(_val, scrollItem)) {
				_act = _val.active;
				_txt = _val.name;
				_spr = _val.spr;
				_tol = _val.tooltip != "";
				
			} else {
				_act = !string_starts_with(_txt, "-");
				_sub =  string_starts_with(_txt, ">");
				_txt =  string_trim_start(_txt, ["-", ">", " "]);
			}
			
			var _hov = false;
			
			if(_act) {
				if(sc_content.hover && point_in_rectangle(_m[0], _m[1], _lx, _ly, _lx + _dw, _ly + hght - 1)) {
					sc_content.hover_content = true;
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
			
			draw_set_text(font, align, fa_center, _sub? COLORS._main_text_sub : COLORS._main_text);
			if(align == fa_center) {
				var _xc = _spr != noone? hght + (_dw - hght) / 2 : _dw / 2;
				draw_text_add(_lx + _xc, _ly + hght / 2, _txt);
				
			} else if(align == fa_left) {
				var _tx = _tpad + _lx;
				if(_spr != noone) _tx += _tpad + hght;
				
				draw_text_add(_tx, _ly + hght / 2, _txt);
			}
			
			if(_spr) {
				var _ss = 28 / sprite_get_height(_val.spr);
				draw_sprite_uniform(_val.spr, _val.spr_ind, _lx + ui(8) + hght / 2, _ly + hght / 2, _ss, _val.spr_blend);
			}
			
			_ly += hght;
			_lh += hght;
		}
		
		if(!_hori) _h = _lh + ui(8);
		
		if(update_hover) {
			UNDO_HOLDING = true;
				 if(hovering != "") scrollbox.onModify(array_find(scrollbox.data, hovering));
			else if(initVal > -1)   scrollbox.onModify(initVal);
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
		
		return _h + ui(8);
	});
	
	sc_content.scroll_resize = false;
#endregion
