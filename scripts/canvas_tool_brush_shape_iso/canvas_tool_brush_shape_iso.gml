enum CANVAS_TOOL_SHAPE_ISO {
	cube,
}

function canvas_tool_shape_iso(_shape, _toolAttr) : canvas_tool() constructor {
	shape   = _shape;
	tool_attribute = _toolAttr;
	
	use_color_3d    = true;
	brush_resizable = true;
	mouse_holding   = 0;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_points = [ [ 0, 0 ], [ 0, 0 ], 0 ];
	
	function init() {
		mouse_points  = [ [ 0, 0 ], [ 0, 0 ], 0 ];
		mouse_holding = 0;
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		var _ang = tool_attribute.iso_angle;
		
		if(mouse_holding) {
			updated = true;
			
			surface_set_shader(drawing_surface, noone, true, BLEND.maximum);
			
					 if(_ang == 0) canvas_draw_iso_cube( brush, mouse_points, subtool);
				else if(_ang == 1) canvas_draw_diag_cube(brush, mouse_points, subtool);
				
			surface_reset_shader();
		}
		
		switch(mouse_holding) {
			case 0 :
				mouse_points[0][0] = mouse_cur_x;
				mouse_points[0][1] = mouse_cur_y;
				
				if(mouse_press(mb_left, active)) {
					mouse_points[1][0] = mouse_cur_x;
					mouse_points[1][1] = mouse_cur_y;
				
					mouse_points[2] = 0;
					
					node.tool_pick_color(mouse_cur_x, mouse_cur_y);
					mouse_holding = 1;
				}
				break;
				
			case 1 :
				if(key_mod_press(SHIFT)) {
					var x0 = mouse_points[0][0];
					var y0 = mouse_points[0][1];
						
					var _dx = mouse_cur_x - x0;
					var _dy = mouse_cur_y - y0;
					
					if(abs(_dx) > abs(_dy)) x0 = x0 + _dx;
					else y0 = y0 + _dy;
					
					mouse_points[1][0] = x0;
					mouse_points[1][1] = y0;
					
				} else {
					mouse_points[1][0] = mouse_cur_x;
					mouse_points[1][1] = mouse_cur_y;
				}
				
				if(mouse_release(mb_left))
					mouse_holding = 2;
				
				break;
				
			case 2 :
				mouse_points[2] = mouse_cur_y - mouse_points[1][1];
				
				if(mouse_press(mb_left, active)) {
					apply_draw_surface();
					mouse_holding = 0;
				}
					
				break;
		}
		
		if(key_press(vk_escape)) {
			mouse_holding = 0;
			surface_clear(drawing_surface);
		}
		
		pactive     = active;
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(mouse_holding == 0) { brush.drawPoint(mouse_cur_x, mouse_cur_y); return; }
		
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(mouse_holding == 0)  return;
		if(brush.sizing)        return;
		if(!node.attributes.show_slope_check)  return;
		
	}

	function drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {
		draw_surface_ext_safe(drawing_surface, _x, _y, _s, _s);
	}
}

