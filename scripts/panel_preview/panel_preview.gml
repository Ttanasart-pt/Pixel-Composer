function Panel_Preview() : PanelContent() constructor {
	context_str = "Preview";
	
	last_focus = noone;
	
	function initSize() {
		canvas_x = w / 2 - ui(64);
		canvas_y = h / 2 - ui(64);
	}
	initSize();
	
	canvas_s = ui(1);
	canvas_w = ui(128);
	canvas_h = ui(128);
	canvas_a = 0;
	
	canvas_bg = -1;
	
	do_fullView = false;
	
	canvas_hover = true;
	canvas_dragging = false;
	canvas_drag_key = 0;
	canvas_drag_mx  = 0;
	canvas_drag_my  = 0;
	canvas_drag_sx  = 0;
	canvas_drag_sy  = 0;
	
	preview_node	= [ noone, noone ];
	preview_surface = [ 0, 0 ];
	
	preview_x		= 0;
	preview_x_to	= 0;
	preview_x_max	= 0;
	preview_sequence  = [ 0, 0 ];
	_preview_sequence = preview_sequence;
	preview_rate     = 10;
	
	grid_show	 = false;
	grid_snap	 = false;
	grid_width	 = 16;
	grid_height	 = 16;
	grid_opacity = 0.5;
	grid_color   = COLORS.panel_preview_grid;
	
	tool_index		= -1;
	tool_sub_index	= 0;
	
	right_menu_y = 8;
	mouse_on_preview = false;
	
	resetViewOnDoubleClick = true;
	
	splitView = 0;
	splitPosition = 0.5;
	splitSelection = 0;
	
	splitViewDragging = false;
	splitViewStart = 0;
	splitViewMouse = 0;
	
	tileMode = false;
	
	toolbar_height = ui(40);
	toolbars = [
		[ 
			THEME.icon_reset_when_preview,
			function() { return resetViewOnDoubleClick;  },
			function() { return resetViewOnDoubleClick? "Center canvas on preview" : "Keep canvas on preview" }, 
			function() { resetViewOnDoubleClick = !resetViewOnDoubleClick; } 
		],
		[ 
			THEME.icon_split_view,
			function() { return splitView;  },
			function() { 
				switch(splitView) {
					case 0 : return "Split view off";
					case 1 : return "Horizontal split view";
					case 2 : return "Vertical split view";
				}
				return "Split view";
			}, 
			function() { splitView = (splitView + 1) % 3; } 
		],
		[
			THEME.icon_tile_view,
			function() { return tileMode? 2 : 3;  },
			function() { 
				switch(tileMode) {
					case 0 : return "Tile off";
					case 1 : return "Tile horizontal";
					case 2 : return "Tile vertical";
					case 3 : return "Tile both";
				}
				return "Tile mode";
			}, 
			function() { tileMode = tileMode? 0 : 3; } 
		],
		[ 
			THEME.icon_grid_setting,
			function() { return 0; },
			function() { return "Grid setting" }, 
			function(param) { 
				var gs = dialogCall(o_dialog_preview_grid, param.x, param.y); 
				gs.anchor = ANCHOR.bottom | ANCHOR.left;
			} 
		],
	];
	
	actions = [
		[ 
			THEME.icon_center_canvas,
			"Center canvas", 
			function() { fullView(); }
		],
		[ 
			THEME.icon_preview_export,
			"Export canvas", 
			function() { saveCurrentFrame(); }
		],
	]
	
	tb_framerate = new textBox(TEXTBOX_INPUT.number, function(val) { preview_rate = real(val); });
	
	addHotkey("Preview", "Focus content",		"F", MOD_KEY.none,	function() { fullView(); });
	addHotkey("Preview", "Save current frame",	"S", MOD_KEY.shift,	function() { saveCurrentFrame(); });
	
	addHotkey("Preview", "Toggle grid",			"G", MOD_KEY.ctrl,	function() { grid_show = !grid_show; });
	
	function setNodePreview(node) {
		if(resetViewOnDoubleClick)
			do_fullView = true;
		
		preview_node[splitView? splitSelection : 0] = node;
	}
	
	function getNodePreview() { return preview_node[splitView? splitSelection : 0]; }
	function getNodePreviewSurface() { return preview_surface[splitView? splitSelection : 0]; }
	function getNodePreviewSequence() { return preview_sequence[splitView? splitSelection : 0]; }
	
	function getPreviewData() {
		preview_surface  = [ 0, 0 ];
		preview_sequence = [ 0, 0 ];
		
		for( var i = 0; i < 2; i++ ) {
			var node = preview_node[i];
			
			if(node == noone) continue;
			
			var _prev_val = node.getPreviewValue();
			
			if(_prev_val == undefined) continue;
			if(_prev_val == noone) continue;
			if(_prev_val.type != VALUE_TYPE.surface) continue;
			
			var value = _prev_val.getValue();
			
			if(is_array(value)) {
				preview_sequence[i] = value;
				canvas_a = array_length(value);
			} else {
				preview_surface[i] = value;
				canvas_a = 0;
			}
			
			if(preview_sequence[i] != 0) {
				if(array_length(preview_sequence[i]) == 0) return;
				preview_surface[i] = preview_sequence[i][safe_mod(node.preview_index, array_length(preview_sequence[i]))];
			}
		}
		
		var prevS = getNodePreviewSurface();
		if(is_surface(prevS)) {
			canvas_w = surface_get_width(prevS);
			canvas_h = surface_get_height(prevS);	
		}
	}
	
	function dragCanvas() {
		if(canvas_dragging) {
			if(!MOUSE_WRAPPING) {
				var dx = mx - canvas_drag_mx;
				var dy = my - canvas_drag_my;
				
				canvas_x += dx;
				canvas_y += dy;
			}
			
			canvas_drag_mx = mx;
			canvas_drag_my = my;
			setMouseWrap();
			
			if(mouse_release(canvas_drag_key)) 
				canvas_dragging = false;
		}
		
		if(pFOCUS && pHOVER && canvas_hover) {
			var hold = false;
			if(mouse_press(mb_middle)) {
				hold = true;
				canvas_drag_key = mb_middle;
			} else if(mouse_press(mb_left) && key_mod_press(ALT)) {
				hold = true;
				canvas_drag_key = mb_left;
			}
			
			if(hold) {
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
		var prevS = getNodePreviewSurface();
		if(!is_surface(prevS)) return;
		
		canvas_w = surface_get_width(prevS);
		canvas_h = surface_get_height(prevS);
		
		var ss = min((w - 32) / canvas_w, (h - 32 - toolbar_height) / canvas_h);
		canvas_s = ss;
		canvas_x = w / 2 - canvas_w * canvas_s / 2;
		canvas_y = (h - toolbar_height) / 2 - canvas_h * canvas_s / 2;
		
		if(PANEL_GRAPH.node_focus) {
			canvas_x -= PANEL_GRAPH.node_focus.preview_x * canvas_s;
			canvas_y -= PANEL_GRAPH.node_focus.preview_y * canvas_s;
		}
	}
	
	sbChannel = new scrollBox([], function(index) { 
		var node = getNodePreview();
		if(node == noone) return;
		
		node.preview_channel = sbChannelIndex[index]; 
	});
	
	sbChannelIndex = [];
	sbChannel.align = fa_left;
	function drawNodeChannel(_x, _y) {
		var _node = getNodePreview();
		if(_node == noone) return;
		if(ds_list_size(_node.outputs) < 2) return;
		
		var chName = [];
		sbChannelIndex = [];
		
		var ww = ui(96);
		var hh = toolbar_height - ui(12);
		draw_set_text(f_p0, fa_center, fa_center);
		
		for( var i = 0; i < ds_list_size(_node.outputs); i++ ) {
			if(_node.outputs[| i].type != VALUE_TYPE.surface) continue;
			
			array_push(chName, _node.outputs[| i].name);
			array_push(sbChannelIndex, i);
			ww = max(ww, string_width(_node.outputs[| i].name) + ui(40));
		}
		sbChannel.data_list = chName;
		sbChannel.hover = pHOVER;
		sbChannel.active = pFOCUS;
		
		sbChannel.draw(_x - ww, _y - hh / 2, ww, hh, _node.outputs[| _node.preview_channel].name, [mx, my], x, y);
		right_menu_y += ui(40);
	}
	
	function drawNodePreview() {
		var ss  = canvas_s;
		var psx = 0, psy = 0;
		var psw = 0, psh = 0;
		var pswd = 0, pshd = 0;
		var psx1 = 0, psy1 = 0;
		
		var ssx = 0, ssy = 0;
		var ssw = 0, ssh = 0;
		
		if(is_surface(preview_surface[0])) {
			psx = canvas_x + preview_node[0].preview_x * ss;
			psy = canvas_y + preview_node[0].preview_y * ss;
			
			psw = surface_get_width(preview_surface[0]);
			psh = surface_get_height(preview_surface[0]);
			pswd = psw * ss;
			pshd = psh * ss;
			
			psx1 = psx + pswd;
			psy1 = psy + pshd;	
		}
		
		if(is_surface(preview_surface[1])) {
			var ssx = canvas_x + preview_node[1].preview_x * ss;
			var ssy = canvas_y + preview_node[1].preview_y * ss;
			
			var ssw = surface_get_width(preview_surface[1]);
			var ssh = surface_get_height(preview_surface[1]);
		}
		
		switch(splitView) {
			case 0 :
				if(is_surface(preview_surface[0])) {
					preview_node[0].previewing = 1;
					
					switch(tileMode) {
						case 0 : 
							var aa = preview_node[0].preview_alpha;
							draw_surface_ext_safe(preview_surface[0], psx, psy, ss, ss, 0, c_white, aa); 
							break;
						case 1 : draw_surface_ext_safe(preview_surface[0], psx, psy, ss, ss, 0, c_white, 1); break;
						case 2 : draw_surface_ext_safe(preview_surface[0], psx, psy, ss, ss, 0, c_white, 1); break;
						case 3 : draw_surface_tiled_ext_safe(preview_surface[0], psx, psy, ss, ss, c_white, 1); break;
					}
				}
				break;
			case 1 :
				var sp = splitPosition * w;
				
				if(is_surface(preview_surface[0])) {
					preview_node[0].previewing = 2;
					var maxX = min(sp, psx1);
					var sW = min(psw, (maxX - psx) / ss);
					
					if(sW > 0)
						draw_surface_part_ext_safe(preview_surface[0], 0, 0, sW, psh, psx, psy, ss, ss, 0, c_white, 1);
				}
				
				if(is_surface(preview_surface[1])) {
					preview_node[1].previewing = 3;
					var minX = max(ssx, sp);
					var sX = (minX - ssx) / ss;
					var spx = max(sp, ssx);
					
					if(sX >= 0 && sX < ssw)
						draw_surface_part_ext_safe(preview_surface[1], sX, 0, ssw - sX, ssh, spx, ssy, ss, ss, 0, c_white, 1);
				}
				break;
			case 2 :
				var sp = splitPosition * h;
					
				if(is_surface(preview_surface[0])) {
					preview_node[0].previewing = 4;
					var maxY = min(sp, psy1);
					var sH = min(psh, (maxY - psy) / ss);
					
					if(sH > 0)
						draw_surface_part_ext_safe(preview_surface[0], 0, 0, psw, sH, psx, psy, ss, ss, 0, c_white, 1);
				}
				
				if(is_surface(preview_surface[1])) {
					preview_node[1].previewing = 5;
					var minY = max(ssy, sp);
					var sY = (minY - ssy) / ss;
					var spy = max(sp, ssy);
					
					if(sY >= 0 && sY < ssh)
						draw_surface_part_ext_safe(preview_surface[1], 0, sY, ssw, ssh - sY, ssx, spy, ss, ss, 0, c_white, 1);
				}
				break;
		}
		
		if(is_surface(preview_surface[0])) {
			if(grid_show) {
				var _gw = grid_width  * canvas_s;
				var _gh = grid_height * canvas_s;
			
				var gw = floor(pswd / _gw);
				var gh = floor(pshd / _gh);
			
				var cx = canvas_x;
				var cy = canvas_y;
			
				draw_set_color(grid_color);
				draw_set_alpha(grid_opacity);
				
				for( var i = 1; i < gw; i++ ) {
					var _xx = cx + i * _gw;
					draw_line(_xx, cy, _xx, cy + pshd);
				}
			
				for( var i = 1; i < gh; i++ ) {
					var _yy = cy + i * _gh;
					draw_line(cx, _yy, cx + pswd, _yy);
				}
				
				draw_set_alpha(1);
			}
		
			draw_set_color(COLORS.panel_preview_surface_outline);
			draw_rectangle(psx, psy, psx + pswd, psy + pshd, true);
		}
	}
	
	function drawPreviewOverlay() {
		right_menu_y = ui(8);
		draw_set_text(f_p0, fa_right, fa_top, fps >= ANIMATOR.framerate? COLORS._main_text_sub : COLORS._main_value_negative);
		draw_text(w - ui(8), right_menu_y, "fps " + string(fps));
		right_menu_y += string_height("l");
		
		var _node = getNodePreview();
		if(_node == noone) return;
		
		draw_set_text(f_p0, fa_right, fa_top, COLORS._main_text_sub);
		draw_text(w - ui(8), right_menu_y, "frame " + string(ANIMATOR.current_frame) + "/" + string(ANIMATOR.frames_total));
		
		right_menu_y += string_height("l");
		var txt = string(canvas_w) + "x" + string(canvas_h) + "px";
		if(canvas_a) txt = string(canvas_a) + " x " + txt;
		draw_text(w - ui(8), right_menu_y, txt);
		
		right_menu_y += string_height("l");
		draw_text(w - ui(8), right_menu_y, "x" + string(canvas_s));
		right_menu_y += string_height("l");
		
		var pseq = getNodePreviewSequence();
		if(pseq == 0) return;
		
		if(!array_equals(pseq, _preview_sequence)) {
			_preview_sequence = pseq;
			preview_x    = 0;
			preview_x_to = 0;
		}
		
		var prev_size = ui(48);
		preview_x = lerp_float(preview_x, preview_x_to, 4);
			
		if(pHOVER && my > h - toolbar_height - prev_size - ui(16)) {
			canvas_hover = false;
			
			if(mouse_wheel_down())	preview_x_to = clamp(preview_x_to - prev_size, - preview_x_max, 0);
			if(mouse_wheel_up())	preview_x_to = clamp(preview_x_to + prev_size, - preview_x_max, 0);
		}
			
		preview_x_max = 0;
		var xx = preview_x + ui(8);
		var yy = h - toolbar_height - prev_size - ui(8);
		if(my > yy) mouse_on_preview = false;
		
		for(var i = 0; i < array_length(pseq); i++) {
			var prev   = pseq[i];
			if(!is_surface(prev)) continue;
				
			var prev_w = surface_get_width(prev);
			var prev_h = surface_get_height(prev);
			var ss     = prev_size / max(prev_w, prev_h);
			var prev_sw = prev_w * ss;
			
			draw_set_color(COLORS.panel_preview_surface_outline);
			draw_rectangle(xx, yy, xx + prev_w * ss, yy + prev_h * ss, true);
				
			if(pHOVER && point_in_rectangle(mx, my, xx, yy, xx + prev_sw, yy + prev_h * ss)) {
				if(mouse_press(mb_left, pFOCUS)) {
					_node.preview_index = i;
					_node.onValueUpdate(0);
					if(resetViewOnDoubleClick)
						do_fullView = true;
				}
				draw_surface_ext_safe(prev, xx, yy, ss, ss, 0, c_white, 1);
			} else {
				draw_surface_ext_safe(prev, xx, yy, ss, ss, 0, c_white, 0.5);	
			}
				
			if(i == _node.preview_index) {
				draw_set_color(COLORS._main_accent);
				draw_rectangle(xx, yy, xx + prev_sw, yy + prev_h * ss, true);
			}
			
			xx += prev_sw + ui(8);
			preview_x_max += prev_sw + ui(8);
		}
		preview_x_max = max(preview_x_max - ui(100), 0);
			
		var by = h - toolbar_height - prev_size - ui(56);
		var bx = ui(10);
			
		var b = buttonInstant(THEME.button_hide, bx, by, ui(40), ui(40), [mx, my], pFOCUS, pHOVER);
			
		if(_node.preview_speed == 0) {
			if(b) {
				draw_sprite_ui_uniform(THEME.sequence_control, 1, bx + ui(20), by + ui(20), 1, COLORS._main_icon, 1);
				if(b == 2) _node.preview_speed = preview_rate / game_get_speed(gamespeed_fps);
			}
			draw_sprite_ui_uniform(THEME.sequence_control, 1, bx + ui(20), by + ui(20), 1, COLORS._main_icon, 0.5);
		} else {
			if(b) {
				draw_sprite_ui_uniform(THEME.sequence_control, 0, bx + ui(20), by + ui(20), 1, COLORS._main_accent, 1);
				if(b == 2) _node.preview_speed = 0;
			}
			draw_sprite_ui_uniform(THEME.sequence_control, 0, bx + ui(20), by + ui(20), 1, COLORS._main_accent, .75);
		}
	}
	
	function drawNodeTools(active, _node) {
		var _mx = mx;
		var _my = my;
		var isHover = pHOVER && mouse_on_preview;
		
		if(_node.tools != -1) {
			var xx = ui(16);
			var yy = ui(16);
			
			for(var i = 0; i < array_length(_node.tools); i++) {
				var b = buttonInstant(THEME.button, xx, yy, ui(40), ui(40), [_mx, _my], pFOCUS, isHover);
				if(b > 0) active = false;
				yy += ui(48);
			}
		}
		
		var cx = canvas_x + _node.preview_x * canvas_s;
		var cy = canvas_y + _node.preview_y * canvas_s;
		var _snx = 0, _sny = 0;
		
		if(key_mod_press(CTRL)) {
			_snx = grid_show? grid_width : 1;
			_sny = grid_show? grid_height : 1;
		} else if(grid_snap) {
			_snx = grid_width;
			_sny = grid_height;
		}
		
		_node.drawOverlay(active && isHover && !key_mod_press(CTRL), cx, cy, canvas_s, _mx, _my, _snx, _sny);
		
		if(_node.tools != -1) {
			var xx = ui(16);
			var yy = ui(16);
			
			for(var i = 0; i < array_length(_node.tools); i++) {
				var b = buttonInstant(THEME.button, xx, yy, ui(40), ui(40), [_mx, _my], pFOCUS, isHover);
				var toggle = false;
				if(b == 1)
					TOOLTIP = _node.tools[i][0];
				else if(b == 2)
					toggle = true;
				
				if(pFOCUS && keyboard_check_pressed(ord(string(i + 1))))
					toggle = true;
					
				if(toggle) {
					if(is_array(_node.tools[i][1])) {
						if(tool_index == i) {
							tool_sub_index++;
							if(tool_sub_index >= array_length(_node.tools[i][1])) {
								tool_index = -1;
								tool_sub_index = 0;
							}
						} else 
							tool_index = i;
					} else
						tool_index = tool_index == i? -1 : i;
				}
				
				if(tool_index == i)
					draw_sprite_stretched(THEME.button, 2, xx, yy, ui(40), ui(40));
				
				if(is_array(_node.tools[i][1])) {
					var _ind = tool_sub_index % array_length(_node.tools[i][1]);
					draw_sprite_ui_uniform(_node.tools[i][1][_ind], 0, xx + ui(20), yy + ui(20));
				} else
					draw_sprite_ui_uniform(_node.tools[i][1], 0, xx + ui(20), yy + ui(20));
				yy += ui(48);
			}
		}
	}
	
	function drawToolBar() {
		toolbar_height = ui(40);
		var ty = h - toolbar_height;
		//draw_sprite_stretched_ext(THEME.toolbar_shadow, 0, 0, ty - 12 + 4, w, 12, c_white, 0.5);
		draw_set_color(COLORS.panel_toolbar_fill);
		draw_rectangle(0, ty, w, h, false);
		
		draw_set_color(COLORS.panel_toolbar_outline);
		draw_line(0, ty, w, ty);
		
		var tbx = toolbar_height / 2;
		var tby = ty + toolbar_height / 2;
		
		for( var i = 0; i < array_length(toolbars); i++ ) {
			var tb = toolbars[i];
			var tbSpr = tb[0];
			var tbInd = tb[1]();
			var tbTooltip = tb[2]();
			
			var b = buttonInstant(THEME.button_hide, tbx - ui(14), tby - ui(14), ui(28), ui(28), [mx, my], pFOCUS, pHOVER, tbTooltip, tbSpr, tbInd);
			if(b == 2) tb[3]( { x: x + tbx - ui(14), y: y + tby - ui(14) } );
			
			tbx += ui(32);
		}
		
		tbx = w - toolbar_height / 2;
		for( var i = 0; i < array_length(actions); i++ ) {
			var tb = actions[i];
			var tbSpr = tb[0];
			var tbTooltip = tb[1];
			
			var b = buttonInstant(THEME.button_hide, tbx - ui(14), tby - ui(14), ui(28), ui(28), [mx, my], pFOCUS, pHOVER, tbTooltip, tbSpr, 0);
			if(b == 2) tb[2]();
			
			tbx -= ui(32);
		}
		
		draw_set_color(COLORS.panel_toolbar_separator);
		draw_line_width(tbx + ui(12), tby - toolbar_height / 2 + ui(8), tbx + ui(12), tby + toolbar_height / 2 - ui(8), 2);
		drawNodeChannel(tbx, tby);
	}
	
	function drawSplitView() {
		if(splitView == 0) return;
		
		draw_set_color(COLORS.panel_preview_split_line);
		
		if(splitViewDragging) {
			if(splitView == 1) {
				var cx = splitViewStart + (mx - splitViewMouse);
				splitPosition = clamp(cx / w, .1, .9);
			} else if(splitView == 2) {
				var cy = splitViewStart + (my - splitViewMouse);
				splitPosition = clamp(cy / h, .1, .9);
			}
			
			if(mouse_release(mb_left))
				splitViewDragging = false;
		}
		
		if(splitView == 1) {
			var sx = w * splitPosition;
			
			if(mouse_on_preview && point_in_rectangle(mx, my, sx - ui(4), 0, sx + ui(4), h)) {
				draw_line_width(sx, 0, sx, h, 2);
				if(mouse_press(mb_left, pFOCUS)) {
					splitViewDragging = true;
					splitViewStart = sx;
					splitViewMouse = mx;
				}
			} else 
				draw_line_width(sx, 0, sx, h, 1);
			
			draw_sprite_ui_uniform(THEME.icon_active_split, 0, splitSelection? sx + ui(16) : sx - ui(16), ui(16),, COLORS._main_accent);
			
			if(mouse_on_preview && mouse_press(mb_left, pFOCUS)) {
				if(point_in_rectangle(mx, my, 0, 0, sx, h))
					splitSelection = 0;
				else if(point_in_rectangle(mx, my, sx, 0, w, h))
					splitSelection = 1;
			}
		} else {
			var sy = h * splitPosition;
			
			if(mouse_on_preview && point_in_rectangle(mx, my, 0, sy - ui(4), w, sy + ui(4))) {
				draw_line_width(0, sy, w, sy, 2);
				if(mouse_press(mb_left, pFOCUS)) {
					splitViewDragging = true;
					splitViewStart = sy;
					splitViewMouse = my;
				}
			} else
				draw_line_width(0, sy, w, sy, 1);
			draw_sprite_ui_uniform(THEME.icon_active_split, 0, ui(16), splitSelection? sy + ui(16) : sy - ui(16),, COLORS._main_accent);
			
			if(mouse_on_preview && mouse_press(mb_left, pFOCUS)) {
				if(point_in_rectangle(mx, my, 0, 0, w, sy))
					splitSelection = 0;
				else if(point_in_rectangle(mx, my, 0, sy, w, h))
					splitSelection = 1;
			}
		}
	}
	
	function drawContent(panel) {
		mouse_on_preview = pHOVER && point_in_rectangle(mx, my, 0, 0, w, h - toolbar_height);
		
		draw_clear(COLORS.panel_bg_clear);
		if(canvas_bg == -1) {
			if(canvas_s >= 1) draw_sprite_tiled_ext(s_transparent, 0, canvas_x, canvas_y, canvas_s, canvas_s, c_white, 0.5);
		} else {
			draw_clear(canvas_bg);
		}
		
		dragCanvas();
		getPreviewData();
		drawNodePreview();
		drawPreviewOverlay();
		
		if(PANEL_GRAPH.node_focus)
			drawNodeTools(pFOCUS, PANEL_GRAPH.node_focus);
		if(last_focus != PANEL_GRAPH.node_focus) {
			last_focus = PANEL_GRAPH.node_focus;
			tool_index = -1;
		}
		
		if(do_fullView) {
			do_fullView = false;
			fullView();
		}
		
		if(my < h - toolbar_height && mouse_press(mb_right, pFOCUS)) {
			var dia = dialogCall(o_dialog_menubox, mouse_mx + ui(8), mouse_my + ui(8));
			dia.setMenu([ 
				[ "Save current preview as...", function() { PANEL_PREVIEW.saveCurrentFrame(); } ], 
				[ "Save all current previews as...", function() { PANEL_PREVIEW.saveAllCurrentFrames(); } ], 
			]);
		}
		
		drawSplitView();
		drawToolBar();
	}
	
	function saveCurrentFrame() {
		var prevS = getNodePreviewSurface();
		if(!is_surface(prevS)) return;
		
		var path = get_save_filename(".png", "export");
		if(path == "") return;
		if(filename_ext(path) != ".png") path += ".png";
		
		surface_save(prevS, path);
	}
	
	function saveAllCurrentFrames() {
		var path = get_save_filename(".png", "export");
		if(path == "") return;
		
		var ext = ".png";
		var name = string_replace_all(path, ext, "");
		var ind  = 0;
		
		var pseq = getNodePreviewSequence();
		for(var i = 0; i < array_length(pseq); i++) {
			var prev   = pseq[i];
			if(!is_surface(prev)) continue;
			var _name = name + string(ind) + ext;
			surface_save(prev, _name);
			ind++;
		}
	}
}