function buttonAnchor(_onClick) : widget() constructor {
	onClick = _onClick;
	index   = 4;
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _m, spr = THEME.button, blend = c_white) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		var cx = x + w / 2;
		var cy = y + h / 2;
		hovering = false;
		
		for( var i = -1; i <= 1; i++ ) 
		for( var j = -1; j <= 1; j++ ) {
			var _bx = cx + j * 9;
			var _by = cy + i * 9;
			var _in = (i + 1) * 3 + (j + 1);
			
			var hov = hover && point_in_rectangle(_m[0], _m[1], _bx - 4, _by - 4, _bx + 4, _by + 4);
			var cc  = hov? COLORS._main_accent : COLORS._main_icon;
			var aa  = 0.75 + (_in == index || hov) * 0.25;
			
			draw_sprite_ext(THEME.prop_anchor, _in == index, _bx, _by, 1, 1, 0, cc, aa);
			
			if(hov) {
				hovering = true;
				if(mouse_click(mb_left, active))
					onClick(_in);
			}
		}
		
		resetFocus();
		
		return _h;
	}
}