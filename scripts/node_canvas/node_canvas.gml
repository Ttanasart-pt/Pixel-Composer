function Node_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Canvas";
	color	= COLORS.node_blend_canvas;
	preview_channel = 1;
	
	inputs[|  0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[|  1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	inputs[|  2] = nodeValue("Brush size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[|  3] = nodeValue("Fill threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[|  4] = nodeValue("Fill type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["4 connect", "8 connect", "Entire canvas"]);
	
	inputs[|  5] = nodeValue("Draw preview overlay", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[|  6] = nodeValue("Brush", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1)
		.setVisible(true, false);
	
	inputs[|  7] = nodeValue("Surface amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[|  8] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1);
	
	inputs[|  9] = nodeValue("Background alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
		
	inputs[| 10] = nodeValue("Render background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 11] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Output",	false],	0, 
		["Brush",	false], 6, 2, 1, 11,
		["Fill",	false], 3, 4, 
		["Display", false], 8, 10, 9, 
	];
	
	attribute_surface_depth();
	
	canvas_surface  = surface_create_empty(1, 1);
	drawing_surface = surface_create_empty(1, 1);
	canvas_buffer   = buffer_create(1 * 1 * 4, buffer_fixed, 2);
	surface_w = 1;
	surface_h = 1;
	
	prev_surface		  = surface_create_empty(1, 1);
	preview_draw_surface  = surface_create_empty(1, 1);
	_preview_draw_surface = surface_create_empty(1, 1);
	
	is_selecting	= false;
	is_selected		= false;
	is_select_drag  = false;
	selection_surface	= surface_create_empty(1, 1);
	selection_mask		= surface_create_empty(1, 1);
	selection_position	= [ 0, 0 ];
	selection_sx = 0;
	selection_sy = 0;
	selection_mx = 0;
	selection_my = 0;
	
	tool_channel_edit      = new checkBoxGroup(THEME.tools_canvas_channel, function(ind, val) { tool_attribute.channel[ind] = val; });
	tool_attribute.channel = [ true, true, true, true ];
	tool_settings = [
		[ "Channel", tool_channel_edit, "channel", tool_attribute ],
	];
	
	tools = [
		new NodeTool( "Selection",	[ THEME.canvas_tools_selection_rectangle, THEME.canvas_tools_selection_circle ] ),
		new NodeTool( "Pencil",		THEME.canvas_tools_pencil ),
		new NodeTool( "Eraser",		THEME.canvas_tools_eraser ),
		new NodeTool( "Rectangle",	[ THEME.canvas_tools_rect, THEME.canvas_tools_rect_fill ]),
		new NodeTool( "Ellipse",	[ THEME.canvas_tools_ellip, THEME.canvas_tools_ellip_fill ]),
		new NodeTool( "Fill",		THEME.canvas_tools_bucket ),
	];
	
	draw_stack  = ds_list_create();
	
	function apply_draw_surface() {
		var _alp = inputs[| 11].getValue();
		
		BLEND_ALPHA;
		if(isUsingTool("Eraser"))
			gpu_set_blendmode(bm_subtract);
		draw_surface_ext_safe(drawing_surface, 0, 0, 1, 1, 0, c_white, _alp);
				
		surface_clear(drawing_surface);
		BLEND_NORMAL;
		
		surface_store_buffer();
	}
	
	function surface_store_buffer() {
		buffer_delete(canvas_buffer);
		
		surface_w = surface_get_width(canvas_surface);
		surface_h = surface_get_height(canvas_surface);
		canvas_buffer = buffer_create(surface_w * surface_h * 4, buffer_fixed, 4);
		buffer_get_surface(canvas_buffer, canvas_surface, 0);
		
		triggerRender();
		apply_surface();
	}
	
	function apply_surface() {
		var _dim = inputs[|  0].getValue();
		var cDep = attrDepth();
		
		if(!is_surface(canvas_surface))
			canvas_surface = surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer);
		else if(surface_get_width(canvas_surface) != _dim[0] || surface_get_height(canvas_surface) != _dim[1]) {
			buffer_delete(canvas_buffer);
			canvas_buffer = buffer_create(_dim[0] * _dim[1] * 4, buffer_fixed, 4);
			canvas_surface = surface_size_to(canvas_surface, _dim[0], _dim[1]);
		}
		
		drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], cDep);
		surface_clear(drawing_surface);
	}
	
	function draw_point_size(_x, _y, _siz, _brush) { #region
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
				draw_circle_prec(_x, _y, _siz / 2, 0);
		} else {
			var _sw = surface_get_width(_brush);
			var _sh = surface_get_height(_brush);
			
			draw_surface_ext_safe(_brush, _x - floor(_sw / 2), _y - floor(_sh / 2), 1, 1, 0, draw_get_color(), draw_get_alpha());
		}
	} #endregion
	
	function draw_line_size(_x0, _y0, _x1, _y1, _siz, _brush) { #region 
		if(_siz == 1 && _brush == -1) 
			draw_line(_x0, _y0, _x1, _y1);
		else {
			var diss  = point_distance(_x0, _y0, _x1, _y1);
			var dirr  = point_direction(_x0, _y0, _x1, _y1);
			var st_x  = lengthdir_x(1, dirr);
			var st_y  = lengthdir_y(1, dirr);
			
			for( var i = 0; i <= diss; i += 1 ) {
				var _px = _x0 + st_x * i;
				var _py = _y0 + st_y * i;
				
				draw_point_size(_px, _py, _siz, _brush);
			}
			
			draw_point_size(_x1, _y1, _siz, _brush);
		}
	} #endregion
	
	function draw_rect_size(_x0, _y0, _x1, _y1, _siz, _fill, _brush) { #region
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
	} #endregion
	
	function draw_ellp_size(_x0, _y0, _x1, _y1, _siz, _fill, _brush) { #region
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
	} #endregion
	
	function get_color_buffer(_x, _y) { #region 
		var pos = (surface_w * _y + _x) * 4;
		if(pos > buffer_get_size(canvas_buffer)) {
			print("Error buffer overflow " + string(pos) + "/" + string(buffer_get_size(canvas_buffer)));
			return 0;
		}
		
		buffer_seek(canvas_buffer, buffer_seek_start, pos);
		var c = buffer_read(canvas_buffer, buffer_u32);
		
		return c;
	} #endregion
	
	function ff_fillable(colorBase, colorFill, _x, _y, _thres) { #region
		var d = color_diff(colorBase, get_color_buffer(_x, _y), true);
		return d <= _thres && d != colorFill;
	} #endregion
	
	function flood_fill_scanline(_x, _y, _surf, _thres, _corner = false) { #region
		var _alp = inputs[| 11].getValue();
		
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
				draw_set_alpha(_alp);
				draw_point(x1, y1);
				draw_set_alpha(1);
				
				buffer_seek(canvas_buffer, buffer_seek_start, (surface_w * y1 + x1) * 4);
				buffer_write(canvas_buffer, buffer_u32, colorFill);
			    
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
	} #endregion
	
	function canvas_fill(_x, _y, _surf, _thres) { #region
		var _alp = inputs[| 11].getValue();
		
		var w = surface_get_width(_surf);
		var h = surface_get_height(_surf);
		
		var _c1 = get_color_buffer(_x, _y);
		var thr = _thres * _thres;
		
		draw_set_alpha(_alp);
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
		draw_set_alpha(1);
	} #endregion
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = 0;
	mouse_pre_draw_y = 0;
	
	mouse_holding = false;
	
	//static getPreviewValue = function() { return key_mod_press(ALT)? outputs[| 0] : noone; }
	
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
			surface_store_buffer();
			
		var _surf_w		= surface_get_width(canvas_surface);
		var _surf_h		= surface_get_height(canvas_surface);
		
		if(!isUsingTool("Selection") && is_surface(selection_surface)) {
			var pos_x = selection_position[0];
			var pos_y = selection_position[1];
						
			surface_set_target(canvas_surface);
				BLEND_ALPHA
				draw_surface(selection_surface, pos_x, pos_y);
				BLEND_NORMAL
			surface_reset_target();
							
			surface_store_buffer();
			surface_free(selection_surface);
		}
		
		surface_set_target(canvas_surface);
		draw_set_color(_col);
		
		if(!isUsingTool("Selection"))
			gpu_set_colorwriteenable(tool_attribute.channel[0], tool_attribute.channel[1], tool_attribute.channel[2], tool_attribute.channel[3]);
		
		if(isUsingTool("Selection")) {
			if(is_selected) {
				if(!is_surface(selection_surface)) {
					is_selected = false;
				} else {
					if(is_select_drag) {
						var px = selection_sx + (mouse_cur_x - selection_mx);
						var py = selection_sy + (mouse_cur_y - selection_my);
						
						selection_position[0] = px;
						selection_position[1] = py;
						
						if(mouse_release(mb_left))
							is_select_drag = false;
					}
					
					if(mouse_press(mb_left, active)) {
						var pos_x = selection_position[0];
						var pos_y = selection_position[1];
						var sel_w = surface_get_width(selection_surface);
						var sel_h = surface_get_height(selection_surface);
						
						if(point_in_rectangle(mouse_cur_x, mouse_cur_y, pos_x, pos_y, pos_x + sel_w, pos_y + sel_h)) {
							is_select_drag = true;
							selection_sx = pos_x;
							selection_sy = pos_y;
							selection_mx = mouse_cur_x;
							selection_my = mouse_cur_y;
						} else {
							is_selected = false;
						
							surface_set_target(canvas_surface);
								BLEND_ALPHA
								draw_surface(selection_surface, pos_x, pos_y);
								BLEND_NORMAL
							surface_reset_target();
							
							surface_store_buffer();
							surface_free(selection_surface);
						}
					}
				}
			}
			
			if(!is_selected) {
				if(is_selecting) {
					var sel_x0 = min(selection_sx, mouse_cur_x);
					var sel_y0 = min(selection_sy, mouse_cur_y);
					var sel_x1 = max(selection_sx, mouse_cur_x);
					var sel_y1 = max(selection_sy, mouse_cur_y);
				
					var sel_w = sel_x1 - sel_x0 + 1;
					var sel_h = sel_y1 - sel_y0 + 1;
				
					selection_mask = surface_verify(selection_mask, sel_w, sel_h);
					surface_set_target(selection_mask);
						DRAW_CLEAR
						draw_set_color(c_white);
						if(isUsingTool("Selection", 0))
							draw_rectangle(0, 0, sel_w, sel_h, false);
						else if(isUsingTool("Selection", 1))
							draw_ellipse(0, 0, sel_w - 1, sel_h - 1, false);
					surface_reset_target();
				
					if(mouse_release(mb_left)) {
						is_selecting = false;
					
						if(sel_x0 != sel_x1 && sel_y0 != sel_y1) {
							is_selected = true;
						
							selection_surface = surface_create(sel_w, sel_h);
						
							surface_set_target(selection_surface);
								DRAW_CLEAR
								draw_surface(canvas_surface, -sel_x0, -sel_y0);
							
								BLEND_MULTIPLY
									draw_surface(selection_mask, 0, 0);
								BLEND_NORMAL
							surface_reset_target();
						
							surface_set_target(canvas_surface);
								gpu_set_blendmode(bm_subtract);
								draw_surface(selection_surface, sel_x0, sel_y0);
								gpu_set_blendmode(bm_normal);
							surface_reset_target();
						
							surface_store_buffer();
						
							selection_position = [ sel_x0, sel_y0 ];
						}
					}
				} else {
					if(mouse_press(mb_left, active)) {
						is_selecting = true;
						selection_sx = mouse_cur_x;
						selection_sy = mouse_cur_y;
					
						surface_free_safe(selection_mask);
					}
				}
			}
		} else if(isUsingTool("Pencil") || isUsingTool("Eraser")) {
			if(key_mod_press(SHIFT) && key_mod_press(CTRL)) {
				var aa = point_direction(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
				var dd = point_distance(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
				var _a = round(aa / 45) * 45;
				dd = dd * cos(degtorad(_a - aa));
				
				mouse_cur_x = mouse_pre_draw_x + lengthdir_x(dd, _a);
				mouse_cur_y = mouse_pre_draw_y + lengthdir_y(dd, _a);
			}
			
			if(mouse_press(mb_left, active)) {
				drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], attrDepth());
				
				surface_set_shader(drawing_surface, noone);
					draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
				surface_reset_shader();
				
				mouse_holding = true;
				if(key_mod_press(SHIFT)) {
					surface_set_shader(drawing_surface, noone, true, BLEND.alpha);
						//print($"===== DRAW LINE {mouse_pre_draw_x}, {mouse_pre_draw_y}, {mouse_cur_x}, {mouse_cur_y} =====");
						draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
						//print($"===== DRAW LINE END =====");
					surface_reset_shader();
					mouse_holding = false;
					
					apply_draw_surface();
				}
				
				mouse_pre_draw_x = mouse_cur_x;
				mouse_pre_draw_y = mouse_cur_y;	
			}
			
			if(mouse_holding && mouse_click(mb_left, active)) {
				if(mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y) {
					surface_set_shader(drawing_surface, noone, false, BLEND.alpha);
						draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
						draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
					surface_reset_shader();
				}
				
				mouse_pre_draw_x = mouse_cur_x;
				mouse_pre_draw_y = mouse_cur_y;	
			}
			
			if(mouse_holding && mouse_release(mb_left)) {
				mouse_holding = false;
				apply_draw_surface();
			}
			
			BLEND_NORMAL;
			
			mouse_pre_x = mouse_cur_x;
			mouse_pre_y = mouse_cur_y;
			
		} else if(isUsingTool("Rectangle") || isUsingTool("Ellipse")) {
			if(mouse_holding && key_mod_press(SHIFT)) {
				var ww = mouse_cur_x - mouse_pre_x;
				var hh = mouse_cur_y - mouse_pre_y;
				var ss = max(abs(ww), abs(hh));
				
				mouse_cur_x = mouse_pre_x + ss * sign(ww);
				mouse_cur_y = mouse_pre_y + ss * sign(hh);
			}
			
			if(mouse_press(mb_left, active)) {
				mouse_pre_x = mouse_cur_x;
				mouse_pre_y = mouse_cur_y;
				
				mouse_holding = true;
			}
			
			if(mouse_holding) {
				drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], attrDepth());
				
				surface_set_shader(drawing_surface, noone);
					if(isUsingTool("Rectangle"))
						draw_rect_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, isUsingTool("Rectangle", 1), _brush);
					else if(isUsingTool("Ellipse"))
						draw_ellp_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, isUsingTool("Ellipse", 1), _brush);
				surface_reset_shader();
				
				if(mouse_release(mb_left)) {
					apply_draw_surface();
					mouse_holding = false;
				}
			}
		} else if(isUsingTool("Fill") || (DRAGGING && DRAGGING.type == "Color")) {
			if(point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, _surf_w - 1, _surf_h - 1)) {
				var fill = DRAGGING? mouse_release(mb_left) : mouse_press(mb_left);
				
				if(fill) {
					if(DRAGGING) draw_set_color(DRAGGING.data);
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
					surface_store_buffer();
				}
			}
		}
		
		draw_set_alpha(1);
		gpu_set_colorwriteenable(true, true, true, true);
		surface_reset_target();
		
		if(key_mod_press(ALT)) return;
		
		#region preview
			var _bg  = inputs[|  8].getValue();
			var _bga = inputs[|  9].getValue();
			var _bgr = inputs[| 10].getValue();
			var _alp = inputs[| 11].getValue();
			
			var __s = surface_get_target();
			
			prev_surface 		  = surface_verify(prev_surface,		  _dim[0], _dim[1]);
			preview_draw_surface  = surface_verify(preview_draw_surface,  _dim[0], _dim[1]);
			_preview_draw_surface = surface_verify(_preview_draw_surface, surface_get_width(__s), surface_get_height(__s));
			
			surface_set_shader(preview_draw_surface, noone,, BLEND.alpha);
				draw_surface_safe(drawing_surface, 0, 0);
				
				draw_set_color(_col);
				if(isUsingTool("Selection")) {
					if(is_selected)
						draw_surface(selection_surface, selection_position[0], selection_position[1]);
					else if(is_selecting) {
						var sel_x0 = min(selection_sx, mouse_cur_x);
						var sel_y0 = min(selection_sy, mouse_cur_y);
						draw_surface_safe(selection_mask, sel_x0, sel_y0);
					}
				} else if(isUsingTool("Pencil") || isUsingTool("Eraser")) {
					if(mouse_holding) {
						if(isUsingTool("Eraser")) draw_set_color(c_white);
					
						if(key_mod_press(SHIFT))	draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
						else						draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
					}
				} else if(isUsingTool("Rectangle"))	{
					if(mouse_holding) draw_rect_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, isUsingTool("Rectangle", 1), _brush);
				} else if(isUsingTool("Ellipse")) {
					if(mouse_holding) draw_ellp_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, isUsingTool("Ellipse", 1), _brush); 
				}
			surface_reset_shader();
			
			if(_bgr && is_surface(_bg))
				draw_surface_ext(_bg, _x, _y, _s, _s, 0, c_white, _bga);
			
			if(!isNotUsingTool()) { 
				if(isUsingTool("Selection")) {
					if(is_selected) {
						var pos_x = _x + selection_position[0] * _s;
						var pos_y = _y + selection_position[1] * _s;
						var sel_w = surface_get_width(selection_surface)  * _s;
						var sel_h = surface_get_height(selection_surface) * _s;
						
						draw_set_color(c_white);
						draw_rectangle_dashed(pos_x, pos_y, pos_x + sel_w, pos_y + sel_h, true, 4);
						
						draw_surface_ext(selection_surface, pos_x, pos_y, _s, _s, 0, c_white, 1);
					}
				} else {
					gpu_set_colorwriteenable(tool_attribute.channel[0], tool_attribute.channel[1], tool_attribute.channel[2], tool_attribute.channel[3]);
					draw_surface_ext_safe(preview_draw_surface, _x, _y, _s, _s, 0, isUsingTool("Eraser")? c_red : c_white, isUsingTool("Eraser")? 0.2 : _alp);
					gpu_set_colorwriteenable(true, true, true, true);
				}
				
				surface_set_target(_preview_draw_surface);
					DRAW_CLEAR
					draw_surface_ext(preview_draw_surface, _x, _y, _s, _s, 0, c_white, 1);
				surface_reset_target();
				
				shader_set(sh_brush_outline);
					shader_set_f("dimension", surface_get_width(_preview_draw_surface), surface_get_height(_preview_draw_surface));
					draw_surface_ext(_preview_draw_surface, 0, 0, 1, 1, 0, c_white, 1);
				shader_reset();
			}
		#endregion
		
		var _x0 = _x;
		var _y0 = _y;
		var _x1 = _x0 + _dim[0] * _s;
		var _y1 = _y0 + _dim[1] * _s;
		
		draw_set_color(COLORS.panel_preview_surface_outline);
		draw_rectangle(_x0, _y0, _x1 - 1, _y1 - 1, true);
		
		previewing = 1;
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _dim   = inputs[|  0].getValue();
		var _bg    = inputs[|  8].getValue();
		var _bga   = inputs[|  9].getValue();
		var _bgr   = inputs[| 10].getValue();
		
		var cDep   = attrDepth();
		apply_surface();
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], cDep);
			
		surface_set_shader(_outSurf, noone,, BLEND.alpha);
			if(_bgr && is_surface(_bg))
				draw_surface_stretched_ext(_bg, 0, 0, _dim[0], _dim[1], c_white, _bga);
			draw_surface_safe(canvas_surface, 0, 0);
		surface_reset_shader();
		
		outputs[| 0].setValue(_outSurf);
	}
	
	static doSerialize = function(_map) {
		surface_store_buffer();
		var comp = buffer_compress(canvas_buffer, 0, buffer_get_size(canvas_buffer));
		var enc  = buffer_base64_encode(comp, 0, buffer_get_size(comp));
			
		_map.surface = enc;
	}
	
	static doApplyDeserialize = function() {
		if(!struct_has(load_map, "surface")) return;	
		var buff = buffer_base64_decode(load_map.surface);
		canvas_buffer = buffer_decompress(buff);
		
		var _dim     = inputs[|  0].getValue();
		var _outSurf = outputs[| 0].getValue();
		_outSurf     = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		canvas_surface = surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer);
		
		apply_surface();
	}
	
	static onCleanUp = function() {
		surface_free(canvas_surface);
	}
}