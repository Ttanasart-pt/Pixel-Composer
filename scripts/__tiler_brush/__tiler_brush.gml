function tiler_brush(node) constructor {
    brush_size    = 1;
    brush_indices = [[]];
    brush_width   = 0;
    brush_height  = 0;
    brush_surface = noone;
    brush_erase   = false;
	autoterrain   = noone;
    
    brush_sizing    = false;
	brush_sizing_s  = 0;
	brush_sizing_mx = 0;
	brush_sizing_my = 0;
	brush_sizing_dx = 0;
	brush_sizing_dy = 0;
	
	self.node = node;
	
	function step(hover, active, _x, _y, _s, _mx, _my) {
		var attr = node.tool_attribute;
		var _siz = attr.size;
		
		brush_size = _siz;
		
		if(brush_size = PEN_USE && attr.pressure)
			brush_size = round(lerp(attr.pressure_size[0], attr.pressure_size[1], power(PEN_PRESSURE / 1024, 2)));
	}
	
	function sizing(hover, active, _x, _y, _s, _mx, _my) {
		var attr = node.tool_attribute;
		var _siz = attr.size;
		
		if(brush_sizing) {
			var s = brush_sizing_s + (_mx - brush_sizing_mx) / 16;
				s = max(1, s);
			attr.size = s;
			
			if(mouse_release(mb_right)) 
				brush_sizing = false;
					
		} else if(mouse_press(mb_right, active) && key_mod_press(SHIFT) && brush_surface == noone) {
				
			brush_sizing    = true;
			brush_sizing_s  = _siz;
			brush_sizing_mx = _mx;
			brush_sizing_my = _my;
			
			brush_sizing_dx = round((_mx - _x) / _s - 0.5);
			brush_sizing_dy = round((_my - _y) / _s - 0.5);
		}
	}
}

function tiler_draw_point_brush(brush, _x, _y, _shader = true) {
	if(brush.brush_height * brush.brush_width == 0) return;
	
	var _siz = brush.brush_size;
	var _bw  = brush.brush_width;
	var _bh  = brush.brush_height;
	var _er  = brush.brush_erase;
	var _b, _xx, _yy;
	
	if(_siz <= 0 || _siz >= global.FIX_POINTS_AMOUNT) return;
	
	if(_shader) { shader_set(sh_draw_tile_brush); BLEND_OVERRIDE }
	
	if(_er) {
		shader_set_f("index",   -1);
		shader_set_f("varient",  0);
	}
	    	
	if(_siz == 1) {
		for( var i = 0, n = _bh; i < n; i++ ) 
		for( var j = 0, m = _bw; j < m; j++ ) {
			_b = brush.brush_indices[i][j];
			
			if(!_er) {
				shader_set_f("index",   _b[0]);
		    	shader_set_f("varient", _b[1]);
			}
			
	    	_xx = _x + j;
	    	_yy = _y + i;
	    	draw_point(_xx, _yy);
		}
		
	} else {
		var fx = global.FIX_POINTS[_siz];
		
		for( var k = 0, o = array_length(fx); k < o; k++ ) {
			var dx = fx[k][0] * _bw;
			var dy = fx[k][1] * _bh;
			
			for( var i = 0, n = _bh; i < n; i++ ) 
			for( var j = 0, m = _bw; j < m; j++ ) {
				_b = brush.brush_indices[i][j];
				
				if(!_er) {
					shader_set_f("index",   _b[0]);
			    	shader_set_f("varient", _b[1]);
				}
				
		    	_xx = _x + j;
		    	_yy = _y + i;
	    		draw_point(dx + _xx, dy + _yy);
			}
		}
	}
	
	if(_shader) { BLEND_NORMAL shader_reset(); }
}

