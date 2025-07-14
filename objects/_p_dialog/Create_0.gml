/// @description init
#macro DIALOG_PAD 8
#macro DIALOG_DRAW_BG    draw_sprite_stretched(THEME.dialog, 0, dialog_x - 8, dialog_y - 8, dialog_w + 16, dialog_h + 16);
#macro DIALOG_DRAW_FOCUS draw_sprite_stretched_ext(THEME.dialog, 1, dialog_x - 8, dialog_y - 8, dialog_w + 16, dialog_h + 16, COLORS._main_accent, 1);

#macro DIALOG_WINCLEAR  //
#macro DIALOG_WINCLEAR1 //
#macro DIALOG_PREDRAW   //
#macro DIALOG_POSTDRAW  //

#region data
	on_top    = false;

	with(_p_dialog) { 
		if(on_top) continue; 
		other.depth = min(depth - 1, other.depth); 
	}
	
	ds_list_add(DIALOGS, self);
	
	prefocus  = FOCUS;
	refocus   = false;
	
	active    = true;
	dialog_w  = 320;
	dialog_h  = 320;
	_dialog_w = 320;
	_dialog_h = 320;
	dialog_x  = 0;
	dialog_y  = 0;
	anchor    = ANCHOR.none;
	
	title          = "dialog";
	context_str    = "Dialog";
	window_drawing = false;
	
	title_height = 64;
	padding      = 20;
	
	children = [];
	parent   = noone;
	
	alarm[0] = 1;
	ready    = false;
	
	volatile = false;
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
	passthrough     = false;
	
	function doDrag() {
		if(!active) return;
		
		mouse_active = true;
		if(!draggable) return;
		
		if(dialog_dragging) {
			var _dx = dialog_drag_sx + mouse_mx - dialog_drag_mx;
			var _dy = dialog_drag_sy + mouse_my - dialog_drag_my;
			
			var _wx = window_get_x();
			var _wy = window_get_y();
			
			dialog_x = clamp(_dx, ui(16) - dialog_w, WIN_W - ui(16));
			dialog_y = clamp(_dy, ui(16) - dialog_h, WIN_H - ui(16));
			
			if(mouse_release(mb_left))
				dialog_dragging = false;
		}
		
		if(mouse_draggable && !dialog_resizing && point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + title_height)) {
			mouse_active = false;
			if(mouse_press(mb_left, sFOCUS)) {
				dialog_dragging = true;
				dialog_drag_sx  = dialog_x;
				dialog_drag_sy  = dialog_y;
				dialog_drag_mx  = mouse_mx;
				dialog_drag_my  = mouse_my;
			}
		}
	
		mouse_draggable = true;
	}
	
	dialog_resizable = false;
	dialog_resizing = 0;
	dialog_resiz_sx = 0;
	dialog_resiz_sy = 0;
	dialog_resiz_sw = 0;
	dialog_resiz_sh = 0;
	dialog_resiz_mx = 0;
	dialog_resiz_my = 0;
	dialog_w_min    = 320;
	dialog_h_min    = 320;
	dialog_w_max    = WIN_W;
	dialog_h_max    = WIN_H;
	onResize        = undefined;
	
	function doResize() {
		if(!active) return;
		if(!dialog_resizable) return;
		
		if(dialog_resizing != 0) {
			
			if(dialog_resizing & 0b0001) {
				var ww = dialog_resiz_sw + (mouse_mx - dialog_resiz_mx);
				    ww = clamp(ww, dialog_w_min, dialog_w_max);
				dialog_w = ww;
			} 
			
			if(dialog_resizing & 0b0010) {
				var hh = dialog_resiz_sh + (mouse_my - dialog_resiz_my);
				    hh = clamp(hh, dialog_h_min, dialog_h_max);
				dialog_h = hh;
			}
			
			if(dialog_resizing & 0b0100) {
				var ww = dialog_resiz_sw - (mouse_mx - dialog_resiz_mx);
				    ww = clamp(ww, dialog_w_min, dialog_w_max);
				dialog_x = dialog_resiz_sx - (ww - dialog_resiz_sw);
				dialog_w = ww;
			} 
			
			if(dialog_resizing & 0b1000) {
				var hh = dialog_resiz_sh - (mouse_my - dialog_resiz_my);
				    hh = clamp(hh, dialog_h_min, dialog_h_max);
				
				dialog_y = dialog_resiz_sy - (hh - dialog_resiz_sh);
				dialog_h = hh;
			}
			
			switch(dialog_resizing) {
				case 0b0001 : case 0b0100 : CURSOR = cr_size_we;   break;
				case 0b0010 : case 0b1000 : CURSOR = cr_size_ns;   break;
				case 0b0011 : case 0b1100 : CURSOR = cr_size_nwse; break;
				case 0b1001 : case 0b0110 : CURSOR = cr_size_nesw; break;
			}
			
			if(mouse_release(mb_left)) dialog_resizing = 0;
		}
		
		if(sHOVER) {
			var _x0 = dialog_x;
			var _y0 = dialog_y;
			var _x1 = dialog_x + dialog_w;
			var _y1 = dialog_y + dialog_h;
			var _sel_mask = 0;
			
			if(point_in_rectangle(mouse_mx, mouse_my, _x0, _y0, _x1, _y1)) {
				if(distance_to_line(mouse_mx, mouse_my, _x1, _y0, _x1, _y1) < DIALOG_PAD) _sel_mask |= 1 << 0;
				if(distance_to_line(mouse_mx, mouse_my, _x0, _y1, _x1, _y1) < DIALOG_PAD) _sel_mask |= 1 << 1;
				if(distance_to_line(mouse_mx, mouse_my, _x0, _y0, _x0, _y1) < DIALOG_PAD) _sel_mask |= 1 << 2;
				if(distance_to_line(mouse_mx, mouse_my, _x0, _y0, _x1, _y0) < DIALOG_PAD) _sel_mask |= 1 << 3;
			}
			
			if(_sel_mask != 0) {
				mouse_active = false;
				
				switch(_sel_mask) {
					case 0b0001 : case 0b0100 : CURSOR = cr_size_we;   break;
					case 0b0010 : case 0b1000 : CURSOR = cr_size_ns;   break;
					case 0b0011 : case 0b1100 : CURSOR = cr_size_nwse; break;
					case 0b1001 : case 0b0110 : CURSOR = cr_size_nesw; break;
				}
				
				if(mouse_press(mb_left, sFOCUS)) {
					dialog_resizing = _sel_mask;
					dialog_resiz_sx = dialog_x;
					dialog_resiz_sy = dialog_y;
					dialog_resiz_sw = dialog_w;
					dialog_resiz_sh = dialog_h;
					dialog_resiz_mx = mouse_mx;
					dialog_resiz_my = mouse_my;
				}
			}
		}
		
	}
