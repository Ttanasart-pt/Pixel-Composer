function Node_Slideshow(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name    = "Slideshow";
	bg_spr  = THEME.node_frame_bg;
	color   = COLORS._main_accent;
	setDimension(128, 32);
	
	is_controller = true;
	slide_title   = "";
	slide_anchor  = 0;
	slide_speed   = 32;
	slide_zoom    = 0;
	slide_size    = [64, 64];
	anchors       = {};
	
	////- =Display
	newInput( 1, nodeValue_Text(    "Title" ));
	newInput( 0, nodeValue_Int(     "Order",     struct_size(project.slideShow) ));
	newInput( 5, nodeValue_Vec2(    "Half Size", [400, 200] ));
	
	////- =Transition
	newInput( 2, nodeValue_EScroll( "Anchor",        0, [ "Center", "Top left" ]));
	newInput( 3, nodeValue_Float(   "Arrival Speed", 4 ));
	newInput( 4, nodeValue_Float(   "Zoom Level",    0 ));
	// 6
	
	input_display_list = [ 
		[ "Display",    false ], 1, 0, 5, 
		[ "Transition", false ], 2, 3, 
	];
	
	////- Node
	
	static step = function() {
		var _ord = inputs[0].getValue();
		project.slideShow[$ _ord] = self;
		
		slide_title  = inputs[1].getValue();
		slide_size   = inputs[5].getValue();
		
		slide_anchor = inputs[2].getValue();
		slide_speed  = max(1, 100 / inputs[3].getValue());
		slide_zoom   = inputs[4].getValue();
		
		setDisplayName($"Slide-{slide_title}", false);
	}
	
	////- Slideshow
	
	static slideInit = function() {
		var _anchs = struct_get_names(anchors);
		for( var i = 0, n = array_length(_anchs); i < n; i++ ) {
			var _an  = _anchs[i];
			var _anc = anchors[$ _an];
			if(_anc.slide_obj != self) continue;
			
			_anc.slideInit();
		}
	}
	
	static slideStep = function(_t = 0) {
		var _anchs = struct_get_names(anchors);
		for( var i = 0, n = array_length(_anchs); i < n; i++ ) {
			var _an  = _anchs[i];
			var _anc = anchors[$ _an];
			if(_anc.slide_obj != self) continue;
			
			_anc.slideStep(_t);
		}
	}
	
	////- Draw
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s, _panel = noone) {
		var ww = w * _s;
		var hh = h * _s;
		
		var x0 = x * _s + _x;
		var y0 = y * _s + _y;
		var hov = point_in_circle(_mx, _my, x0, y0, 16 * _s);
		
		var area_w = slide_size[0] * _s;
		var area_h = slide_size[1] * _s;
		var area_x = slide_anchor? x0 : x0 - area_w;
		var area_y = slide_anchor? y0 : y0 - area_h;
		
		draw_sprite_stretched_ext(bg_spr, 0, area_x, area_y, area_w * 2, area_h * 2, color, .1 + .1 * hov);
		draw_sprite_stretched_add(bg_spr, 1, area_x, area_y, area_w * 2, area_h * 2, color, bg_spr_add);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_spr, 1, area_x, area_y, area_w * 2, area_h * 2, COLORS._main_accent);
			active_draw_index = -1;
		}
		return hov;
	}
	
	static drawNodeFG = function(_x, _y, _mx, _my, _s, _panel = noone) {
		var x0 = x * _s + _x;
		var y0 = y * _s + _y;
		var ts  = .3 * _s;
		
		draw_anchor_cross(0, x0, y0, 16 * _s, 1);
		draw_set_text(f_sdf, fa_left, fa_top, color);
		draw_text_transformed(x0 + 4 * _s, y0, slide_title, ts, ts, 0);
	}
}