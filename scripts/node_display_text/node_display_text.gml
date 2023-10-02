function Node_Display_Text(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Display Text";
	w = 240;
	h = 160;
	
	bg_spr		= THEME.node_frame_bg;
	
	size_dragging = false;
	size_dragging_w = w;
	size_dragging_h = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height = false;
	name_hover  = false;
	draw_scale  = 1;
	
	ta_editor   = new textArea(TEXTBOX_INPUT.text, function(val) { inputs[| 1].setValue(val); })
	
	inputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white )
		.rejectArray();
	
	inputs[| 1] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "Text")
		.rejectArray();
	
	inputs[| 2] = nodeValue("Style", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Header", "Sub header", "Normal"])
		.rejectArray();
	
	inputs[| 3] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.75)
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	inputs[| 4] = nodeValue("Line width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, -1)
		.rejectArray();
	
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
									
								draw_sprite_stretched_points(THEME.node_bg, 0, _tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4);
									
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
	
	static line_update = function(txt, line_width = -1) {
		_prev_text = txt;
		_lines = [];
		
		var ch, i = 1, ss = "", _txt = _prev_text;
		var len = string_length(_prev_text);
		
		var _line_man = string_splice(_txt, "\n");
		
		draw_set_font(font);
		
		for( var i = 0, n = array_length(_line_man); i < n; i++ ) {
			var _tx = _line_man[i];
			
			while(string_length(_tx) > 0) {
				var sp = min(string_pos(" ", _tx));
				if(sp == 0) sp = string_length(_tx);
			
				var _ps = string_copy(_tx, 1, sp);
				_tx = string_copy(_tx, sp + 1, string_length(_tx) - sp);
			
				if(line_width > 0 && string_width(string_raw(ss + _ps)) >= line_width) {
					array_push(_lines, ss);
					ss = _ps;
				} else if(string_length(_tx) <= 0) {
					array_push(_lines, ss + _ps);
					ss = "";
				} else 
					ss += _ps;	
			}
		}
		
		if(ss != "") array_push(_lines, ss);
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 1 || index == 4)
			line_update(getInputData(1), getInputData(4));
	}
	
	static drawNodeBase = function(xx, yy, mx, my, _s) {
		var color  = getInputData(0);
		var txt = getInputData(1);
		if(txt == "") txt = "..."
		var sty = getInputData(2);
		var alp = getInputData(3);
		var wid = getInputData(4);
		
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
			
		if(WIDGET_CURRENT == ta_editor) {
			ta_editor.font = font;
			ta_editor.draw(tx, ty, wid * _s, 0, txt, [ mx, my ] );
		} else {
			if(_prev_text != txt)
				line_update(txt, wid);
			
			draw_set_alpha(alp);
			draw_set_text(font, fa_left, fa_top, color);
			for( var i = 0, n = array_length(_lines); i < n; i++ ) {
				var _line = _lines[i];
				var _h = line_get_height(font);
				var _w = draw_text_style(tx, ty, _line, _s);
			
				ww = max(ww, _w);
				hh += _h;
				ty += _h * _s;
			}
			draw_set_alpha(1);
			
			if(PANEL_GRAPH.node_hovering == self && PANEL_GRAPH.node_focus == self) {
				if(point_in_rectangle(mx, my, xx, yy, xx + ww + 8, yy + hh + 8) && DOUBLE_CLICK) {
					ta_editor._current_text = txt;
					ta_editor.activate();
				}
			}
		}
		
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
		
		drawNodeBase(xx, yy, _mx, _my, _s);
		return noone;
	}
}