#endregion

#region focus
	function point_in(mx, my) {
		INLINE
		var _r = dialog_resizable * 6;
		var x0 = dialog_x            - _r;
		var x1 = dialog_x + dialog_w + _r;
		var y0 = dialog_y            - _r;
		var y1 = dialog_y + dialog_h + _r;
		
		return point_in_rectangle(mx, my, x0, y0, x1, y1);
	}
	
	function checkFocus() {
		if(!active) return;
		
		var _mx = FILE_IS_DROPPING? FILE_DROPPING_X : mouse_mx;
		var _my = FILE_IS_DROPPING? FILE_DROPPING_Y : mouse_my;
		
		if(point_in(_mx, _my) && depth <= DIALOG_DEPTH_HOVER) {
			DIALOG_DEPTH_HOVER = depth;
			HOVER = self.id;
		}
		
	}
	
	function checkDepth() {
		if(!active) return;
		if(HOVER != self.id) return;
		
		
		if(mouse_press(mb_any, true, true)) {
			setFocus(self.id, context_str);
			
			with(_p_dialog) other.depth = min(other.depth, depth - 1);
		}
		
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
		
		if(MOUSE_POOL.lpress || MOUSE_POOL.rpress) { 
			if(!volatile && !isTop()) return;
			
			for( var i = 0, n = array_length(children); i < n; i++ )
				if(instance_exists(children[i])) return;
			
			if(checkClosable() && destroy_on_click_out && !point_in(mouse_mx, mouse_my)) {
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