function Node_PB_Draw_Star(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Star";
	
	newInput(pbi+0, nodeValue_i("Sides", self, 3));
	
	newInput(pbi+1, nodeValue_r("Angle", self, 0));
	
	newInput(pbi+2, nodeValue_s("Inner Radius", self, .5));
	
	newInput(pbi+3, nodeValue_eb("Mode", self, 0, [ "Fill", "Lines" ]));
	
	newInput(pbi+4, nodeValue_f("Thickness", self, 1));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape",  false], pbi+3, pbi+0, pbi+1, pbi+2, pbi+4, 
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _side = _data[pbi+0];
		var _angl = _data[pbi+1];
		var _innr = _data[pbi+2];
		var _mode = _data[pbi+3];
		var _thck = _data[pbi+4];
		
		inputs[pbi+2].setVisible(_mode == 0);
		inputs[pbi+4].setVisible(_mode == 1);
		
		var _cx = (_x0 + _x1) / 2;
		var _cy = (_y0 + _y1) / 2;
		
		var _hw = (_x1 - _x0) / 2;
		var _hh = (_y1 - _y0) / 2;
		
		var _iw = _hw * _innr;
		var _ih = _hh * _innr;
		var _st = 360 / _side;
		
		if(_mode == 0) {
			
			draw_primitive_begin(pr_trianglelist);
			
			for( var i = 0; i < _side; i++ ) {
			    var _a0 = _angl + i * _st;
			    var _ox = _cx + lengthdir_x(_hw, _a0);
			    var _oy = _cy + lengthdir_y(_hh, _a0);
			    
			    var _a1 = _a0 + _st / 2;
			    var _ix = _cx + lengthdir_x(_iw, _a1);
			    var _iy = _cy + lengthdir_y(_ih, _a1);
			    
			    var _a2 = _a0 + _st;
			    var _nx = _cx + lengthdir_x(_hw, _a2);
			    var _ny = _cy + lengthdir_y(_hh, _a2);
			    
			    draw_vertex(_cx, _cy);
			    draw_vertex(_ox, _oy);
			    draw_vertex(_ix, _iy);
			    
			    draw_vertex(_cx, _cy);
			    draw_vertex(_ix, _iy);
			    draw_vertex(_nx, _ny);
			    
			}
			
			draw_primitive_end();
			
		} else if(_mode == 1) {
			var _ox, _oy;
			var _nx, _ny;
			var _i = 0;
			
			for( var i = 0; i <= _side; i++ ) {
				var _a0 = _angl + _i * _st;
				_i = (_i + 2) % _side;
				
			    _nx = _cx + lengthdir_x(_hw, _a0);
			    _ny = _cy + lengthdir_y(_hh, _a0);
				
				if(i) draw_line_width(_ox, _oy, _nx, _ny, _thck);
				
				_ox = _nx; 
				_oy = _ny;
				
			}
			
			if(_side % 2 == 0) {
				var _i = 1;
				for( var i = 0; i <= _side; i++ ) {
					var _a0 = _angl + _i * _st;
					_i = (_i + 2) % _side;
					
				    _nx = _cx + lengthdir_x(_hw, _a0);
				    _ny = _cy + lengthdir_y(_hh, _a0);
					
					if(i) draw_line_width(_ox, _oy, _nx, _ny, _thck);
					
					_ox = _nx; 
					_oy = _ny;
					
				}
			}
		}
	}
}