function canvas_draw_iso_cube(brush, _p, _fill = false) {
	var p0x = _p[0][0], p0y = _p[0][1];
	var p1x = _p[1][0], p1y = _p[1][1];
	var ww  = p1x - p0x;
	
	var cc = draw_get_color();
	
	if(p1x < p0x) {
		var tx = p0x, ty = p0y;
		p0x = p1x; p0y = p1y;
		p1x = tx;  p1y = ty;
	}
	
	if(p1x == p0x && p1y > p0y) {
		var t = p0y;
		p0y = p1y;
		p1y = t;
	}
	
    if(p1x == p0x && p1y < p0y) p1x++;
    
	var d  = _p[2];
	var w  = p1x - p0x + 1;
	var h  = p0y - p1y;
	
	var h2 = (w + 2 * h) / 4;
	var h1 = h2 - h;
	var w1 = h1 * 2;
	
	var p0px = p0x + w1;
	var p0py = p0y + h1;
	var p1px = p1x - w1;
	var p1py = p1y - h1;
	
	var _simp = true;
	
	if(w > 0) {
		if(round(h2) < 0) {
			if(round(w1) > 0) {
				p0x = floor(p1px);
				p0y = floor(p1py);
				p1x = ceil(p0px) + 1;
				p1y = ceil(p0py);
				
				if(ww < 0) { p0x--; p1x--; }
				_simp = false;
			}
			
		} else if(round(h2) > 0) {
			if(round(w1) < 0) {
				p0x = floor(p0px);
				p0y = floor(p0py);
				p1x = ceil(p1px) + 1;
				p1y = ceil(p1py);
				
				if(frac(p0py) >= 0.5) { p0x--; }
				if(ww < 0 && frac(p0px) == 0 && frac(p0py) == 0) { p0x--; p1x--; }
				_simp = false;
				
			} else if(round(w1) > 0) {
				_simp = false;
				
			}
		}
	}
	
	if(_simp) {
		if(_fill == 2) {
			if(d == 0) {
				canvas_draw_line(p0x, p0y, p1x, p1y);
			} else {
				canvas_draw_triangle(p0x, p0y, p1x, p1y,     p1x, p1y + d, false);
				canvas_draw_triangle(p0x, p0y, p0x, p0y + d, p1x, p1y + d, false);
			}
			
		} else {
			brush.drawLine(p0x, p0y, p1x, p1y);
				
			if(d != 0) {
				brush.drawLine(p0x, p0y + d, p1x, p1y + d);
				
				brush.drawLine( p0x,  p0y,  p0x,  p0y + d);
				brush.drawLine( p1x,  p1y,  p1x,  p1y + d);
			} 
		}
	} else {
		var w  = p1x - p0x + 1;
		var h  = p0y - p1y;
		
		var h2 = (w + 2 * h) / 4;
		var h1 = h2 - h;
		var w1 = h1 * 2;
		
		var p0px = p0x + w1;
		var p0py = p0y + h1;
		var p1px = p1x - w1;
		var p1py = p1y - h1;
		
		p0py -= (abs(w) > 4);
		p1py += (abs(w) > 4);
		
		if(d > 0) {
			p0y  += d;
			p1y  += d;
			p0py += d;
			p1py += d;
			d = -d;
		}
		
		draw_set_color(cc);
		
		if(_fill == 2) {
			if(d == 0) {
				canvas_draw_line(p0x,  p0y,  p0px - 1, p0py);
				canvas_draw_line(p0px, p0py, p1x,      p1y);
				canvas_draw_line(p1x,  p1y,  p1px + 1, p1py);
				canvas_draw_line(p1px, p1py, p0x,      p0y);
				
				canvas_draw_triangle(p0x,     p0y, p0px - 1, p0py,     p1x - 1, p1y, false);
				canvas_draw_triangle(p1x - 1, p1y, p1px,     p1py - 1, p0x,     p0y, false);
				
			} else {
				
				draw_set_color(brush.colors[1]);
				canvas_draw_triangle(p0px, p0py - 1, p1x, p1y + d, p1x,  p1y - 1,  false);
				canvas_draw_triangle(p0px, p0py - 1, p1x, p1y + d, p0px, p0py + d, false);
				canvas_draw_line(p0px,     p0py + 1 + d, p1x,  p1y + 1 + d);
				canvas_draw_line(p0px,     p0py,         p1x,  p1y);
				canvas_draw_line(p1x,      p1y,          p1x,  p1y  + d);
				canvas_draw_line(p0px,     p0py - 1,     p0px, p0py + d);
     if(d < -1) canvas_draw_line(p0px,     p0py - 1,     p1x,  p1y - 1);
				
				draw_set_color(brush.colors[0]);
				canvas_draw_triangle(p0px - 1, p0py, p0x,  p0y + d, p0x,      p0y,          false);
				canvas_draw_triangle(p0px - 1, p0py, p0x,  p0y + d, p0px - 1, p0py - 1 + d, false);
				canvas_draw_line(p0x,      p0y + d, p0px - 1, p0py + d);
				canvas_draw_line(p0x,      p0y,     p0px - 1, p0py);
				canvas_draw_line(p0x,      p0y,     p0x,      p0y + d);
				canvas_draw_line(p0px - 1, p0py,    p0px - 1, p0py + d);
				
				draw_set_color(cc);
				canvas_draw_triangle(p0x,     p0y + d, p0px - 1, p0py + d,     p1x - 1, p1y + d, false);
				canvas_draw_triangle(p1x - 1, p1y + d, p1px,     p1py + d - 1, p0x,     p0y + d, false);
				canvas_draw_line(p0x,  p0y  + d, p0px - 1, p0py + d);
				canvas_draw_line(p0px, p0py + d, p1x,      p1y  + d);
				canvas_draw_line(p1x,  p1y  + d, p1px + 1, p1py + d);
				canvas_draw_line(p1px, p1py + d, p0x,      p0y  + d);
				
			}
			
		} else {
			brush.drawLine(p0x,  p0y,  p0px - 1, p0py);
			brush.drawLine(p0px, p0py, p1x,      p1y);
			
			if(_fill == 1) {
				brush.drawLine(p1x,  p1y,  p1px + 1, p1py);
				brush.drawLine(p1px, p1py, p0x,      p0y);
			}
			
			if(d != 0) {
				brush.drawLine(p0x,  p0y  + d, p0px - 1, p0py + d);
				brush.drawLine(p0px, p0py + d, p1x,      p1y  + d);
				brush.drawLine(p1x,  p1y  + d, p1px + 1, p1py + d);
				brush.drawLine(p1px, p1py + d, p0x,      p0y  + d);
				
				brush.drawLine(p0x,      p0y,  p0x,      p0y + d);
				brush.drawLine(p1x,      p1y,  p1x,      p1y + d);
				brush.drawLine(p0px - 1, p0py, p0px - 1, p0py + d);
				
				if(_fill == 1)
					brush.drawLine(p1px, p1py - 1, p1px, p1py + d);
				
			} else if(_fill == 0) {
				brush.drawLine(p1x,  p1y,  p1px + 1, p1py);
				brush.drawLine(p1px, p1py, p0x,      p0y);
			}
		}
	}
}

