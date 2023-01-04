function draw_circle_border(xx, yy, r, w) {
	var step = 32;
	var angle_step = 360 / step;

	var px, py, _px, _py;

	for(var i = 0; i <= step; i++){
		var px = xx + lengthdir_x(r, i * angle_step);
		var py = yy + lengthdir_y(r, i * angle_step);
	
		if(i)
			draw_line_round(_px, _py, px, py, w);
		
		_px = px;
		_py = py;
	}
}

function draw_ellipse_border(x0, y0, x1, y1, w) {
	var step = 32;
	var angle_step = 360 / step;
	
	var px, py, _px, _py;
	var cx = (x0 + x1) / 2;
	var cy = (y0 + y1) / 2;
	
	var ww = abs(x0 - x1) / 2;
	var hh = abs(y0 - y1) / 2;

	for(var i = 0; i <= step; i++){
		var px = cx + lengthdir_x(ww, i * angle_step);
		var py = cy + lengthdir_y(hh, i * angle_step);
	
		if(i)
			draw_line_round(_px, _py, px, py, w);
	
		_px = px;
		_py = py;
	}
}