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
	
	padding = ui(2);
	content = noone;
	childs = ds_list_create();
	anchor = ANCHOR.none;
	
	x = _x;
	y = _y;
	w = _w;
	h = _h;
	split = -1;
	
	min_w = ui(32);
	min_h = ui(32);
	
	dragging  = -1;
	drag_sval = 0;
	drag_sm   = 0;
	mouse_active = true;
	
	content_surface = surface_create_valid(w, h);
	mask_surface    = surface_create_valid(w, h);
	
	function resetMask() {
		surface_set_target(mask_surface);
		draw_clear(c_black);
		gpu_set_blendmode(bm_subtract);
		draw_sprite_stretched(THEME.ui_panel_bg, 0, padding, padding, w - padding * 2, h - padding * 2);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}
	resetMask();
	
	function setPadding(padding) {
		self.padding = padding;
		resetMask();
	}
	
	function refresh() {
		if(is_surface(content_surface) && surface_exists(content_surface)) 
			surface_size_to(content_surface, w, h);
		else
			content_surface = surface_create_valid(w, h);
		
		if(is_surface(mask_surface) && surface_exists(mask_surface)) 
			surface_size_to(mask_surface, w, h);
		else
			mask_surface = surface_create_valid(w, h);
		resetMask();
		
		if(content != noone) 
			content.refresh();
			
		for( var i = 0; i < ds_list_size(childs); i++ )
			childs[| i].refresh();
	}
	
	function move(dx, dy) {
		x += dx;
		y += dy;
		
		for(var i = 0; i < ds_list_size(childs); i++) {
			var _panel = childs[| i];
			_panel.move(dx, dy);
		}
		
		if(content) {
			content.x = x;
			content.y = y;
		}
	}
	
	function resizable(dw, dh, oppose = ANCHOR.left) {
		if(content && (w + dw < content.min_w || h + dh < content.min_h)) {
			return false;
		}
		
		var rec = true;
		for(var i = 0; i < ds_list_size(childs); i++) {
			var panel = childs[| i];
			
			if(panel.anchor != oppose || panel.content == noone)
				if(!panel.resizable(dw, dh))
					return false;
		}
		
		return true;
	}
	
	function refreshSize() { //refresh content surface after resize
		if(content) {
			content.w = w;
			content.h = h;
			content.onResize();
		} else if(ds_list_size(childs) == 2) {
			print("=== Refreshing (" + string(w) + ", " + string(h) + ") " + string(split) + " ===");
			
			var tw = childs[| 0].w + childs[| 1].w;
			var th = childs[| 0].h + childs[| 1].h;
			
			var fixChild = childs[| 1].x == x && childs[| 1].y == y;
			
			childs[| fixChild].x = x;
			childs[| fixChild].y = y;
			
			if(split == 0) {
				childs[|  fixChild].w = childs[| fixChild].w / tw * w;
				childs[|  fixChild].h = h;
			
				childs[| !fixChild].x = x + childs[| fixChild].w;
				childs[| !fixChild].y = y;
					
				childs[| !fixChild].w = w - childs[| fixChild].w;
				childs[| !fixChild].h = h;
			} else if(split == 1) {	
				childs[|  fixChild].w = w;
				childs[|  fixChild].h = childs[| fixChild].h / th * h;
			
				childs[| !fixChild].x = x;
				childs[| !fixChild].y = y + childs[| fixChild].h;
					
				childs[| !fixChild].w = w;
				childs[| !fixChild].h = h - childs[| fixChild].h;
			}
			
			for(var i = 0; i < ds_list_size(childs); i++) {
				childs[| i].refreshSize();
			}
		}
		
		refresh();
	}
	
	function resize(dw, dh, oppose = ANCHOR.left) {
		if(dw == 0 && dh == 0) return;
		
		var _w = dw, _h = dh;
		
		for(var i = 0; i < ds_list_size(childs); i++) {
			var panel = childs[| i];
			
			if(panel.anchor != oppose || panel.content == noone)
				panel.resize(dw, dh, oppose);
		}
		
		w = max(w + dw, min_w);
		h = max(h + dh, min_h);
		
		if(w > 1 && h > 1) {
			if(is_surface(content_surface)) 
				surface_size_to(content_surface, w, h);
			
			if(is_surface(mask_surface)) 
				surface_size_to(mask_surface, w, h);
			else 
				mask_surface = surface_create_valid(w, h);
			
			resetMask();
		}
		
		refreshSize();
	}
	
	function set(_content) {
		content = _content;
		content.onSetPanel(self);
	}
	
	function split_h(_w) {
		if(abs(_w) > w) return noone;
		
		if(_w < 0) _w = w + _w;
		var _panelParent = new Panel(parent, x, y, w, h);
		_panelParent.anchor = anchor;
		_panelParent.split  = 0;
		
		var _panelL = self;
		ds_list_add(_panelParent.childs, _panelL);
		
		var _panelR = new Panel(_panelParent, x + _w, y, w - _w, h);
		_panelR.anchor = ANCHOR.right;
		
		var prev_w = w;
		w = _w;
		if(content) {
			content.w = w;
			content.onResize();
		}
		
		if(parent == noone) PANEL_MAIN = _panelParent;
		else {
			ds_list_delete(parent.childs, ds_list_find_index(parent.childs, self));
		}
		parent = _panelParent;
		anchor = ANCHOR.left;
		
		if(content) content = noone;
		
		return [ _panelL, _panelR ];
	}
	
	function split_v(_h) {
		if(abs(_h) > h) return noone;
		
		if(_h < 0) _h = h + _h;
		var _panelParent = new Panel(parent, x, y, w, h);
		_panelParent.anchor = anchor;
		_panelParent.split  = 1;
		
		var _panelT = self;
		ds_list_add(_panelParent.childs, _panelT);
		var _panelB = new Panel(_panelParent, x, y + _h, w, h - _h);
		_panelB.anchor = ANCHOR.bottom;
		
		var prev_h = h;
		h = _h;
		if(content) {
			content.h = h;
			content.onResize();
		}
		
		if(parent == noone) PANEL_MAIN = _panelParent;
		else {
			ds_list_delete(parent.childs, ds_list_find_index(parent.childs, self));
		}
		parent = _panelParent;
		anchor = ANCHOR.top;
		
		if(content) content = noone;
		
		return [_panelT, _panelB];
	}
	
	function stepBegin() {
		if(content) content.panelStepBegin(self);
		
		if(o_main.panel_dragging != noone) dragging = -1;
		
		if(dragging == 1) {
			var _mx = clamp(mouse_mx, ui(16), WIN_W - ui(16));
			var dw = _mx - drag_sm;
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
			
			if(mouse_release(mb_left)) dragging = -1;
		} else if(dragging == 2) {
			var _my = clamp(mouse_my, ui(16), WIN_H - ui(16));
			var dh = _my - drag_sm;
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
			
			if(mouse_release(mb_left)) dragging = -1;
		} else {
			if(content != noone) {
				if(point_in_rectangle(mouse_mx, mouse_my, x + ui(2), y + ui(2), x + w - ui(4), y + h - ui(4))) {
					HOVER = self;
					if(mouse_press(mb_any))   
						setFocus(self);
					if(FOCUS == self && content) 
						FOCUS_STR = content.context_str;
				}
			} else {
				for(var i = 0; i < ds_list_size(childs); i++) {
					var _panel = childs[| i];
					_panel.stepBegin();
				}
			}
		}
	}
	
	static step = function() {
		for(var i = 0; i < ds_list_size(childs); i++) {
			var _panel = childs[| i];
			_panel.step();
		}
	}
	
	function draw() {
		if(content != noone) {
			if(!keyboard_check(ord("W")))
				drawPanel();
			return;
		}
		
		if(keyboard_check(ord("W")) && point_in_rectangle(mouse_mx, mouse_my, x, y, x + w, y + h)) {
			draw_set_color(c_lime);
			draw_set_alpha(0.1);
			draw_rectangle(x + 8, y + 8, x + w - 8, y + h - 8, false);
			draw_set_alpha(1);
			draw_rectangle(x + 8, y + 8, x + w - 8, y + h - 8,  true);
		}
		
		if(ds_list_empty(childs)) 
			return;
		
		var _drag = true;
		for(var i = 0; i < ds_list_size(childs); i++) {
			var _panel = childs[| i];
			if(_panel.content && !_panel.content.draggable)
				_drag = false;
		}
			
		for(var i = 0; i < ds_list_size(childs); i++) {
			var _panel = childs[| i];
			_panel.draw();
				
			if!(_drag && (HOVER == noone || is_struct(HOVER)))
				continue;
				
			switch(_panel.anchor) {
				case ANCHOR.left :
					if(!point_in_rectangle(mouse_mx, mouse_my, _panel.x + _panel.w - ui(2), _panel.y, _panel.x + _panel.w + ui(2), _panel.y + _panel.h))
						break;
							
					CURSOR = cr_size_we;
					if(mouse_press(mb_left)) {
						dragging  = 1;
						drag_sval = _panel.w;
						drag_sm   = mouse_mx;
					}
					break;
				case ANCHOR.top :
					if(!point_in_rectangle(mouse_mx, mouse_my, _panel.x, _panel.y + _panel.h - ui(2), _panel.x + _panel.w, _panel.y + _panel.h + ui(2)))
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
	}
	
	function drawPanel() {
		if(w <= ui(16)) return;
		var p = ui(8);
		var m_in = point_in_rectangle(mouse_mx, mouse_my, x + p, y + p, x + w - p, y + h - p);
		var m_ot = point_in_rectangle(mouse_mx, mouse_my, x, y, x + w, y + h);
		mouse_active = m_in;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 0, x + padding, y + padding, w - padding * 2, h - padding * 2);
		
		if(!is_surface(mask_surface)) {
			mask_surface = surface_create_valid(w, h);
			resetMask();
		}
		
		if(!is_surface(content_surface)) content_surface = surface_create_valid(w, h);
		surface_set_target(content_surface);
			draw_clear(COLORS.panel_bg_clear);
			if(content) {
				min_w = content.min_w;
				min_h = content.min_h;
				if(w >= min_w && h >= min_h)
					content.draw(self);
			}
			
			gpu_set_blendmode(bm_subtract);
			draw_surface_safe(mask_surface, 0, 0);
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		draw_surface_safe(content_surface, x, y);
			
		if(FOCUS == self) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, x + padding, y + padding, w - padding * 2, h - padding * 2, COLORS._main_accent, 1);	
			if(content && !m_in && m_ot && DOUBLE_CLICK) {
				content.dragSurface = surface_clone(content_surface);
				o_main.panel_dragging = content;
				
				content = noone;				
				var ind = !ds_list_find_index(parent.childs, self); //index of the other child
				var sib = parent.childs[| ind];
				
				if(parent.childs[| ind].content == noone) { //other child is compound panel
					var gparent = parent.parent;
					var pind    = ds_list_find_index(gparent.childs, parent); //index of parent in grandparent object
					gparent.childs[| pind] = sib;
					gparent.refreshSize();
				} else { //other child is content panel, set parent to content panel
					parent.set(sib.content);
					ds_list_clear(parent.childs);
				}
			}
		}
		
		if(o_main.panel_dragging != noone && m_ot) {
			var dx = (mouse_mx - x) / w;
			var dy = (mouse_my - y) / h;
			var p  = ui(8);
			
			draw_set_color(COLORS._main_accent);
			o_main.panel_hovering = self;
			
			if(dx + dy > 1) {
				if((1 - dx) + dy > 1) {
					draw_set_alpha(.4);
					draw_roundrect_ext(x + p, y + h / 2 + p, x + w - p, y + h - p, 8, 8, false);
					draw_set_alpha(1.);
					draw_roundrect_ext(x + p, y + h / 2 + p, x + w - p, y + h - p, 8, 8,  true);
					
					o_main.panel_split = 3;
				} else {
					draw_set_alpha(.4);
					draw_roundrect_ext(x + p + w / 2, y + p, x + w - p, y + h - p, 8, 8, false);
					draw_set_alpha(1.);
					draw_roundrect_ext(x + p + w / 2, y + p, x + w - p, y + h - p, 8, 8,  true);
					
					o_main.panel_split = 1;
				}
			} else {
				if((1 - dx) + dy > 1) {
					draw_set_alpha(.4);
					draw_roundrect_ext(x + p, y + p, x + w / 2 - p, y + h - p, 8, 8, false);
					draw_set_alpha(1.);
					draw_roundrect_ext(x + p, y + p, x + w / 2 - p, y + h - p, 8, 8,  true);
					
					o_main.panel_split = 2;
				} else {
					draw_set_alpha(.4);
					draw_roundrect_ext(x + p, y + p, x + w - p, y + h / 2 - p, 8, 8, false);
					draw_set_alpha(1.);
					draw_roundrect_ext(x + p, y + p, x + w - p, y + h / 2 - p, 8, 8,  true);
					
					o_main.panel_split = 0;
				}
			}
		}
	}
	
	function remove() {
		if(parent == noone) {
			show_message("What are you trying to do!");
			return;
		}
		
		ds_list_delete(parent.childs, ds_list_find_index(parent.childs, self));
		var otherPanel = parent.childs[| 0];
		parent.set(otherPanel.content);
		ds_list_clear(parent.childs);
	}
}

