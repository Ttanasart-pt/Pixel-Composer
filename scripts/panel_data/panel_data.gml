enum ANCHOR {
	none    = 0,
	top     = 1,
	bottom  = 2,
	left    = 4,
	right   = 8
}

function Panel(_parent, _x, _y, _w, _h) constructor {
	parent = _parent;
	if(parent) array_push(parent.childs, self);
	
	padding = THEME_VALUE.panel_margin;
	content = [];
	childs  = [];
	anchor  = ANCHOR.none;
	content_index = 0;
	
	x  = _x; tx = _x;
	y  = _y; ty = _y;
	w  = _w; tw = _w;  
	h  = _h; th = _h;
	split = "";
	
	tab_align   = 0;
	tab_width   = 0;
	tab_height  = ui(24);
	tab_x       = 0;
	tab_x_to    = 0;
	tab_surface = noone;
	
	min_w = ui(40);
	min_h = ui(40);
	
	dragging     = -1;
	drag_sval    =  0;
	drag_sm      =  0;
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
	
	draw_droppable = false;
	
	border_rb_close = menuItem(__txt("Close"), function() /*=>*/ { var con = getContent(); if(con == noone) return; con.close(); }, THEME.cross);
	
	border_rb_menu = [
		menuItem(__txt("Move"),    function() /*=>*/ { extract(); panel_mouse = 1; }),
		menuItem(__txt("Pop out"), function() /*=>*/ { popWindow(); }, THEME.node_goto),
		border_rb_close,
	];
	
	tab_align_item = menuItemGroup(__txt("Tab Alignment"), [
        [ [THEME.panel_tab_align, 0], function() /*=>*/ { tab_align = 0; refreshSize(); } ],
        [ [THEME.panel_tab_align, 1], function() /*=>*/ { tab_align = 1; refreshSize(); } ],
        [ [THEME.panel_tab_align, 2], function() /*=>*/ { tab_align = 2; refreshSize(); } ],
        [ [THEME.panel_tab_align, 3], function() /*=>*/ { tab_align = 3; refreshSize(); } ],
    ]);
	
	static getContent = function() /*=>*/ {return array_safe_get_fast(content, content_index, noone)};
	
	////- Content
	
	function setContent(_content = noone, _switch = false) {
		array_append(content, _content);
		
		for( var i = 0, n = array_length(content); i < n; i++ ) 
			content[i].onSetPanel(self);
			
		if(_switch) switchContent(_content);
		refresh();
	}
	
	function switchContent(_content) {
		var _ind = array_find(content, _content);
		if(_ind == -1) return;
		
		setTab(_ind);
	}
	
	function setTab(tabIndex, forceFocus = false) {
		if(tabIndex < 0) return;
		if(tabIndex >= array_length(content)) return;
		if(content_index == tabIndex) {
			if(forceFocus) content[tabIndex].onFocusBegin();
			return;
		}
		
		var prec = array_safe_get_fast(content, content_index);
		if(prec) prec.onFocusEnd();
		
		content_index = tabIndex;
		
		var prec = array_safe_get_fast(content, content_index);
		if(prec) prec.onFocusBegin();
	}
	
	function replacePanel(panel) {
		setContent(panel.content);
		childs = panel.childs;
		split  = panel.split;
		
		refreshSize();
	}
	
	function refresh() {
		resetMask();
		
		array_foreach(content, function(c) /*=>*/ { c.refresh(); });
		array_foreach(childs,  function(c) /*=>*/ { c.refresh(); });
	}
	
	////- Sizing
	
	function setPadding(_padding) { padding = _padding; refresh(); }
	
	function move(dx, dy) {
		x += dx;
		y += dy;
		
		for(var i = 0; i < array_length(childs); i++) {
			var _panel = childs[i];
			_panel.move(dx, dy);
		}
		
		for( var i = 0, n = array_length(content); i < n; i++ ) {
			content[i].x = x;
			content[i].y = y;
		}
	}
	
	function setTabSize() {
		var tab  = array_length(content) > 1;
		var tabh = tab * tab_height;
		
		switch(tab_align) {
			case 0 : 
				tx = x; 
				ty = y + tabh;
				tw = w; 
				th = h - tabh;
				break;
			
			case 1 : 
				tx = x; 
				ty = y;
				tw = w; 
				th = h - tabh;
				break;
				
			case 2 : 
				tx = x + tabh; 
				ty = y;
				tw = w - tabh; 
				th = h;
				break;
			
			case 3 : 
				tx = x; 
				ty = y;
				tw = w - tabh; 
				th = h;
				break;
		}
	}
	
	function resizable(dw, dh, oppose = ANCHOR.left) {
		setTabSize();
		var hori = oppose == ANCHOR.left || oppose == ANCHOR.right;
		
		if(!array_empty(content)) {
			var res = true;
			for( var i = 0, n = array_length(content); i < n; i++ )
				res = res && hori? tw + dw > content[i].min_w : th + dh > content[i].min_h;
			return res;
		}
		
		var _c0 = array_safe_get(childs, 0, noone);
		var _c1 = array_safe_get(childs, 1, noone);
		
		if(_c0 == noone || _c1 == noone) return false;
		
		var ind  = hori? _c1.w > _c0.w : _c1.h > _c0.h;
		return childs[ind].resizable(dw, dh, oppose);
	}
	
	function refreshSize(recur = true) { // refresh content surface after resize
		setTabSize();
		
		for( var i = 0, n = array_length(content); i < n; i++ ) {
			content[i].w = max(tw, content[i].min_w);
			content[i].h = max(th, content[i].min_h);
			content[i].onResize();
		}
			
		if(array_length(childs) == 2) {
			//print("=== Refreshing (" + string(w) + ", " + string(h) + ") " + string(split) + " ===");
			
			var _tw = childs[0].w + childs[1].w;
			var _th = childs[0].h + childs[1].h;
			
			var fixChild = split == "h"? childs[1].x < childs[0].x : childs[1].y < childs[0].y;
			
			childs[fixChild].x = x;
			childs[fixChild].y = y;
			
			if(split == "h") {
				childs[ fixChild].w = round(childs[fixChild].w / _tw * w);
				childs[ fixChild].h = round(h);
			
				childs[!fixChild].x = x + childs[fixChild].w;
				childs[!fixChild].y = y;
					
				childs[!fixChild].w = round(w - childs[fixChild].w);
				childs[!fixChild].h = round(h);
				
				childs[ fixChild].anchor = ANCHOR.left;
				childs[!fixChild].anchor = ANCHOR.right;
			} else if(split == "v") {	
				childs[ fixChild].w = round(w);
				childs[ fixChild].h = round(childs[fixChild].h / _th * h);
			
				childs[!fixChild].x = x;
				childs[!fixChild].y = y + childs[fixChild].h;
					
				childs[!fixChild].w = round(w);
				childs[!fixChild].h = round(h - childs[fixChild].h);
				
				childs[ fixChild].anchor = ANCHOR.top;
				childs[!fixChild].anchor = ANCHOR.bottom;
			}
			
			if(recur)
			for(var i = 0; i < array_length(childs); i++)
				childs[i].refreshSize();
		}
		
		refresh();
	}
	
	function resize(dw, dh, oppose = ANCHOR.left) {
		if(dw == 0 && dh == 0) return;
		
		if(array_length(childs) == 2) {
			var hori = oppose == ANCHOR.left || oppose == ANCHOR.right;
			var ind  = hori? childs[1].w > childs[0].w : childs[1].h > childs[0].h;
			childs[ind].resize(dw, dh, oppose);
		}
		
		w = max(round(w + dw), min_w);
		h = max(round(h + dh), min_h);
		
		refreshSize(false);
	}
	
	function split_h(_w) {
		if(abs(_w) > w) {
			print($"Error: Split panel larger than size w ({_w} > {w})");
			return noone;
		}
		
		if(_w < 0) _w = w + _w;
		var _panelParent = new Panel(parent, x, y, w, h);
		_panelParent.anchor = anchor;
		_panelParent.split  = "h";
		
		var _panelL = self;
		array_push(_panelParent.childs, _panelL);
		
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
			array_remove(parent.childs, self);
			
		parent	= _panelParent;
		anchor	= ANCHOR.left;
		content = [];
		
		return [ _panelL, _panelR ];
	}
	
	function split_v(_h) {
		if(abs(_h) > h) {
			print($"Error: Split panel larger than size h ({_h} > {h})");
			return noone;
		}
		
		if(_h < 0) _h = h + _h;
		var _panelParent = new Panel(parent, x, y, w, h);
		_panelParent.anchor = anchor;
		_panelParent.split  = "v";
		
		var _panelT = self;
		array_push(_panelParent.childs, _panelT);
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
			array_remove(parent.childs, self);
		
		parent	= _panelParent;
		anchor	= ANCHOR.top;
		content = [];
		
		return [_panelT, _panelB];
	}
	
	////- Step
	
	function stepBegin() {
		var con = getContent();
		if(FULL_SCREEN_CONTENT != noone && con == FULL_SCREEN_CONTENT && self != FULL_SCREEN_PARENT) return;
		
		for( var i = 0, n = array_length(content); i < n; i++ ) 
			content[i].panelStepBegin(self);
		
		if(o_main.panel_dragging != noone) dragging = -1;
		
		if(dragging == 1) {
			var _mx = clamp(mouse_mx, ui(16), WIN_W - ui(16));
			var dw  = round(_mx - drag_sm);
			var res = true;
			
			for(var i = 0; i < array_length(childs); i++) {
				var _panel = childs[i];
				switch(_panel.anchor) {
					case ANCHOR.left:
						res = res && _panel.resizable(dw, 0, ANCHOR.left);
						break;
					case ANCHOR.right:
						res = res && _panel.resizable(-dw, 0, ANCHOR.right);
						break;
				}
			}
			
			if(res) {
				drag_sm = _mx;
				
				for(var i = 0; i < array_length(childs); i++) {
					var _panel = childs[i];
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
			
			for(var i = 0; i < array_length(childs); i++) {
				var _panel = childs[i];
				switch(_panel.anchor) {
					case ANCHOR.top:
						res = res && _panel.resizable(0, dh, ANCHOR.top);
						break;
					case ANCHOR.bottom:
						res = res && _panel.resizable(0, -dh, ANCHOR.bottom);
						break;
				}
			}
				
			if(res) {
				drag_sm = _my;
				
				for(var i = 0; i < array_length(childs); i++) {
					var _panel = childs[i];
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
			var _mx = mouse_mxs;
			var _my = mouse_mys;
			
			if(con && point_in_rectangle(_mx, _my, x + ui(2), y + ui(2), x + w - ui(4), y + h - ui(4))) {
				HOVER = self;
				
				if(mouse_press(mb_any))
					setFocus(self, con.context_str);
				
			} else {
				for(var i = 0; i < array_length(childs); i++)
					childs[i].stepBegin();
			}
		}
	}
	
	static step = function() {
		for(var i = 0; i < array_length(childs); i++)
			childs[i].step();
	}
	
	////- Draw
	
	function resetMask() {
		setTabSize();
		
		content_surface = surface_verify(content_surface, tw, th);
		mask_surface    = surface_verify(mask_surface, tw, th);
		surface_set_target(mask_surface);
			draw_clear(c_black);
			gpu_set_blendmode(bm_subtract);
			draw_sprite_stretched(THEME.ui_panel_bg, 0, padding, padding, tw - padding * 2, th - padding * 2);
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
	} resetMask();
	
	static draw = function() {
		if(!array_empty(content)) { drawContent(); return; }
		
		if(array_empty(childs)) return;
		
		var _min_w = ui(32);
		var _min_h = ui(32);
		
		if(split == "h") {
			_min_w = childs[0].min_w + childs[1].min_w;
			_min_h = max(childs[0].min_h + childs[1].min_h);
			
		} else {
			_min_w = max(childs[0].min_w, childs[1].min_w);
			_min_h = childs[0].min_h + childs[1].min_h;
		}
		
		for(var i = 0, n = array_length(childs); i < n; i++) {
			var _panel = array_safe_get(childs, i, 0);
			if(_panel == 0) continue;
			
			_panel.draw();
			
			if!(HOVER == noone || is_struct(HOVER)) continue;
			
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
						dragging  = 2;
						drag_sval = _panel.h;
						drag_sm   = mouse_my;
					}
					break;
			}
		}
		
		if(self == PANEL_MAIN && o_main.panel_dragging != noone && key_mod_press(CTRL))
			checkHover();
	}
	
	function drawTabH() {
		var _top    = tab_align == 0;
		var tab_w   = w - padding * 2 + 1;
		var tab_h   = tab_height + ui(4);
		
		var tsx     = x + padding - 2;
		var tsy     = _top? y + ui(2) : y + h - tab_h - ui(1);
		var msx     = mouse_x - tsx;
		var msy     = mouse_y - tsy;
		
		tab_surface = surface_verify(tab_surface, tab_w, tab_h);
		tab_cover   = noone;
		
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
				var cont = content[i];
				var txt  = cont.title;
				var icn  = cont.icon;
				
				var tbw = string_width(txt) + ui(16 + 16) + (icn != noone) * ui(16 + 4);
				var foc = false;
				
				tab_width += tbw + ui(2);
				if(msx >= tbx && msx <= tbx + tbw) tabHov = i;
				if(tab_holding == cont) { tbx += tbw + ui(2); continue; }
				
				cont.tab_x = cont.tab_x == 0? tbx : lerp_float(cont.tab_x, tbx, 5);
				
				var _tbx = cont.tab_x;
				var _tby = tby;
				var _tbw = tbw;
				var _tbh = tbh + THEME_VALUE.panel_tab_extend - !_top;
				
				var _hov = point_in_rectangle(msx, msy, _tbx, _tby, _tbx + _tbw, tab_height);
				
				if(i == content_index) {
					foc = FOCUS == self || (instance_exists(o_dialog_menubox) && o_dialog_menubox.getContextPanel() == self);
					var cc = foc? (PREFERENCES.panel_outline_accent? COLORS._main_accent : COLORS.panel_select_border) : COLORS.panel_tab;
					draw_sprite_stretched_ext(THEME.ui_panel_tab, 1 + foc, _tbx, _tby, _tbw, _tbh, cc, 1);
					
					if(!foc) tab_cover = _top? BBOX().fromWH(tsx + _tbx + 1, tsy + _tby + tbh - ui(3), _tbw - 2, THEME_VALUE.panel_tab_extend) : 
					                           BBOX().fromWH(tsx + _tbx + 1, tsy + 3, _tbw - 2, THEME_VALUE.panel_tab_extend);
					
				} else {
					var cc = COLORS.panel_tab_inactive;
					if(HOVER == self && _hov)
						var cc = COLORS.panel_tab_hover;
						
					draw_sprite_stretched_ext(THEME.ui_panel_tab, 0, _tbx, _tby, _tbw, _tbh, cc, 1);
				}
				
				var aa = 0.5;
				if(point_in_rectangle(msx, msy, _tbx + _tbw - ui(16), _tby, _tbx + _tbw, tab_height)) {
					aa = 1;
					if(mouse_press(mb_left, FOCUS == self)) 
						rem = i;
						
				} else if(HOVER == self && _hov) {
					if(mouse_press(mb_left, FOCUS == self)) {
						setTab(i);
						
						tab_holding    = cont;
						tab_hold_state = 0;
						tab_holding_mx = msx;
						tab_holding_my = msy;
						tab_holding_sx = tab_holding.tab_x;
					}
					
					if(mouse_press(mb_right, FOCUS == self)) {
						var menu = array_clone(border_rb_menu);
						if(instanceof(cont) == "Panel_Menu")
							array_remove(menu, border_rb_close);
						array_push(menu, tab_align_item);
						
						menuCall("panel_border_menu", menu);
					}
					
					if(mouse_press(mb_middle, FOCUS == self))
						rem = i;
					
					if(DRAGGING)
						setTab(i);
				}
				
				var cc =  foc? COLORS.panel_tab_icon : COLORS._main_text_sub;
				var tc = _top? tab_height / 2 - ui(1) : tab_height / 2 + ui(2);
				
				draw_sprite_ui(THEME.tab_exit, 0, _tbx + _tbw - ui(12), tc + ui(1), 1, 1, 0, cc, aa);
				
				if(icn != noone) {
					draw_sprite_ui(icn, 0, _tbx + ui(8 + 8), tc + ui(1), 1, 1, 0, cc); 
					_tbx += ui(20);
				}
				
				draw_set_text(f_p3, fa_left, fa_center, foc? COLORS.panel_tab_text : COLORS._main_text_sub);
				draw_text_add(_tbx + ui(8), tc, txt);
				
				tbx += _tbw + ui(2);
			}
			
			if(rem > -1) content[rem].close();
			
			tab_width = max(0, tab_width - w + ui(32));
			if(point_in_rectangle(msx, msy, 0, 0, w, tab_height) && MOUSE_WHEEL != 0) 
				tab_x_to = clamp(tab_x_to + ui(64) * MOUSE_WHEEL, -tab_width, 0);
				
			if(tab_holding) {
				draw_set_font(f_p3);
				
				var txt  = tab_holding.title;
				var icn  = tab_holding.icon;
				var tbw  = string_width(txt) + ui(16 + 16);
				if(icn != noone) tbw += ui(16 + 4);
				
				var _tbx = tab_holding.tab_x;
				var _tby = tby;
				var _tbw = tbw;
				var _tbh = tbh + THEME_VALUE.panel_tab_extend;
				var  tc  = _top? tab_height / 2 - ui(1) : tab_height / 2 + ui(2);
				
				draw_sprite_stretched_ext(THEME.ui_panel_tab, 2, _tbx, _tby, _tbw, _tbh, PREFERENCES.panel_outline_accent? COLORS._main_accent : COLORS.panel_select_border, 1);
				draw_sprite_ui(THEME.tab_exit, 0, _tbx + _tbw - ui(12), tc + 1, 1, 1, 0, COLORS.panel_tab_icon);
				
				if(icn != noone) {
					draw_sprite_ui(icn, 0, _tbx + ui(8 + 8), tc + 1, 1, 1, 0, COLORS.panel_tab_icon);
					_tbx += ui(20);
				}
				
				draw_set_text(f_p3, fa_left, fa_center, COLORS.panel_tab_text);
				draw_text_add(_tbx + ui(8), tc, txt);
				
				if(tab_hold_state == 0) {
					if(point_distance(tab_holding_mx, tab_holding_my, msx, msy) > 8)
						tab_hold_state = 1;
						
				} else if(tab_hold_state == 1) {
					if(point_in_rectangle(msx, msy, 0, 0, w, tab_height)) {
						if(msx < ui(32))		tab_x_to = clamp(tab_x_to + ui(2), -tab_width, 0);
						if(msx > w - ui(32))	tab_x_to = clamp(tab_x_to - ui(2), -tab_width, 0);
					}
			
					tab_holding.tab_x = clamp(tab_holding_sx + (msx - tab_holding_mx), 1, w - _tbw - ui(4));
					
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
	}
	
	function drawTabV() {
		var _left   = tab_align == 2;
		var tab_w   = tab_height + ui(4);
		var tab_h   = h - padding * 2 + 1;
		
		var tsx     = _left? x + padding - 2 : x + w - tab_w;
		var tsy     = y + ui(2);
		var msx     = mouse_x - tsx;
		var msy     = mouse_y - tsy;
		
		tab_surface = surface_verify(tab_surface, tab_w, tab_h);
		tab_cover   = noone;
		
		surface_set_target(tab_surface);
			DRAW_CLEAR
			
			var tbx = tab_x;
			var tby = 0;
			var tbh = tab_height + ui(2);
			var tabHov = msy < 0 ? 0 : array_length(content) - 1;
			
			var rem   = -1;
			var hover = HOVER == self;
			var focus = FOCUS == self;
			
			tab_x = lerp_float(tab_x, tab_x_to, 5);
			tab_width = 0;
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text_sub);
			for( var i = 0, n = array_length(content); i < n; i++ ) {
				var cont = content[i];
				var txt  = cont.title;
				var icn  = cont.icon;
				
				var tbw  = string_width(txt) + ui(16 + 16) + (icn != noone) * ui(16 + 4);
				var foc  = false;
				
				tab_width += tbw + ui(2);
				if(msy >= tbx && msy <= tbx + tbw) tabHov = i;
				if(tab_holding == cont) { tbx += tbw + ui(2); continue; }
				
				cont.tab_x = cont.tab_x == 0? tbx : lerp_float(cont.tab_x, tbx, 5);
				
				var _tbx = tby;
				var _tby = cont.tab_x;
				var _tbw = tbh + THEME_VALUE.panel_tab_extend;
				var _tbh = tbw;
				
				var _hov = hover && point_in_rectangle(msx, msy, _tbx, _tby, _tbx + _tbw, _tby + _tbh);
				
				if(i == content_index) {
					foc = focus || (instance_exists(o_dialog_menubox) && o_dialog_menubox.getContextPanel() == self);
					
					var cc = COLORS.panel_tab;
					if(foc) {
						if(PREFERENCES.panel_outline_accent) cc = COLORS._main_accent;
						else cc = COLORS.panel_select_border;
					}
					
					draw_sprite_stretched_ext(THEME.ui_panel_tab, 1 + foc, _tbx, _tby, _tbw, _tbh, cc, 1);
					if(!foc) tab_cover = _left? BBOX().fromWH(tsx + _tbx + _tbw - ui(4), tsy + _tby + 1, THEME_VALUE.panel_tab_extend, _tbh - 2) : 
					                            BBOX().fromWH(tsx + ui(2), tsy + _tby + 1, THEME_VALUE.panel_tab_extend, _tbh - 2);
					
				} else {
					var cc = COLORS.panel_tab_inactive;
					if(_hov) cc = COLORS.panel_tab_hover;
						
					draw_sprite_stretched_ext(THEME.ui_panel_tab, 0, _tbx, _tby, _tbw, _tbh, cc, 1);
				}
				
				var aa = 0.5;
				if(point_in_rectangle(msx, msy, _tbx, _tby + _tbh - ui(16), tab_height, _tby + _tbh)) {
					aa = 1;
					if(mouse_press(mb_left, focus)) 
						rem = i;
						
				} else if(_hov) {
					if(mouse_press(mb_left, focus)) {
						setTab(i);
						
						tab_holding    = cont;
						tab_hold_state = 0;
						tab_holding_mx = msx;
						tab_holding_my = msy;
						tab_holding_sx = tab_holding.tab_x;
					}
					
					if(mouse_press(mb_right, focus)) {
						var menu = array_clone(border_rb_menu);
						if(instanceof(cont) == "Panel_Menu")
							array_remove(menu, border_rb_close);
						array_push(menu, tab_align_item);
						
						menuCall("panel_border_menu", menu);
					}
					
					if(mouse_press(mb_middle, focus)) 
						rem = i;
					
					if(DRAGGING)
						setTab(i);
				}
				
				var cc =  foc?  COLORS.panel_tab_icon : COLORS._main_text_sub;
				var tc = _left? tab_height / 2 : tab_height / 2 + ui(2);
				
				draw_sprite_ui(THEME.tab_exit, 0, tc - !_left, _tby + _tbh - ui(12), 1, 1, 0, cc, aa);
				
				if(icn != noone) {
					draw_sprite_ui(icn, 0, tc - !_left, _tby + ui(8 + 8), 1, 1, 0, cc);
					_tbx += ui(20);
				}
				
				draw_set_text(f_p3, _left? fa_right : fa_left, fa_center, foc? COLORS.panel_tab_text : COLORS._main_text_sub);
				draw_text_transform_add(tc, _tby + ui(8), txt, 1, _left? 90 : -90);
				
				tbx += _tbh + ui(2);
			}
			
			if(rem > -1) content[rem].close();
			
			tab_width = max(0, tab_width - h + ui(32));
			if(point_in_rectangle(msx, msy, 0, 0, tab_height, h) && MOUSE_WHEEL != 0) 
				tab_x_to = clamp(tab_x_to + ui(64) * MOUSE_WHEEL, -tab_width, 0);
				
			if(tab_holding) {
				draw_set_font(f_p3);
				
				var txt  = tab_holding.title;
				var icn  = tab_holding.icon;
				var tbw  = string_width(txt) + ui(16 + 16);
				if(icn != noone) tbw += ui(16 + 4);
				
				var _tbx = tby;
				var _tby = tab_holding.tab_x;
				var _tbw = tbh + THEME_VALUE.panel_tab_extend;
				var _tbh = tbw;
				
				var cc = PREFERENCES.panel_outline_accent? COLORS._main_accent : COLORS.panel_select_border;
				var tc = _left? tab_height / 2 : tab_height / 2 + ui(2);
				
				draw_sprite_stretched_ext(THEME.ui_panel_tab, 2, _tbx, _tby, _tbw, _tbh, cc, 1);
				draw_sprite_ui(THEME.tab_exit, 0, tc - !_left, _tby + _tbh - ui(12), 1, 1, 0, COLORS.panel_tab_icon);
				
				if(icn != noone) {
					draw_sprite_ui(icn, 0, tc - !_left, _tby + ui(8 + 8), 1, 1, 0, COLORS._main_text_sub);
					_tbx += ui(20);
				}
				
				draw_set_text(f_p3, _left? fa_right : fa_left, fa_center, fa_center, COLORS.panel_tab_text);
				draw_text_transform_add(tc, _tby + ui(8), txt, 1, _left? 90 : -90);
				
				if(tab_hold_state == 0) {
					if(point_distance(tab_holding_mx, tab_holding_my, msx, msy) > 8)
						tab_hold_state = 1;
						
				} else if(tab_hold_state == 1) {
					if(point_in_rectangle(msx, msy, 0, 0, tab_height, h)) {
						if(msy < ui(32))		tab_x_to = clamp(tab_x_to + ui(2), -tab_width, 0);
						if(msy > h - ui(32))	tab_x_to = clamp(tab_x_to - ui(2), -tab_width, 0);
					}
					
					tab_holding.tab_x = clamp(tab_holding_sx + (msy - tab_holding_my), 1, h - _tbw - ui(4));
					
					array_remove(content, tab_holding);
					array_insert(content, tabHov, tab_holding);
					setTab(array_find(content, tab_holding));
					
					if(abs(msx - tab_holding_mx) > ui(32)) {
						extract();
						tab_holding = noone;
					}
				}
				
				if(mouse_release(mb_left))
					tab_holding = noone;
			}
		surface_reset_target();
		
		draw_surface(tab_surface, tsx, tsy);
	}
	
	function drawContent() {
		setTabSize();
		if(w <= ui(16) || th < ui(16)) return;
		
		var con = getContent();
		if(FULL_SCREEN_CONTENT != noone && con == FULL_SCREEN_CONTENT && self != FULL_SCREEN_PARENT) return;
		
		var tab  = array_length(content) > 1;
		if(tab) { if(tab_align < 2) drawTabH(); else drawTabV(); }
		
		var _mx = mouse_mxs;
		var _my = mouse_mys;
			
		var p = ui(6);
		var m_in = point_in_rectangle(_mx, _my, tx + p, ty + p, tx + tw - p, ty + th - p);
		var m_ot = point_in_rectangle(_mx, _my, tx, ty, tx + tw, ty + th);
		mouse_active = m_in;
		
		var _tw = tw - padding * 2;
		var _th = th - padding * 2;
		draw_sprite_stretched(THEME.ui_panel_bg, 0, tx + padding, ty + padding, _tw, _th);
		
		if(!is_surface(mask_surface)) {
			mask_surface = surface_create_valid(tw, th);
			refresh();
		}
		
		content_surface = surface_verify(content_surface, tw, th);
		var _active = true;
		if(con && con.pause_when_rendering && IS_RENDERING) _active = false; 
		
		if(_active) {
			surface_set_target(content_surface);
				draw_clear(COLORS.panel_bg_clear);
				
				if(con) {
					min_w = con.min_w;
					min_h = con.min_h;
					if(tw >= min_w && th >= min_h)
						con.draw(self);
						
					else {
						draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
						draw_text(tw / 2, th / 2, "Panel too small for content");
					}
				} else {
					draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
					draw_text(tw / 2, th / 2, "No content");
				}
				
				gpu_set_blendmode(bm_subtract);
				draw_surface_safe(mask_surface);
				gpu_set_blendmode(bm_normal);
			surface_reset_target();
			
			draw_surface_safe(content_surface, tx, ty);
			
		} else 
			draw_surface_ext_safe(content_surface, tx, ty, 1, 1, 0, c_white, .5);
		
		draw_sprite_stretched_ext(THEME.ui_panel, 1, tx + padding, ty + padding, _tw, _th, COLORS.panel_frame);
		if(tab && tab_cover != noone) draw_sprite_bbox(THEME.ui_panel_tab, 3, tab_cover);
		
		if(FOCUS == self || (instance_exists(o_dialog_menubox) && o_dialog_menubox.getContextPanel() == self)) {
			var _color = PREFERENCES.panel_outline_accent? COLORS._main_accent : COLORS.panel_select_border;
			draw_sprite_stretched_ext(THEME.ui_panel, 1, tx + padding, ty + padding, tw - padding * 2, th - padding * 2, _color, 1);	
		}
		
		if(FOCUS == self && parent != noone && !m_in && m_ot) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, tx + padding, ty + padding, tw - padding * 2, th - padding * 2, c_white, 0.4);
			
			if(DOUBLE_CLICK) {
				extract();
				panel_mouse = 0;
				
			} else if(mouse_press(mb_right)) {
				var menu = array_clone(border_rb_menu);
				if(instanceof(getContent()) == "Panel_Menu")
					array_remove(menu, border_rb_close);
					
				menuCall("panel_border_menu", menu);
			}
		} 
		
		if(draw_droppable) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, tx + padding, ty + padding, tw - padding * 2, th - padding * 2, COLORS._main_value_positive, 1);	
			draw_droppable = false;
		}
		
		if(o_main.panel_dragging != noone && m_ot && !key_mod_press(CTRL))
			checkHover();
	}
	
	function drawGUI() {
		for( var i = 0; i < array_length(childs); i++ ) 
			childs[i].drawGUI();
		
		var con = getContent();
		if(con == noone) return;
		con.drawGUI();
	}
	
	////- Actions
	
	function extract() {
		var con = getContent();
		con.dragSurface = surface_clone(content_surface);
		o_main.panel_dragging = con;
				
		array_remove(content, con);
		refresh();
		setTab(0);
		
		HOVER = noone;
		FOCUS = noone;
		
		if(!array_empty(content)) return;
		var ind = !array_find(parent.childs, self); //index of the other child
		var sib = parent.childs[ind];
		
		if(!array_empty(sib.content) && array_length(sib.childs) == 2) { //other child is compound panel
			var gparent = parent.parent;
			if(gparent == noone) {
				sib.x = PANEL_MAIN.x; sib.y = PANEL_MAIN.y;
				sib.w = PANEL_MAIN.w; sib.h = PANEL_MAIN.h;
						
				PANEL_MAIN = sib;
				sib.parent = noone;
				PANEL_MAIN.refreshSize();
			} else {
				var pind    = array_find(gparent.childs, parent); //index of parent in grandparent object
				gparent.childs[pind] = sib; //replace parent with sibling
				sib.parent = gparent;
				gparent.refreshSize();
			}
		} else if(!array_empty(sib.content)) { //other child is content panel, set parent to content panel
			parent.setContent(sib.content);
			parent.childs = [];
		}
	}
	
	function popWindow() {
		var con = getContent();
		if(con == noone) return;
		
		dialogPanelCall(con);
		extract();
		o_main.panel_dragging = noone;
	}
	
	function checkHover() {
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
	}
	
	function onFocusBegin() { INLINE if(FOCUS.getContent()) FOCUS.getContent().onFocusBegin(); }
	function onFocusEnd()   { INLINE if(FOCUS.getContent()) FOCUS.getContent().onFocusEnd();   }
	
	function remove(con = getContent()) {
		var curr = getContent();
		
		array_remove(content, con);
		if(con) con.onClose();
		if(con == curr) setTab(0, true);
		else			setTab(array_find(content, curr), true);
		
		refresh();
		
		if(!array_empty(content)) return;
		if(parent == noone) { show_message("Can't close the main panel."); return; }
		
		if(array_length(parent.childs) == 2) {
			array_remove(parent.childs, self);
			parent.replacePanel(parent.childs[0]);
		}
	}
}

