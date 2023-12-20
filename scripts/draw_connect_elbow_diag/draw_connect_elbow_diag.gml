function draw_line_elbow_diag_color(x0, y0, x1, y1, cx = noone, cy = noone, _s = 1, thick = 1, c1 = c_white, c2 = c_white, corner = 0, indexIn = 1, indexOut = 1, type = LINE_STYLE.solid) { #region
	var __dash = 6 * _s;
	var __line = type == LINE_STYLE.solid? draw_line_width_color : draw_line_dashed_color;
	
	if(y0 == y1) { __line(x0, y0, x1, y1, thick, c1, c2, __dash); return; }
	
	corner = min(corner, abs(y1 - y0) / 2); 
	var sample = floor(corner / 8);
	sample = clamp(sample, 0, 8);
	if(sample == 0) corner = 0;
	
	if(cx == noone) cx = (x0 + x1) / 2;
	if(cy == noone) cy = (y0 + y1) / 2;
	
	var iy  = sign(y1 - y0);
	
	var xx0 = x0 + 16 * _s * indexIn;
	var xx1 = x1 - 16 * _s * indexOut;
	var yy0 = y0 + 16 * _s * iy;
	var yy1 = y1 - 16 * _s * iy;
	
	var ix  = sign(xx0 - xx1);
	
	var vert = abs(yy1 - yy0) > abs(xx1 - xx0);
	var inv  = vert || xx1 <= xx0;
	var _x0  = min(x0, x1);	
	var _x1  = max(x0, x1);
	var _y0  = min(y0, y1);	
	var _y1  = max(y0, y1);
	var rx   = _x1 - _x0;
	var ry   = _y1 - _y0;
	
	if(inv) {
		var cm   = merge_color(c1, c2, 0.5);
		
		var ofl  = cy < _y0 || cy > _y1;
		var iy0  = sign(cy - y0);
		var iy1  = sign(y1 - cy);
		var rrx  = abs(xx0 - xx1);
		
		var cS  = min(corner, 16 * _s);
		
		if(xx1 > xx0 && !ofl) {
			if(abs(y1 - y0) < abs(xx1 - xx0))
				cS = 0;
			
			var cS0 = min(cS, abs(cy - y0) - rrx / 2);
			cS0 = max(0, cS0);
			
			var cS1 = min(cS, abs(cy - y1) - rrx / 2);
			cS1 = max(0, cS1);
			
			var top = abs(cy - y0) < rrx / 2;
			var bot = abs(y1 - cy) < rrx / 2;
			
			if(top) {
				__line(x0, y0, xx0, y0, thick, c1, c1, __dash);
				__line(xx1 + cS, y1, x1, y1, thick, c2, c2, __dash);
				
				var cor = (cy - y0) * 2;
				var x1s = xx1 - cor * iy;
				var y1s = y0 + cor;
				var xcr = min(cS, abs(xx1 - x1s) / 2);
				var ycr = min(cS, abs( y0 - y1s) / 2);
				
				var _xcr = xcr / sqrt(2);
				var _ycr = ycr / sqrt(2);
				
				__line(xx0, y0, x1s - xcr, y0, thick, c1, cm, __dash);
				__line(xx1, y1s + ycr * iy, xx1, y1 - cS * iy, thick, cm, c2, __dash);
				
				__line(x1s + _xcr, y0 + _xcr * iy, xx1 - _ycr, y1s - _ycr * iy, thick, cm, cm, __dash);
				
				if(cS)  draw_corner(xx1, y1 - cS * iy, xx1, y1, xx1 + cS, y1, thick, c2, sample);
				if(xcr) draw_corner(x1s - xcr, y0, x1s, y0, x1s + _xcr, y0 + _xcr * iy, thick, cm, sample);
				if(ycr) draw_corner(xx1 - _ycr, y1s - _ycr * iy, xx1, y1s, xx1, y1s + ycr * iy, thick, cm, sample);
			} else if(bot) {
				__line(x0, y0, xx0 - cS, y0, thick, c1, c1, __dash);
				__line(xx1, y1, x1, y1, thick, c2, c2, __dash);
				
				var cor = (y1 - cy) * 2;
				var x1s = xx0 + cor * iy;
				var y1s = y1 - cor;
				var xcr = min(cS, abs(xx0 - x1s) / 2);
				var ycr = min(cS, abs( y1 - y1s) / 2);
				
				var _xcr = xcr / sqrt(2);
				var _ycr = ycr / sqrt(2);
				
				__line(xx0, y0 + cS * iy, xx0, y1s - ycr * iy, thick, c1, cm, __dash);
				__line(x1s + xcr, y1, xx1, y1, thick, cm, c2, __dash);
				
				__line(xx0 + _ycr, y1s + _ycr * iy, x1s - _xcr, y1 - _xcr * iy, thick, cm, cm, __dash);
				
				if(cS)  draw_corner(xx0 - cS, y0, xx0, y0, xx0, y0 + cS * iy, thick, c1, sample);
				if(xcr) draw_corner(x1s - _xcr, y1 - _xcr * iy, x1s, y1, x1s + xcr, y1, thick, cm, sample);
				if(ycr) draw_corner(xx0, y1s - ycr * iy, xx0, y1s, xx0 + _ycr, y1s + _ycr * iy, thick, cm, sample);
			} else {
				__line(x0, y0, xx0 - cS0, y0, thick, c1, c1, __dash);
				__line(xx1 + cS1, y1, x1, y1, thick, c2, c2, __dash);
			
				var cor = rrx / 2;
				var yC0 = cy - cor * iy0;
				var yC1 = cy + cor * iy1;
				
				var corY0 = min(corner, abs(yC0 - (y0 + cS0 * iy)), abs(xx1 - xx0));
				var corY1 = min(corner, abs(yC1 - (y1 - cS1 * iy)), abs(xx1 - xx0));
				
				var _corY0 = corY0 / sqrt(2);
				var _corY1 = corY1 / sqrt(2);
				
				__line(xx0, y0 + cS0 * iy, xx0, yC0 - corY0 * iy, thick, c1, cm, __dash);
				__line(xx1, yC1 + corY1 * iy, xx1, y1 - cS1 * iy, thick, cm, c2, __dash);
				
				__line(xx0 + _corY0, yC0 + _corY0 * iy, xx1 - _corY1, yC1 - _corY1 * iy, thick, cm, cm, __dash);
				
				if(cS0) draw_corner(xx0 - cS0, y0, xx0, y0, xx0, y0 + cS0 * iy0, thick, c1, sample);
				if(cS1) draw_corner(xx1, y1 - cS1 * iy1, xx1, y1, xx1 + cS1, y1, thick, c2, sample);
				
				if(corY0) draw_corner(xx0, yC0 - corY0 * iy, xx0, yC0, xx0 + _corY0, yC0 + _corY0 * iy, thick, cm, sample);
				if(corY1) draw_corner(xx1, yC1 + corY1 * iy, xx1, yC1, xx1 - _corY1, yC1 - _corY1 * iy, thick, cm, sample);
			}
		} else {
			var cR0 = min(cS, abs(y0 - cy) / 2);
			var cR1 = min(cS, abs(y1 - cy) / 2);
			
			var cut0 = min(abs(cy - yy0) / 2, abs(xx1 - xx0) / 2, ofl? 16 * _s : 9999);
			var cut1 = min(abs(cy - yy1) / 2, abs(xx1 - xx0) / 2, ofl? 16 * _s : 9999);
			
			var crX0 = xx0;
			var crY0 =  cy - cut0 * iy0;
			var crX1 = xx0 - cut0 * ix;
			var crY1 = cy;
			var crX2 = xx1 + cut1 * ix;
			var crY2 = cy;
			var crX3 = xx1;
			var crY3 =  cy + cut1 * iy1;
			
			var crn0 = min(cS / 2, abs(crY0 - (y0 + cR0 * iy0)) / 2, abs(crX1 - crX2) / 2);
			var crn1 = min(cS / 2, abs(crY3 - (y1 - cR1 * iy1)) / 2, abs(crX1 - crX2) / 2);
			
			var _crn0 = crn0 / sqrt(2);
			var _crn1 = crn1 / sqrt(2);
			
			__line(x0, y0, xx0 - cR0, y0, thick, c1, c1, __dash);
			__line(xx1 + cR1, y1, x1, y1, thick, c2, c2, __dash);
		
			if(cS) draw_corner(xx0 - cR0, y0, xx0, y0, xx0, y0 + cR0 * iy0, thick, c1);
			if(cS) draw_corner(xx1, y1 - cR1 * iy1, xx1, y1, xx1 + cR1, y1, thick, c2);
				
			if(abs(crX0 - crX3) == abs(crY0 - crY3)) { 
				var cR = min(cS, abs(xx1 - xx0) / 2);
				var _cR = cR / sqrt(2);
				
				__line(       crX0,   y0 + cR0 * iy0,       crX0, crY0 -  cR * iy0, thick, c1, cm, __dash);
				__line(       crX3,   y1 - cR1 * iy1,       crX3, crY3 +  cR * iy1, thick, c2, cm, __dash);
				__line( crX0 - _cR, crY0 + _cR * iy0, crX3 + _cR, crY3 - _cR * iy1, thick, cm, cm, __dash);
				
				if(cR)  {
					draw_corner(      crX0, crY0 -  cR * iy0, crX0, crY0, crX0 - _cR, crY0 + _cR * iy0, thick, cm, sample);
					draw_corner(crX3 + _cR, crY3 - _cR * iy1, crX3, crY3,       crX3, crY3 +  cR * iy1, thick, cm, sample);
				}
			} else { 
				__line(            crX0,    y0 + cR0 * iy0,             crX0, crY0 - crn0 * iy0, thick, c1, cm, __dash);
				__line(crX1 - crn0 * ix,              crY1, crX2 + crn1 * ix,              crY2, thick, cm, cm, __dash);
				__line(            crX3, crY3 + crn1 * iy1,             crX3,    y1 - cR1 * iy1, thick, cm, c2, __dash);
			
				__line(crX0 - _crn0 * ix, crY0 + _crn0 * iy0, crX1 + _crn0 * ix, crY1 - _crn0 * iy0, thick, cm, cm, __dash);
				__line(crX2 - _crn1 * ix, crY2 + _crn1 * iy1, crX3 + _crn1 * ix, crY3 - _crn1 * iy1, thick, cm, cm, __dash);
				
				if(crn0) {
					draw_corner(             crX0,  crY0 - crn0 * iy0, crX0, crY0, crX0 - _crn0 * ix, crY0 + _crn0 * iy0, thick, cm, sample);
					draw_corner(crX1 + _crn0 * ix, crY1 - _crn0 * iy0, crX1, crY1, crX1 -  crn0 * ix,               crY1, thick, cm, sample);
				}
			
				if(crn1) {
					draw_corner(crX2 + crn1 * ix,              crY2, crX2, crY2, crX2 - _crn1 * ix, crY2 + _crn1 * iy1, thick, cm, sample);
					draw_corner(            crX3, crY3 + crn1 * iy1, crX3, crY3, crX3 + _crn1 * ix, crY3 - _crn1 * iy1, thick, cm, sample);
				}
			}
		}
	} else {
		cx = clamp(cx, _x0 + abs(ry) / 2, _x1 - abs(ry) / 2);
		cy = clamp(cy, _y0 + abs(rx) / 2, _y1 - abs(rx) / 2);
	
		var ry   = _y1 - _y0;
		var _xc0 = clamp(cx - (ry / 2) * sign(x1 - x0), _x0, _x1);
		var _xc1 = clamp(cx + (ry / 2) * sign(x1 - x0), _x0, _x1);
		
		var rat  = rx == 0? 0.5 : (cx - _x0) / rx;
		var cm   = merge_color(c1, c2, rat);
		var iy   = sign(y1 - y0);
		
		var corn = min(corner, abs(x0 - _xc0), abs(x1 - _xc1), abs(y1 - y0) / 2);
		var cor2 = corn / sqrt(2);
			
		__line(  x0,   y0, _xc0 - corn,   y0, thick, c1, cm, __dash);
		__line(_xc0 + cor2,   y0 + cor2 * iy, _xc1 - cor2,   y1 - cor2 * iy, thick, cm, cm, __dash);
		__line(_xc1 + corn,   y1,   x1,   y1, thick, cm, c2, __dash);
			
		if(corn) {
			draw_corner(_xc0 - corn, y0, _xc0, y0, _xc0 + cor2, y0 + cor2 * iy, thick, cm, sample);
			draw_corner(_xc1 - cor2, y1 - cor2 * iy, _xc1, y1, _xc1 + corn, y1, thick, cm, sample);
		}
	}
} #endregion

