function buttonAnchor(_onClick) : widget() constructor {
	onClick = _onClick;
	index   = 4;
	click   = true;
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _m, spr = THEME.button_def, blend = c_white) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		var cx = x + w / 2;
		var cy = y + h / 2;
		hovering = false;
		
		var spacing = 9;
		
		for( var i = -1; i <= 1; i++ ) 
		for( var j = -1; j <= 1; j++ ) {
			var _bx  = cx + j * spacing;
			var _by  = cy + i * spacing;
			var _in  = (i + 1) * 3 + (j + 1);
			var _fil = is_array(index)? index[_in] : _in == index;
			
			var hov = hover && point_in_rectangle(_m[0], _m[1], _bx - 4, _by - 4, _bx + 4, _by + 4);
			var cc  = hov? COLORS._main_accent : COLORS._main_icon;
			var aa  = 0.75 + (_fil || hov) * 0.25;
			
			draw_sprite_ext(THEME.prop_anchor, _fil, _bx, _by, 1, 1, 0, cc, aa);
			
			if(hov) {
				hovering = true;
				if(mouse_click(mb_left, active))
					onClick(_in);
			}
		}
		
		resetFocus();
		
		return _h;
	}
	
	static clone = function() { #region
		var cln = new buttonAnchor(onClick);
		
		return cln;
	} #endregion
}