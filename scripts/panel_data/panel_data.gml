enum ANCHOR {
	none    = 0,
	top     = 1,
	bottom  = 2,
	left    = 4,
	right   = 8
}

function Panel(_parent, _x, _y, _w, _h) constructor {
	parent = _parent;
	if(parent) ds_list_add(parent.childs, self);
	
	padding = THEME_VALUE.panel_margin;
	content = [];
	content_index = 0;
	childs  = ds_list_create();
	anchor  = ANCHOR.none;
	
	x = _x;
	y = _y;
	w = _w;
	h = _h;
	tx = x;
	ty = y;
	tw = w;
	th = h;
	split = "";
	
	tab_width   = 0;
	tab_height  = ui(24);
	tab_x       = 0;
	tab_x_to    = 0;
	tab_surface = noone;
	
	min_w = ui(40);
	min_h = ui(40);
	
	dragging  = -1;
	drag_sval = 0;
	drag_sm   = 0;
	mouse_active = true;
	
	content_surface = surface_create_valid(w, h);
	mask_surface    = surface_create_valid(w, h);
	
	tab_holding    = noone;
	tab_hold_state = 0;
	tab_holding_mx = 0;
	tab_holding_my = 0;
	tab_holding_sx = 0;
	tab_holding_sy = 0;
	tab_cover	   = noone;
	
	border_rb_close = menuItem(__txt("Close"), function() { #region
		var con = getContent();
		if(con == noone) return;
		con.close();
	}, THEME.cross); #endregion
	
	border_rb_menu = [ #region
		menuItem(__txt("Move"),    function() { 
			extract(); 
			panel_mouse = 1;
		}),
		menuItem(__txtx("panel_pop_out", "Pop out"), function() { popWindow(); }, THEME.node_goto),
		border_rb_close
	]; #endregion
	
	static getContent = function() { return array_safe_get(content, content_index, noone, ARRAY_OVERFLOW._default); }
	static hasContent = function() { return bool(array_length(content)); }
	
	function resetMask() { #region
		var tab = array_length(content) > 1;
		tx = x; ty = y + tab * ui(tab_height);
		tw = w; th = h - tab * ui(tab_height);
		
		content_surface = surface_verify(content_surface, tw, th);
		mask_surface    = surface_verify(mask_surface, tw, th);
		surface_set_target(mask_surface);
		draw_clear(c_black);
		gpu_set_blendmode(bm_subtract);
		draw_sprite_stretched(THEME.ui_panel_bg, 0, padding, padding, tw - padding * 2, th - padding * 2);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
	} resetMask(); #endregion
	
	function setPadding(padding) { #region
		self.padding = padding;
		refresh();
	} #endregion
	
	function refresh() { #region
		resetMask();
		
		for( var i = 0, n = array_length(content); i < n; i++ )
			content[i].refresh();
			
		for( var i = 0; i < ds_list_size(childs); i++ )
			childs[| i].refresh();
	} #endregion
	
	function move(dx, dy) { #region
		x += dx;
		y += dy;
		
		for(var i = 0; i < ds_list_size(childs); i++) {
			var _panel = childs[| i];
			_panel.move(dx, dy);
		}
		
		for( var i = 0, n = array_length(content); i < n; i++ ) {
			content[i].x = x;
			content[i].y = y;
		}
	} #endregion
	
	function resizable(dw, dh, oppose = ANCHOR.left) { #region
		var tab = array_length(content) > 1;
		tx = x; ty = y + tab * ui(tab_height);
		tw = w; th = h - tab * ui(tab_height);
		
		var hori = oppose == ANCHOR.left || oppose == ANCHOR.right;
		
		if(hasContent()) {
			var res = true;
			for( var i = 0, n = array_length(content); i < n; i++ )
				res &= hori? tw + dw > content[i].min_w : th + dh > content[i].min_h;
			return res;
		}
		
		var ind  = hori? childs[| 1].w > childs[| 0].w : childs[| 1].h > childs[| 0].h;
		return childs[| ind].resizable(dw, dh, oppose);
	} #endregion
	
	function refreshSize(recur = true) { #region //refresh content surface after resize
		//__debug_counter("refresh size");
		var tab = array_length(content) > 1;
		tx = x; ty = y + tab * ui(tab_height);
		tw = w; th = h - tab * ui(tab_height);
		
		for( var i = 0, n = array_length(content); i < n; i++ ) {
			content[i].w = max(tw, content[i].min_w);
			content[i].h = max(th, content[i].min_h);
			content[i].onResize();
		}
			
		if(ds_list_size(childs) == 2) {
			//print("=== Refreshing (" + string(w) + ", " + string(h) + ") " + string(split) + " ===");
			
			var _tw = childs[| 0].w + childs[| 1].w;
			var _th = childs[| 0].h + childs[| 1].h;
			
			var fixChild = split == "h"? childs[| 1].x < childs[| 0].x : childs[| 1].y < childs[| 0].y;
			
			childs[| fixChild].x = x;
			childs[| fixChild].y = y;
			
			if(split == "h") {
				childs[|  fixChild].w = round(childs[| fixChild].w / _tw * w);
				childs[|  fixChild].h = round(h);
			
				childs[| !fixChild].x = x + childs[| fixChild].w;
				childs[| !fixChild].y = y;
					
				childs[| !fixChild].w = round(w - childs[| fixChild].w);
				childs[| !fixChild].h = round(h);
				
				childs[|  fixChild].anchor = ANCHOR.left;
				childs[| !fixChild].anchor = ANCHOR.right;
			} else if(split == "v") {	
				childs[|  fixChild].w = round(w);
				childs[|  fixChild].h = round(childs[| fixChild].h / _th * h);
			
				childs[| !fixChild].x = x;
				childs[| !fixChild].y = y + childs[| fixChild].h;
					
				childs[| !fixChild].w = round(w);
				childs[| !fixChild].h = round(h - childs[| fixChild].h);
				
				childs[|  fixChild].anchor = ANCHOR.top;
				childs[| !fixChild].anchor = ANCHOR.bottom;
			}
			
			if(recur)
			for(var i = 0; i < ds_list_size(childs); i++)
				childs[| i].refreshSize();
		}
		
		refresh();
	} #endregion
	
	function resize(dw, dh, oppose = ANCHOR.left) { #region
		if(dw == 0 && dh == 0) return;
		
		if(ds_list_size(childs) == 2) {
			var hori = oppose == ANCHOR.left || oppose == ANCHOR.right;
			var ind  = hori? childs[| 1].w > childs[| 0].w : childs[| 1].h > childs[| 0].h;
			childs[| ind].resize(dw, dh, oppose);
		}
		
		w = max(round(w + dw), min_w);
		h = max(round(h + dh), min_h);
		
		refreshSize(false);
	} #endregion
	
	function setContent(_content = noone, _switch = false) { #region
		if(is_array(_content))
			content = array_append(content, _content);
		else 
			array_push(content, _content);
		
		for( var i = 0, n = array_length(content); i < n; i++ ) 
			content[i].onSetPanel(self);
			
		if(_switch) setTab(array_find(content, _content));
			
		refresh();
	} #endregion
	
	function split_h(_w) { #region
		if(abs(_w) > w) {
			print("Error: Split panel larger than size w (" + string(_w) + " > " + string(w) + ")");
			return noone;
		}
		
		if(_w < 0) _w = w + _w;
		var _panelParent = new Panel(parent, x, y, w, h);
		_panelParent.anchor = anchor;
		_panelParent.split  = "h";
		
		var _panelL = self;
		ds_list_add(_panelParent.childs, _panelL);
		
		var _panelR = new Panel(_panelParent, x + _w, y, w - _w, h);
		_panelR.anchor = ANCHOR.right;
		
		var prev_w = w;
		w = _w;
		for( var i = 0, n = array_length(content); i < n; i++ ) {
			content[i].w = w;
			content[i].onResize();
		}
		
		if(parent == noone) 
			PANEL_MAIN = _panelParent;
		else
			ds_list_delete(parent.childs, ds_list_find_index(parent.childs, self));
			
		parent	= _panelParent;
		anchor	= ANCHOR.left;
		content = [];
		
		return [ _panelL, _panelR ];
	} #endregion
	
	function split_v(_h) { #region
		if(abs(_h) > h) {
			print("Error: Split panel larger than size h (" + string(_h) + " > " + string(h) + ")");
			return noone;
		}
		
		if(_h < 0) _h = h + _h;
		var _panelParent = new Panel(parent, x, y, w, h);
		_panelParent.anchor = anchor;
		_panelParent.split  = "v";
		
		var _panelT = self;
		ds_list_add(_panelParent.childs, _panelT);
		var _panelB = new Panel(_panelParent, x, y + _h, w, h - _h);
		_panelB.anchor = ANCHOR.bottom;
		
		var prev_h = h;
		h = _h;
		for( var i = 0, n = array_length(content); i < n; i++ ) {
			content[i].h = h;
			content[i].onResize();
		}
		
		if(parent == noone) 
			PANEL_MAIN = _panelParent;
		else
			ds_list_delete(parent.childs, ds_list_find_index(parent.childs, self));
		
		parent	= _panelParent;
		anchor	= ANCHOR.top;
		content = [];
		
		return [_panelT, _panelB];
	} #endregion
	
	function stepBegin() { #region
		var con = getContent();
		if(con) con.panelStepBegin(self);
		
		if(o_main.panel_dragging != noone) dragging = -1;
		
		if(dragging == 1) {
			var _mx = clamp(mouse_mx, ui(16), WIN_W - ui(16));
			var dw  = round(_mx - drag_sm);
			var res = true;
			
			for(var i = 0; i < ds_list_size(childs); i++) {
				var _panel = childs[| i];
				switch(_panel.anchor) {
					case ANCHOR.left:
						res &= _panel.resizable(dw, 0, ANCHOR.left);
						break;
					case ANCHOR.right:
						res &= _panel.resizable(-dw, 0, ANCHOR.right);
						break;
				}
			}
			
			if(res) {
				drag_sm = _mx;
				
				for(var i = 0; i < ds_list_size(childs); i++) {
					var _panel = childs[| i];
					switch(_panel.anchor) {
						case ANCHOR.left:
							_panel.resize(dw, 0, ANCHOR.left);
							break;
						case ANCHOR.right:
							_panel.resize(-dw, 0, ANCHOR.right);
							_panel.move(dw, 0);
							break;
					}
				}
			}
			
			if(mouse_release(mb_left)) {
				refreshSize();
				dragging = -1;
			}
		} else if(dragging == 2) {
			var _my = clamp(mouse_my, ui(16), WIN_H - ui(16));
			var dh  = round(_my - drag_sm);
			var res = true;
			
			for(var i = 0; i < ds_list_size(childs); i++) {
				var _panel = childs[| i];
				switch(_panel.anchor) {
					case ANCHOR.top:
						res &= _panel.resizable(0, dh, ANCHOR.top);
						break;
					case ANCHOR.bottom:
						res &= _panel.resizable(0, -dh, ANCHOR.bottom);
						break;
				}
			}
				
			if(res) {
				drag_sm = _my;
				
				for(var i = 0; i < ds_list_size(childs); i++) {
					var _panel = childs[| i];
					switch(_panel.anchor) {
						case ANCHOR.top:
							_panel.resize(0, dh, ANCHOR.top);
							break;
						case ANCHOR.bottom:
							_panel.resize(0, -dh, ANCHOR.bottom);
							_panel.move(0, dh);
							break;
					}
				}
			}
			
			if(mouse_release(mb_left)) {
				refreshSize();
				dragging = -1;
			}
		} else {
			if(con && point_in_rectangle(mouse_mx, mouse_my, x + ui(2), y + ui(2), x + w - ui(4), y + h - ui(4))) {
				HOVER = self;
				if(mouse_press(mb_any))   
					setFocus(self);
				if(FOCUS == self && con) 
					FOCUS_STR = con.context_str;
			} else {
				for(var i = 0; i < ds_list_size(childs); i++) {
					var _panel = childs[| i];
					_panel.stepBegin();
				}
			}
		}
	} #endregion
	
	static step = function() { #region
		for(var i = 0; i < ds_list_size(childs); i++) {
			var _panel = childs[| i];
			_panel.step();
		}
	} #endregion
	
	static draw = function() { #region
		if(hasContent()) {
			drawPanel();
			return;
		}
		
		if(ds_list_empty(childs)) 
			return;
		
		var min_w = ui(32);
		var min_h = ui(32);
		if(split == "h") {
			min_w = childs[| 0].min_w + childs[| 1].min_w;
			min_h = max(childs[| 0].min_h + childs[| 1].min_h);
		} else {
			min_w = max(childs[| 0].min_w, childs[| 1].min_w);
			min_h = childs[| 0].min_h + childs[| 1].min_h;
		}
		
		for(var i = 0; i < ds_list_size(childs); i++) {
			var _panel = childs[| i];
			_panel.draw();
			
			if!(HOVER == noone || is_struct(HOVER))
				continue;
			
			var p = ui(6 - 1);
			switch(_panel.anchor) {
				case ANCHOR.left :
					if(!point_in_rectangle(mouse_mx, mouse_my, _panel.x + _panel.w - p, _panel.y, _panel.x + _panel.w + p, _panel.y + _panel.h))
						break;
							
					CURSOR = cr_size_we;
					if(mouse_press(mb_left)) {
						dragging  = 1;
						drag_sval = _panel.w;
						drag_sm   = mouse_mx;
					}
					break;
				case ANCHOR.top :
					if(!point_in_rectangle(mouse_mx, mouse_my, _panel.x, _panel.y + _panel.h - p, _panel.x + _panel.w, _panel.y + _panel.h + p))
						break;
							
					CURSOR = cr_size_ns;
					if(mouse_press(mb_left)) {
						dragging = 2;
						drag_sval = _panel.h;
						drag_sm   = mouse_my;
					}
					break;
			}
		}
		
		if(self == PANEL_MAIN && o_main.panel_dragging != noone && key_mod_press(CTRL))
			checkHover();
	} #endregion
	
	function drawTab() { #region
		tab_surface = surface_verify(tab_surface, w - padding * 2 + 1, tab_height + ui(4));
		
		var tsx = x + padding - 1;
		var tsy = y + ui(2);
		var msx = mouse_x - tsx;
		var msy = mouse_y - tsy;
		tab_cover = noone;
		
		surface_set_target(tab_surface);
			DRAW_CLEAR
			
			var tbx = tab_x + ui(1);
			var tby = 0;
			var tbh = tab_height + ui(2);
			var tabHov = msx < 0 ? 0 : array_length(content) - 1;
			
			tab_x = lerp_float(tab_x, tab_x_to, 5);
			tab_width = 0;
			
			var rem = -1;
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text_sub);
			for( var i = 0, n = array_length(content); i < n; i++ ) {
				var txt = content[i].title;
				var icn = content[i].icon;
				
				var tbw = string_width(txt) + ui(16 + 16);
				if(icn != noone) tbw += ui(16 + 4);
				var foc = false;
				
				tab_width += tbw + ui(2);
				if(msx >= tbx && msy <= tbx + tbw) 
					tabHov = i;
					
				if(tab_holding == content[i]) {
					tbx += tbw + ui(2);
					continue;
				}
				
				content[i].tab_x = content[i].tab_x == 0? tbx : lerp_float(content[i].tab_x, tbx, 5);
				var _tbx = content[i].tab_x;
				var _hov = point_in_rectangle(msx, msy, _tbx, tby, _tbx + tbw, tab_height);
				var _tdh = tbh + THEME_VALUE.panel_tab_extend;
				
				if(i == content_index) {
					foc = FOCUS == self;
					var cc = FOCUS == self? COLORS._main_accent : COLORS.panel_tab;
					draw_sprite_stretched_ext(THEME.ui_panel_tab, 1 + (FOCUS == self), _tbx, tby, tbw, _tdh, cc, 1);
					if(!foc)
						tab_cover = BBOX().fromWH(tsx + _tbx, tsy + tby + tbh - ui(3), tbw, THEME_VALUE.panel_tab_extend);
				} else {
					var cc = COLORS.panel_tab_inactive;
					if(HOVER == self && _hov)
						var cc = COLORS.panel_tab_hover;
						
					draw_sprite_stretched_ext(THEME.ui_panel_tab, 0, _tbx, tby, tbw, _tdh, cc, 1);
				}
				
				var aa = 0.5;
				if(point_in_rectangle(msx, msy, _tbx + tbw - ui(16), tby, _tbx + tbw, tab_height)) {
					aa = 1;
					if(mouse_press(mb_left, FOCUS == self)) 
						rem = i;
				} else if(HOVER == self && _hov) {
					if(mouse_press(mb_left, FOCUS == self)) {
						setTab(i);
						
						tab_holding = content[i];
						tab_hold_state = 0;
						tab_holding_mx = msx;
						tab_holding_my = msy;
						tab_holding_sx = tab_holding.tab_x;
					}
					
					if(mouse_press(mb_right, FOCUS == self)) {
						var menu = array_clone(border_rb_menu);
						if(instanceof(content[i]) == "Panel_Menu")
							array_remove(menu, 2);
						
						menuCall("panel_border_menu",,, menu);
					}
					
					if(mouse_press(mb_middle, FOCUS == self))
						rem = i;
					
					if(DRAGGING)
						setTab(i);
				}
				
				draw_sprite_ui(THEME.tab_exit, 0, _tbx + tbw - ui(12), tab_height / 2 + 1,,,, foc? COLORS.panel_tab_icon : COLORS._main_text_sub, aa);
				
				if(icn != noone) {
					draw_sprite_ui(icn, 0, _tbx + ui(8 + 8), tab_height / 2 + 1,,,, foc? COLORS.panel_tab_icon : COLORS._main_text_sub);
					_tbx += ui(20);
				}
				
				draw_set_text(f_p3, fa_left, fa_bottom, foc? COLORS.panel_tab_text : COLORS._main_text_sub);
				draw_text_add(_tbx + ui(8), tab_height - ui(4), txt);
				
				tbx += tbw + ui(2);
			}
			
			if(rem > -1) content[rem].close();
			
			tab_width = max(0, tab_width - w + ui(32));
			if(point_in_rectangle(msx, msy, 0, 0, w, tab_height)) {
				if(mouse_wheel_up())	tab_x_to = clamp(tab_x_to + ui(64) * SCROLL_SPEED, -tab_width, 0);
				if(mouse_wheel_down())	tab_x_to = clamp(tab_x_to - ui(64) * SCROLL_SPEED, -tab_width, 0);
			}
			
			if(tab_holding) {
				draw_set_font(f_p3);
				
				var _tbx = tab_holding.tab_x;
				var txt  = tab_holding.title;
				var icn  = tab_holding.icon;
				var tbw  = string_width(txt) + ui(16 + 16);
				if(icn != noone) tbw += ui(16 + 4);
				
				draw_sprite_stretched_ext(THEME.ui_panel_tab, 2, _tbx, tby, tbw, tbh, COLORS._main_accent, 1);
				draw_sprite_ui(THEME.tab_exit, 0, _tbx + tbw - ui(12), tab_height / 2 + 1,,,, COLORS.panel_tab_icon);
				
				if(icn != noone) {
					draw_sprite_ui(icn, 0, _tbx + ui(8 + 8), tab_height / 2 + 1,,,, COLORS.panel_tab_icon);
					_tbx += ui(20);
				}
				draw_set_text(f_p3, fa_left, fa_bottom, COLORS.panel_tab_text);
				draw_text_add(_tbx + ui(8), tab_height - ui(4), txt);
				
				if(tab_hold_state == 0) {
					if(point_distance(tab_holding_mx, tab_holding_my, msx, msy) > 8)
						tab_hold_state = 1;
				} else if(tab_hold_state == 1) {
					if(point_in_rectangle(msx, msy, 0, 0, w, tab_height)) {
						if(msx < ui(32))		tab_x_to = clamp(tab_x_to + ui(2), -tab_width, 0);
						if(msx > w - ui(32))	tab_x_to = clamp(tab_x_to - ui(2), -tab_width, 0);
					}
			
					tab_holding.tab_x = clamp(tab_holding_sx + (msx - tab_holding_mx), 1, w - tbw - ui(4));
					
					array_remove(content, tab_holding);
					array_insert(content, tabHov, tab_holding);
					setTab(array_find(content, tab_holding));
					
					if(abs(msy - tab_holding_my) > ui(32)) {
						extract();
						tab_holding = noone;
					}
				}
				
				if(mouse_release(mb_left))
					tab_holding = noone;
			}
		surface_reset_target();
		
		draw_surface(tab_surface, tsx, tsy);
	} #endregion
	
	function setTab(tabIndex) { #region
		if(tabIndex < 0) return;
		if(tabIndex >= array_length(content)) return;
		
		var prec = array_safe_get(content, content_index);
		if(prec) prec.onFocusEnd();
		
		content_index = tabIndex;
		
		var prec = array_safe_get(content, content_index);
		if(prec) prec.onFocusBegin();
	} #endregion
	
	function drawPanel() { #region
		if(w <= ui(16)) return;
		var tab = array_length(content) > 1;
		tx = x; ty = y + tab * ui(tab_height);
		tw = w; th = h - tab * ui(tab_height);
		if(th < ui(16)) return;
		
		var con = getContent();
		if(tab) drawTab();
		
		var p = ui(6);
		var m_in = point_in_rectangle(mouse_mx, mouse_my, tx + p, ty + p, tx + tw - p, ty + th - p);
		var m_ot = point_in_rectangle(mouse_mx, mouse_my, tx, ty, tx + tw, ty + th);
		mouse_active = m_in;
		
		var _tw = tw - padding * 2;
		var _th = th - padding * 2;
		draw_sprite_stretched(THEME.ui_panel_bg, 0, tx + padding, ty + padding, _tw, _th);
		
		if(!is_surface(mask_surface)) {
			mask_surface = surface_create_valid(tw, th);
			refresh();
		}
		
		content_surface = surface_verify(content_surface, tw, th);
			
		surface_set_target(content_surface);
			draw_clear(COLORS.panel_bg_clear);
			if(con) {
				min_w = con.min_w;
				min_h = con.min_h;
				if(tw >= min_w && th >= min_h)
					con.draw(self);
			}
			
			gpu_set_blendmode(bm_subtract);
			draw_surface_safe(mask_surface, 0, 0);
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		draw_surface_safe(content_surface, tx, ty);
		draw_sprite_stretched(THEME.ui_panel_fg, 0, tx + padding, ty + padding, _tw, _th);
		if(tab) draw_sprite_bbox(THEME.ui_panel_tab, 3, tab_cover);
		
		if(FOCUS == self && parent != noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, tx + padding, ty + padding, tw - padding * 2, th - padding * 2, COLORS._main_accent, 1);	
			
			if(hasContent() && !m_in && m_ot) {
				draw_sprite_stretched_ext(THEME.ui_panel_active, 0, tx + padding, ty + padding, tw - padding * 2, th - padding * 2, c_white, 0.4);
				
				if(DOUBLE_CLICK) {
					extract();
					panel_mouse = 0;
				} else if(mouse_press(mb_right)) {
					var menu = array_clone(border_rb_menu);
					if(instanceof(getContent()) == "Panel_Menu")
						array_remove(menu, 2, border_rb_close);
						
					menuCall("panel_border_menu",,, menu);
				}
			}
		} 
		
		if(o_main.panel_dragging != noone && m_ot && !key_mod_press(CTRL))
			checkHover();
	} #endregion
	
	function drawGUI() { #region
		for( var i = 0; i < ds_list_size(childs); i++ ) 
			childs[| i].drawGUI();
		
		var con = getContent();
		if(con == noone) return;
		con.drawGUI();
	} #endregion
	
	function extract() { #region
		var con = getContent();
		con.dragSurface = surface_clone(content_surface);
		o_main.panel_dragging = con;
				
		array_remove(content, con);
		refresh();
		setTab(0);
		
		HOVER = noone;
		FOCUS = noone;
		
		if(hasContent()) return;
		var ind = !ds_list_find_index(parent.childs, self); //index of the other child
		var sib = parent.childs[| ind];
		
		if(!sib.hasContent() && ds_list_size(sib.childs) == 2) { //other child is compound panel
			var gparent = parent.parent;
			if(gparent == noone) {
				sib.x = PANEL_MAIN.x; sib.y = PANEL_MAIN.y;
				sib.w = PANEL_MAIN.w; sib.h = PANEL_MAIN.h;
						
				PANEL_MAIN = sib;
				sib.parent = noone;
				PANEL_MAIN.refreshSize();
			} else {
				var pind    = ds_list_find_index(gparent.childs, parent); //index of parent in grandparent object
				gparent.childs[| pind] = sib; //replace parent with sibling
				sib.parent = gparent;
				gparent.refreshSize();
			}
		} else if(sib.hasContent()) { //other child is content panel, set parent to content panel
			parent.setContent(sib.content);
			ds_list_clear(parent.childs);
		}
	} #endregion
	
	function popWindow() { #region
		var con = getContent();
		if(con == noone) return;
		
		dialogPanelCall(con);
		extract();
		o_main.panel_dragging = noone;
	} #endregion
	
	function checkHover() { #region
		var dx = (mouse_mx - x) / w;
		var dy = (mouse_my - y) / h;
		var p  = ui(8);
			
		draw_set_color(COLORS._main_accent);
		o_main.panel_hovering = self;
		
		var x0 = x + p;
		var y0 = y + p;
		var x1 = x + w - p;
		var y1 = y + h - p;
		var xc = x + w / 2;
		var yc = y + h / 2;
		
		if(point_in_rectangle(mouse_mx, mouse_my, x + w * 1 / 3, y + h * 1 / 3, x + w * 2 / 3, y + h * 2 / 3)) {
			o_main.panel_split = 4;
			
			o_main.panel_draw_x0_to = x + w * 1 / 3;
			o_main.panel_draw_y0_to = y + h * 1 / 3;
			o_main.panel_draw_x1_to = x + w * 2 / 3;
			o_main.panel_draw_y1_to = y + h * 2 / 3;
		} else {
			if(dx + dy > 1) {
				if((1 - dx) + dy > 1) {
					o_main.panel_draw_x0_to = x0;
					o_main.panel_draw_y0_to = yc;
					o_main.panel_draw_x1_to = x1;
					o_main.panel_draw_y1_to = y1;
					
					o_main.panel_split = 3;
				} else {
					o_main.panel_draw_x0_to = xc;
					o_main.panel_draw_y0_to = y0;
					o_main.panel_draw_x1_to = x1;
					o_main.panel_draw_y1_to = y1;
					
					o_main.panel_split = 1;
				}
			} else {
				if((1 - dx) + dy > 1) {
					o_main.panel_draw_x0_to = x0;
					o_main.panel_draw_y0_to = y0;
					o_main.panel_draw_x1_to = xc;
					o_main.panel_draw_y1_to = y1;
					
					o_main.panel_split = 2;
				} else {
					o_main.panel_draw_x0_to = x0;
					o_main.panel_draw_y0_to = y0;
					o_main.panel_draw_x1_to = x1;
					o_main.panel_draw_y1_to = yc;
					
					o_main.panel_split = 0;
				}
			}
		}
	} #endregion
	
	function remove(con = getContent()) { #region
		var curr = getContent();
		
		array_remove(content, con);
		if(con) con.onClose();
		if(con == curr) setTab(0);
		else			setTab(array_find(content, curr));
		
		refresh();
		if(hasContent()) return;
		if(parent == noone) {
			show_message("Can't close main panel.");
			return;
		}
		
		ds_list_delete(parent.childs, ds_list_find_index(parent.childs, self));
		var otherPanel = parent.childs[| 0];
		parent.setContent(otherPanel.content);
		ds_list_clear(parent.childs);
	} #endregion
}