function PanelContent() constructor {
	context_str = "";
	draggable = true;
	expandable = true;
	
	panel = noone;
	mx = 0;
	my = 0;
	
	x = 0;
	y = 0;
	w = 1;
	h = 1;
	
	min_w = ui(32);
	min_h = ui(32);
	
	pFOCUS = false;
	pHOVER = false;
	
	dragSurface = surface_create(1, 1);
	
	function refresh() {
		onResize();
	}
	
	function onResize() {}
	
	function onFocusBegin() {}
	function onFocusEnd() {}
	
	function initSize() {}
	function setPanelSize(panel) {
		x = panel.x;
		y = panel.y;
		w = panel.w;
		h = panel.h;
	}
	
	function onSetPanel(panel) {
		self.panel = panel;
		setPanelSize(panel);
		initSize();
		onResize();
	}
	
	function panelStepBegin(panel) {
		setPanelSize(panel);
		onStepBegin();
	}
	
	function onStepBegin() {
		mx = mouse_mx - x;
		my = mouse_my - y;
		
		stepBegin();
	}
	
	function stepBegin() {}
	
	function draw(panel) { 
		pFOCUS = FOCUS == panel && panel.mouse_active;
		pHOVER = HOVER == panel && panel.mouse_active;
		
		drawContent(panel);
	}
	
	function drawContent(panel) {}
}

function setFocus(target, fstring = noone) {
	if(FOCUS != noone && is_struct(FOCUS) && FOCUS.content)
		FOCUS.content.onFocusEnd();
	
	FOCUS = target;
	if(fstring != noone) 
		FOCUS_STR = fstring;
	
	if(FOCUS != noone && is_struct(FOCUS) && FOCUS.content)	
		FOCUS.content.onFocusBegin();
}