function tiler_draw_line_brush(brush, _x0, _y0, _x1, _y1, _shader = true) { 
	if(brush.brush_height * brush.brush_width == 0) return;
	
	var _siz = brush.brush_size;
	var _bw  = brush.brush_width;
	var _bh  = brush.brush_height;
	var _er  = brush.brush_erase;
	
	if(_shader) { shader_set(sh_draw_tile_brush); BLEND_OVERRIDE }
	
	if(_er) {
		shader_set_f("index",   -1);
		shader_set_f("varient",  0);
	}
	
	var _dx   = _x1 - _x0;
	var _dy   = _y1 - _y0;
	var _axis = abs(_dx) > abs(_dy);
	var _lenM = _axis? _dx : _dy;
	var _lenS = _axis? _dy : _dx;
	var _blM  = _axis? _bw : _bh;
	
	var _rep  = floor(abs(_lenM / _blM)) + 1;
	
	if(_rep == 1) {
		tiler_draw_point_brush(brush, _x0, _y0, false);
			
	} else {
		var _bx   = _x0, _brx;
		var _by   = _y0, _bry;
		var _bsx  = _axis? _bw * sign(_dx) : _lenS / (_rep - 1);
		var _bsy  = _axis? _lenS / (_rep - 1) : _bh * sign(_dy);
		
		var _ox = _x0 % _bw;
		var _oy = _y0 % _bh;
		
		var r = 0;
		repeat(_rep) {
			_brx = floor(_bx / _bw) * _bw + _ox;
			_bry = floor(_by / _bh) * _bh + _oy;
			
			tiler_draw_point_brush(brush, _brx, _bry, false);
			
			_bx += _bsx;
			_by += _bsy;
		}
	}
	
	if(_shader) { BLEND_NORMAL shader_reset(); }
}

function tiler_draw_rect_brush(brush, _x0, _y0, _x1, _y1, _fill, _shader = true) {
	if(brush.brush_height * brush.brush_width == 0) return;
	
	if(_x0 == _x1 && _y0 == _y1) {
		tiler_draw_point_brush(brush, _x0, _y0, _shader);
		return;
		
	} else if(_x0 == _x1) {
		tiler_draw_point_brush(brush, _x0, _y0, _shader);
		tiler_draw_point_brush(brush, _x1, _y1, _shader);
		tiler_draw_line_brush(brush, _x0, _y0, _x0, _y1, _shader);
		return;
		
	} else if(_y0 == _y1) {
		tiler_draw_point_brush(brush, _x0, _y0, _shader);
		tiler_draw_point_brush(brush, _x1, _y1, _shader);
		tiler_draw_line_brush(brush, _x0, _y0, _x1, _y0, _shader);
		return;
	}
		
	var _min_x = min(_x0, _x1);
	var _max_x = max(_x0, _x1);
	var _min_y = min(_y0, _y1);
	var _max_y = max(_y0, _y1);
	
	var _bw  = brush.brush_width;
	var _bh  = brush.brush_height;
	var _er  = brush.brush_erase;
	
	if(_fill) {
		if(_shader) { shader_set(sh_draw_tile_brush); BLEND_OVERRIDE }
			
		if(_er) {
			shader_set_f("index",   -1);
			shader_set_f("varient",  0);
		}
		
		for(var _y = _min_y; _y <= _max_y; _y++)
		for(var _x = _min_x; _x <= _max_x; _x++) {
			var _b = brush.brush_indices[(_y - _min_y) % _bh][(_x - _min_x) % _bw];
			
			if(!_er) {
				shader_set_f("index",   _b[0]);
		    	shader_set_f("varient", _b[1]);
			}
			
			draw_point(_x, _y);
		}
		
		if(_shader) { BLEND_NORMAL shader_reset(); }
		
	} else {
		if(brush.brush_size == 1) {
			if(_shader) { shader_set(sh_draw_tile_brush); BLEND_OVERRIDE }
			
			var _b = brush.brush_indices[0][0];
			
			shader_set_f("index",   brush.brush_erase? -1 : _b[0]);
	    	shader_set_f("varient", brush.brush_erase?  0 : _b[1]);
			
			draw_rectangle(_min_x + 1, _min_y + 1, _max_x - 1, _max_y - 1, 1);
			if(_shader) { BLEND_NORMAL shader_reset(); }
			
		} else {
			tiler_draw_line_brush(brush, _min_x, _min_y, _max_x, _min_y, _shader);
			tiler_draw_line_brush(brush, _min_x, _min_y, _min_x, _max_y, _shader);
			tiler_draw_line_brush(brush, _max_x, _max_y, _max_x, _min_y, _shader);
			tiler_draw_line_brush(brush, _max_x, _max_y, _min_x, _max_y, _shader);
		}
	}
}
	
