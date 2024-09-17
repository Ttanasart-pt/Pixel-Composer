/// @description init
#macro DIALOG_PAD 8
#macro DIALOG_DRAW_BG    draw_sprite_stretched(THEME.dialog, 0, dialog_x - 8, dialog_y - 8, dialog_w + 16, dialog_h + 16);
#macro DIALOG_DRAW_FOCUS draw_sprite_stretched_ext(THEME.dialog, 1, dialog_x - 8, dialog_y - 8, dialog_w + 16, dialog_h + 16, COLORS._main_accent, 1);

#macro DIALOG_WINCLEAR  if(window != noone) { winwin_draw_clear(COLORS.panel_bg_clear, 0); }
#macro DIALOG_WINCLEAR1 if(window != noone) { winwin_draw_clear(COLORS.panel_bg_clear, 1); }
#macro DIALOG_PREDRAW  if(window != noone) { winwin_draw_begin(window); WINDOW_ACTIVE = window; window_drawing =  true; }
#macro DIALOG_POSTDRAW if(window != noone) { winwin_draw_end();         WINDOW_ACTIVE = noone;  window_drawing = false; }

#region data
	on_top    = false;

	with(_p_dialog) { 
		if(on_top) continue; 
		other.depth = min(depth - 1, other.depth); 
	}
	
	ds_list_add(DIALOGS, self);
	
	active    = true;
	dialog_w  = 320;
	dialog_h  = 320;
	_dialog_w = 320;
	_dialog_h = 320;
	dialog_x  = 0;
	dialog_y  = 0;
	anchor    = ANCHOR.none;
	
	title  = "dialog";
	window = noone;
	window_drawing = false;
	
	title_height = 64;
	padding      = 20;
	
	children = [];
	parent   = noone;
	
	alarm[0] = 1;
	ready    = false;
	
	destroy_on_escape    = true;
	destroy_on_click_out = false;
	
	init_pressing = mouse_click(mb_left);
#endregion

