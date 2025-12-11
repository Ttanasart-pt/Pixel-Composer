function __enum_array_gen(arr, spr, col = COLORS._main_icon, ind = undefined) { 
	__spr = spr;
	__c   = col;
	__i   = ind;
	
	return array_map(arr, function(v,i) /*=>*/ {return new scrollItem(v, __spr, __i == undefined? i : __i[i]).setBlend(__c)}); 
}

function scrollItem(_name, _spr = noone, _spr_ind = 0, _spr_blend = COLORS._main_icon) constructor {
	name = _name;
	data = _name;
	
	spr       = _spr;
	spr_ind   = _spr_ind;
	spr_blend = _spr_blend;
	spr_scale = true;
	
	active  = true;
	tooltip = "";
	data    = undefined;
	
	static setSpriteScale = function( ) /*=>*/ { spr_scale = false; return self; }
	static setBlend       = function(c) /*=>*/ { spr_blend = c;     return self; }
	static setActive      = function(a) /*=>*/ { active    = a;     return self; }
	static setTooltip     = function(t) /*=>*/ { tooltip   = t;     return self; }
	static setData        = function(d) /*=>*/ { data      = d;     return self; }
}

function scrollBox(_data, _onModify, _update_hover = true) : widget() constructor {
	update_hover = _update_hover;
	
	onModify  = _onModify;	
	data_list = _data;
	data      = _data;
	curr_val  = -1;
	
	arrow_spr = THEME.scroll_box_arrow;
	arrow_ind = 0;
	
	open      = false;
	open_rx   = 0;
	open_ry   = 0;
	filter    = true;
	
	align          = fa_center;
	horizontal     = false;
	padding        = ui(8);
	padding_scroll = ui(8);
	item_pad       = ui(8);
	text_color     = COLORS._main_text;
	show_icon      = true;
	
	minWidth = 0;
	type     = 0;
	hide     = 0;
	
	static setType          = function(l) /*=>*/ { type           = l; return self; }
	static setHorizontal    = function(l) /*=>*/ { horizontal     = l; return self; }
	static setAlign         = function(l) /*=>*/ { align          = l; return self; }
	static setTextColor     = function(l) /*=>*/ { text_color     = l; return self; }
	static setUpdateHover   = function(l) /*=>*/ { update_hover   = l; return self; }
	static setMinWidth      = function(l) /*=>*/ { minWidth       = l; return self; }
	static setFilter        = function(l) /*=>*/ { filter         = l; return self; }
	static setPadding       = function(l) /*=>*/ { padding        = l; return self; }
	static setPaddingItem   = function(l) /*=>*/ { item_pad       = l; return self; }
	static setPaddingScroll = function(l) /*=>*/ { padding_scroll = l; return self; }
	
	static trigger = function() {
		data = is_method(data_list)? data_list() : data_list;
		
		var ind = curr_val;
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
		w = _w;
		h = _h;
		
		open_rx = _rx;
		open_ry = _ry;
		
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
		curr_val = _val;
		
		var _text = is(_selVal, scrollItem)? _selVal.name : _selVal;
		if(is_string(_text)) _text = string_trim_start(_text, ["-", ">", " "]);
		
		draw_set_font(type == 1? f_p0b : font);
		var _txw = is_string(_text)? string_width(_text) : ui(32);
		if(type == 1) _w = _txw + padding * 2 + ui(24);
		
		var bs = min(h, ui(32));
		if(type == 0 && hide == 0) draw_sprite_stretched(THEME.textbox, 3, _x, _y, w, h);
		
		var _arr = h > ui(16);
		var _sps = min(1, h / 24);
		var _ars = .5;
		var _arw = _arr * (sprite_get_width(arrow_spr) * _ars + ui(8));
		var _spr = is(_selVal, scrollItem) && _selVal.spr;
		
		if(side_button != noone) {
			var bx = _x + _w - bs;
			
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx - _arw, _y, bs + _arw, _h, CDEF.main_mdwhite, 1);
			side_button.setFocusHover(active, hover);
			side_button.draw(bx, _y + h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
			_w -= bs;
		}
		
		if(_w - bs > ui(100) && front_button) {
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, bs, _h, CDEF.main_mdwhite, 1);
			front_button.setFocusHover(active, hover);
			front_button.draw(_x, _y + h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
			
			_x += bs;
			_w -= bs;
		}
		
		if(open) { resetFocus(); return h; }
		
		var _hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + h);
		if(_hovering) {
			if(mouse_press(mb_left, active))
				trigger();
				
			if(is_array(data_list) && !array_empty(data_list) && MOUSE_WHEEL != 0 && key_mod_press(SHIFT)) {
				var len = array_length(data_list);
				var dir = sign(MOUSE_WHEEL);
				var ind = _val;
				
				do {
					ind = safe_mod(ind - dir + len, len);
				} until(data_list[ind] != -1 || ind == _val);
				
				onModify(ind);
			}
		}
		
		var _x0  = _x;
		var _x1  = _x + _w - _arw;
		var _yc  = _y + h / 2;
		
		if(_spr) _x0 += ui(32);
		var _xc  = (_x0 + _x1) / 2;
		var _tx1 = _x;
		
		var _sci = gpu_get_scissor();
		gpu_set_scissor(_x, _y, _w, h);
		
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
			var cc = _hovering? COLORS._main_icon_light : COLORS._main_icon;
			var aa = .4 + .4 * interactable;
			
			if(type == 0) {
				if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _x1, _y, _arw, h, CDEF.main_mdwhite, 1);
				draw_sprite_ui_uniform(arrow_spr, arrow_ind, _x1 + _arw / 2, _yc, _ars, cc, aa);
			}
			
			if(type == 1) {
				if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _tx1, _y, ui(32), h, CDEF.main_mdwhite, 1);
				draw_sprite_ui_uniform(arrow_spr, arrow_ind, _tx1 + ui(16),  _yc, _ars, cc, aa);
			}
		}
		
		gpu_set_scissor(_sci);
		if(hide == 0 && type == 0) draw_sprite_stretched_ext(THEME.textbox, _hovering, _x, _y, w, h, boxColor, .5 + .5 * interactable);
		
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