/// @description init
#macro DIALOG_PAD ui(8)
#macro DIALOG_SHOW_FOCUS (FOCUS == self.id || (FOCUS && FOCUS[$ "preFocus"] == self.id) || (instance_exists(o_dialog_menubox) && o_dialog_menubox.getContextPanel() == self))

#macro DIALOG_DRAW_BG                           \
	if(is_winwin(window)) winwin_start(window); \
	var _dialog_x = window? 0 : dialog_x;       \ 
	var _dialog_y = window? 0 : dialog_y;       \
	draw_sprite_stretched( THEME.dialog, 0, _dialog_x - 8, _dialog_y - 8, _dialog_w + 16, _dialog_h + 16 );

#macro DIALOG_DRAW_FOCUS                                                                                                \
	var foc = FOCUS == self.id || (FOCUS && FOCUS[$ "preFocus"] == self.id);                                            \
	var cc  = PREFERENCES.panel_outline_accent? COLORS._main_accent : COLORS.panel_select_border                        \
	if(foc || (instance_exists(o_dialog_menubox) && o_dialog_menubox.getContextPanel() == self))                        \
		 draw_sprite_stretched_ext( THEME.dialog, 1, _dialog_x-8, _dialog_y-8, _dialog_w+16, _dialog_h+16, cc, 1 );     \
	else draw_sprite_stretched_ext( THEME.dialog, 1, _dialog_x-8, _dialog_y-8, _dialog_w+16, _dialog_h+16, COLORS.panel_frame, 1 ); \
	if(is_winwin(window)) winwin_end();

#macro DIALOG_DRAW_FOCUS_UNEND                                                                                          \
	var foc = FOCUS == self.id || (FOCUS && FOCUS[$ "preFocus"] == self.id);                                            \
	var cc  = PREFERENCES.panel_outline_accent? COLORS._main_accent : COLORS.panel_select_border                        \
	if(foc || (instance_exists(o_dialog_menubox) && o_dialog_menubox.getContextPanel() == self))                        \
		 draw_sprite_stretched_ext( THEME.dialog, 1, _dialog_x-8, _dialog_y-8, _dialog_w+16, _dialog_h+16, cc, 1 );     \
	else draw_sprite_stretched_ext( THEME.dialog, 1, _dialog_x-8, _dialog_y-8, _dialog_w+16, _dialog_h+16, COLORS.panel_frame, 1 );

#macro DIALOG_WINDOW_START                      \
	if(is_winwin(window)) winwin_start(window); \
	var _dialog_x = window? 0 : dialog_x;       \ 
	var _dialog_y = window? 0 : dialog_y;

#macro DIALOG_WINDOW_END                  \
	if(is_winwin(window)) winwin_end();

#region data
	on_top    = false;

	with(_p_dialog)  { if(!on_top) other.depth = min(depth - 1, other.depth); }
	with(o_pie_menu) { other.depth = min(depth - 1, other.depth); }
	
	ds_list_add(DIALOGS, self);
	
	preFocus  = FOCUS;
	refocus   = false; function doRefocus() { refocus = true; return self; }
	
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
	
	init_pressing = mouse_lclick();
	init_rclick   = mouse_rclick();
