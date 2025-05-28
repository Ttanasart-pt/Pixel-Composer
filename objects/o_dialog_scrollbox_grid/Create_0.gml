/// @description init
event_inherited();

#region 
	max_h	 = 640;
	
	font     = f_p0
	align	 = fa_center;
	text_pad = ui(8);
	item_pad = ui(8);
	
	grid_width  = ui(80);
	grid_height = ui(88);
	grid_pad    = ui(4);
	
	draggable = false;
	destroy_on_click_out = true;
	
	selecting	  = -1;
	scrollbox	  = noone;
	data		  = [];
	initVal		  = 0;
	update_hover  = true;
	
	KEYBOARD_RESET
	search_string = "";
	tb_search     = new textBox(TEXTBOX_INPUT.text, function(s) /*=>*/ { search_string = string(s); filterSearch(); })
					.setAutoUpdate().setEmpty().setFont(f_p2).setAlign(fa_left);
	
	WIDGET_CURRENT  = tb_search;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	function initScroll(scroll) {
		scrollbox	= scroll;
		dialog_w	= max(ui(200), scroll.w);
		data		= scroll.data;
		
		grid_width  = ui(80);
		grid_height = ui(88);
		draw_set_font(f_p4);
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _val = data[i];
			var _txt = _val.name;
			
			var _tw = string_width(_txt);
			grid_width = max(grid_width, _tw + ui(24));
		}
		
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
		var len = array_length(data);
		var col = min(len, 6);
		var row = min(ceil(len / col), 4);
		
		var ww = grid_width  * col + grid_pad * (col - 1);
		var hh = grid_height * row + grid_pad * (row - 1) + ui(40);
		
		dialog_w = ww;
		dialog_h = hh;
		
		sc_content.resize(dialog_w, dialog_h - ui(40));
		
		resetPosition();
	}
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var hght = line_get_height(font) + item_pad;
		var _dw  = sc_content.surface_w;
		var hov  = noone;
		var gw   = grid_width;
		var gh   = grid_height;
		
		var len  = array_length(data);
		var col  = min(len, 6);
		var row  = ceil(len / col);
		var _h   = row * gh + grid_pad * (row - 1);
		
		if(MOUSE_MOVED) selecting = noone;
		
		for( var i = 0; i < len; i++ ) {
			var _val = data[i];
			
			var _act = _val.active;
			var _txt = _val.name;
			var _spr = _val.spr;
			var _tol = _val.tooltip != "";
			var _sca = _val.spr_scale;
			
			var _cc  = i % col;
			var _rr  = floor(i / col);
			var _xx  =      gw * _cc + grid_pad * _cc;
			var _yy  = _y + gh * _rr + grid_pad * _rr;
			
			if(_act) {
				if(sc_content.hover && point_in_rectangle(_m[0], _m[1], _xx, _yy, _xx + gw, _yy + gh)) {
					sc_content.hover_content = true;
					selecting = i;
					hov       = _val;
				}
			
				if(selecting == i) {
					draw_sprite_stretched_ext(THEME.textbox, 3, _xx, _yy, gw, gh, COLORS.dialog_menubox_highlight, 1);
					
					if(sc_content.active && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter))) {
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
			
			if(_spr) {
				var _sw = sprite_get_width(_spr);
				var _sh = sprite_get_height(_spr);
				var _ss = min((gw - ui(16)) / _sw, (gh - ui(24)) / _sh);
            	
            	var _sx = _xx + gw / 2;
            	var _sy = _yy + ui(4) + (gh - ui(24)) / 2;
            	
				draw_sprite_ext(_spr, _val.spr_ind, _sx, _sy, _ss, _ss, 0, _val.spr_blend);
			}
			
			draw_set_text(f_p4, fa_center, fa_bottom, _act? COLORS._main_text : COLORS._main_text_sub);
			draw_text_add(_xx + gw / 2, _yy + gh - ui(4), _txt);
			
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