function PanelContent() constructor {
	title	= "";
	icon	= noone;
	context_str = "";
	draggable   = true;
	expandable  = true;
	resizable   = true;
	
	auto_pin = false;
	panel = noone;
	mx = 0;
	my = 0;
	
	x = 0;
	y = 0;
	w = 640;
	h = 480;
	padding		 = ui(16);
	title_height = ui(28);
	
	tab_x = 0;
	
	min_w = ui(40);
	min_h = ui(40);
	
	pFOCUS = false;
	pHOVER = false;
	
	in_dialog = false;
	
	dragSurface = surface_create(1, 1);
	showHeader  = true;
	
	function refresh() { #region
		setPanelSize(panel);
		onResize();
	} #endregion
	
	function onResize() {}
	
	function onFocusBegin() {}
	function onFocusEnd() {}
	
	static initSize = function() {}
	
	function setPanelSize(panel) { #region
		x = panel.tx;
		y = panel.ty;
		w = panel.tw;
		h = panel.th;
	} #endregion
	
	function onSetPanel(panel) { #region
		self.panel = panel;
		setPanelSize(panel);
		initSize();
		onResize();
	} #endregion
	
	function panelStepBegin(panel) { #region
		setPanelSize(panel);
		onStepBegin();
	} #endregion
	
	function onStepBegin() { #region
		mx = mouse_mx - x;
		my = mouse_my - y;
		
		stepBegin();
	} #endregion
	
	function stepBegin() {}
	
	static draw = function(panel) { #region
		self.panel = panel;
		if(o_main.panel_dragging == noone) {
			pFOCUS = FOCUS == panel && panel.mouse_active;
			pHOVER = HOVER == panel && panel.mouse_active;
		}
		
		drawContent(panel);
	} #endregion
	
	function drawContent(panel) {}
	
	function drawGUI() {}
	
	function close() { panel.remove(self); }
	
	function onClose() {}
}

function setFocus(target, fstring = noone) {
	if(FOCUS != noone && is_struct(FOCUS) && FOCUS.getContent())
		FOCUS.getContent().onFocusEnd();
	
	FOCUS = target;
	if(fstring != noone) 
		FOCUS_STR = fstring;
	
	if(FOCUS != noone && is_struct(FOCUS) && FOCUS.getContent())	
		FOCUS.getContent().onFocusBegin();
}