function draw_line_connect(x0, y0, x1, y1, _s = 1, thick = 1, c1 = c_white, c2 = c_white, params = {}) {
	if(y0 == y1) {
		draw_line_width_color(x0, y0, x1, y1, thick, c1, c2); 
		return;
	}
	
	var extend    = params.extend;
    var corner    = min(extend, params.corner, min(abs(x0 - x1), abs(y0 - y1)) / 2);
	var type      = params.type;
	
	var sample = clamp(corner / 4, 1, 8);
	
	var xx0 = x0 + extend * _s;
	var xx1 = x1 - extend * _s;
	var dir = point_direction(xx0, y0, xx1, y1);
	
	var cx0 = xx0 + lengthdir_x(corner, dir);
	var cy0 =  y0 + lengthdir_y(corner, dir);
	var cx1 = xx1 - lengthdir_x(corner, dir);
	var cy1 =  y1 - lengthdir_y(corner, dir);
	
    draw_line_width_color( x0, y0, xx0 - corner, y0, thick, c1, c1); 
    draw_line_width_color(xx1 + corner, y1,  x1, y1, thick, c2, c2); 
    draw_line_width_color(cx0, cy0, cx1, cy1, thick, c1, c2); 
    
    draw_corner(xx0 - corner, y0, 
                xx0, y0, 
                cx0, cy0, 
                thick, c1, sample);
                
    draw_corner(cx1, cy1, 
                xx1, y1, 
                xx1 + corner, y1, 
                thick, c2, sample);
                
}

function distance_to_linear_connection(mx, my, x0, y0, x1, y1, _s, extend) {
	var xx0 = x0 + extend * _s;
	var xx1 = x1 - extend * _s;
	return distance_to_line(mx, my, xx0, y0, xx1, y1);
}

function point_to_linear_connection(mx, my, x0, y0, x1, y1, _s, extend, _p = undefined) {
	var xx0 = x0 + extend * _s;
	var xx1 = x1 - extend * _s;
	return point_to_line(mx, my, xx0, y0, xx1, y1, _p);
}