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
			if(string_pos(string_lower(search_string), string_lower(val)) > 0)
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
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_get_height(font) + item_pad;
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		var hovering  = "";
		
		for(var i = 0; i < array_length(data); i++) {
			var _val = data[i];
			var txt  = is_instanceof(_val, scrollItem)? _val.name : _val;
			var _spr = is_instanceof(_val, scrollItem) && _val.spr;
			var _tol = is_instanceof(_val, scrollItem) && _val.tooltip != "";
			
			var clickable = !string_starts_with(txt, "-");
			if(!clickable)
				txt = string_delete(txt, 1, 1);
			
			if(data[i] == -1) {
				draw_sprite_stretched(THEME.menu_separator, 0, ui(8), _ly, _dw - ui(16), ui(6));
				_ly += ui(8);
				_h  += ui(8);
				
				continue;
			}
			
			if(clickable) {
				if(sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, _ly, _dw, _ly + hght - 1)) {
					sc_content.hover_content = true;
					selecting = i;
					hovering  = data[i];
					
					if(_tol) TOOLTIP = _val.tooltip;
				}
			
				if(selecting == i) {
					draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
					if(sc_content.active && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter))) {
						initVal = array_find(scrollbox.data, _val);
						instance_destroy();
					}
				}
			}
				
			draw_set_text(font, align, fa_center, clickable? COLORS._main_text : COLORS._main_text_sub);
			if(align == fa_center) {
				var _xc = _spr? hght + (_dw - hght) / 2 : _dw / 2;
				draw_text_cut(_xc, _ly + hght / 2, txt, _dw);
				
			} else if(align == fa_left) 
				draw_text_cut(text_pad + _spr * hght, _ly + hght / 2, txt, _dw);
			
			if(_spr) draw_sprite_ext(_val.spr, _val.spr_ind, ui(8) + hght / 2, _ly + hght / 2, 1, 1, 0, _val.spr_blend, 1);
			
			_ly += hght;
			_h  += hght;
		}
		
		if(update_hover) {
			UNDO_HOLDING = true;
			if(hovering != "")
				scrollbox.onModify(array_find(scrollbox.data, hovering));
			else if(initVal > -1)
				scrollbox.onModify(initVal);
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
