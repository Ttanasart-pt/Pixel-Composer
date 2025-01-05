function buttonAnchor(_input = noone, _onClick = noone) : widget() constructor {
	onClick = _onClick;
	input   = _input;
	index   = 4;
	click   = true;
	
	center  = true;
	context = noone;
	
	static drawParam = function(params) { return draw(params.x, params.y, params.w, params.h, params.m); }
	
	static trigger = function(_index) {
		if(input == noone) {
			onClick(_index);
			return;
		}
		
		switch(_index) {
			case 0 : input.setValue([ 0.0, 0.0 ]); break; case 1 : input.setValue([ 0.5, 0.0 ]); break; case 2 : input.setValue([ 1.0, 0.0 ]); break;
			case 3 : input.setValue([ 0.0, 0.5 ]); break; case 4 : input.setValue([ 0.5, 0.5 ]); break; case 5 : input.setValue([ 1.0, 0.5 ]); break;
			case 6 : input.setValue([ 0.0, 1.0 ]); break; case 7 : input.setValue([ 0.5, 1.0 ]); break; case 8 : input.setValue([ 1.0, 1.0 ]); break;
		}
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
			if(!center && i == 0 && j == 0) continue;
			
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
				if(mouse_click(mb_left, active)) trigger(_in)
			}
		}
		
		resetFocus();
		
		return _h;
	}
	
	static clone = function() /*=>*/ {return new buttonAnchor(input, onClick)}
}