function draw_line_elbow_diag_corner(x0, y0, x1, y1, _s = 1, thick = 1, col1 = c_white, col2 = c_white, corner = 0, indexIn = 1, indexOut = 1, type = LINE_STYLE.solid) { #region
	var sample = floor(corner / 8);
	sample = clamp(sample, 0, 8);
	if(sample == 0) corner = 0;
	
	var rat  = abs(x0 - x1) / (abs(x0 - x1) + abs(y0 - y1));
	var colc = merge_color(col1, col2, rat);
	
	var sx   = sign(x1 - x0);
	var sy   = sign(y1 - y0);
	var diag = min(abs(x0 - x1) / 2, abs(y0 - y1) / 2);
	corner   = min(corner, abs(x0 - x1 - diag), abs(y0 - y1 - diag));
	var cor2 = corner / sqrt(2);
	
	draw_line_width_color(                     x0,                        y0, x1 - (diag + corner) * sx,                      y0, thick, col1, colc);
	draw_line_width_color(x1 - (diag - cor2) * sx,            y0 + cor2 * sy,            x1 - cor2 * sx, y0 + (diag - cor2) * sy, thick, colc, colc);
	draw_line_width_color(                     x1, y0 + (diag + corner) * sy,                        x1,                      y1, thick, colc, col2);
	
	draw_corner(x1 - (diag + corner) * sx, y0, x1 - diag * sx, y0, x1 - (diag - cor2) * sx, y0 + cor2 * sy, thick, colc, sample);
	draw_corner(x1 - cor2 * sx, y0 + (diag - cor2) * sy, x1, y0 + diag * sy, x1, y0 + (diag + corner) * sy, thick, colc, sample);
	
	//draw_circle(x1 - diag * sx, y0, 4, false);
	//draw_circle(x1, y0 + diag * sy, 4, false);
} #endregion

