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
	
	content = noone;
	childs = ds_list_create();
	anchor = ANCHOR.none;
	
	x = _x;
	y = _y;
	w = _w;
	h = _h;
	
	min_w = 32;
	min_h = 32;
	
	dragging  = -1;
	drag_sval = 0;
	drag_sm   = 0;
	
	content_surface = surface_create_valid(w, h);
	mask_surface    = surface_create_valid(w, h);
	
	function resetMask() {
		surface_set_target(mask_surface);
		draw_clear(c_black);
		gpu_set_blendmode(bm_subtract);
		draw_sprite_stretched(s_ui_panel_bg, 0, 2, 2, w - 4, h - 4);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}
	resetMask();
	
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
			
		for( var i = 0; i < ds_list_size(childs); i++ ) {
			childs[| i].refresh();
		}
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
		
		if(content) {
			content.w = w;
			content.h = h;
			content.onResize();
		}
	}
	
	function set(_content) {
		content = _content;
		content.panel = self;
		content.x = x;
		content.y = y;
		content.w = w;
		content.h = h;
	}
	
	function split_h(_w) {
		if(abs(_w) > w) return noone;
		
		if(_w < 0) _w = w + _w;
		var _panelParent = new Panel(parent, x, y, w, h);
		_panelParent.anchor = anchor;
		
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
		if(content) content.onStepBegin();
		
		if(dragging == 1) {
			var _mx = clamp(mouse_mx, 16, WIN_W - 16);
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
			
			if(mouse_check_button_released(mb_left)) dragging = -1;
		} else if(dragging == 2) {
			var _my = clamp(mouse_my, 16, WIN_H - 16);
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
			
			if(mouse_check_button_released(mb_left)) dragging = -1;
		} else {
			for(var i = 0; i < ds_list_size(childs); i++) {
				var _panel = childs[| i];
				_panel.stepBegin();
			}
			
			if(ds_list_empty(childs)) {
				if(point_in_rectangle(mouse_mx, mouse_my, x + 2, y + 2, x + w - 4, y + h - 4)) {
					HOVER = self;
					if(mouse_check_button_pressed(mb_left))   setFocus(self);
					if(mouse_check_button_pressed(mb_right))  setFocus(self);
					if(mouse_check_button_pressed(mb_middle)) setFocus(self);
					if(FOCUS == self && content) 
						FOCUS_STR = content.context_str;
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
		if(ds_list_empty(childs)) {
			drawPanel();
		} else {
			var _drag = true;
			for(var i = 0; i < ds_list_size(childs); i++) {
				var _panel = childs[| i];
				if(_panel.content && !_panel.content.draggable)
					_drag = false;
			}
			
			for(var i = 0; i < ds_list_size(childs); i++) {
				var _panel = childs[| i];
				_panel.draw();
				
				if(_drag && (HOVER == noone || is_struct(HOVER)) ) {
					switch(_panel.anchor) {
						case ANCHOR.left :
							if(point_in_rectangle(mouse_mx, mouse_my, _panel.x + _panel.w - 2, _panel.y, _panel.x + _panel.w + 2, _panel.y + _panel.h)) {
								CURSOR = cr_size_we;
								if(mouse_check_button_pressed(mb_left)) {
									dragging  = 1;
									drag_sval = _panel.w;
									drag_sm   = mouse_mx;
								}
							}
							break;
						case ANCHOR.top :
							if(point_in_rectangle(mouse_mx, mouse_my, _panel.x, _panel.y + _panel.h - 2, _panel.x + _panel.w, _panel.y + _panel.h + 2)) {
								CURSOR = cr_size_ns;
								if(mouse_check_button_pressed(mb_left)) {
									dragging = 2;
									drag_sval = _panel.h;
									drag_sm   = mouse_my;
								}
							}
							break;
					}
				}
			}
		}
	}
	
	function drawPanel() {
		if(w <= 16) return;
		draw_sprite_stretched(s_ui_panel_bg, 0, x + 2, y + 2, w - 4, h - 4);
		
		if(!is_surface(mask_surface)) {
			mask_surface = surface_create_valid(w, h);
			resetMask();
		}
		
		if(!is_surface(content_surface)) content_surface = surface_create(w, h);
		surface_set_target(content_surface);
			draw_clear(c_ui_blue_black);
			if(content) {
				min_w = content.min_w;
				min_h = content.min_h;
				if(w >= min_w && h >= min_h)
					content.draw();
			}
			
			gpu_set_blendmode(bm_subtract);
			draw_surface_safe(mask_surface, 0, 0);
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		draw_surface_safe(content_surface, x, y);
		
		if(FOCUS == self) draw_sprite_stretched(s_ui_panel_active, 0, x + 2, y + 2, w - 4, h - 4);
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

function PanelContent(_panel) constructor {
	context_str = "";
	panel = _panel;
	panel.content = self;
	
	draggable = true;
	
	x = panel.x;
	y = panel.y;
	w = panel.w;
	h = panel.h;
	mx = 0;
	my = 0;
	
	min_w = 32;
	min_h = 32;
	
	function refresh() {
		onResize();
	}
	
	function onResize() {}
	
	function onFocusBegin() {}
	function onFocusEnd() {}
	
	function onStepBegin() {
		mx = mouse_mx - x;
		my = mouse_my - y;
		
		stepBegin();
	}
	
	function stepBegin() {}
	
	function draw() {
		drawContent();
	}
	
	function drawContent() {}
}

function setFocus(target) {
	if(FOCUS != noone && is_struct(FOCUS) && FOCUS.content)
		FOCUS.content.onFocusEnd();
	
	FOCUS = target;
	
	if(FOCUS != noone && is_struct(FOCUS) && FOCUS.content)	
		FOCUS.content.onFocusBegin();
}