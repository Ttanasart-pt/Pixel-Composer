global.__FRAME_LABEL_SCALE = 1;

function Node_Frame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Frame";
	w      = 240;
	h      = 160;
	bg_spr = THEME.node_frame_bg;
	
	size_dragging    = false;
	size_dragging_w  = w;
	size_dragging_h  = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height      = false;
	name_hover       = false;
	hover_progress   = 0;
	
	color  = c_white;
	alpha  = 1;
	scale  = 1;
	lcolor = false;
	
	tb_name     = textBox_Text(function(txt) /*=>*/ { setDisplayName(txt); }).setFont(f_p2).setHide(true).setAlign(fa_center);
	name_height = 18;
	__nodes     = [];
	
	draw_x0 = 0;
	draw_y0 = 0;
	draw_x1 = 0;
	draw_y1 = 0;
	
	newInput(0, nodeValue_Vec2(   "Size",       [ 240, 160 ] ));
	newInput(1, nodeValue_Color(  "Color",       ca_white    ));
	newInput(2, nodeValue_Slider( "Alpha",       0.75        ));
	newInput(3, nodeValue_Slider( "Label size",  global.__FRAME_LABEL_SCALE ));
	newInput(4, nodeValue_Slider( "Blend label", 0 ));
	
	input_display_list = [ 0, 1, 3, 4 ];
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()});
	
	static move = function(_x, _y) {
		if(moved) return;
		if(x == _x && y == _y) return;
		
		var _dx = _x - x;
		var _dy = _y - y;
		
		x = _x; 
		y = _y; 
		moved = true;
		
		for( var i = 0, n = array_length(__nodes); i < n; i++ ) {
			var _n  = __nodes[i];
			var _nx = _n.x + _dx;
			var _ny = _n.y + _dy;
			
			_n.move(_nx, _ny);
		}
		
		if(!LOADING) project.modified = true;
	}
	
	////- Update
	
	static onValueUpdate = function(index = 3) { 
		previewable = true;
		global.__FRAME_LABEL_SCALE = inputs[3].getValue();
		
		var sz = inputs[0].getValue();
		w = sz[0];
		h = sz[1];
		
		color  = inputs[1].getValue();
		alpha  = _color_get_alpha(color);
		
		scale  = inputs[3].getValue();
		lcolor = inputs[4].getValue();
	}
	
	static setHeight = function() {}
	
	static isRenderable = function() /*=>*/ {return false};
	static doUpdate = function() {}
	static update   = function() {}
	
	////- Draw
	
	static preDraw = function(_x, _y, _mx, _my, _s) {}
	
	static drawNode  = function() { return noone; }
	static drawBadge = function() { return noone; }
	
	static drawNodeBase = function(xx, yy, _s, _panel = noone) {
		var _nh = ui(name_height);
		var _yy = yy - _nh;
		
		var x0 =  xx;
		var y0 = _yy;
		var x1 =  xx + w * _s;
		var y1 = _yy + _nh + h * _s;
		
		draw_x0 = x0;
		draw_y0 = y0;
		draw_x1 = x1;
		draw_y1 = y1;
		
		if(_panel != noone) {
			px0 =  3;
			py0 =  3;
			px1 = -3 + _panel.w;
			py1 = -0 + _panel.h - _panel.toolbar_height;
			
			draw_x0 = max(x0, px0);
			draw_y0 = max(y0, py0);
			draw_x1 = min(x1, px1);
			draw_y1 = min(y1, py1);
		}
		
		var _h  = max(draw_y1 - draw_y0, _nh);
		
		if(y0 > 0)	draw_y1 = draw_y0 + _h;
		else		draw_y0 = draw_y1 - _h;
		
		if(draw_x1 - draw_x0 < 4) return;
		
		var _dw = x1 - x0;
		var _dh = y1 - y0;
		
		draw_sprite_stretched_ext(bg_spr, 0, x0, y0, _dw, _dh, color, alpha);
	}
	
	static drawNodeFG = function(_x, _y, _mx, _my, _s, _dparam, _panel = noone) {
		if(draw_x1 - draw_x0 < 4) return;
		
		var _nh = ui(name_height);
		var _w  = draw_x1 - draw_x0;
		var _h  = draw_y1 - draw_y0;
		var txt = renamed? display_name : name;
		
		draw_sprite_stretched_ext(bg_spr, 1, draw_x0, draw_y0, _w, _h, color, alpha * .50);
		
		if(WIDGET_CURRENT == tb_name) {
			var nh = 24;
			draw_sprite_stretched_ext(bg_spr, 2, draw_x0, draw_y0, _w, nh, color, alpha * .75);
			
			tb_name.setFocusHover(PANEL_GRAPH.pFOCUS, PANEL_GRAPH.pHOVER);
			tb_name.draw(draw_x0, draw_y0, _w, nh, txt, [ _mx, _my ]);
			
		} else {
			draw_sprite_stretched_ext(bg_spr, 2, draw_x0, draw_y0, _w, _nh, color, alpha * .75);
			
			draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text);
			draw_text_cut((draw_x0 + draw_x1) / 2, draw_y0 + _nh + 1, txt, _w - 4);
			
			if(point_in_rectangle(_mx, _my, draw_x0, draw_y0, draw_x0 + _w, draw_y0 + _nh)) {
				if(PANEL_GRAPH.pFOCUS && DOUBLE_CLICK)
					tb_name.activate(txt);
			}
		}
		
		draw_sprite_stretched_add(bg_spr, 1, draw_x0, draw_y0, _w, _h, c_white, .20);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_spr, 1, draw_x0, draw_y0, _w, _h, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		drawBadge(_x, _y, _s);
	}
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s, _dparam, _panel = noone) {
		
		if(size_dragging) {
			w = size_dragging_w + (mouse_mx - size_dragging_mx) / _s;
			h = size_dragging_h + (mouse_my - size_dragging_my) / _s;
			
			if(!key_mod_press(CTRL)) {
				w = value_snap(w, 16);
				h = value_snap(h, 16);
			}
			
			if(mouse_release(mb_left)) {
				size_dragging = false;
				inputs[0].setValue([ w, h ]);
			}
		}
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		drawNodeBase(xx, yy, _s, _panel);
		
		var x1  = xx + w * _s;
		var y1  = yy + h * _s;
		var x0  = x1 - 16 * THEME_SCALE;
		var y0  = y1 - 16 * THEME_SCALE;
		var ics = 0.5;
		var shf = 8 * ics;
		
		if(w * _s < 32 || h * _s < 32) return point_in_rectangle(_mx, _my, xx, yy, x1, y1);
		
		var _aa = size_dragging? .3 : .15;
		
		if(_panel != noone && !name_hover && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			_aa = .3;
			PANEL_GRAPH.drag_locking = true;
			
			if(mouse_press(mb_left)) {
				size_dragging	 = true;
				size_dragging_w  = w;
				size_dragging_h  = h;
				size_dragging_mx = mouse_mx;
				size_dragging_my = mouse_my;
			}
		}
		
		draw_sprite_ext_add(THEME.node_resize, 0, x1 - shf, y1 - shf, ics, ics, 0, c_white, _aa);
		
		return point_in_rectangle(_mx, _my, xx, yy, x1, y1);
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		var y0 = yy - ui(name_height);
		
		var hover  = point_in_rectangle(_mx, _my, xx, y0, xx + w * _s, yy);
		name_hover = hover;
		
		return hover;
	}

	////- Serialize
	
	static postApplyDeserialize  = function() {
		onValueUpdate();
	}
	
}