#endregion

 ////- Window manipulations
	
	windowConfig = new winwin_config();
	window       = undefined;
	
	mouse_active	= false;
	draggable		= true;
	dialog_dragging = false;
	dialog_drag_sx  = 0;
	dialog_drag_sy  = 0;
	dialog_drag_mx  = 0;
	dialog_drag_my  = 0;
	mouse_draggable = true;
	
	onDrag = undefined;
	
	function doDrag() {
		if(!active) return;
		
		mouse_active = true;
		if(!draggable) return;
		
		if(dialog_dragging) {
			var diax = dialog_x;
			var diay = dialog_y;
			
			dialog_x = dialog_drag_sx + mouse_rx - dialog_drag_mx;
			dialog_y = dialog_drag_sy + mouse_ry - dialog_drag_my;
			
			var dx = dialog_x - diax;
			var dy = dialog_y - diay;
			
			if(onDrag) onDrag(dx, dy);
			
			if(mouse_lrelease()) dialog_dragging = false;
		}
		
		var diax = window_get_x() + dialog_x;
		var diay = window_get_y() + dialog_y;
		
		var _x0 = diax;
		var _y0 = diay;
		var _x1 = diax + dialog_w;
		var _y1 = diay + title_height;
		
		if(mouse_draggable && !dialog_resizing && point_in_rectangle(mouse_rx, mouse_ry, _x0, _y0, _x1, _y1)) {
			mouse_active = false;
			if(mouse_lpress(sFOCUS)) {
				dialog_dragging = true;
				dialog_drag_sx  = dialog_x;
				dialog_drag_sy  = dialog_y;
				dialog_drag_mx  = mouse_rx;
				dialog_drag_my  = mouse_ry;
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
		if(!active || !dialog_resizable) return;
		
		if(dialog_resizing != 0) {
			var dx = mouse_rx - dialog_resiz_mx;
			var dy = mouse_ry - dialog_resiz_my;
			
			if(dialog_resizing & 0b0001) {
				var ww = dialog_resiz_sw + dx;
				    ww = clamp(ww, dialog_w_min, dialog_w_max);
				dialog_w = ww;
			} 
			
			if(dialog_resizing & 0b0010) {
				var hh = dialog_resiz_sh + dy;
				    hh = clamp(hh, dialog_h_min, dialog_h_max);
				dialog_h = hh;
			}
			
			if(dialog_resizing & 0b0100) {
				var ww = dialog_resiz_sw - dx;
				    ww = clamp(ww, dialog_w_min, dialog_w_max);
				dialog_x = dialog_resiz_sx - (ww - dialog_resiz_sw);
				dialog_w = ww;
			} 
			
			if(dialog_resizing & 0b1000) {
				var hh = dialog_resiz_sh - dy;
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
			
			if(mouse_lrelease()) dialog_resizing = 0;
		}
		
		if(sHOVER) {
			var diax = window_get_x() + dialog_x;
			var diay = window_get_y() + dialog_y;
			
			var _x0 = diax;
			var _y0 = diay;
			var _x1 = diax + dialog_w;
			var _y1 = diay + dialog_h;
			var _sel_mask = 0;
			
			if(point_in_rectangle(mouse_rx, mouse_ry, _x0, _y0, _x1, _y1)) {
				if(distance_to_line(mouse_rx, mouse_ry, _x1, _y0, _x1, _y1) < DIALOG_PAD) _sel_mask |= 1 << 0;
				if(distance_to_line(mouse_rx, mouse_ry, _x0, _y1, _x1, _y1) < DIALOG_PAD) _sel_mask |= 1 << 1;
				if(distance_to_line(mouse_rx, mouse_ry, _x0, _y0, _x0, _y1) < DIALOG_PAD) _sel_mask |= 1 << 2;
				if(distance_to_line(mouse_rx, mouse_ry, _x0, _y0, _x1, _y0) < DIALOG_PAD) _sel_mask |= 1 << 3;
			}
			
			if(_sel_mask != 0) {
				mouse_active = false;
				
				switch(_sel_mask) {
					case 0b0001 : case 0b0100 : CURSOR = cr_size_we;   break;
					case 0b0010 : case 0b1000 : CURSOR = cr_size_ns;   break;
					case 0b0011 : case 0b1100 : CURSOR = cr_size_nwse; break;
					case 0b1001 : case 0b0110 : CURSOR = cr_size_nesw; break;
				}
				
				if(mouse_lpress(sFOCUS)) {
					dialog_resizing = _sel_mask;
					dialog_resiz_sx = dialog_x;
					dialog_resiz_sy = dialog_y;
					dialog_resiz_sw = dialog_w;
					dialog_resiz_sh = dialog_h;
					dialog_resiz_mx = mouse_rx;
					dialog_resiz_my = mouse_ry;
				}
			}
		}
		
	}

 ////- Focus
		
	function point_in(mx, my) {
		var diax = dialog_x; 
		var diay = dialog_y;
	
		var _r = dialog_resizable * 6;
		var x0 = diax            - _r;
		var x1 = diax + dialog_w + _r;
		var y0 = diay            - _r;
		var y1 = diay + dialog_h + _r;
		
		return point_in_rectangle(mx, my, x0, y0, x1, y1);
	}
	
	onCheckMouse = undefined;
	function checkMouse() {
		if(!active) return;
		
		var _mx = mouse_mx;
		var _my = mouse_my;
		
		var useWindow = is_winwin(window);
		
		if(useWindow) {
			_mx = winwin_mouse_get_x(window);
			_my = winwin_mouse_get_y(window);
		}
		
		if(FILE_IS_DROPPING) {
			_mx = FILE_DROPPING_X;
			_my = FILE_DROPPING_Y;
				
		}
		
		var _hoverRect  = useWindow? winwin_mouse_is_over(window) : point_in(_mx, _my);
		var _depthHover = useWindow? winwin_mouse_is_over(window) : depth <= DIALOG_DEPTH_HOVER;
		
		if(_hoverRect && _depthHover) {
			DIALOG_DEPTH_HOVER = depth;
			HOVER = self.id;
		}
		
		if(onCheckMouse) onCheckMouse();
		
		if(!DIALOG_CLICK || init_pressing) return;
		
		if(mouse_lpress() || mouse_rpress()) { 
			if(!volatile && !isTop()) return;
			
			for( var i = 0, n = array_length(children); i < n; i++ )
				if(instance_exists(children[i])) return;
			
			if(checkClosable() && destroy_on_click_out && !_hoverRect) {
				instance_destroy(self);
				onDestroy();
				DIALOG_CLICK = false;
			}
		}
	}
	
	onCheckFocus = undefined;
	function checkFocus() { if(onCheckFocus) onCheckFocus(); }
	
	function checkDepth() {
		if(!active) return;
		if(HOVER != self.id) return;
		
		if(mouse_press(mb_any, true, true)) {
			setFocus(self.id);
			with(_p_dialog) other.depth = min(other.depth, depth - 1);
		}
		
	}
	
	function onInit()       {}
	function onFocusBegin() {}
	function onFocusEnd()   {}
	
	function onResetPosition() {}
	function resetPosition()   {
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
		onResetPosition();
		
		if(MULTI_WINDOWS) {
			if(is_winwin(window)) {
				winwin_set_rectangle(window, window_get_x() + dialog_x, window_get_y() + dialog_y, dialog_w, dialog_h);
				
			} else {
				var wx = window_get_x() + dialog_x;
				var wy = window_get_y() + dialog_y;
				window = winwin_create(wx, wy, dialog_w, dialog_h, windowConfig);
				winwin_set_shadow(window, false);
				winwin_enable_per_pixel_alpha(window);
				winwin_order_front(window);
				
				array_push(WINWIN_ALL, window);
			}
		}
	}
	
	function isTop() {
		with(_p_dialog) if(depth < other.depth) return false;
		return true;
	}
	
	function checkClosable() { return true; }
		
	function onDestroy() {}

 ////- Children
		
	function addChildren(object) {
			object.parent = self;
			array_push_unique(children, object.id);
		}