function scrollItem(name, spr = noone, spr_ind = 0, spr_blend = COLORS._main_icon) constructor {
	self.name = name;
	self.data = name;
	
	self.spr       = spr;
	self.spr_ind   = spr_ind;
	self.spr_blend = spr_blend;
	
	tooltip = "";
	
	static setTooltip = function(_tt) { tooltip = _tt; return self; }
}

function scrollBox(_data, _onModify, update_hover = true) : widget() constructor {
	self.update_hover = update_hover;
	
	onModify  = _onModify;	
	data_list = _data;
	data      = _data;
	curr_text = 0;
	
	arrow_spr = THEME.scroll_box_arrow;
	arrow_ind = 0;
	
	open    = false;
	open_rx = 0;
	open_ry = 0;
	
	align        = fa_center;
	horizontal   = false;
	extra_button = noone;
	padding      = ui(8);
	item_pad     = ui(8);
	
	type = 0;
	
	static trigger = function() {
		if(is_method(data_list)) data = data_list();
		else					 data = data_list;
		
		var ind = array_find(data, curr_text);
		open    = true;
		
		FOCUS_BEFORE = FOCUS;
		with(dialogCall(horizontal? o_dialog_scrollbox_horizontal : o_dialog_scrollbox, x + open_rx, y + open_ry)) {
			initVal      = ind;
			font         = other.font;
			align        = other.align;
			text_pad     = other.padding;
			item_pad     = other.item_pad;
			update_hover = other.update_hover;
			
			initScroll(other);
		}
	}
	
	static drawParam = function(params) {
		setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _val, _m = mouse_ui, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		open_rx = _rx;
		open_ry = _ry;
		h = _h;
		
		if(is_method(data_list)) data = data_list();
		else					 data = data_list;
		
		var _selVal = _val;
		
		if(is_array(_val)) return 0;
		if(is_numeric(_val)) _selVal = array_safe_get_fast(data, _val);
		
		var _text = is_instanceof(_selVal, scrollItem)? _selVal.name : _selVal;
		if(is_string(_text)) _text = string_trim_start(_text, ["-", ">", " "]);
		curr_text = _text;
		
		w = _w;
		draw_set_font(type == 1? f_p0b : font);
		var _txw = is_string(_text)? string_width(_text) : ui(32);
		if(type == 1)
			w = _txw + padding * 2 + ui(24);
		
		if(extra_button != noone) {
			extra_button.setFocusHover(active, hover);
			extra_button.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			w -= ui(40);
		}
		
		if(open) {
			resetFocus();
			return h;
		}
		
		if(type == 0) draw_sprite_stretched(THEME.textbox, 3, _x, _y, w, _h);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + w, _y + _h)) {
			if(type == 0) draw_sprite_stretched(THEME.textbox, 1, _x, _y, w, _h);
			if(type == 1) draw_sprite_stretched(THEME.button_hide_fill, 1, _x, _y, w, _h);
			
			if(mouse_press(mb_left, active))
				trigger();
				
			if(mouse_click(mb_left, active))
				draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, w, _h, COLORS._main_accent, 1);	
			
			if(is_array(data_list) && key_mod_press(SHIFT)) {
				var ind = array_find(data_list, _text);
				var len = array_length(data_list);
				if(len) {
					if(mouse_wheel_down())	onModify(safe_mod(ind + 1 + len, len));
					if(mouse_wheel_up())	onModify(safe_mod(ind - 1 + len, len));
				}
			}
		} else {
			if(type == 0) draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, w, _h, c_white, 0.5 + 0.5 * interactable);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var _sps = min(1, _h / 24);
		var _ars = min(1, _h / 48);
		var _arw = sprite_get_width(arrow_spr) * _ars + ui(8);
		var _spr = is_instanceof(_selVal, scrollItem) && _selVal.spr;
		
		var _x0  = _x;
		var _x1  = _x + w - _arw;
		var _yc = _y + _h / 2;
		
		if(_spr) _x0 += ui(32);
		var _xc  = (_x0 + _x1) / 2;
		var _tx1 = _x;
		
		draw_set_text(type == 1? f_p0b : font, align, fa_center, COLORS._main_text);
		
		if(_h >= line_get_height()) {
			if(is_string(_text))  {
				
				draw_set_alpha(0.5 + 0.5 * interactable);
						 if(align == fa_center) { draw_text_add(_xc, _yc, _text, _sps);           _tx1 = _xc + _txw / 2;       }
					else if(align == fa_left)   { draw_text_add(_x0 + padding, _yc, _text, _sps); _tx1 = _x0 + padding + _txw; }
				draw_set_alpha(1);
				
			} else if(sprite_exists(_selVal)) {
				draw_sprite_ext(_selVal, _val, _xc, _yc);
			}
		}
		
		if(_spr) draw_sprite_ext(_selVal.spr, _selVal.spr_ind, _x + ui(16) * _sps, _yc, _sps, _sps, 0, _selVal.spr_blend, 1);
		
		if(type == 0) draw_sprite_ui_uniform(arrow_spr, arrow_ind, _x1 + _arw / 2, _yc, _ars, COLORS._main_icon, 0.5 + 0.5 * interactable);
		if(type == 1) draw_sprite_ui_uniform(arrow_spr, arrow_ind, _tx1 + ui(16),  _yc, _ars, COLORS._main_icon, 0.5 + 0.5 * interactable);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new scrollBox(data, onModify, update_hover);
		
		return cln;
	}
}