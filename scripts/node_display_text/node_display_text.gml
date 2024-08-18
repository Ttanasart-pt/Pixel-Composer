function Node_Display_Text(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Display Text";
	setDimension(16, 16);
	
	previewable = false;
	
	size_dragging    = false;
	size_dragging_w  = w;
	size_dragging_h  = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height = false;
	name_hover  = false;
	draw_scale  = 1;
	init_size   = true;
	
	ta_editor   = new textArea(TEXTBOX_INPUT.text, function(val) { inputs[1].setValue(val); })
	
	inputs[0] = nodeValue_Color("Color", self, c_white )
		.rejectArray();
	
	newInput(1, nodeValue_Text("Text", self, "Text"));
	
	inputs[2] = nodeValue_Enum_Scroll("Style", self,  2, [ "Header", "Sub header", "Normal" ])
		.rejectArray();
	
	inputs[3] = nodeValue_Float("Alpha", self, 0.75)
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	inputs[4] = nodeValue_Float("Line width", self, -1)
		.rejectArray();
	
	inputs[5]  = nodeValue_Vec2("Position", self, [ x, y ])
		.rejectArray();
	
	inputs[6] = nodeValue_Float("Line height", self, 0)
		.rejectArray();
		
	input_display_list = [1, 
		["Styling", false], 2, 0, 4, 6, 
		["Display", false], 5, 
	];
	
	_prev_text = "";
	font   = f_sdf_medium;
	fsize  = 1;
	line_h = 0;
	_lines = [];
	draw_simple = false;
	
	pos_x  = x;
	pos_y  = y;
	
	ml_press   = 0;
	ml_release = 0;
	ml_double  = 0;
	mr_press   = 0;
	mr_release = 0;
	mm_press   = 0;
	mm_release = 0;
	
	static move = function(_x, _y, _s) {
		if(x == _x && y == _y) return;
		if(!LOADING) PROJECT.modified = true;
		
		x = _x;
		y = _y;
		
		if(inputs[5].setValue([ _x, _y ]))
			UNDO_HOLDING = true;
	}
	
	static button_reactive_update = function() {
		ml_press   = lerp_float(ml_press  , 0, 5);
		ml_release = lerp_float(ml_release, 0, 5);
		ml_double  = lerp_float(ml_double,  0, 5);
		mr_press   = lerp_float(mr_press  , 0, 5);
		mr_release = lerp_float(mr_release, 0, 5);
		mm_press   = lerp_float(mm_press  , 0, 5);
		mm_release = lerp_float(mm_release, 0, 5);
		
		if(mouse_press(mb_left))     ml_press   = 2;
		if(mouse_release(mb_left))   ml_release = 2;
		if(DOUBLE_CLICK)		     ml_double  = 2;
		if(mouse_press(mb_right))    mr_press   = 2;
		if(mouse_release(mb_right))  mr_release = 2;
		if(mouse_press(mb_middle))   mm_press   = 2;
		if(mouse_release(mb_middle)) mm_release = 2;
	}
	
	static button_reactive = function(key) {
		switch(key) {
			case "left_mouse_click" :		 return clamp(ml_press, 0, 1);
			case "left_mouse_double_click" : return clamp(ml_double, 0, 1);
			case "left_mouse_release" :		 return clamp(ml_release, 0, 1);
			case "left_mouse_drag" :		 return mouse_click(mb_left);
			
			case "right_mouse_click" :		 return clamp(mr_press, 0, 1);
			case "right_mouse_release" :	 return clamp(mr_release, 0, 1);
			case "right_mouse_drag" :		 return mouse_click(mb_right);
			
			case "middle_mouse_click" :		 return clamp(mm_press, 0, 1);
			case "middle_mouse_release" :	 return clamp(mm_release, 0, 1);
			case "middle_mouse_drag" :		 return mouse_click(mb_middle);
			
			case "ctrl" :  return key_mod_press(CTRL);
			case "alt" :   return key_mod_press(ALT);
			case "shift" : return key_mod_press(SHIFT);
			
			case "space" : return keyboard_check(vk_space);
			case "f1" :    return keyboard_check(vk_f1);
			case "f2" :    return keyboard_check(vk_f2);
			case "f3" :    return keyboard_check(vk_f3);
			case "f4" :    return keyboard_check(vk_f4);
			case "f5" :    return keyboard_check(vk_f5);
			case "f6" :    return keyboard_check(vk_f6);
			case "f7" :    return keyboard_check(vk_f7);
			case "f8" :    return keyboard_check(vk_f8);
			case "f9" :    return keyboard_check(vk_f9);
			case "f10" :   return keyboard_check(vk_f10);
			case "f11" :   return keyboard_check(vk_f11);
			case "f12" :   return keyboard_check(vk_f12);
		}
		
		if(string_length(key) == 1) return keyboard_check(ord(string_upper(key)));
		
		return 0;
	}
	
	static draw_text_style = function(_x, _y, txt, _s, _mx, _my) {
		var _ss = _s * fsize;
		
		if(draw_simple) {
			draw_text_add_float(_x, _y, txt, _ss);
			return string_width(txt) * fsize;
		}
		
		var _tx   = _x;
		var index = 1;
		var _len  = string_length(txt);
		var _ch   = "";
		var _ch_h = string_height("l") * _ss;
		var _mode = 0;
		
		var _cmd  = "";
		var _str  = "";
		var width = 0;
		
		var _tw, _th;
		
		var _ff = draw_get_font();
		var _cc = draw_get_color();
		var _aa = draw_get_alpha();
		
		repeat(_len) {
			_ch = string_char_at(txt, index);
			index++;
			
			switch(_ch) {
				case "<" : _mode = 1; continue;
					
				case ">" : 
					var _c = string_splice(_cmd, " ");
					
					if(array_length(_c) > 1) {
						switch(_c[0]) {
							case "bt" :
								var _bch = "";
								for( var i = 1; i < array_length(_c); i++ )
									_bch += i > 1? " " + _c[i] : _c[i];
								
								var _bw = string_width(_bch);
								
								_tx += 4 * _s;
								_tw  = _bw * _ss;
								_th  = string_height(_bch) * _ss;
								
								draw_sprite_stretched_points(THEME.ui_panel_bg, 0, _tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4, COLORS._main_icon_light);
								draw_sprite_stretched_points(THEME.ui_panel, 1, _tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4, CDEF.main_dkgrey);
									
								draw_set_color(_cc);
								draw_text_add_float(_tx, _y, _bch, _ss);
								
								var _reac = button_reactive(string_to_var(_bch));
								if(_reac > 0) {
									draw_sprite_stretched_points(THEME.ui_panel_bg, 4, _tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4, COLORS._main_accent, _reac);
									
									draw_set_color(merge_color(0, COLORS.panel_bg_clear_inner, 0.5));
									draw_set_alpha(_reac);
									draw_text_transformed(_tx, _y, _bch, _ss, _ss, 0);
									draw_set_alpha(_aa);
									draw_set_color(_cc);
								} 
								
								_tx   += _tw + 4 * _s;
								width += _bw * fsize + 8;
								break;
							
							case "node" :
								var _bch = "";
								for( var i = 1; i < array_length(_c); i++ )
									_bch += i > 1? " " + _c[i] : _c[i];
								
								var _bw = string_width(_bch);
								
								_tx += 4 * _s;
								_tw  = _bw * _ss;
								_th  = string_height(_bch) * _ss;
								
								draw_sprite_stretched_ext(THEME.node_bg, 0, _tx - 4, _y - 4, _tw + 8, _th + 8, c_white, .75);
								draw_sprite_stretched_add(THEME.node_bg, 0, _tx - 4, _y - 4, _tw + 8, _th + 8, c_white, .10);
								
								draw_set_color(_cc);
								draw_text_add_float(_tx, _y, _bch, _ss);
								
								_tx   += _tw + 4 * _s;
								width += _bw * fsize + 8;
								break;
								
							case "panel" :
								var _key = _c[1] + " panel";
								var _tss = 11 / 32;
								draw_set_color(_cc);
								draw_set_font(f_sdf);
								
								_tw = string_width(_key)  * _s * _tss;
								_th = string_height(_key) * _s * _tss;
								
								draw_set_color(COLORS._main_accent);
								
								if(PANEL_GRAPH.node_hovering == self && point_in_rectangle(_mx, _my, _tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4)) {
									draw_sprite_stretched_points(THEME.ui_panel, 1, _tx - 4, _y - 4, _tx + _tw + 4, _y + _th + 4, COLORS._main_accent, 1);
									
									switch(string_lower(_c[1])) {
										case "graph" :      FOCUSING_PANEL = PANEL_GRAPH;      break;
										case "preview" :    FOCUSING_PANEL = PANEL_PREVIEW;    break;
										case "inspector" :  FOCUSING_PANEL = PANEL_INSPECTOR;  break;
										case "animation" :  FOCUSING_PANEL = PANEL_ANIMATION;  break;
										case "collection" : FOCUSING_PANEL = PANEL_COLLECTION; break;
									}
								}
								
								draw_text_add_float(_tx, _y, _key, _s * _tss);
								
								_tx   += _tw;
								width += string_width(_key) * _tss;
								
								draw_set_font(_ff);
								draw_set_color(_cc);
								draw_set_alpha(_aa);
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
								
								_tx   += _tw * _spr_s;
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
					_str += _ch; 
					break;
					
				case 1 : 
					if(_str != "") {
						draw_text_add_float(_tx, _y, _str, _ss);
						_tw = string_width(_str);
						
						_tx   += _tw * _ss;
						width += _tw * fsize;
						_str = "";
					}
						
					_cmd += _ch; 
					break;
			}
		}
		
		if(_str != "") {
			draw_text_add_float(_tx, _y, _str, _ss);
			_tw = string_width(_str);
			
			_tx   += _tw * _ss;
			width += _tw * fsize;
			_str = "";
		}
		
		return width;
	}
	
	static string_raw = function(txt) {
		var index  = 1;
		var _len   = string_length(txt);
		var _ch    = "";
		var _mode  = 0;
		var ch_str = "";
		
		var b = buffer_create(1, buffer_grow, 1);
		
		while(index <= _len) {
			_ch = string_char_at(txt, index);
			index++;
			
			switch(_ch) {
				case "<" : _mode = 1; continue;
				
				case ">" : 
					var _c = string_splice(ch_str, " ");
					
					if(array_length(_c) > 1) {
						switch(_c[0]) {
							case "bt"   :
							case "node" : 
								var _bch = "";
								for( var i = 1; i < array_length(_c); i++ )
									_bch += i > 1? " " + _c[i] : _c[i];
								
								buffer_write(b, buffer_text, _bch);
								break;
						}
					}
					
					ch_str = "";
					_mode = 0; 
					continue;
			}
			
			switch(_mode) {
				case 0 : buffer_write(b, buffer_text, _ch); break;
				case 1 : ch_str += _ch; break;
			}
		}
		
		buffer_to_start(b);
		var ss = buffer_read(b, buffer_text);
		buffer_delete(b);
		
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
				
				var fullStr = ss + _ps;
				
				if(line_width > 0 && string_width(string_raw(fullStr)) * fsize >= line_width) {
					array_push(_lines, ss);
					ss = _ps;
					
				} else if(string_length(_tx) <= 0) {
					array_push(_lines, fullStr);
					ss = "";
					
				} else 
					ss += _ps;	
			}
			
			array_push(_lines, "/");
		}
		
		if(ss != "") array_push(_lines, ss);
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 1 || index == 4) line_update(getInputData(1), getInputData(4));
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx = (x - 3) * _s + _x;
		var yy = y * _s + _y;
		var jun;
		
		if(in_cache_len != array_length(inputDisplayList) || out_cache_len != array_length(outputs)) {
			refreshNodeDisplay();
			
			in_cache_len  = array_length(inputDisplayList);
			out_cache_len = array_length(outputs);
		}
			
		var _iny = yy + (junction_draw_hei_y * 0.5) * _s;
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) { 
			inputs[i].x = xx; 
			inputs[i].y = _iny; 
		}
		
		for(var i = 0; i < in_cache_len; i++) {
			jun = inputDisplayList[i];
			
			jun.x = xx;
			jun.y = _iny;
			_iny += junction_draw_hei_y * _s;
		}
	}
	
	static drawNodeBase = function(xx, yy, mx, my, _s) {
		if(draw_graph_culled && !init_size) return;
		
		var color  = getInputData(0);
		var txt    = getInputData(1);
		if(txt == "") txt = "..."
		draw_simple = string_pos("<", txt) == 0;
		
		var sty  = getInputData(2);
		var alp  = _color_get_alpha(color);
		var wid  = getInputData(4);
		var posi = getInputData(5);
		line_h   = getInputData(6);
		
		pos_x = posi[0];
		pos_y = posi[1];
		
		font = f_p1;
		switch(sty) {
			case 0 : font = f_sdf;        fsize  = 20 / 32; break;
			case 1 : font = f_sdf;        fsize  = 0.5;     break;
			case 2 : font = f_sdf_medium; fsize  = 0.5;     break;
		}
		
		var ww = 0;
		var hh = 0;
			
		var tx = xx + 4;
		var ty = yy + 4;
			
		if(WIDGET_CURRENT == ta_editor) {
			switch(sty) {
				case 0 : ta_editor.font = f_h3; break;
				case 1 : ta_editor.font = f_h5; break;
				case 2 : ta_editor.font = f_p1; break;
			}
			
			ta_editor.draw(tx, ty, wid * _s, 0, txt, [ mx, my ] );
		} else {
			if(_prev_text != txt) line_update(txt, wid);
			
			draw_set_alpha(alp);
			draw_set_text(font, fa_left, fa_top, color);
			for( var i = 0, n = array_length(_lines); i < n; i++ ) {
				var _line = _lines[i];
				if(_line == "/") {
					hh += 8;
					ty += 8 * _s;
					continue;
				}
				
				var _h = line_get_height(font) * fsize + line_h;
				var _w = draw_text_style(tx, ty, _line, _s, mx, my);
			
				ww = max(ww, _w);
				hh += _h;
				ty += _h * _s;
			}
			draw_set_alpha(1);
			
			if(inputs[1].value_from == noone && PANEL_GRAPH.node_hovering == self && PANEL_GRAPH.getFocusingNode() == self) {
				if(point_in_rectangle(mx, my, xx, yy, xx + ww + 8, yy + hh + 8) && DOUBLE_CLICK) {
					ta_editor._current_text = txt;
					ta_editor.activate();
				}
			}
		}
		
		draw_scale = _s;
		w = ww + 8;
		h = hh + 8;
		
		init_size = false;
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		if(!active) return;
		
		var hover = noone;
		draw_set_circle_precision(16);
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			var jun = inputDisplayList[i];
			
			if(jun.drawJunction_fast(_s, _mx, _my))
				hover = jun;
		}
		
		return hover;
	}
	
	static update = function() {
		init_size = true;
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		button_reactive_update();
		drawNodeBase(xx, yy, _mx, _my, _s);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_spr, 1, xx, yy, w * _s, h * _s, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		return drawJunctions(xx, yy, _mx, _my, _s);
	}
}