function draw_circle_border(xx, yy, r, w) {
	var step = 32;
	var angle_step = 360 / step;

	var px, py, _px, _py;

	for(var i = 0; i <= step; i++){
		var px = xx + lengthdir_x(r, i * angle_step);
		var py = yy + lengthdir_y(r, i * angle_step);
	
		if(i>0){
			draw_line_round(_px, _py, px, py, w);
		}
	
		_px = px;
		_py = py;
	}
}