function Panel_Preview(_panel) : PanelContent(_panel) constructor {
	context_str = "Preview";
	
	last_focus = noone;
	
	canvas_x = w / 2 - 64;
	canvas_y = h / 2 - 64;
	canvas_s = 1;
	canvas_w = 128;
	canvas_h = 128;
	
	canvas_bg = -1;
	
	do_fullView = false;
	
	canvas_hover = true;
	canvas_dragging = false;
	canvas_drag_mx  = 0;
	canvas_drag_my  = 0;
	canvas_drag_sx  = 0;
	canvas_drag_sy  = 0;
	
	preview_channel = 0;
	preview_surface = 0;
	
	preview_x		= 0;
	preview_x_to	= 0;
	preview_x_max	= 0;
	preview_sequence  = 0;
	_preview_sequence = 0;
	preview_rate     = 10;
	
	grid_show	= false;
	grid_width	= 16;
	grid_height	= 16;
	
	tool_index		= -1;
	tool_sub_index	= 0;
	
	tb_framerate = new textBox(TEXTBOX_INPUT.number, function(val) { preview_rate = real(val); })
	
	addHotkey("Preview", "Focus content",		"F", MOD_KEY.none,	function() { fullView(); });
	addHotkey("Preview", "Save current frame",	"S", MOD_KEY.shift,	function() { saveCurrentFrame(); });
	
	addHotkey("Preview", "Toggle grid",			"G", MOD_KEY.ctrl,	function() { grid_show = !grid_show; });
	
	function dragCanvas() {
		if(canvas_dragging) {
			var dx = mx - canvas_drag_mx;
			var dy = my - canvas_drag_my;
			canvas_drag_mx = mx;
			canvas_drag_my = my;
			
			canvas_x += dx;
			canvas_y += dy;
			
			if(mouse_check_button_released(mb_middle)) 
				canvas_dragging = false;
		}
		
		if(FOCUS == panel && HOVER == panel && canvas_hover) {
			if(mouse_check_button_pressed(mb_middle)) {
				canvas_dragging = true;	
				canvas_drag_mx  = mx;
				canvas_drag_my  = my;
				canvas_drag_sx  = canvas_x;
				canvas_drag_sy  = canvas_y;
			}
			
			var _canvas_s = canvas_s;
			var inc = 0.5;
			if(canvas_s > 16)		inc = 2;
			else if(canvas_s > 8)	inc = 1;
			
			if(mouse_wheel_down()) canvas_s = max(round(canvas_s / inc) * inc - inc, 0.25);
			if(mouse_wheel_up())   canvas_s = min(round(canvas_s / inc) * inc + inc, 32);
			if(_canvas_s != canvas_s) {
				var dx = (canvas_s - _canvas_s) * ((mx - canvas_x) / _canvas_s);
				var dy = (canvas_s - _canvas_s) * ((my - canvas_y) / _canvas_s);
				canvas_x -= dx;
				canvas_y -= dy;
			}
		}
		canvas_hover = true;
	}
	
	function fullView() {
		if(!is_surface(preview_surface)) return;
		
		canvas_w = surface_get_width(preview_surface);
		canvas_h = surface_get_height(preview_surface);
					
		var ss = min((w - 32) / canvas_w, (h - 32) / canvas_h);
		canvas_s = ss;
		canvas_x = w / 2 - canvas_w * canvas_s / 2;
		canvas_y = h / 2 - canvas_h * canvas_s / 2;
		
		if(PANEL_GRAPH.node_focus) {
			canvas_x -= PANEL_GRAPH.node_focus.preview_x * canvas_s;
			canvas_y -= PANEL_GRAPH.node_focus.preview_y * canvas_s;
		}
	}
	
	function drawNodePreview(_node) {
		var index = 0;
		preview_surface  = 0;
		preview_sequence = 0;
		var _channel = _node.force_preview_channel == -1? preview_channel : _node.force_preview_channel;
		
		for(var i = 0; i < ds_list_size(_node.outputs); i++) {
			var val = _node.outputs[| i];
			if(val.type == VALUE_TYPE.surface) {
				if(index == _channel) {
					var value = val.getValue();
					
					if(is_array(value)) {
						preview_sequence = value;
					} else {
						preview_surface = value;
						canvas_w = surface_get_width(preview_surface);
						canvas_h = surface_get_height(preview_surface);
					}
					
					break;
				}
				index++;
			}
		}
		
		if(preview_sequence != 0) {
			if(array_length(preview_sequence) == 0) return;
			preview_surface = preview_sequence[safe_mod(_node.preview_frame, array_length(preview_sequence))];
			
			canvas_w = surface_get_width(preview_surface);
			canvas_h = surface_get_height(preview_surface);	
		}
		
		if(is_surface(preview_surface)) {
			draw_surface_ext_safe(preview_surface, canvas_x + _node.preview_x * canvas_s, canvas_y + _node.preview_y * canvas_s, canvas_s, canvas_s, 0, c_white, 1);
			
			if(FOCUS == panel) {
				if(mouse_check_button_pressed(mb_right)) {
					var dia = dialogCall(o_dialog_menubox, mouse_mx + 8, mouse_my + 8);
					dia.setMenu([ 
						[ "Save current preview as...", function() { PANEL_PREVIEW.saveCurrentFrame(); } ], 
						[ "Save all current previews as...", function() { PANEL_PREVIEW.saveAllCurrentFrames(); } ], 
					]);
				}
			}
			
			if(do_fullView) {
				do_fullView = false;
				fullView();
			}
		}
	}
	
	function drawPreviewOverlay(_node) {
		draw_set_text(f_p0, fa_right, fa_top, c_ui_blue_ltgrey);
		draw_text(w - 8, 38, "frame " + string(ANIMATOR.current_frame) + "/" + string(ANIMATOR.frames_total));
		draw_text(w - 8, 58, string(canvas_w) + "x" + string(canvas_h) + "px");
		draw_text(w - 8, 78, "x" + string(canvas_s));
		
		var prev_size = 48;
		preview_x = lerp_float(preview_x, preview_x_to, 5);
		
		if(preview_sequence != 0) {
			if(preview_sequence != _preview_sequence) {
				_preview_sequence = preview_sequence;
				preview_x    = 0;
				preview_x_to = 0;
			}
			
			if(HOVER == panel && my > h - prev_size - 16) {
				canvas_hover = false;
				if(mouse_wheel_down())	preview_x_to = clamp(preview_x_to - prev_size, - preview_x_max, 0);
				if(mouse_wheel_up())	preview_x_to = clamp(preview_x_to + prev_size, - preview_x_max, 0);
			}
			
			preview_x_max = 0;
			for(var i = 0; i < array_length(preview_sequence); i++) {
				var xx = preview_x + 8 + (prev_size + 8) * i;
				var yy = h - prev_size - 8;
				
				var prev   = preview_sequence[i];
				if(!is_surface(prev)) continue;
				
				var prev_w = surface_get_width(prev);
				var prev_h = surface_get_height(prev);	
				var ss     = prev_size / max(prev_w, prev_h);
				
				draw_set_color(c_ui_blue_grey);
				draw_rectangle(xx, yy, xx + prev_w * ss, yy + prev_h * ss, true);
				
				if(FOCUS == panel && point_in_rectangle(mx, my, xx, yy, xx + prev_w * ss, yy + prev_h * ss)) {
					if(mouse_check_button_pressed(mb_left)) {
						_node.preview_index = i;
						do_fullView = true;
					}
					draw_surface_ext_safe(prev, xx, yy, ss, ss, 0, c_white, 1);
				} else {
					draw_surface_ext_safe(prev, xx, yy, ss, ss, 0, c_white, 0.5);	
				}
				
				if(i == _node.preview_frame) {
					draw_set_color(c_ui_orange);
					draw_rectangle(xx, yy, xx + prev_w * ss, yy + prev_h * ss, true);
				}
				
				preview_x_max += prev_size + 8;
			}
			preview_x_max = max(preview_x_max - 100, 0);
			
			var by = h - prev_size - 56;
			var bx = 10;
			
			var b = buttonInstant(s_button_hide, bx, by, 40, 40, [mx, my], FOCUS == panel, HOVER == panel);
			
			if(_node.preview_speed == 0) {
				if(b) {
					draw_sprite_ext(s_sequence_control, 1, bx + 20, by + 20, 1, 1, 0, c_ui_blue_ltgrey, 1);
					if(b == 2) _node.preview_speed = preview_rate / room_speed;
				}
				draw_sprite_ext(s_sequence_control, 1, bx + 20, by + 20, 1, 1, 0, c_ui_blue_ltgrey, 0.5);
			} else {
				if(b) {
					draw_sprite_ext(s_sequence_control, 0, bx + 20, by + 20, 1, 1, 0, c_ui_orange, 1);
					if(b == 2) _node.preview_speed = 0;
				}
				draw_sprite_ext(s_sequence_control, 0, bx + 20, by + 20, 1, 1, 0, c_ui_orange, .75);
			}
			
			tb_framerate.active = FOCUS == panel;
			tb_framerate.hover  = HOVER == panel;
			tb_framerate.draw(bx + 52, by + 4, 64, 32, preview_rate, [mx, my]);
		}
		
		draw_set_color(c_ui_blue_grey);
		var cx = canvas_x + _node.preview_x * canvas_s;
		var cy = canvas_y + _node.preview_y * canvas_s;
		var _ww = canvas_w * canvas_s;
		var _hh = canvas_h * canvas_s;
		draw_rectangle(cx, cy, cx + _ww, cy + _hh, true);
		
		if(grid_show) {
			var _gw = grid_width  * canvas_s;
			var _gh = grid_height * canvas_s;
			
			var gw = ceil(_ww / _gw);
			var gh = ceil(_hh / _gh);
			
			draw_set_color(c_ui_blue_ltgrey);
			for( var i = 0; i < gw; i++ ) {
				var _xx = cx + i * _gw;
				draw_line(_xx, cy, _xx, cy + _hh);
			}
			
			for( var i = 0; i < gh; i++ ) {
				var _yy = cy + i * _gh;
				draw_line(cx, _yy, cx + _ww, _yy);
			}
		}
	}
	
	function drawNodeOverlay(_active, _node) {
		var active = _active;
		if(_node.tools != -1) {
			var xx = 16;
			var yy = 16;
			
			for(var i = 0; i < array_length(_node.tools); i++) {
				var b = buttonInstant(s_button, xx, yy, 40, 40, [mx, my], FOCUS == panel, HOVER == panel);
				var toggle = false;
				if(b == 1) {
					TOOLTIP = _node.tools[i][0];
					active = false;
				} else if(b == 2) {
					toggle = true;
					active = false;
				}
				
				if(FOCUS == panel && keyboard_check_pressed(ord(string(i + 1))))
					toggle = true;
					
				if(toggle) {
					if(is_array(_node.tools[i][1])) {
						if(tool_index == i)
							tool_sub_index = (tool_sub_index + 1) % array_length(_node.tools[i][1]);
						tool_index = i;
					} else
						tool_index = tool_index == i? -1 : i;
				}
				
				if(tool_index == i)
					draw_sprite_stretched(s_button, 2, xx, yy, 40, 40);
				
				if(is_array(_node.tools[i][1])) {
					var _ind = tool_sub_index % array_length(_node.tools[i][1]);
					draw_sprite_ext(_node.tools[i][1][_ind], 0, xx + 20, yy + 20, 1, 1, 0, c_white, 1);
				} else
					draw_sprite_ext(_node.tools[i][1], 0, xx + 20, yy + 20, 1, 1, 0, c_white, 1);
				yy += 48;
			}
		}
		
		_node.drawOverlay(active, canvas_x + _node.preview_x * canvas_s, canvas_y + _node.preview_y * canvas_s, canvas_s, mx, my);
	}
	
	function drawContent() {
		draw_clear(c_ui_blue_black);
		if(canvas_bg == -1) {
			if(canvas_s >= 1) draw_sprite_tiled_ext(s_transparent, 0, canvas_x, canvas_y, canvas_s, canvas_s, c_white, 0.5);
		} else {
			draw_clear(canvas_bg);
		}
		
		dragCanvas();
		if(PANEL_GRAPH.node_previewing) {
			PANEL_GRAPH.node_previewing.previewing = true;
			drawNodePreview(PANEL_GRAPH.node_previewing);
			drawPreviewOverlay(PANEL_GRAPH.node_previewing);
		}
		
		if(PANEL_GRAPH.node_focus) {
			drawNodeOverlay(FOCUS == panel, PANEL_GRAPH.node_focus);
		}
		
		if(last_focus != PANEL_GRAPH.node_focus) {
			last_focus = PANEL_GRAPH.node_focus;
			tool_index = -1;
		}
		
		draw_set_text(f_p0, fa_right, fa_top, c_ui_blue_ltgrey);
		draw_text(w - 8, 08, "fps " + string(fps));
	}
	
	function saveCurrentFrame() {
		if(!is_surface(preview_surface)) return;
		
		var path = get_save_filename(".png", "export");
		if(path == "") return;
		if(filename_ext(path) == "") path += ".png";
		
		surface_save(preview_surface, path);
	}
	
	function saveAllCurrentFrames() {
		var path = get_save_filename(".png", "export");
		if(path == "") return;
		
		var ext  = filename_ext(path);
		if(ext == "") ext = ".png";
		var name = string_replace_all(path, ext, "");
		var ind  = 0;
		
		for(var i = 0; i < array_length(preview_sequence); i++) {
			var prev   = preview_sequence[i];
			if(!is_surface(prev)) continue;
			var _name = name + string(ind) + ext;
			surface_save(prev, _name);
			ind++;
		}
	}
}