function draw_surface_align(surface, _x, _y, _s, _halign = fa_left, _valign = fa_top) {
	if(!is_surface(surface)) return;
	
	var w = surface_get_width_safe(surface) * _s;
	var h = surface_get_height_safe(surface) * _s;
	
	var _sx = _x, _sy = _y;
	switch(_halign) {
		case fa_left:	_sx = _x;			break;	
		case fa_center: _sx = _x - w / 2;	break;	
		case fa_right:	_sx = _x - w;		break;	
	}
	
	switch(_valign) {
		case fa_top:	_sy = _y;			break;	
		case fa_center: _sy = _y - h / 2;	break;	
		case fa_bottom:	_sy = _y - h;		break;	
	}
	
	draw_surface_ext_safe(surface, _sx, _sy, _s, _s, 0, c_white, 1);
}