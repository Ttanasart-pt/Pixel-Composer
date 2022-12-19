function Node_Canvas(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name	= "Canvas";
	color	= COLORS.node_blend_canvas;
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black );
	inputs[| 2] = nodeValue(2, "Brush size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 3] = nodeValue(3, "Fill threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 4] = nodeValue(4, "Fill type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["4 connect", "8 connect", "Entire canvas"]);
	
	inputs[| 5] = nodeValue(5, "Draw preview overlay", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 6] = nodeValue(6, "Brush", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1);
	
	inputs[| 7] = nodeValue(7, "Surface amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 1] = nodeValue(1, "Preview", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 
		["Output",	false],	0, 
		["Brush",	false], 6, 1, 2, 
		["Fill",	false], 3, 4, 
		["Preview", false], 5 
	];
	
	surface_buffer = buffer_create(1 * 1 * 4, buffer_fixed, 2);
	
	tools = [
		[ "Pencil",		THEME.canvas_tools_pencil ],
		[ "Eraser",		THEME.canvas_tools_eraser ],
		[ "Rectangle",	[ THEME.canvas_tools_rect, THEME.canvas_tools_rect_fill ]],
		[ "Ellipse",	[ THEME.canvas_tools_ellip, THEME.canvas_tools_ellip_fill ]],
		[ "Fill",		THEME.canvas_tools_bucket ],
	];
	
	display_reset(0, 1);
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = 0;
	mouse_pre_draw_y = 0;
	
	mouse_holding = false;
	
	draw_stack  = ds_list_create();
	
	function surface_update() {
		var _surf = outputs[| 0].getValue();
		buffer_get_surface(surface_buffer, _surf, 0);
		triggerRender();
	}
	
	function draw_point_size(_x, _y, _siz, _brush) {
		if(!is_surface(_brush)) {
			if(_siz <= 1) 
				draw_point(_x, _y);
			else if(_siz == 2) { 
				draw_point(_x, _y);
				draw_point(_x + 1, _y);
				draw_point(_x,     _y + 1);
				draw_point(_x + 1, _y + 1);
			} else if(_siz == 3) { 
				draw_point(_x, _y);	
				draw_point(_x - 1, _y);	
				draw_point(_x,     _y - 1);	
				draw_point(_x + 1, _y);	
				draw_point(_x,     _y + 1);	
			} else
				draw_circle(_x, _y, _siz / 2, 0);
		} else {
			var _sw = surface_get_width(_brush);
			var _sh = surface_get_height(_brush);
			
			draw_surface_ext(_brush, _x - _sw / 2, _y - _sh / 2, 1, 1, 0, draw_get_color(), 1);
		}
	}
	
	function draw_line_size(_x0, _y0, _x1, _y1, _siz, _brush) {
		if(_siz == 1 && _brush == -1) 
			draw_line(_x0, _y0, _x1, _y1);
		else {
			var diss  = floor(point_distance(_x0, _y0, _x1, _y1));
			var dirr  = point_direction(_x0, _y0, _x1, _y1);
			var st_x  = lengthdir_x(1, dirr);
			var st_y  = lengthdir_y(1, dirr);
			
			for( var i = 0; i <= diss; i++ ) {
				var _x = _x0 + st_x * i;
				var _y = _y0 + st_y * i;
				
				draw_point_size(_x, _y, _siz, _brush);
			}
		}
	}
	
	function draw_rect_size(_x0, _y0, _x1, _y1, _siz, _fill, _brush) {
		if(_x0 == _x1 && _y0 == _y1) {
			draw_point_size(_x0, _y0, _siz, _brush);
			return;
		} else if(_x0 == _x1) {
			draw_point_size(_x0, _y0, _siz, _brush);
			draw_point_size(_x1, _y1, _siz, _brush);
			draw_line_size(_x0, _y0, _x0, _y1, _siz, _brush);
			return;
		} else if(_y0 == _y1) {
			draw_point_size(_x0, _y0, _siz, _brush);
			draw_point_size(_x1, _y1, _siz, _brush);
			draw_line_size(_x0, _y0, _x1, _y0, _siz, _brush);
			return;
		}
		
		var _min_x = min(_x0, _x1);
		var _max_x = max(_x0, _x1);
		var _min_y = min(_y0, _y1);
		var _may_y = max(_y0, _y1);
		
		if(_fill) {
			draw_rectangle(_min_x, _min_y, _max_x, _may_y, 0);
		} else if(_siz == 1 && _brush == -1)
			draw_rectangle(_min_x + 1, _min_y + 1, _max_x - 1, _may_y - 1, 1);
		else {
			draw_line_size(_min_x, _min_y, _max_x, _min_y, _siz, _brush);
			draw_line_size(_min_x, _min_y, _min_x, _may_y, _siz, _brush);
			draw_line_size(_max_x, _may_y, _max_x, _min_y, _siz, _brush);
			draw_line_size(_max_x, _may_y, _min_x, _may_y, _siz, _brush);
		}
	}
	
	function draw_ellp_size(_x0, _y0, _x1, _y1, _siz, _fill, _brush) {
		if(_x0 == _x1 && _y0 == _y1) {
			draw_point_size(_x0, _y0, _siz, _brush);	
			return;
		} else if(_x0 == _x1) {
			draw_point_size(_x0, _y0, _siz, _brush);
			draw_point_size(_x1, _y1, _siz, _brush);
			draw_line_size(_x0, _y0, _x0, _y1, _siz, _brush);
			return;
		} else if(_y0 == _y1) {
			draw_point_size(_x0, _y0, _siz, _brush);
			draw_point_size(_x1, _y1, _siz, _brush);
			draw_line_size(_x0, _y0, _x1, _y0, _siz, _brush);
			return;
		}
		
		var _min_x = min(_x0, _x1) - 1;
		var _max_x = max(_x0, _x1);
		var _min_y = min(_y0, _y1) - 1;
		var _max_y = max(_y0, _y1);
		
		if(_fill) {
			draw_ellipse(_min_x, _min_y, _max_x, _max_y, 0);
		} else {
			var samp = 64;
			var cx = (_min_x + _max_x) / 2;
			var cy = (_min_y + _max_y) / 2;
			var rx = abs(_x0 - _x1) / 2;
			var ry = abs(_y0 - _y1) / 2;
			
			var ox, oy, nx, ny;
			for( var i = 0; i <= samp; i++ ) {
				nx = cx + lengthdir_x(rx, 360 / samp * i);
				ny = cy + lengthdir_y(ry, 360 / samp * i);
				
				if(i) draw_line_size(ox, oy, nx, ny, _siz, _brush);
				
				ox = nx;
				oy = ny;
			}
		}
	}
	
	function color_diff(c1, c2) {
		var _c1_r =  c1 & 255;
		var _c1_g = (c1 >> 8) & 255;
		var _c1_b = (c1 >> 16) & 255;
		var _c1_a = (c1 >> 24) & 255;
		
		var _c2_r =  c2 & 255;
		var _c2_g = (c2 >> 8) & 255;
		var _c2_b = (c2 >> 16) & 255;
		var _c2_a = (c2 >> 24) & 255;
		
		var dist = sqrt(
			sqr(_c1_r - _c2_r) + 
			sqr(_c1_g - _c2_g) + 
			sqr(_c1_b - _c2_b) + 
			sqr(_c1_a - _c2_a)
		);
		
		return dist / 510;
	}
	
	function get_color_buffer(_x, _y, w, h) {
		buffer_seek(surface_buffer, buffer_seek_start, (w * _y + _x) * 4);
		var c = buffer_read(surface_buffer, buffer_u32);
		
		return c;
	}
	
	function flood_fill_scanline(_x, _y, _surf, _thres, _corner = false) {
		var w = surface_get_width(_surf);
		var h = surface_get_height(_surf);
		
		var _c0 = draw_get_color() + (255 << 24);
		var _c1 = get_color_buffer(_x, _y, w, h);
		if(color_diff(_c0, _c1) <= _thres) return;
		
		var x1, y1, x_start;
		var spanAbove, spanBelow;

		var stack = ds_stack_create();
		ds_stack_push(stack, [_x, _y]);
		while(!ds_stack_empty(stack)) {
			var pos = ds_stack_pop(stack);
			x1 = pos[0];
			y1 = pos[1];
			
			while(x1 >= 0 && color_diff(_c1, get_color_buffer(x1, y1, w, h)) <= _thres) {
				x1--;
			}
			
			x1++;
			x_start = x1;
			
			spanAbove = 0;
			spanBelow = 0;
			
			while(x1 < w && color_diff(_c1, get_color_buffer(x1, y1, w, h)) <= _thres) {
				draw_point(x1, y1);
				buffer_seek(surface_buffer, buffer_seek_start, (w * y1 + x1) * 4);
				buffer_write(surface_buffer, buffer_u32, _c0);
			    
				if(y1 > 0) {
					if(x1 == x_start && x1 > 0 && _corner) {
						var _delta = color_diff(_c1, get_color_buffer(x1 - 1, y1 - 1, w, h));
						if(!spanAbove && _delta <= _thres) {
							ds_stack_push(stack, [x1 - 1, y1 - 1]);
						    spanAbove = 1;
					    } else if(spanAbove && _delta > _thres) {
							spanAbove = 0;
					    }
					}
					
					var _delta = color_diff(_c1, get_color_buffer(x1, y1 - 1, w, h));
					if(!spanAbove && _delta <= _thres) {
						ds_stack_push(stack, [x1, y1 - 1]);
					    spanAbove = 1;
				    } else if(spanAbove && _delta > _thres) {
						spanAbove = 0;
				    }
				}
				
				if(y1 < h - 1) {
					if(x1 == x_start && x1 > 0 && _corner) {
						var _delta = color_diff(_c1, get_color_buffer(x1 - 1, y1 + 1, w, h));
						if(!spanBelow && _delta <= _thres) {
							ds_stack_push(stack, [x1 - 1, y1 + 1]);
						    spanBelow = 1;
					    } else if(spanBelow && _delta > _thres) {
							spanBelow = 0;
					    }
					}
					
					var _delta = color_diff(_c1, get_color_buffer(x1, y1 + 1, w, h));
					if(!spanBelow && _delta <= _thres) {
					    ds_stack_push(stack, [x1, y1 + 1]);
					    spanBelow = 1;
				    } else if(spanBelow && _delta > _thres) {
						spanBelow = 0;
				    }
				}
			    x1++;
			}
			
			if(x1 < w - 1 && _corner) {
				var _delta = color_diff(_c1, get_color_buffer(x1, y1 - 1, w, h));
				if(!spanAbove && _delta <= _thres) {
					ds_stack_push(stack, [x1, y1 - 1]);
					spanAbove = 1;
				} else if(spanAbove && _delta > _thres) {
					spanAbove = 0;
				}
				
				var _delta = color_diff(_c1, get_color_buffer(x1, y1 + 1, w, h));
				if(!spanBelow && _delta <= _thres) {
					ds_stack_push(stack, [x1, y1 + 1]);
					spanBelow = 1;
				} else if(spanBelow && _delta > _thres) {
					spanBelow = 0;
				}
			}
		}	
	}
	
	function canvas_fill(_x, _y, _surf, _thres) {
		var w = surface_get_width(_surf);
		var h = surface_get_height(_surf);
		
		var _c1 = get_color_buffer(_x, _y, w, h);
		
		for( var i = 0; i < w; i++ ) {
			for( var j = 0; j < h; j++ ) {
				if(i == _x && j == _y) {
					draw_point(i, j);
					continue;
				}
				
				var _c2 = get_color_buffer(i, j, w, h);
				if(color_diff(_c1, _c2) <= _thres)
					draw_point(i, j);
			}
		}	
		
		surface_update();
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!active) return;
		if(keyboard_check(vk_alt)) return;
		
		var _col		= inputs[| 1].getValue();
		var _siz		= inputs[| 2].getValue();
		var _thr		= inputs[| 3].getValue();
		var _fill_type	= inputs[| 4].getValue();
		var _prev		= inputs[| 5].getValue();
		var _brush		= inputs[| 6].getValue();
		
		var _surf		= outputs[| 0].getValue();
		var _surf_prev	= outputs[| 1].getValue();
		var _surf_w		= surface_get_width(_surf);
		var _surf_h		= surface_get_height(_surf);
		
		if(!surface_exists(_surf)) return;
		if(!surface_exists(_surf_prev)) return;
		
		surface_set_target(_surf);
		draw_set_color(_col);
		
		var _tool = PANEL_PREVIEW.tool_index;
		var _sub_tool = PANEL_PREVIEW.tool_sub_index;
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(_tool == 0 || _tool == 1) {
			if(_tool == 1) gpu_set_blendmode(bm_subtract);
			
			if(keyboard_check(vk_shift) && keyboard_check(vk_control)) {
				var aa = point_direction(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
				var dd = point_distance(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
				var _a = round(aa / 45) * 45;
				dd = dd * cos(degtorad(_a - aa));
				
				mouse_cur_x = mouse_pre_draw_x + lengthdir_x(dd, _a);
				mouse_cur_y = mouse_pre_draw_y + lengthdir_y(dd, _a);
			}
			
			if(mouse_press(mb_left)) {
				draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
				
				mouse_holding = true;
				if(keyboard_check(vk_shift)) {
					draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
					mouse_holding = false;
				}
				
				mouse_pre_draw_x = mouse_cur_x;
				mouse_pre_draw_y = mouse_cur_y;	
			}
			
			if(mouse_holding && mouse_click(mb_left, active)) {
				draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
				draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
				
				mouse_pre_draw_x = mouse_cur_x;
				mouse_pre_draw_y = mouse_cur_y;	
			}
			
			if(_tool == 1) gpu_set_blendmode(bm_normal);
			
			if(mouse_release(mb_left)) {
				surface_update();
				mouse_holding = false;
			}
				
			mouse_pre_x = mouse_cur_x;
			mouse_pre_y = mouse_cur_y;
		
		} else if(_tool == 2 || _tool == 3) {
			if(mouse_holding && keyboard_check(vk_shift)) {
				var ww = mouse_cur_x - mouse_pre_x;
				var hh = mouse_cur_y - mouse_pre_y;
				var ss = max(abs(ww), abs(hh));
				
				mouse_cur_x = mouse_pre_x + ss * sign(ww);
				mouse_cur_y = mouse_pre_y + ss * sign(hh);
			}
			
			if(mouse_press(mb_left)) {
				mouse_pre_x = mouse_cur_x;
				mouse_pre_y = mouse_cur_y;
				
				mouse_holding = true;
			}
			
			if(mouse_release(mb_left)) {
				if(_tool == 2) {
					draw_rect_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, _sub_tool, _brush);
				} else if(_tool == 3) {
					draw_ellp_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, _sub_tool, _brush);
				} 
				
				surface_update();
				mouse_holding = false;
			}
		} else if(_tool == 4) {
			if(point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, _surf_w - 1, _surf_h - 1) && mouse_press(mb_left)) {
				switch(_fill_type) {
					case 0 :	
						flood_fill_scanline(mouse_cur_x, mouse_cur_y, _surf, _thr, false);
						break;
					case 1 :	
						flood_fill_scanline(mouse_cur_x, mouse_cur_y, _surf, _thr, true);
						break;
					case 2 :	
						canvas_fill(mouse_cur_x, mouse_cur_y, _surf, _thr);
						break;
				}
				
				surface_update();
			}
		}
		
		surface_reset_target();
		
		surface_set_target(_surf_prev);
		draw_clear_alpha(0, 0);
		draw_surface_safe(_surf, 0, 0);
		
		draw_set_color(_col);
		
		if(_tool == 0 || _tool == 1) {
			if(_tool == 1) gpu_set_blendmode(bm_subtract);
			
			if(keyboard_check(vk_shift))
				draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
			else 
				draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
				
			if(_tool == 1) gpu_set_blendmode(bm_normal);
		} else if (_tool == 2 || _tool == 3) {
			if(mouse_holding) {
				if(_tool == 2)
					draw_rect_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, _sub_tool, _brush);
				else if(_tool == 3)
					draw_ellp_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, _sub_tool, _brush); 
			}
		}
		
		surface_reset_target();
		
		#region preview
			if(_prev) draw_surface_ext(_surf_prev, _x, _y, _s, _s, 0, c_white, 1);
			
			if (_tool == 2 || _tool == 3) {
				if(mouse_holding) {
					var _pr_x = _x + mouse_pre_x * _s;
					var _pr_y = _y + mouse_pre_y * _s;
					var _cr_x = _x + mouse_cur_x * _s;
					var _cr_y = _y + mouse_cur_y * _s;
				
					//draw_set_color(c_red);
					//draw_rectangle(_pr_x, _pr_y, _cr_x, _cr_y, 1);
				}
			}
			
			if(_tool > -1 && point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, _surf_w - 1, _surf_h - 1)) {
				var _pr_x = _x + mouse_cur_x * _s;
				var _pr_y = _y + mouse_cur_y * _s;
				
				draw_set_color(c_white);
				draw_rectangle(_pr_x, _pr_y, _pr_x + _s - 1, _pr_y + _s - 1, 1);
			}
		#endregion
	}
	
	static update = function() {
		var _dim   = inputs[| 0].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
			
			buffer_set_surface(surface_buffer, _outSurf, 0);
		} else {
			if(surface_size_to(_outSurf, _dim[0], _dim[1])) {
				buffer_delete(surface_buffer);
				surface_buffer = -1;
				surface_buffer = buffer_create(surface_get_width(_outSurf) * surface_get_height(_outSurf) * 4, buffer_fixed, 2);
			}
		}
		
		var _outSurf = outputs[| 1].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
			outputs[| 1].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
	}
	doUpdate();
	
	static doSerialize = function(_map) {
		_map[? "surface"] = buffer_base64_encode(surface_buffer, 0, buffer_get_size(surface_buffer));
	}
	
	static postDeserialize = function() {
		if(!ds_map_exists(load_map, "surface")) return;
		surface_buffer = buffer_base64_decode(load_map[? "surface"]);
		var _outSurf = outputs[| 0].getValue();
		buffer_set_surface(surface_buffer, _outSurf, 0);
	}
}