function PanelContent() constructor {
	title		= "";
	icon		= noone;
	context_str = "";
	draggable   = true;
	expandable  = true;
	resizable   = true;
	
	anchor      = ANCHOR.none;
	auto_pin	= false;
	panel		= noone;
	
	mx = 0;
	my = 0;
	x  = 0;
	y  = 0;
	w  = 640;
	h  = 480;
	padding		 = ui(12);
	title_height = ui(28);
	
	tab_x  = 0;
	min_w  = ui(40);
	min_h  = ui(40);
	
	pFOCUS = false;
	pHOVER = false;
	
	in_dialog   = false;
	
	dragSurface = noone;
	showHeader  = true;
	
	title_actions = [];
	pause_when_rendering = false;
	
	////- Size
	
	static refresh = function() {
		setPanelSize(panel);
		onResize();
	}
	
	static onResize     = function() {}
	static setPanelSize = function(_panel) {
		x = _panel.tx;
		y = _panel.ty;
		w = _panel.tw;
		h = _panel.th;
	}
	
	////- Focus
	
	static onFocusBegin = function() {}
	static onFocusEnd   = function() {}
	static initSize     = function() {}
	
	////- Panel
	
	static onSetPanel     = function(_panel) {
		panel = _panel;
		setPanelSize(_panel);
		initSize();
		onResize();
	}
	static panelStepBegin = function(_panel) {
		setPanelSize(_panel);
		onStepBegin();
	}
	
	////- Step
	
	static onStepBegin = function() {
		mx = mouse_mx - x;
		my = mouse_my - y;
		
		stepBegin();
	}
	static stepBegin   = function() {}
	
	////- Draw
	
	static draw = function(_panel) {
		panel = _panel;
		
		if(o_main.panel_dragging == noone) {
			pFOCUS = FOCUS == panel/* && panel.mouse_active*/;
			pHOVER = !CURSOR_IS_LOCK && HOVER == panel && panel.mouse_active;
			if(pFOCUS) FOCUS_CONTENT = self;
		}
		
		drawContent(panel);
	}
	
	static drawContent   = function(_panel) {}
	static preDraw       = function() {}
	static drawGUI       = function() {}
	static onFullScreen  = function() {}
	
	////- Actions
	
	static checkClosable = function() { return true; }
	static close         = function() { panel.remove(self); }
	static onClose       = function() {}
	
	static asyncCallback = function(async_load) {}
	
	////- Serialize
	
	static serialize     = function()     { return { name: instanceof(self) }; }
	static deserialize   = function(data) { return self; }
}

function setFocus(target, fstring = noone) {
	if((instance_exists(FOCUS) && variable_instance_exists(FOCUS, "onFocusEnd")) || 
		(is_struct(FOCUS) && struct_has(FOCUS, "onFocusEnd"))) 
		FOCUS.onFocusEnd();
	
	FOCUS = target;
	if(fstring != noone) FOCUS_STR = fstring;
	
	if((instance_exists(FOCUS) && variable_instance_exists(FOCUS, "onFocusBegin")) || 
		(is_struct(FOCUS) && struct_has(FOCUS, "onFocusBegin"))) 
		FOCUS.onFocusBegin();
		
}

function getFocusContent() {
	if(is(FOCUS, Panel)) 
		return FOCUS.getContent(); 
		
	if(instance_exists(FOCUS) && FOCUS.object_index == o_dialog_panel) 
		return FOCUS.content;
	
	return FOCUS;
}