#region windows
	mouse_active	= false;
	draggable		= true;
	dialog_dragging = false;
	dialog_drag_sx  = 0;
	dialog_drag_sy  = 0;
	dialog_drag_mx  = 0;
	dialog_drag_my  = 0;
	mouse_draggable = true;
	
	passthrough = false;
	
	function doDrag() {
		if(!active) return;
		
		mouse_active = true;
		if(!draggable) return;
		
		WINDOW_ACTIVE = window;
		
		if(window == noone) {
			if(dialog_dragging) {
				var _dx = dialog_drag_sx + mouse_mx - dialog_drag_mx;
				var _dy = dialog_drag_sy + mouse_my - dialog_drag_my;
				
				var _wx = window_get_x();
				var _wy = window_get_y();
				
				dialog_x = clamp(_dx, ui(16) - dialog_w, WIN_W - ui(16));
				dialog_y = clamp(_dy, ui(16) - dialog_h, WIN_H - ui(16));
					
				if(PREFERENCES.multi_window && !point_in_rectangle(mouse_raw_x, mouse_raw_y, _wx, _wy, _wx + WIN_W, _wy + WIN_H)) {
					o_main.dialog_popup_to = 1;
					o_main.dialog_popup_x  = mouse_mx;
					o_main.dialog_popup_y  = mouse_my;
					
					if(mouse_release(mb_left)) {
						var _cfg = winwin_config_ext(title, winwin_kind_borderless, false, true);
						window   = winwin_create_ext(_wx + _dx, _wy + _dy, dialog_w, dialog_h, _cfg);
						dialog_x = 0;
						dialog_y = 0;
					}
				}
				
				if(mouse_release(mb_left))
					dialog_dragging = false;
			}
			
			if(mouse_draggable && point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + title_height)) {
				mouse_active = false;
				if(mouse_press(mb_left, sFOCUS)) {
					dialog_dragging = true;
					dialog_drag_sx  = dialog_x;
					dialog_drag_sy  = dialog_y;
					dialog_drag_mx  = mouse_mx;
					dialog_drag_my  = mouse_my;
				}
			}
			
		} else {
			
			if(dialog_dragging) {
				var _dx = dialog_drag_sx + mouse_raw_x - dialog_drag_mx;
				var _dy = dialog_drag_sy + mouse_raw_y - dialog_drag_my;
				
				winwin_set_position_safe(window, _dx, _dy);
				
				if(mouse_release(mb_left))
					dialog_dragging = false;
			}
			
			if(mouse_draggable && point_in_rectangle(mouse_mx, mouse_my, 0, 0, dialog_w, title_height)) {
				mouse_active = false;
				// print($"{mouse_mx}, {mouse_my} / {mouse_press(mb_left, sFOCUS)}");
				
				if(mouse_press(mb_left, sFOCUS)) {
					dialog_dragging = true;
					dialog_drag_sx  = winwin_get_x_safe(window);
					dialog_drag_sy  = winwin_get_y_safe(window);
					dialog_drag_mx  = mouse_raw_x;
					dialog_drag_my  = mouse_raw_y;
				}
			}
		}
		
		mouse_draggable = true;
		WINDOW_ACTIVE = noone;
	}
	
	dialog_resizable = false;
	dialog_resizing = 0;
	dialog_resiz_sw = 0;
	dialog_resiz_sh = 0;
	dialog_resiz_mx = 0;
	dialog_resiz_my = 0;
	dialog_w_min = 320;
	dialog_h_min = 320;
	dialog_w_max = WIN_W;
	dialog_h_max = WIN_H;
	onResize = -1;
	
	function doResize() {
		if(!active) return;
		if(!dialog_resizable) return;
		
		if(window == noone) {
			if(dialog_resizing & 1 << 0 != 0) {
				var ww = dialog_resiz_sw + (mouse_mx - dialog_resiz_mx);
				ww = clamp(ww, dialog_w_min, dialog_w_max);
				dialog_w = ww;
			} 
			
			if(dialog_resizing & 1 << 1 != 0) {
				var hh = dialog_resiz_sh + (mouse_my - dialog_resiz_my);
				hh = clamp(hh, dialog_h_min, dialog_h_max);
				dialog_h = hh;
			}
			
			if(mouse_release(mb_left)) dialog_resizing = 0;
			
			if(sHOVER && distance_to_line(mouse_mx, mouse_my, dialog_x + dialog_w, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h) < 12) {
				
				mouse_active = false;
				CURSOR = cr_size_we;
				if(mouse_press(mb_left, sFOCUS)) {
					dialog_resizing |= 1 << 0;
					dialog_resiz_sw = dialog_w;
					dialog_resiz_mx = mouse_mx;
					dialog_resiz_my = mouse_my;
				}
			} 
				
			if(sHOVER && distance_to_line(mouse_mx, mouse_my, dialog_x, dialog_y + dialog_h, dialog_x + dialog_w, dialog_y + dialog_h) < 12) {
				
				mouse_active = false;
				if(CURSOR == cr_size_we) CURSOR = cr_size_nwse;
				else                     CURSOR = cr_size_ns;
				
				if(mouse_press(mb_left, sFOCUS)) {
					dialog_resizing |= 1 << 1;
					dialog_resiz_sh = dialog_h;
					dialog_resiz_mx = mouse_mx;
					dialog_resiz_my = mouse_my;
				}
			}
			
		} else {
			WINDOW_ACTIVE = window;
			
			var ww = dialog_resiz_sw;
			var hh = dialog_resiz_sh;
			
			if(dialog_resizing & 1 << 0 != 0) {
				ww = dialog_resiz_sw + (mouse_raw_x - dialog_resiz_mx);
				ww = clamp(ww, dialog_w_min, dialog_w_max);
			} 
			
			if(dialog_resizing & 1 << 1 != 0) {
				hh = dialog_resiz_sh + (mouse_raw_y - dialog_resiz_my);
				hh = clamp(hh, dialog_h_min, dialog_h_max);
			}
			
			if(dialog_resizing != 0) {
				winwin_set_size_safe(window, ww, hh);
				if(mouse_release(mb_left)) dialog_resizing = 0;
			}
			
			if(sHOVER && distance_to_line(mouse_mx, mouse_my, dialog_w, 0, dialog_w, dialog_h) < 12) {
				
				mouse_active = false;
				CURSOR = cr_size_we;
				
				if(mouse_press(mb_left, sFOCUS)) {
					dialog_resizing |= 1 << 0;
					dialog_resiz_sw = dialog_w;
					dialog_resiz_sh = dialog_h;
					dialog_resiz_mx = mouse_raw_x;
					dialog_resiz_my = mouse_raw_y;
				}
			} 
				
			if(sHOVER && distance_to_line(mouse_mx, mouse_my, 0, dialog_h, dialog_w, dialog_h) < 12) {
				
				mouse_active = false;
				if(CURSOR == cr_size_we) CURSOR = cr_size_nwse;
				else                     CURSOR = cr_size_ns;  
				
				if(mouse_press(mb_left, sFOCUS)) {
					dialog_resizing |= 1 << 1;
					dialog_resiz_sw = dialog_w;
					dialog_resiz_sh = dialog_h;
					dialog_resiz_mx = mouse_raw_x;
					dialog_resiz_my = mouse_raw_y;
				}
			}
			
			winwin_set_cursor(window, CURSOR);
			WINDOW_ACTIVE = noone;
		}
	}
