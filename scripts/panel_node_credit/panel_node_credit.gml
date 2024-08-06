function Panel_Node_Cost() : PanelContent() constructor {
	title = "Insufficient node credit";
	w = ui(640);
	h = ui(480);
	
	bundles = [
		[ "Small pack",			"100",        "$0.99" ],
		[ "Nodes for days!",	"500 + 100",  "$4.99" ],
		[ "All the nodes!!",	"2000 + 500", "$19.99" ],
	];
	
	function drawContent(panel) {
		draw_set_text(f_h3, fa_center, fa_top, COLORS._main_text);
		draw_text_add(w / 2, 8, "Insufficient node credit");
		
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_text_ext_add(16, 56, @"Pixel Composer has adopted a new node credit system. Effective immediately each node created in PC will now cost $0.01.

For your convenience we have develop a node credit system which allows you to top-up your credit for uninterrupted PC experience.", -1, w - 32);
		
		draw_set_text(f_p0b, fa_center, fa_top, COLORS._main_text_accent);
		draw_text_add(w / 2, 180, "Choose your top-up amount:");
		
		var _w = (w - 32 - 16) / 3;
		var _h = 240;
		
		var _x = 16;
		var _y = 224;
		
		for( var i = 0; i < 3; i++ ) {
			var _bx = _x + (_w + 8) * i;
			var _by = _y;
			
			var cc = i == 1? COLORS._main_text_accent : COLORS._main_text;
			
			if(pHOVER && point_in_rectangle(mx, my, _bx, _by, _bx + _w, _by + _h)) {
				draw_sprite_stretched_ext(THEME.s_box_r5_clr, 1, _bx, _by, _w, _h, cc, 1);
				if(mouse_press(mb_left, pFOCUS))
					url_open("https://ko-fi.com/makhamdev");
			} else
				draw_sprite_stretched_ext(THEME.s_box_r5_clr, 0, _bx, _by, _w, _h, cc, 1);
				
			draw_set_text(f_h5, fa_center, fa_top, cc);
			draw_text_add(_bx + _w / 2, _by + 8, bundles[i][0]);
			
			draw_sprite(node_credit, i, _bx + _w / 2, _by + _h / 2 - 16);
			
			draw_set_text(f_h3, fa_center, fa_top, COLORS._main_text);
			draw_text_add(_bx + _w / 2, _by + _h - 80, bundles[i][1]);
			
			draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(_bx + _w / 2, _by + _h - 52, "nodes");
				
			draw_set_text(f_p0b, fa_center, fa_top, COLORS._main_text);
			draw_text_add(_bx + _w / 2, _by + _h - 32, bundles[i][2]);
			
			if(i == 1) draw_sprite(credit_badge_popular, 0, _bx + _w / 2, _by);
			if(i == 2) draw_sprite(credit_badge_value,   0, _bx + _w / 2, _by);
		}
		
	}
}