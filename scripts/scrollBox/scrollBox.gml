function scrollItem(_name, _spr = noone, _spr_ind = 0, _spr_blend = COLORS._main_icon) constructor {
	name = _name;
	data = _name;
	
	spr       = _spr;
	spr_ind   = _spr_ind;
	spr_blend = _spr_blend;
	spr_scale = true;
	
	active  = true;
	tooltip = "";
	
	static setSpriteScale = function( ) /*=>*/ { spr_scale = false; return self; }
	static setBlend       = function(c) /*=>*/ { spr_blend = c;     return self; }
	static setActive      = function(a) /*=>*/ { active    = a;     return self; }
	static setTooltip     = function(t) /*=>*/ { tooltip   = t;     return self; }
}

function scrollBox(_data, _onModify, _update_hover = true) : widget() constructor {
	update_hover = _update_hover;
	
	onModify  = _onModify;	
	data_list = _data;
	data      = _data;
	curr_text = 0;
	
	arrow_spr = THEME.scroll_box_arrow;
	arrow_ind = 0;
	
	open    = false;
	open_rx = 0;
	open_ry = 0;
	filter  = true;
	
	align          = fa_center;
	horizontal     = false;
	padding        = ui(8);
	padding_scroll = ui(8);
	item_pad       = ui(8);
	text_color     = COLORS._main_text;
	show_icon      = true;
	
	minWidth = 0;
	type = 0;
	hide = 0;
	
	static setType          = function(_l) /*=>*/ { type           = _l; return self; }
	static setHorizontal    = function(_l) /*=>*/ { horizontal     = _l; return self; }
	static setAlign         = function(_l) /*=>*/ { align          = _l; return self; }
	static setTextColor     = function(_l) /*=>*/ { text_color     = _l; return self; }
	static setUpdateHover   = function(_l) /*=>*/ { update_hover   = _l; return self; }
	static setMinWidth      = function(_l) /*=>*/ { minWidth       = _l; return self; }
	static setFilter        = function(_l) /*=>*/ { filter         = _l; return self; }
	static setPadding       = function(_l) /*=>*/ { padding        = _l; return self; }
	static setPaddingItem   = function(_l) /*=>*/ { item_pad       = _l; return self; }
	static setPaddingScroll = function(_l) /*=>*/ { padding_scroll = _l; return self; }
	
	static trigger = function() {
		data = is_method(data_list)? data_list() : data_list;
		
		var ind = array_find(data, curr_text);
		open    = true;
		
		FOCUS_BEFORE = FOCUS;
		var _object;
		
		switch(horizontal) {
			case 0 : _object = o_dialog_scrollbox;            break;
			case 1 : _object = o_dialog_scrollbox_horizontal; break;
			case 2 : _object = o_dialog_scrollbox_grid;       break;
		}
		
		with(dialogCall(_object, x + open_rx, y + open_ry)) {
			initVal      = ind;
			font         = other.font;
			align        = other.align;
			text_pad     = other.padding;
			item_pad     = other.item_pad;
			update_hover = other.update_hover;
			minWidth     = other.minWidth;
			
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
		
		if(horizontal == 2) h = ui(80);
		
		data = is_method(data_list)? data_list() : data_list;
		
		if(array_empty(data)) {
			draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, h);
			
			if(type == 0) {
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, h, c_white, 0.5);
				draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
				draw_text_add(_x + _w / 2, _y + h / 2, "no data");
			}
			return h;
		}
		
		var _selVal = _val;
		
		if(is_array(_val)) return 0;
		if(is_numeric(_val)) _selVal = array_safe_get_fast(data, _val);
		
		var _text = is_instanceof(_selVal, scrollItem)? _selVal.name : _selVal;
		if(is_string(_text)) _text = string_trim_start(_text, ["-", ">", " "]);
		curr_text = _text;
		
		w = _w;
		draw_set_font(type == 1? f_p0b : font);
		var _txw = is_string(_text)? string_width(_text) : ui(32);
		if(type == 1) w = _txw + padding * 2 + ui(24);
		
		var _bs = min(h, ui(32));
		
		if(side_button != noone) {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			w -= _bs + ui(4);
		}
		
		if(_w - _bs > ui(100) && front_button) {
			front_button.setFocusHover(active, hover);
			front_button.draw(_x, _y + h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			
			_x += _bs + ui(4);
			 w -= _bs + ui(4);
		}
		
		if(open) { resetFocus(); return h; }
		
		if(type == 0 && hide == 0) draw_sprite_stretched(THEME.textbox, 3, _x, _y, w, h);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + w, _y + h)) {
			if(type == 0) draw_sprite_stretched(THEME.textbox, 1, _x, _y, w, h);
			if(type == 1) draw_sprite_stretched(THEME.button_hide_fill, 1, _x, _y, w, h);
			
			if(mouse_press(mb_left, active))
				trigger();
				
			if(mouse_click(mb_left, active))
				draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, w, h, COLORS._main_accent, 1);	
			
			if(is_array(data_list) && key_mod_press(SHIFT)) {
				var len = array_length(data_list);
				var ind = safe_mod(_val + sign(MOUSE_WHEEL) + len, len);
				if(len && MOUSE_WHEEL != 0) onModify(ind);
				
			}
		} else {
			if(type == 0 && hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, w, h, c_white, 0.5 + 0.5 * interactable);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var _arr = h > ui(16);
		var _sps = min(1, h / 24);
		var _ars = .6;
		var _arw = _arr * (sprite_get_width(arrow_spr) * _ars + ui(8));
		var _spr = is_instanceof(_selVal, scrollItem) && _selVal.spr;
		
		var _x0  = _x;
		var _x1  = _x + w - _arw;
		var _yc = _y + h / 2;
		
		if(_spr) _x0 += ui(32);
		var _xc  = (_x0 + _x1) / 2;
		var _tx1 = _x;
		
		var _sci = gpu_get_scissor();
		gpu_set_scissor(_x, _y, _w, _h);
		
		if(show_icon && horizontal == 2) {
			if(_spr) {
				var _ss = (h - ui(32)) / sprite_get_height(_selVal.spr);
				
				gpu_set_tex_filter(filter);
				draw_sprite_uniform(_selVal.spr, _selVal.spr_ind, _xc, _y + ui(4) + (h - ui(32)) / 2, _ss, _selVal.spr_blend);
				gpu_set_tex_filter(false);
			}
			
			draw_set_text(f_p2, fa_center, fa_bottom, text_color);
			draw_text_add(_xc, _y + h - ui(4), _text);
			
		} else {
			draw_set_text(type == 1? f_p0b : font, align, fa_center, text_color);
			
			if(is_string(_text))  {
				
				draw_set_alpha(0.5 + 0.5 * interactable);
						 if(align == fa_center) { draw_text_add(_xc, _yc, _text, _sps);           _tx1 = _xc + _txw / 2;       }
					else if(align == fa_left)   { draw_text_add(_x0 + padding, _yc, _text, _sps); _tx1 = _x0 + padding + _txw; }
				draw_set_alpha(1);
				
			} else if(sprite_exists(_selVal)) {
				draw_sprite_ext(_selVal, _val, _xc, _yc);
			}
			
			if(show_icon && _spr) {
				var _ss = (h - ui(4)) / sprite_get_height(_selVal.spr);
				
				gpu_set_tex_filter(filter);
				draw_sprite_uniform(_selVal.spr, _selVal.spr_ind, _x + h / 2, _yc, _ss, _selVal.spr_blend);
				gpu_set_tex_filter(false);
			}
		}
		
		if(_arr) {
			if(type == 0) draw_sprite_ui_uniform(arrow_spr, arrow_ind, _x1 + _arw / 2, _yc, _ars, COLORS._main_icon, 0.5 + 0.5 * interactable);
			if(type == 1) draw_sprite_ui_uniform(arrow_spr, arrow_ind, _tx1 + ui(16),  _yc, _ars, COLORS._main_icon, 0.5 + 0.5 * interactable);
		}
		
		gpu_set_scissor(_sci);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new scrollBox(data, onModify, update_hover);
		return cln;
	}
}