#endregion

#region focus
	function point_in(raw_x, raw_y) {
		INLINE
		
		var mx = raw_x - winwin_get_x_safe(window);
		var my = raw_y - winwin_get_y_safe(window);
		
		if(MAC) {
			mx = raw_x;
			my = raw_y;
		}
		
		var _r = dialog_resizable * 6;
		var x0 = dialog_x            - _r;
		var x1 = dialog_x + dialog_w + _r;
		var y0 = dialog_y            - _r;
		var y1 = dialog_y + dialog_h + _r;
		
		return point_in_rectangle(mx, my, x0, y0, x1, y1);
	}
	
	function checkFocus() {
		if(!active) return;
		WINDOW_ACTIVE = window;
		
		if(window == noone) {
			var _mx = FILE_IS_DROPPING? FILE_DROPPING_X : mouse_raw_x;
			var _my = FILE_IS_DROPPING? FILE_DROPPING_Y : mouse_raw_y;
			
			if(MAC) {
				_mx = mouse_mx;
				_my = mouse_my;
			}
			
			if(point_in(_mx, _my)) {
				if(depth < DIALOG_DEPTH_HOVER) {
					DIALOG_DEPTH_HOVER = depth;
					HOVER = self.id;
				}
			}
		} else if (winwin_exists(window)) {
			if(winwin_mouse_is_over_safe(window))
				HOVER = self.id;
		}
		
		WINDOW_ACTIVE = noone;
	}
	
	function checkDepth() {
		if(!active) return;
		if(HOVER != self.id) return;
		
		WINDOW_ACTIVE = window;
		
		if(mouse_press(mb_any, true, true)) {
			setFocus(self.id, "Dialog");
			
			with(_p_dialog) other.depth = min(other.depth, depth - 1);
		}
		
		WINDOW_ACTIVE = noone;
	}
	
	function onFocusBegin() {}
	function onFocusEnd()   {}
	
	function resetPosition() {
		if(!active) return;
		if(anchor == ANCHOR.none) {
			dialog_x = xstart - dialog_w / 2;
			dialog_y = ystart - dialog_h / 2;
		} else {
			if(anchor & ANCHOR.left)   dialog_x = min(xstart, WIN_SW - dialog_w);
			if(anchor & ANCHOR.right)  dialog_x = max(xstart - dialog_w, 0);
			if(anchor & ANCHOR.top)    dialog_y = min(ystart, WIN_SH - dialog_h);
			if(anchor & ANCHOR.bottom) dialog_y = max(ystart - dialog_h, 0);
		}
		
		dialog_x = round(clamp(dialog_x, 2, WIN_SW - dialog_w - 2));
		dialog_y = round(clamp(dialog_y, 2, WIN_SH - dialog_h - 2));
	}
	
	function isTop() {
		with(_p_dialog) if(depth < other.depth) return false;
		return true;
	}
	
	function checkMouse() {
		if(!active)       return;
		if(!DIALOG_CLICK) return;
		if(init_pressing) return;
		
		if(MOUSE_POOL.lpress || MOUSE_POOL.rpress) { //print($"Closing {title}");
			if(!isTop()) {
				// print($"    > Not close, not on top.")
				return;
			}
			
			for( var i = 0, n = array_length(children); i < n; i++ )
				if(instance_exists(children[i])) return;
			
			if(checkClosable() && destroy_on_click_out && !point_in(mouse_raw_x, mouse_raw_y)) {
				instance_destroy(self);
				onDestroy();
				DIALOG_CLICK = false;
			}
		}
	}
	
	function checkClosable() { return true; }
		
	function onDestroy() { }
#endregion

#region children
	function addChildren(object) {
		object.parent = self;
		array_push_unique(children, object.id);
	}
#endregion