function tiler_draw_ellp_brush(brush, _x0, _y0, _x1, _y1, _fill, _shader = true) {
	if(brush.brush_height * brush.brush_width == 0) return;
	
	if(_x0 == _x1 && _y0 == _y1) {
		tiler_draw_point_brush(brush, _x0, _y0, _shader);
		return;
		
	} else if(_x0 == _x1) {
		tiler_draw_point_brush(brush, _x0, _y0, _shader);
		tiler_draw_point_brush(brush, _x1, _y1, _shader);
		tiler_draw_line_brush(brush, _x0, _y0, _x0, _y1, _shader);
		return;
		
	} else if(_y0 == _y1) {
		tiler_draw_point_brush(brush, _x0, _y0, _shader);
		tiler_draw_point_brush(brush, _x1, _y1, _shader);
		tiler_draw_line_brush(brush, _x0, _y0, _x1, _y0, _shader);
		return;
	}
		
	draw_set_circle_precision(64);
	var _min_x = min(_x0, _x1) - 0.5;
	var _max_x = max(_x0, _x1) - 0.5;
	var _min_y = min(_y0, _y1) - 0.5;
	var _max_y = max(_y0, _y1) - 0.5;
	var _cx = (_min_x + _max_x) / 2;
	var _cy = (_min_y + _max_y) / 2;
	var _dx = abs(_min_x - _max_x) / 2;
	var _dy = abs(_min_y - _max_y) / 2;
	
	var _bw  = brush.brush_width;
	var _bh  = brush.brush_height;
	var _er  = brush.brush_erase;
	
	if(_shader) { shader_set(sh_draw_tile_brush); BLEND_OVERRIDE }
	var _b = brush.brush_indices[0][0];

	if(_fill) {
		if(_er) {
			shader_set_f("index",   -1);
			shader_set_f("varient",  0);
		}
		
		for(var _y = _min_y; _y <= _max_y; _y++)
		for(var _x = _min_x; _x <= _max_x; _x++) {
			var _nx = (_x - _cx) / _dx;
			var _ny = (_y - _cy) / _dy;
			var _d  = _nx * _nx + _ny * _ny;
			if(_d > 1) continue;
			
			var _b = brush.brush_indices[(_y - _min_y) % _bh][(_x - _min_x) % _bw];
			
			if(!_er) {
				shader_set_f("index",   _b[0]);
		    	shader_set_f("varient", _b[1]);
			}
			
			draw_point(_x, _y);
		}
		
	} else {
		
		shader_set_f("index",   brush.brush_erase? -1 : _b[0]);
		shader_set_f("varient", brush.brush_erase?  0 : _b[1]);
		
		if(brush.brush_size == 1) {
			draw_ellipse(_min_x, _min_y, _max_x, _max_y, 1);
			
		} else if(brush.brush_size < global.FIX_POINTS_AMOUNT) {
			
			var fx = global.FIX_POINTS[brush.brush_size];
			for( var i = 0, n = array_length(fx); i < n; i++ )
				draw_ellipse(_min_x + fx[i][0], _min_y + fx[i][1], _max_x + fx[i][0], _max_y + fx[i][1], 1);
			
		} else {
			draw_ellipse(_min_x, _min_y, _max_x, _max_y, brush.brush_size);
		}
	}
	
	if(_shader) { BLEND_NORMAL shader_reset(); }
}