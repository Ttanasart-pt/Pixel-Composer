function dynaDraw_cube_fill() : dynaDraw() constructor {
	
	parameters = [  ];
	editors    = [
		
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		if(round(_sx) <= 1 || round(_sy) <= 1) return; 
		
		_sx /= 2;
		_sy /= 2;
		
		var _ftop_cx = _x;
		var _ftop_cy = _y - (_sy + _sx) / 2 + _sx / 2;
		
		var facePnts = [[0,0],[0,0],[0,0],[0,0]];
		
		facePnts[0][0] = _ftop_cx + lengthdir_x(_sx,   _ang);
		facePnts[0][1] = _ftop_cy + lengthdir_y(_sx/2, _ang);
		
		facePnts[1][0] = _ftop_cx + lengthdir_x(_sx,   _ang + 90);
		facePnts[1][1] = _ftop_cy + lengthdir_y(_sx/2, _ang + 90);
		
		facePnts[2][0] = _ftop_cx + lengthdir_x(_sx,   _ang + 180);
		facePnts[2][1] = _ftop_cy + lengthdir_y(_sx/2, _ang + 180);
		
		facePnts[3][0] = _ftop_cx + lengthdir_x(_sx,   _ang + 270);
		facePnts[3][1] = _ftop_cy + lengthdir_y(_sx/2, _ang + 270);
		
		var _ftop_a1_x = facePnts[0][0], _ftop_a1_y = facePnts[0][1]
		var _ftop_a2_x = facePnts[1][0], _ftop_a2_y = facePnts[1][1]
		var _ftop_a3_x = facePnts[2][0], _ftop_a3_y = facePnts[2][1]
		var _ftop_a4_x = facePnts[3][0], _ftop_a4_y = facePnts[3][1]
		
		var _ftop_b1_x = _ftop_a1_x, _ftop_b1_y = _ftop_a1_y + _sy;
		var _ftop_b2_x = _ftop_a2_x, _ftop_b2_y = _ftop_a2_y + _sy;
		var _ftop_b3_x = _ftop_a3_x, _ftop_b3_y = _ftop_a3_y + _sy;
		var _ftop_b4_x = _ftop_a4_x, _ftop_b4_y = _ftop_a4_y + _sy;
		
		var _fl_xi = min_index(_ftop_a1_x, _ftop_a2_x, _ftop_a3_x, _ftop_a4_x);
		var _fr_xi = max_index(_ftop_a1_x, _ftop_a2_x, _ftop_a3_x, _ftop_a4_x);
		var _fc_yi = max_index(_ftop_a1_y, _ftop_a2_y, _ftop_a3_y, _ftop_a4_y);
		
		var fl_x0 = facePnts[_fl_xi][0], fl_y0 = facePnts[_fl_xi][1];
		var fl_x1 = facePnts[_fc_yi][0], fl_y1 = facePnts[_fc_yi][1];
		var fl_x2 = facePnts[_fr_xi][0], fl_y2 = facePnts[_fr_xi][1];
		
		draw_set_alpha(_alp);
		
		draw_set_color(merge_color(_col, c_black, .2));
		draw_rectangle_points( fl_x0, fl_y0,     fl_x1, fl_y1, 
		                      fl_x0, fl_y0+_sy, fl_x1, fl_y1+_sy, false );
		
		draw_set_color(merge_color(_col, c_black, .4));                       
		draw_rectangle_points( fl_x2, fl_y2,     fl_x1, fl_y1, 
		                      fl_x2, fl_y2+_sy, fl_x1, fl_y1+_sy, false );
		
		draw_set_color(_col);
		draw_rectangle_points( _ftop_a1_x, _ftop_a1_y, _ftop_a2_x, _ftop_a2_y, 
		                      _ftop_a4_x, _ftop_a4_y, _ftop_a3_x, _ftop_a3_y, false );
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		
	}
	
	static deserialize = function(m) { 
		return self; 
	}
}