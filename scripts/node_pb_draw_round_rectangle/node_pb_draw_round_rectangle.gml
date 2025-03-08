function Node_PB_Draw_Round_Rectangle(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Round Rectangle";
	
	newInput(pbi+0, nodeValue_Corner("Corner Radius", self, [ 1, 1, 1, 1 ] ));
	
	newInput(pbi+1, nodeValue_Enum_Button("Profile", self, 0, [ "Round", "Sharp" ] ));
	
	newInput(pbi+2, nodeValue_Bool("Clamp", self, false ));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, pbi+1, pbi+2, 
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _rad = _data[pbi+0];
		var _pro = _data[pbi+1];
		var _clm = _data[pbi+2];
		
		var _ww = _x1 - _x0;
		var _hh = _y1 - _y0;
		
		var _tl = floor(_rad[0]);
		var _tr = floor(_rad[1]);
		var _bl = floor(_rad[2]);
		var _br = floor(_rad[3]);
		
		if(_clm) {
			_tl = min(_tl, _ww / 2 + 1, _hh / 2 + 1);
			_tr = min(_tr, _ww / 2 + 1, _hh / 2 + 1);
			_bl = min(_bl, _ww / 2 + 1, _hh / 2 + 1);
			_br = min(_br, _ww / 2 + 1, _hh / 2 + 1);
		}
		
		var _rcx0 = _x0 + _tl, _rcy0 = _y0 + _tl;
		var _rcx1 = _x1 - _tr, _rcy1 = _y0 + _tr;
		var _rcx2 = _x0 + _bl, _rcy2 = _y1 - _bl;
		var _rcx3 = _x1 - _br, _rcy3 = _y1 - _br;
		
		if(_tl > 1) {
			var _cx = _x0 + _tl; 
			var _cy = _y0 + _tl;
			
			     if(_pro == 0) draw_circle_angle(_cx + 1, _cy + 1, _tl, 90, 180);
			else if(_pro == 1) draw_triangle(_cx, _y0 + 1, _cx, _cy, _x0 + 1, _cy, false);
		}
		
		if(_tr > 1) {
			var _cx = _x1 - _tr; 
			var _cy = _y0 + _tr;
			
			     if(_pro == 0) draw_circle_angle(_cx + 1, _cy + 1, _tr, 0, 90);
			else if(_pro == 1) draw_triangle(_cx, _y0, _cx, _cy, _x1, _cy, false);
		}
		
		if(_bl > 1) {
			var _cx = _x0 + _bl; 
			var _cy = _y1 - _bl;
			
			     if(_pro == 0) draw_circle_angle(_cx + 1, _cy + 1, _bl, 180, 270);
			else if(_pro == 1) draw_triangle(_cx, _y1 - 1, _cx, _cy, _x0 + 1, _cy, false);
		}
		
		if(_br > 1) {
			var _cx = _x1 - _br; 
			var _cy = _y1 - _br;
			
			     if(_pro == 0) draw_circle_angle(_cx + 1, _cy + 1, _br, 270, 360);
			else if(_pro == 1) draw_triangle(_cx, _y1, _cx, _cy, _x1, _cy, false);
		}
		
		draw_rectangle_points(_rcx0, _rcy0, _rcx1, _rcy1, _rcx2, _rcy2, _rcx3, _rcy3);
		
		draw_rectangle_points(_rcx0, _y0, _rcx1, _y0, _rcx0, _rcy0, _rcx1, _rcy1);
		draw_rectangle_points(_rcx2, _rcy2, _rcx3, _rcy3, _rcx2, _y1, _rcx3, _y1);
		
		draw_rectangle_points(_x0, _rcy0, _rcx0, _rcy0, _x0, _rcy2, _rcx2, _rcy2);
		draw_rectangle_points(_rcx1, _rcy1, _x1, _rcy1, _rcx3, _rcy3, _x1, _rcy3);
	}
}