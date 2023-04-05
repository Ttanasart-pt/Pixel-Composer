/// @description init
event_inherited();

#region 
	max_h	  = 640;
	align	  = fa_center;
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
		dialog_w	= scroll.w;
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
		for( var i = 0; i < array_length(scrollbox.data); i++ ) {
			var val = scrollbox.data[i];
			
			if(val == -1) continue;
			if(string_pos(string_lower(search_string), string_lower(val)) > 0)
				array_push(data, val);
		}
		
		setSize();
	}
	
	function setSize() {
		var hght = line_height(f_p0, 8);
		var hh	 = ui(16 + 24);
		
		for( var i = 0; i < array_length(data); i++ )
			hh += data[i] == -1? ui(8) : hght;
		
		dialog_h = min(max_h, hh);
		sc_content.resize(dialog_w, dialog_h);
		
		resetPosition();
	}
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_height(f_p0, 8);
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		var hovering  = "";
		
		for(var i = 0; i < array_length(data); i++) {
			var txt  = data[i];
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
				if(sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
					selecting = i;
					hovering  = data[i];
				}
			
				if(selecting == i) {
					draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
					if(sc_content.active && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter))) {
						initVal = array_find(scrollbox.data, txt);
						instance_destroy();
					}
				}
			}
					
			draw_set_text(f_p0, align, fa_center, clickable? COLORS._main_text : COLORS._main_text_sub);
			if(align == fa_center)
				draw_text_cut(_dw / 2, _ly + hght / 2, txt, _dw);
			else if(align == fa_left)
				draw_text_cut(ui(8), _ly + hght / 2, txt, _dw);
			
			_ly += hght;
			_h  += hght;
		}
		
		if(update_hover) {
			UNDO_HOLDING = true;
			if(hovering != "")
				scrollbox.onModify(array_find(scrollbox.data, hovering));
			else
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