function canvas_draw_diag_cube(brush, _p, _fill = false) {
	var p0x = _p[0][0], p0y = _p[0][1];
	var p1x = _p[1][0], p1y = _p[1][1];
	var ww  = p1x - p0x;
	
	var cc = draw_get_color();
	
	if(p1x < p0x) {
		var tx = p0x, ty = p0y;
		p0x = p1x; p0y = p1y;
		p1x = tx;  p1y = ty;
	}
	
	if(p1x == p0x && p1y > p0y) {
		var t = p0y;
		p0y = p1y;
		p1y = t;
	}
	
    if(p1x == p0x && p1y < p0y) p1x++;
    
	var d  = _p[2];
	var w  = p1x - p0x + 1;
	var h  = p0y - p1y;
	
	var h1 = (w - h) / 2;
	var h2 = h1 + h;
	var w1 = h1;
	
	var p0px = p0x + w1;
	var p0py = p0y + h1;
	var p1px = p1x - w1;
	var p1py = p1y - h1;
	
	var _simp = true;
	
	if(w > 0) {
		
		if(round(h2) < 0) {
			if(round(w1) > 0) {
				
				p0x = floor(p1px);
				p0y = floor(p1py);
				p1x = ceil(p0px) + 1;
				p1y = ceil(p0py);
				
				if(ww < 0) { p0x--; p1x--; }
				_simp = false;
			}
			
		} else if(round(h2) > 0) {
			if(round(w1) < 0) {
				
				p0x = floor(p0px);
				p0y = floor(p0py);
				p1x = ceil(p1px) + 1;
				p1y = ceil(p1py);
				
				if(frac(p0py) >= 0.5) { p0x--; }
				if(ww < 0 && frac(p0px) == 0 && frac(p0py) == 0) { p0x--; p1x--; }
				_simp = false;
				
			} else if(round(w1) > 0) {
				_simp = false;
				
			}
		}
	}
	
	if(_simp) {
		if(_fill == 2) {
			if(d == 0) {
				canvas_draw_line(p0x, p0y, p1x, p1y);
			} else {
				canvas_draw_triangle(p0x, p0y, p1x, p1y,     p1x, p1y + d, false);
				canvas_draw_triangle(p0x, p0y, p0x, p0y + d, p1x, p1y + d, false);
			}
			
		} else {
			brush.drawLine(p0x, p0y, p1x, p1y);
				
			if(d != 0) {
				brush.drawLine(p0x, p0y + d, p1x, p1y + d);
				
				brush.drawLine( p0x,  p0y,  p0x,  p0y + d);
				brush.drawLine( p1x,  p1y,  p1x,  p1y + d);
			} 
		}
	} else {
		var w  = p1x - p0x + 1;
		var h  = p0y - p1y;
		
		var h1 = (w - h) / 2;
		var h2 = h1 + h;
		var w1 = h1;
		
		var p0px = p0x + w1;
		var p0py = p0y + h1;
		var p1px = p1x - w1;
		var p1py = p1y - h1;
		
		p0py -= (abs(w) > 4);
		p1py += (abs(w) > 4);
		
		if(d > 0) {
			p0y  += d;
			p1y  += d;
			p0py += d;
			p1py += d;
			d = -d;
		}
		
		draw_set_color(cc);
		
		if(_fill == 2) {
			if(d == 0) {
				canvas_draw_line(p0x,  p0y,  p0px - 1, p0py);
				canvas_draw_line(p0px, p0py, p1x,      p1y);
				canvas_draw_line(p1x,  p1y,  p1px + 1, p1py);
				canvas_draw_line(p1px, p1py, p0x,      p0y);
				
				canvas_draw_triangle(p0x,     p0y, p0px - 1, p0py,     p1x - 1, p1y, false);
				canvas_draw_triangle(p1x - 1, p1y, p1px,     p1py - 1, p0x,     p0y, false);
				
			} else {
				
				draw_set_color(brush.colors[1]);
				canvas_draw_triangle(p0px, p0py - 1, p1x, p1y + d, p1x,  p1y,      false);
				canvas_draw_triangle(p0px, p0py - 1, p1x, p1y + d, p0px, p0py + d, false);
				canvas_draw_line(p0px,     p0py + 1 + d, p1x,  p1y + 1 + d);
				canvas_draw_line(p0px,     p0py,         p1x,  p1y);
				canvas_draw_line(p0px,     p0py - 1,     p0px, p0py + d);
     if(d < -1) canvas_draw_line(p0px,     p0py - 1,     p1x,  p1y - 1);
				
				draw_set_color(brush.colors[0]);
				canvas_draw_triangle(p0px - 1, p0py, p0x,  p0y + d, p0x,      p0y,          false);
				canvas_draw_triangle(p0px - 1, p0py, p0x,  p0y + d, p0px - 1, p0py - 1 + d, false);
				canvas_draw_line(p0x,      p0y + d, p0px - 1, p0py + d);
				canvas_draw_line(p0x,      p0y,     p0px - 1, p0py);
				canvas_draw_line(p0x,      p0y,     p0x,      p0y + d);
				canvas_draw_line(p0px - 1, p0py,    p0px - 1, p0py + d);
				
				draw_set_color(cc);
				canvas_draw_triangle(p0x,     p0y + d, p0px - 1, p0py + d,     p1x - 1, p1y + d, false);
				canvas_draw_triangle(p1x - 1, p1y + d, p1px,     p1py + d - 1, p0x,     p0y + d, false);
				
				canvas_draw_line(p0x,  p0y  + d, p0px - 1, p0py + d);
				canvas_draw_line(p0px, p0py + d, p1x,      p1y  + d);
				canvas_draw_line(p1x,  p1y  + d, p1px + 1, p1py + d);
				canvas_draw_line(p1px, p1py + d, p0x,      p0y  + d);
				
			}
			
		} else {
			brush.drawLine(p0x,  p0y,  p0px - 1, p0py);
			brush.drawLine(p0px, p0py, p1x,      p1y);
			
			if(_fill == 1) {
				brush.drawLine(p1x,  p1y,  p1px + 1, p1py);
				brush.drawLine(p1px, p1py, p0x,      p0y);
			}
			
			if(d != 0) {
				brush.drawLine(p0x,  p0y  + d, p0px - 1, p0py + d);
				brush.drawLine(p0px, p0py + d, p1x,      p1y  + d);
				brush.drawLine(p1x,  p1y  + d, p1px + 1, p1py + d);
				brush.drawLine(p1px, p1py + d, p0x,      p0y  + d);
				
				brush.drawLine(p0x,      p0y,  p0x,      p0y + d);
				brush.drawLine(p1x,      p1y,  p1x,      p1y + d);
				brush.drawLine(p0px - 1, p0py, p0px - 1, p0py + d);
				
				if(_fill == 1)
					brush.drawLine(p1px, p1py, p1px, p1py + d);
				
			} else if(_fill == 0) {
				brush.drawLine(p1x,  p1y,  p1px + 1, p1py);
				brush.drawLine(p1px, p1py, p0x,      p0y);
			}
		}
	}
}