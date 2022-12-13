function Node_Display_Text(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Display text";
	w = 240;
	h = 160;
	min_h = 0;
	bg_spr		= THEME.node_frame_bg;
	
	size_dragging = false;
	size_dragging_w = w;
	size_dragging_h = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height = false;
	name_hover = false;
	draw_scale = 1;
	
	inputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 1] = nodeValue(1, "Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "Text");
	
	inputs[| 2] = nodeValue(2, "Style", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Header", "Sub header", "Normal"])
	
	inputs[| 3] = nodeValue(3, "Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.75)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
	
	inputs[| 4] = nodeValue(4, "Line width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1000000);
	
	input_display_list = [1, 
		["Styling", false], 2, 0, 3, 4];
	
	_prev_text = "";
	font = f_p1;
	_lines = [];
	
	static draw_text_style = function(_x, _y, txt, _s) {
		var _tx = _x;
		var index = 1;
		var _len = string_length(txt);
		var _ch = "";
		var _tw, _th;
		var _ch_h = string_height("l") * _s;
		var _mode = 0;
		var _cmd = "";
		
		var width = 0;
		
		var _cc = draw_get_color();
		
		while(index <= _len) {
			_ch = string_char_at(txt, index);
			index++;
			
			switch(_ch) {
				case "<" : 
					_mode = 1; 
					continue;
				case ">" : 
					var _c = string_splice(_cmd, " ");
					
					if(array_length(_c) > 1) {
						switch(_c[0]) {
							case "bt" :
								var _bch = "";
								for( var i = 1; i < array_length(_c); i++ ) {
									if(i > 1) _bch += " ";
									_bch += _c[i];
								}
								_tw = string_width(_bch) * _s;
								_th = string_height(_bch) * _s;
									
								draw_set_color(COLORS.node_display_text_frame_outline);
								draw_roundrect_ext(_tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4, 8, 8, 0);
								draw_set_color(COLORS.node_display_text_frame_fill);
								draw_roundrect_ext(_tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4, 8, 8, 1);
									
								draw_set_color(_cc);
								draw_text_transformed(_tx, _y, _bch, _s, _s, 0);
								_tx += _tw;
								width += string_width(_bch);
								break;
							case "spr" :
								var _spr_t = _c[1];
								if(!variable_struct_exists(THEME, _spr_t)) break;
								var _spr = variable_struct_get(THEME, _spr_t);
								
								var _spr_i = array_length(_c) > 2? real(_c[2]) : 0;
								var _spr_s = array_length(_c) > 3? _s * real(_c[3]) : _s;
								
								_tw = sprite_get_width(_spr);
								_th = sprite_get_height(_spr) * _spr_s;
								var _ow = sprite_get_xoffset(_spr) * _spr_s;
								var _oh = sprite_get_yoffset(_spr) * _spr_s;
								
								draw_sprite_ext(_spr, _spr_i, _tx + _ow, _y + _ch_h / 2 - _th / 2 + _oh, _spr_s, _spr_s, 0, c_white, 1);
								
								_tx += _tw * _spr_s;
								width += _tw;
								break;
						}
					}
					
					_mode = 0; 
					_cmd = "";
					continue;
			}
			
			switch(_mode) {
				case 0 :	
					_tw = string_width(_ch);
					_th = string_height(_ch);
			
					draw_text_transformed(_tx, _y, _ch, _s, _s, 0);
					_tx += _tw * _s;
					width += _tw;
					break;
				case 1 : 
					_cmd += _ch;
					break;
			}
		}
		
		return width;
	}
	
	static string_raw = function(txt) {
		var index = 1;
		var _len = string_length(txt);
		var _ch = "";
		var _mode = 0;
		var ss = "";
		var ch_str = "";
		
		while(index <= _len) {
			_ch = string_char_at(txt, index);
			index++;
			
			switch(_ch) {
				case "<" : 
					_mode = 1; continue;
				case ">" : 
					var _c = string_splice(ch_str, " ");
					
					if(array_length(_c) > 1) {
						switch(_c[0]) {
							case "bt" :
								var _bch = "";
								for( var i = 1; i < array_length(_c); i++ ) {
									if(i > 1) _bch += " ";
									_bch += _c[i];
								}
								
								ss += _bch;
								break;
						}
					}
					
					ch_str = "";
					_mode = 0; 
					continue;
			}
			
			switch(_mode) {
				case 0 : ss += _ch; break;
				case 1 : ch_str += _ch; break;
			}
		}
		
		return ss;
	}
	
	static line_update = function(txt, line_width = 999999) {
		_prev_text = txt;
		_lines = [];
		
		var ch, i = 1, ss = "", _txt = _prev_text;
		var len = string_length(_prev_text);
		
		draw_set_font(font);
		while(string_length(_txt) > 0) {
			var sp = string_pos(" ", _txt);
			if(sp == 0) sp = string_length(_txt);
			
			var _ps = string_copy(_txt, 1, sp);
			_txt = string_copy(_txt, sp + 1, string_length(_txt) - sp);
			
			if(string_width(string_raw(ss + _ps)) >= line_width) {
				array_push(_lines, ss);
				ss = _ps;
			} else if(string_length(_txt) <= 0) {
				array_push(_lines, ss + _ps);
				ss = "";
			} else {
				ss += _ps;	
			}
		}
		
		if(ss != "") 
			array_push(_lines, ss);
	}
	
	static onValueUpdate = function(index) {
		if(index == 1 || index == 4)
			line_update(inputs[| 1].getValue(), inputs[| 4].getValue());
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		var color  = inputs[| 0].getValue();
		var txt = inputs[| 1].getValue();
		if(txt == "") txt = "..."
		var sty = inputs[| 2].getValue();
		var alp = inputs[| 3].getValue();
		var wid = inputs[| 4].getValue();
		
		font = f_p1;
		switch(sty) {
			case 0 : font = f_h3; break;
			case 1 : font = f_h5; break;
			case 2 : font = f_p1; break;
		}
		
		var ww = 0;
		var hh = 0;
		var tx = xx + 4;
		var ty = yy + 4;
		
		if(_prev_text != txt)
			line_update(txt, wid);
		
		draw_set_alpha(alp);
		draw_set_text(font, fa_left, fa_top, color);
		for( var i = 0; i < array_length(_lines); i++ ) {
			var _line = _lines[i];
			var _h = line_height(font);
			var _w = draw_text_style(tx, ty, _line, _s);
			
			ww = max(ww, _w);
			hh += _h;
			ty += _h * _s;
		}
		draw_set_alpha(1);
		
		draw_scale = _s;
		w = ww + 8;
		h = hh + 8;
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, xx, yy, w * _s, h * _s, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		drawNodeBase(xx, yy, _s);
		return noone;
	}
}