function distance_to_elbow_diag(mx, my, x0, y0, x1, y1, cx, cy, _s, indexIn = 1, indexOut = 1) { #region
	var iy  = sign(y1 - y0);
	var xx0 = x0 + 16 * _s * indexIn;
	var xx1 = x1 - 16 * _s * indexOut;
	var yy0 = y0 + 16 * _s * iy;
	var yy1 = y1 - 16 * _s * iy;
		
	var vert = abs(yy1 - yy0) > abs(xx1 - xx0); 
	var inv  = vert || xx1 <= xx0;
	var _x0  = min(x0, x1);
	var _x1  = max(x0, x1);
	var _y0  = min(y0, y1);	
	var _y1  = max(y0, y1);	
	var rx   = _x1 - _x0;	
	var ry   = _y1 - _y0;
	
	var dist = 9999999;
	if(inv) {
		var ofl = cy < _y0 || cy > _y1;
		var iy  = sign(y1 - y0);
		var iy0 = sign(cy - y0);
		var iy1 = sign(y1 - cy);
		var ix  = sign(xx0 - xx1);
		var rrx = abs(xx0 - xx1);
		
		dist = min(dist, distance_to_line(mx, my, x0, y0, xx0, y0));
		dist = min(dist, distance_to_line(mx, my, xx1, y1, x1, y1));
		
		if(xx1 > xx0 && !ofl) {
			var top = abs(cy - y0) < rrx / 2;
			var bot = abs(y1 - cy) < rrx / 2;
			
			if(top) { 
				var cor = (cy - y0) * 2;
				
				dist = min(dist, distance_to_line(mx, my, xx0, y0, xx1 - cor * iy, y0));
				dist = min(dist, distance_to_line(mx, my, xx1, y0 + cor, xx1, y1));
				
				dist = min(dist, distance_to_line(mx, my, xx1 - cor * iy, y0, xx1, y0 + cor));
			} else if(bot) {
				var cor = (y1 - cy) * 2;
				
				dist = min(dist, distance_to_line(mx, my, xx0, y0, xx0, y1 - cor));
				dist = min(dist, distance_to_line(mx, my, xx0 + cor * iy, y1, xx1, y1));
				
				dist = min(dist, distance_to_line(mx, my, xx0, y1 - cor, xx0 + cor * iy, y1));
			} else {
				var cor = rrx / 2;
				dist = min(dist, distance_to_line(mx, my, xx0, y0, xx0, cy - cor * iy0));
				dist = min(dist, distance_to_line(mx, my, xx1, cy + cor * iy1, xx1, y1));
				
				dist = min(dist, distance_to_line(mx, my, xx0, cy - cor * sign(y1 - y0), xx1, cy + cor * sign(y1 - y0)));
			}
		} else { 
			var cut0 = min(abs(cy - yy0) / 2, abs(xx1 - xx0) / 2, ofl? 16 * _s : 9999);
			var cut1 = min(abs(cy - yy1) / 2, abs(xx1 - xx0) / 2, ofl? 16 * _s : 9999);
			
			var crX0 = xx0;
			var crY0 =  cy - cut0 * iy0;
			var crX1 = xx0 - cut0 * ix;
			var crY1 = cy;
			var crX2 = xx1 + cut1 * ix;
			var crY2 = cy;
			var crX3 = xx1;
			var crY3 =  cy + cut1 * iy1;
			
			dist = min(dist, distance_to_line(mx, my, x0, y0, xx0, y0));
			dist = min(dist, distance_to_line(mx, my, xx1, y1, x1, y1));
		
			if(abs(crX0 - crX3) == abs(crY0 - crY3)) {
				dist = min(dist, distance_to_line(mx, my, crX0,   y0, crX0, crY0));
				dist = min(dist, distance_to_line(mx, my, crX3,   y1, crX3, crY3));
				dist = min(dist, distance_to_line(mx, my, crX0, crY0, crX3, crY3));
			} else {
				dist = min(dist, distance_to_line(mx, my, crX0,   y0, crX0, crY0));
				dist = min(dist, distance_to_line(mx, my, crX1, crY1, crX2, crY2));
				dist = min(dist, distance_to_line(mx, my, crX3, crY3, crX3,   y1));
				
				dist = min(dist, distance_to_line(mx, my, crX0, crY0, crX1, crY1));
				dist = min(dist, distance_to_line(mx, my, crX2, crY2, crX3, crY3));
			}
		}
		return dist;
	} else { 
		cx = clamp(cx, _x0 + abs(ry) / 2, _x1 - abs(ry) / 2);
		cy = clamp(cy, _y0 + abs(rx) / 2, _y1 - abs(rx) / 2);
	
		var ry   = _y1 - _y0;
		var _xc0 = clamp(cx - (ry / 2) * sign(x1 - x0), _x0, _x1);
		var _xc1 = clamp(cx + (ry / 2) * sign(x1 - x0), _x0, _x1);
		
		dist = min(dist, distance_to_line(mx, my,   x0,   y0, _xc0,   y0));
		dist = min(dist, distance_to_line(mx, my, _xc0,   y0, _xc1,   y1));
		dist = min(dist, distance_to_line(mx, my, _xc1,   y1,   x1,   y1));
		
		return dist;
	}
} #endregion

function distance_to_elbow_diag_corner(mx, my, x0, y0, x1, y1) { #region
	var sx   = sign(x1 - x0);
	var sy   = sign(y1 - y0);
	var diag = min(abs(x0 - x1) / 2, abs(y0 - y1) / 2);
	
	var dist = 99999;
	dist = min(dist, distance_to_line(mx, my,             x0,             y0, x1 - diag * sx,             y0));
	dist = min(dist, distance_to_line(mx, my, x1 - diag * sx,             y0,             x1, y0 + diag * sy));
	dist = min(dist, distance_to_line(mx, my,             x1, y0 + diag * sy,             x1,             y1));
	
	return dist;
} #endregion