function connection_get_line(jx, jy, frx, fry) { return [ [jx, jy] , [frx, fry] ]; }

function connection_get_curve(x0, y0, x1, y1, xc = noone, yc = noone) { #region
	if(xc == noone) xc = (x0 + x1) / 2;
	if(yc == noone) yc = (y0 + y1) / 2;
	
	var pnt    = array_create(sample + 1);
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 32 * PROJECT.graphConnection.line_sample);
	    sample = clamp(sample, 2, 128);
	
	var x2 = lerp(x0, x1, 0. - sign(x1 - x0) * 0.2) - abs(y1 - y0) * 0.1;
	var x3 = lerp(x0, x1, 1. + sign(x1 - x0) * 0.2) + abs(y1 - y0) * 0.1;
	var y2 = y0;
	var y3 = y1;
	
	var ox, oy, nx, ny, t, it, oc, nc;
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx =      x0 *				  power(t, 4) 
			+ 4 * x2 * power(it, 1) * power(t, 3) 
			+ 6 * xc * power(it, 2) * power(t, 2) 
			+ 4 * x3 * power(it, 3) * power(t, 1) 
			+     x1 * power(it, 4);
			
		ny =      y0 *                power(t, 4) 
			+ 4 * y2 * power(it, 1) * power(t, 3) 
			+ 6 * yc * power(it, 2) * power(t, 2) 
			+ 4 * y3 * power(it, 3) * power(t, 1) 
			+     y1 * power(it, 4);
			
		pnt[i] = [ nx, ny ];
		
		ox = nx;
		oy = ny;
		oc = nc;
	}
	
	return pnt;
} #endregion
function connection_get_curve_down(x0, y0, x1, y1) { #region
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 32 * PROJECT.graphConnection.line_sample);
	sample = clamp(sample, 2, 128);
	
	var pnt = array_create(sample + 1);
	var x2 = lerp(x0, x1, 0.9);
	var x3 = x1;
	var y2 = lerp(y0, y1, 0.1);
	var y3 = y1;
	
	var c   = draw_get_color();
	var ox, oy, nx, ny, t, it, oc, nc;
	
	for( var i = 0; i <= sample; i++ )  {
		t  = i / sample;
		it = 1 - t;
		
		nx =      x0 *				  power(t, 3) 
			+ 3 * x2 * power(it, 1) * power(t, 2) 
			+ 3 * x3 * power(it, 2) * power(t, 1) 
			+     x1 * power(it, 3);
			
		ny =      y0 *                power(t, 3) 
			+ 3 * y2 * power(it, 1) * power(t, 2) 
			+ 3 * y3 * power(it, 2) * power(t, 1) 
			+     y1 * power(it, 3);
		
		pnt[i] = [ nx, ny ];
		
		ox = nx;
		oy = ny;
		oc = nc;
	}
} #endregion