function Node_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Canvas";
	color	= COLORS.node_blend_canvas;
	preview_channel = 1;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black );
	inputs[| 2] = nodeValue("Brush size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 3] = nodeValue("Fill threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 4] = nodeValue("Fill type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["4 connect", "8 connect", "Entire canvas"]);
	
	inputs[| 5] = nodeValue("Draw preview overlay", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 6] = nodeValue("Brush", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1);
	
	inputs[| 7] = nodeValue("Surface amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[|  8] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1);
	
	inputs[|  9] = nodeValue("Background alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
		
	inputs[| 10] = nodeValue("Render background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	outputs[| 1] = nodeValue("Preview", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Output",	false],	0, 
		["Brush",	false], 6, 1, 2, 
		["Fill",	false], 3, 4, 
		["Display", false], 5, 8, 9, 10,
	];
	
	canvas_surface = surface_create(1, 1);
	surface_buffer = buffer_create(1 * 1 * 4, buffer_fixed, 2);
	surface_w = 1;
	surface_h = 1;
	
	tools = [
		[ "Pencil",		THEME.canvas_tools_pencil ],
		[ "Eraser",		THEME.canvas_tools_eraser ],
		[ "Rectangle",	[ THEME.canvas_tools_rect, THEME.canvas_tools_rect_fill ]],
		[ "Ellipse",	[ THEME.canvas_tools_ellip, THEME.canvas_tools_ellip_fill ]],
		[ "Fill",		THEME.canvas_tools_bucket ],
	];
	
	draw_stack  = ds_list_create();
	
	function surface_update() {
		buffer_delete(surface_buffer);
		
		surface_w = surface_get_width(canvas_surface);
		surface_h = surface_get_height(canvas_surface);
		surface_buffer = buffer_create(surface_w * surface_h * 4, buffer_fixed, 4);
		buffer_get_surface(surface_buffer, canvas_surface, 0);
		
		triggerRender();
		apply_surface();
	}
	
	function apply_surface() {
		var _dim   = inputs[|  0].getValue();
		var _bg    = inputs[|  8].getValue();
		var _bga   = inputs[|  9].getValue();
		var _bgr   = inputs[| 10].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
			
		if(!is_surface(canvas_surface))
			canvas_surface = surface_create_from_buffer(_dim[0], _dim[1], surface_buffer);
		else if(surface_size_to(canvas_surface, _dim[0], _dim[1])) {
			buffer_delete(surface_buffer);
			surface_buffer = buffer_create(_dim[0] * _dim[1] * 4, buffer_fixed, 4);
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ALPHA
			if(_bgr && is_surface(_bg))
				draw_surface_stretched_ext(_bg, 0, 0, _dim[0], _dim[1], c_white, _bga);
			draw_surface(canvas_surface, 0, 0);
		BLEND_NORMAL
		surface_reset_target();
		
		outputs[| 0].setValue(_outSurf);
		
		/////
		
		var _surf_prev = outputs[| 1].getValue();
		_surf_prev = surface_verify(_surf_prev, _dim[0], _dim[1]);
		outputs[| 1].setValue(_surf_prev);
			
		surface_set_target(_surf_prev);
		draw_clear_alpha(0, 0);
		BLEND_ALPHA;
			
		if(is_surface(_bg))
			draw_surface_stretched_ext(_bg, 0, 0, _dim[0], _dim[1], c_white, _bga);
		draw_surface(canvas_surface, 0, 0);
		
		BLEND_NORMAL;
		
		surface_reset_target();
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
			
			draw_surface_ext(_brush, _x - floor(_sw / 2), _y - floor(_sh / 2), 1, 1, 0, draw_get_color(), 1);
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
	
	function get_color_buffer(_x, _y) {
		var pos = (surface_w * _y + _x) * 4;
		if(pos > buffer_get_size(surface_buffer)) {
			print("Error buffer overflow " + string(pos) + "/" + string(buffer_get_size(surface_buffer)));
			return 0;
		}
		
		buffer_seek(surface_buffer, buffer_seek_start, pos);
		var c = buffer_read(surface_buffer, buffer_u32);
		
		return c;
	}
	
	function ff_fillable(colorBase, colorFill, _x, _y, _thres) {
		var d = color_diff(colorBase, get_color_buffer(_x, _y), true);
		return d <= _thres && d != colorFill;
	}
	
	function flood_fill_scanline(_x, _y, _surf, _thres, _corner = false) {
		surface_update();
		
		var colorFill = draw_get_color() + (255 << 24);
		var colorBase = get_color_buffer(_x, _y);
		
		if(colorFill == colorBase) return;
		
		var x1, y1, x_start;
		var spanAbove, spanBelow;
		var thr = _thres * _thres;

		var queue = ds_queue_create();
		ds_queue_enqueue(queue, [_x, _y]);
		
		while(!ds_queue_empty(queue)) {
			var pos = ds_queue_dequeue(queue);
			x1 = pos[0];
			y1 = pos[1];
			
			var colorCurr = get_color_buffer(x1, y1);
			//print("Searching " + string(x1) + ", " + string(y1) + ": " + string(colorCurr));
			
			if(colorCurr == colorFill) continue;		//Color in queue already filled
			
			while(x1 >= 0 && ff_fillable(colorBase, colorFill, x1, y1, thr))			//Shift left
				x1--;
			
			x1++;
			x_start = x1;
			
			spanAbove = false;
			spanBelow = false;
			
			while(x1 < surface_w && ff_fillable(colorBase, colorFill, x1, y1, thr)) {
				draw_point(x1, y1);
				buffer_seek(surface_buffer, buffer_seek_start, (surface_w * y1 + x1) * 4);
				buffer_write(surface_buffer, buffer_u32, colorFill);
			    
				//print("> Filling " + string(x1) + ", " + string(y1) + ": " + string(get_color_buffer(x1, y1)));
				
				if(y1 > 0) {
					if(x1 == x_start && x1 > 0 && _corner) {
						if(!spanAbove && ff_fillable(colorBase, colorFill, x1 - 1, y1 - 1, thr)) {
							ds_queue_enqueue(queue, [x1 - 1, y1 - 1]);
						    spanAbove = true;
					    }
					}
					
					if(ff_fillable(colorBase, colorFill, x1, y1 - 1, thr)) {
						ds_queue_enqueue(queue, [x1, y1 - 1]);
				    }
				}
				
				if(y1 < surface_h - 1) {
					if(x1 == x_start && x1 > 0 && _corner) {
						if(!spanBelow && ff_fillable(colorBase, colorFill, x1 - 1, y1 + 1, thr)) {
							ds_queue_enqueue(queue, [x1 - 1, y1 + 1]);
						    spanBelow = true;
					    }
					}
					
					if(ff_fillable(colorBase, colorFill, x1, y1 + 1, thr)) {
					    ds_queue_enqueue(queue, [x1, y1 + 1]);
				    }
				}
			    x1++;
			}
			
			if(x1 < surface_w - 1 && _corner) {
				if(y1 > 0) {
					if(!spanAbove && ff_fillable(colorBase, colorFill, x1 + 1, y1 - 1, thr)) {
						ds_queue_enqueue(queue, [x1 + 1, y1 - 1]);
						spanAbove = true;
					}
				}
				
				if(y1 < surface_h - 1) {
					if(!spanBelow && ff_fillable(colorBase, colorFill, x1 + 1, y1 + 1, thr)) {
						ds_queue_enqueue(queue, [x1 + 1, y1 + 1]);
						spanBelow = true;
					}
				}
			}
		}	
		
		surface_update();
	}
	
	function canvas_fill(_x, _y, _surf, _thres) {
		var w = surface_get_width(_surf);
		var h = surface_get_height(_surf);
		
		var _c1 = get_color_buffer(_x, _y);
		var thr = _thres * _thres;
		
		for( var i = 0; i < w; i++ ) {
			for( var j = 0; j < h; j++ ) {
				if(i == _x && j == _y) {
					draw_point(i, j);
					continue;
				}
				
				var _c2 = get_color_buffer(i, j);
				if(color_diff(_c1, _c2, true) <= thr)
					draw_point(i, j);
			}
		}	
		
		surface_update();
	}
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = 0;
	mouse_pre_draw_y = 0;
	
	mouse_holding = false;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		var _dim		= inputs[| 0].getValue();
		var _col		= inputs[| 1].getValue();
		var _siz		= inputs[| 2].getValue();
		var _thr		= inputs[| 3].getValue();
		var _fill_type	= inputs[| 4].getValue();
		var _prev		= inputs[| 5].getValue();
		var _brush		= inputs[| 6].getValue();
		
		if(!surface_exists(canvas_surface)) 
			apply_surface();
			
		var _surf_w		= surface_get_width(canvas_surface);
		var _surf_h		= surface_get_height(canvas_surface);
		
		surface_set_target(canvas_surface);
		draw_set_color(_col);
		
		var _tool = PANEL_PREVIEW.tool_index;
		var _sub_tool = PANEL_PREVIEW.tool_sub_index;
		
		if(active) {
			if(_tool == 0 || _tool == 1) {
				if(_tool == 0) BLEND_ALPHA;
			
				if(_tool == 1) {
					gpu_set_blendmode(bm_subtract);
					gpu_set_colorwriteenable(false, false, false, true);
				}
			
				if(key_mod_press(SHIFT) && key_mod_press(CTRL)) {
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
					if(key_mod_press(SHIFT)) {
						draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
						mouse_holding = false;
					}
				
					mouse_pre_draw_x = mouse_cur_x;
					mouse_pre_draw_y = mouse_cur_y;	
				}
			
				if(mouse_holding && mouse_click(mb_left, active)) {
					if(mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y) {
						draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
						draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
					}
				
					mouse_pre_draw_x = mouse_cur_x;
					mouse_pre_draw_y = mouse_cur_y;	
				}
			
				BLEND_NORMAL;
			
				if(_tool == 1)
					gpu_set_colorwriteenable(true, true, true, true);
			
				if(mouse_release(mb_left)) {
					surface_update();
					mouse_holding = false;
				}
				
				mouse_pre_x = mouse_cur_x;
				mouse_pre_y = mouse_cur_y;
				apply_surface();
			
			} else if(_tool == 2 || _tool == 3) {
				if(mouse_holding && key_mod_press(SHIFT)) {
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
					BLEND_ALPHA;
					if(_tool == 2)
						draw_rect_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, _sub_tool, _brush);
					else if(_tool == 3)
						draw_ellp_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, _sub_tool, _brush);
					BLEND_NORMAL;
				
					surface_update();
					mouse_holding = false;
				}
				apply_surface();
			
			} else if(_tool == 4) {
				if(point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, _surf_w - 1, _surf_h - 1) && mouse_press(mb_left)) {
					switch(_fill_type) {
						case 0 :	
							flood_fill_scanline(mouse_cur_x, mouse_cur_y, canvas_surface, _thr, false);
							break;
						case 1 :	
							flood_fill_scanline(mouse_cur_x, mouse_cur_y, canvas_surface, _thr, true);
							break;
						case 2 :	
							canvas_fill(mouse_cur_x, mouse_cur_y, canvas_surface, _thr);
							break;
					}
				
					surface_update();
				}
			}
		}
		
		surface_reset_target();
		
		#region preview
			var _bg    = inputs[|  8].getValue();
			var _bga   = inputs[|  9].getValue();
		
			var _surf_prev = outputs[| 1].getValue();
			_surf_prev = surface_verify(_surf_prev, _dim[0], _dim[1]);
			outputs[| 1].setValue(_surf_prev);
			
			surface_set_target(_surf_prev);
			draw_clear_alpha(0, 0);
			BLEND_ALPHA;
			
			if(is_surface(_bg))
				draw_surface_stretched_ext(_bg, 0, 0, _dim[0], _dim[1], c_white, _bga);
			draw_surface(canvas_surface, 0, 0);
			
			draw_set_color(_col);
			if(_tool == 0 || _tool == 1) {
				if(key_mod_press(SHIFT))
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
			
			BLEND_NORMAL;
			surface_reset_target();
			
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
	
	static step = function() {		
		var _outSurf = outputs[| 0].getValue();
		if(is_surface(_outSurf)) return;
		
		_outSurf = surface_create_from_buffer(surface_w, surface_h, surface_buffer);
		outputs[| 0].setValue(_outSurf);
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		apply_surface();
	}
	
	static doSerialize = function(_map) {
		_map[? "surface"] = buffer_base64_encode(surface_buffer, 0, buffer_get_size(surface_buffer));
	}
	
	static postDeserialize = function() {
		if(!ds_map_exists(load_map, "surface")) return;
		surface_buffer = buffer_base64_decode(load_map[? "surface"]);
		
		buffer_set_surface(surface_buffer, canvas_surface, 0);
		surface_update();
	}
	
	static onCleanUp = function() {
		surface_free(canvas_surface);
	}
}