function Node_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Canvas";
	color	= COLORS.node_blend_canvas;
	
	inputs[|  0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[|  1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	inputs[|  2] = nodeValue("Brush size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 1] });
	
	inputs[|  3] = nodeValue("Fill threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[|  4] = nodeValue("Fill type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["4 connect", "8 connect", "Entire canvas"]);
	
	inputs[|  5] = nodeValue("Draw preview overlay", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[|  6] = nodeValue("Brush", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1)
		.setVisible(true, false);
	
	inputs[|  7] = nodeValue("Surface amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[|  8] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1);
	
	inputs[|  9] = nodeValue("Background alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 10] = nodeValue("Render background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 11] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	frame_renderer_x     = 0;
	frame_renderer_x_to  = 0;
	frame_renderer_x_max = 0;
	
	frame_renderer_content = surface_create(1, 1);
	frame_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _h = 64;
		_y += 8;
		
		var _cnt_hover = false;
		
		draw_sprite_stretched(THEME.button, 0, _x, _y, _w, _h);
		
		if(_hover && frame_renderer.parent != noone && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			frame_renderer.parent.scroll_lock = true;
			_cnt_hover = _hover;
		}
		
		var _ww = _w - 4 - 40;
		var _hh = _h - 4 - 4;
		
		var _x0 = _x + 4;
		var _y0 = _y + 4;
		var _x1 = _x0 + _ww;
		var _y1 = _y0 + _hh;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, _x0, _y0, _ww, _hh);
		
		frame_renderer_x_max   = 0;
		frame_renderer_content = surface_verify(frame_renderer_content, _ww, _hh);
		surface_set_shader(frame_renderer_content);
			var _msx = _m[0] - _x0;
			var _msy = _m[1] - _y0;
			
			var _fr_h = _hh - 8;
			var _fr_w = _fr_h;
			
			var _fr_x = 8 - frame_renderer_x;
			var _fr_y = 4;
			
			var surfs = outputs[| 0].getValue();
			var _del  = noone;
			
			if(!is_array(surfs)) surfs = [ surfs ];
			
			for( var i = 0, n = array_length(surfs); i < n; i++ ) {
				var _surf = surfs[i];
				
				if(!is_surface(_surf)) continue;
				
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				
				var _ss = min(_fr_w / _sw, _fr_h / _sh);
				var _sx = _fr_x;
				var _sy = _fr_y + _fr_h / 2 - _sh * _ss / 2;
				
				draw_surface_ext(_surf, _sx, _sy, _ss, _ss, 0, c_white, 1);
				
				draw_set_color(i == preview_index? COLORS._main_accent : COLORS.panel_toolbar_outline);
				draw_rectangle(_sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss, true);
				
				var _del_x = _sx + _sw * _ss - 8;
				var _del_y = _sy + 8;
				var _del_a = 0;
				
				if(_hover) {
					if(point_in_circle(_msx, _msy, _del_x, _del_y, 8)) {
						_del_a = 1;
						
						if(mouse_press(mb_left, _focus)) 
							_del = i;
					} else if(point_in_rectangle(_msx, _msy, _sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss)) {
						if(mouse_press(mb_left, _focus)) preview_index = i;
					}
				}
				
				draw_sprite(THEME.close_16, _del_a, _del_x, _del_y);
				
				_fr_x += _sw * _ss + 8;
				frame_renderer_x_max += _sw * _ss + 8;
			}
			
			if(_del > noone) removeFrame(_del);
		surface_reset_shader();
		draw_surface(frame_renderer_content, _x0, _y0);
		
		frame_renderer_x_max = max(0, frame_renderer_x_max - 200);
		frame_renderer_x     = lerp_float(frame_renderer_x, frame_renderer_x_to, 3);
		
		if(_cnt_hover) {
			if(mouse_wheel_down()) frame_renderer_x_to = clamp(frame_renderer_x_to + 80, 0, frame_renderer_x_max);
			if(mouse_wheel_up())   frame_renderer_x_to = clamp(frame_renderer_x_to - 80, 0, frame_renderer_x_max);
		}
		
		var _bs = 32;
		var _bx = _x1 + ui(20) - _bs / 2;
		var _by = _y + _h / 2  - _bs / 2;
		
		if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, _focus, _hover,, THEME.add,, COLORS._main_value_positive) == 2) {
			attributes.frames++;
			refreshFrames();
			update();
		}
		
		return 8 + _h;
	}); #endregion
	
	input_display_list = [ 
		["Output",	false],	0, frame_renderer,
		["Brush",	false], 6, 2, 1, 11,
		["Fill",	false], 3, 4, 
		["Display", false], 8, 10, 9, 
	];
	
	attributes.frames = 1;
	attribute_surface_depth();
	
	canvas_surface   = [ surface_create_empty(1, 1) ];
	canvas_buffer    = [ buffer_create(1 * 1 * 4, buffer_fixed, 2) ];
	
	drawing_surface  = surface_create_empty(1, 1);
	_drawing_surface = surface_create_empty(1, 1);
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
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = 0;
	mouse_pre_draw_y = 0;
	
	mouse_holding = false;
	
	brush_sizing    = false;
	brush_sizing_s  = 0;
	brush_sizing_mx = 0;
	brush_sizing_my = 0;
	brush_sizing_dx = 0;
	brush_sizing_dy = 0;
	
	tool_channel_edit = new checkBoxGroup(THEME.tools_canvas_channel, function(ind, val) { tool_attribute.channel[ind] = val; });
	tool_attribute.channel = [ true, true, true, true ];
	tool_settings = [
		[ "Channel", tool_channel_edit, "channel", tool_attribute ],
	];
	
	tools = [
		new NodeTool( "Selection",	[ THEME.canvas_tools_selection_rectangle, THEME.canvas_tools_selection_circle ]),
		new NodeTool( "Pencil",		  THEME.canvas_tools_pencil),
		new NodeTool( "Eraser",		  THEME.canvas_tools_eraser),
		new NodeTool( "Rectangle",	[ THEME.canvas_tools_rect, THEME.canvas_tools_rect_fill ]),
		new NodeTool( "Ellipse",	[ THEME.canvas_tools_ellip, THEME.canvas_tools_ellip_fill ]),
		new NodeTool( "Fill",		  THEME.canvas_tools_bucket),
	];
	
	draw_stack  = ds_list_create();
	
	function removeFrame(index = 0) { #region
		if(attributes.frames <= 1) return;
		
		attributes.frames--;
		
		array_delete(canvas_surface, index, 1);
		array_delete(canvas_buffer,  index, 1);
		update();
	} #endregion
	
	function refreshFrames() { #region
		var fr = attributes.frames;
		
		if(array_length(canvas_surface) < fr) {
			for( var i = array_length(canvas_surface); i < fr; i++ ) {
				canvas_surface[i] = surface_create_empty(1, 1);
			}
		} else 
			array_resize(canvas_surface, fr);
		
		if(array_length(canvas_buffer) < fr) {
			for( var i = array_length(canvas_buffer); i < fr; i++ ) {
				canvas_buffer[i] = buffer_create(1 * 1 * 4, buffer_fixed, 2);
			}
		} else 
			array_resize(canvas_buffer, fr);
	} #endregion
	
	function getCanvasSurface(index = preview_index) { #region
		gml_pragma("forceinline");
		
		return array_safe_get(canvas_surface, index);
	} #endregion
	
	function setCanvasSurface(surface, index = preview_index) { #region
		gml_pragma("forceinline");
		
		canvas_surface[index] = surface;
	} #endregion
	
	function storeAction() { #region
		var action = recordAction(ACTION_TYPE.custom, function(data) { 
			is_selected = false;
			
			var _canvas = surface_clone(getCanvasSurface(data.index));
			
			if(is_surface(data.surface))
				setCanvasSurface(surface_clone(data.surface), data.index); 
			surface_store_buffer(data.index); 
			surface_free(data.surface);
			
			return { surface: _canvas, tooltip: data.tooltip, index: preview_index }
		}, { surface: surface_clone(getCanvasSurface()), tooltip: "Modify canvas", index: preview_index });
		
		action.clear_action = function(data) { surface_free_safe(data.surface); };
	} #endregion
	
	function apply_surfaces() { #region
		for( var i = 0; i < attributes.frames; i++ )
			apply_surface(i);
	} #endregion
	
	function apply_surface(index = preview_index) { #region
		var _dim = getInputData(0);
		var cDep = attrDepth();
		
		var _canvas_surface = getCanvasSurface(index);
		
		if(!is_surface(_canvas_surface)) {
			setCanvasSurface(surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer[index]));
		} else if(surface_get_width_safe(_canvas_surface) != _dim[0] || surface_get_height_safe(_canvas_surface) != _dim[1]) {
			buffer_delete(canvas_buffer[index]);
			canvas_buffer[index] = buffer_create(_dim[0] * _dim[1] * 4, buffer_fixed, 4);
			setCanvasSurface(surface_size_to(_canvas_surface, _dim[0], _dim[1]), index);
		}
		
		drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], cDep);
		surface_clear(drawing_surface);
	} #endregion
	
	function surface_store_buffers(index = preview_index) { #region
		for( var i = 0; i < attributes.frames; i++ )
			surface_store_buffer(i);
	} #endregion
	
	function surface_store_buffer(index = preview_index) { #region
		buffer_delete(canvas_buffer[index]);
		
		var _canvas_surface = getCanvasSurface(index);
		
		surface_w = surface_get_width_safe(_canvas_surface);
		surface_h = surface_get_height_safe(_canvas_surface);
		canvas_buffer[index] = buffer_create(surface_w * surface_h * 4, buffer_fixed, 4);
		buffer_get_surface(canvas_buffer[index], _canvas_surface, 0);
		
		triggerRender();
		apply_surface(index);
	} #endregion
	
	function apply_draw_surface() { #region
		var _alp = getInputData(11);
		
		storeAction();
		
		surface_set_target(getCanvasSurface());
			if(isUsingTool("Eraser")) gpu_set_blendmode(bm_subtract);
			else					  BLEND_ALPHA
			draw_surface_ext_safe(drawing_surface, 0, 0, 1, 1, 0, c_white, _alp);
		surface_reset_target();
				
		surface_clear(drawing_surface);
		BLEND_NORMAL;
		
		surface_store_buffer();
	} #endregion
	
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
			var _sw = surface_get_width_safe(_brush);
			var _sh = surface_get_height_safe(_brush);
			
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
		var _cbuffer = canvas_buffer[preview_index];
		var pos = (surface_w * _y + _x) * 4;
		if(pos >= buffer_get_size(_cbuffer)) {
			print("Error buffer overflow " + string(pos) + "/" + string(buffer_get_size(_cbuffer)));
			return 0;
		}
		
		buffer_seek(_cbuffer, buffer_seek_start, pos);
		var c = buffer_read(_cbuffer, buffer_u32);
		
		return c;
	} #endregion
	
	function ff_fillable(colorBase, colorFill, _x, _y, _thres) { #region
		var d = color_diff(colorBase, get_color_buffer(_x, _y), true);
		return d <= _thres && d != colorFill;
	} #endregion
	
	function flood_fill_scanline(_x, _y, _surf, _thres, _corner = false) { #region
		var _alp = getInputData(11);
		
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
				
				var _cbuffer = canvas_buffer[preview_index];
				buffer_seek(_cbuffer, buffer_seek_start, (surface_w * y1 + x1) * 4);
				buffer_write(_cbuffer, buffer_u32, colorFill);
			    
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
		var _alp = getInputData(11);
		
		var w = surface_get_width_safe(_surf);
		var h = surface_get_height_safe(_surf);
		
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
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		var _dim		= getInputData(0);
		var _col		= getInputData(1);
		var _siz		= getInputData(2);
		var _thr		= getInputData(3);
		var _fill_type	= getInputData(4);
		var _prev		= getInputData(5);
		var _brush		= getInputData(6);
		
		if(key_mod_press(ALT)) return;
		
		var _canvas_surface = getCanvasSurface();
		
		if(!surface_exists(_canvas_surface)) {
			surface_store_buffer();
			_canvas_surface = getCanvasSurface();
		}
		
		var _surf_w		= surface_get_width_safe(_canvas_surface);
		var _surf_h		= surface_get_height_safe(_canvas_surface);
		
		#region drawing surface review
			_drawing_surface = surface_verify(_drawing_surface, _surf_w, _surf_h);
			surface_set_target(_drawing_surface);
				DRAW_CLEAR
				draw_surface_safe(drawing_surface);
			surface_reset_target();
		#endregion
		
		if(!isUsingTool("Selection") && is_surface(selection_surface)) { #region
			var pos_x = selection_position[0];
			var pos_y = selection_position[1];
						
			surface_set_target(_canvas_surface);
				BLEND_ALPHA
				draw_surface_safe(selection_surface, pos_x, pos_y);
				BLEND_NORMAL
			surface_reset_target();
							
			surface_store_buffer();
			surface_free(selection_surface);
		} #endregion
		
		draw_set_color(_col);
		
		if(!isUsingTool("Selection"))
			gpu_set_colorwriteenable(tool_attribute.channel[0], tool_attribute.channel[1], tool_attribute.channel[2], tool_attribute.channel[3]);
		
		if(isUsingTool("Selection")) { #region
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
						var sel_w = surface_get_width_safe(selection_surface);
						var sel_h = surface_get_height_safe(selection_surface);
						
						if(point_in_rectangle(mouse_cur_x, mouse_cur_y, pos_x, pos_y, pos_x + sel_w, pos_y + sel_h)) {
							is_select_drag = true;
							selection_sx = pos_x;
							selection_sy = pos_y;
							selection_mx = mouse_cur_x;
							selection_my = mouse_cur_y;
						} else {
							is_selected = false;
						
							surface_set_target(_canvas_surface);
								BLEND_ALPHA
								draw_surface_safe(selection_surface, pos_x, pos_y);
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
								draw_surface_safe(_canvas_surface, -sel_x0, -sel_y0);
							
								BLEND_MULTIPLY
									draw_surface_safe(selection_mask, 0, 0);
								BLEND_NORMAL
							surface_reset_target();
							
							storeAction();
							surface_set_target(_canvas_surface);
								gpu_set_blendmode(bm_subtract);
								draw_surface_safe(selection_surface, sel_x0, sel_y0);
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
		#endregion
		} else if(isUsingTool("Pencil") || isUsingTool("Eraser")) { #region
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
						draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
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
			
			if(brush_sizing) {
				var s = brush_sizing_s + (_mx - brush_sizing_mx) / 16;
				    s = max(1, s);
				inputs[| 2].setValue(s);
				
				if(mouse_release(mb_right)) 
					brush_sizing = false;
			} else if(mouse_press(mb_right, active) && key_mod_press(SHIFT) && !is_surface(_brush)) {
				brush_sizing    = true;
				brush_sizing_s  = _siz;
				brush_sizing_mx = _mx;
				brush_sizing_my = _my;
				
				brush_sizing_dx = mouse_cur_x;
				brush_sizing_dy = mouse_cur_y;
			}
		#endregion
		} else if(isUsingTool("Rectangle") || isUsingTool("Ellipse")) { #region
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
		#endregion
		} else if(isUsingTool("Fill") || (DRAGGING && DRAGGING.type == "Color")) { #region
			var fill = DRAGGING? mouse_release(mb_left, active) : mouse_press(mb_left, active);
			
			if(fill && point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, _surf_w - 1, _surf_h - 1)) {
				storeAction();
				surface_set_target(_canvas_surface);
				if(DRAGGING) draw_set_color(DRAGGING.data);
				switch(_fill_type) {
					case 0 :	
						flood_fill_scanline(mouse_cur_x, mouse_cur_y, _canvas_surface, _thr, false);
						break;
					case 1 :	
						flood_fill_scanline(mouse_cur_x, mouse_cur_y, _canvas_surface, _thr, true);
						break;
					case 2 :	
						canvas_fill(mouse_cur_x, mouse_cur_y, _canvas_surface, _thr);
						break;
				}	
				surface_store_buffer();
				surface_reset_target();
			}
		#endregion
		}
		
		draw_set_alpha(1);
		gpu_set_colorwriteenable(true, true, true, true);
		
		#region preview
			var _bg  = getInputData(8);
			var _bga = getInputData(9);
			var _bgr = getInputData(10);
			var _alp = getInputData(11);
			
			var __s = surface_get_target();
			
			prev_surface 		  = surface_verify(prev_surface,		  _dim[0], _dim[1]);
			preview_draw_surface  = surface_verify(preview_draw_surface,  _dim[0], _dim[1]);
			_preview_draw_surface = surface_verify(_preview_draw_surface, surface_get_width_safe(__s), surface_get_height_safe(__s));
			
			surface_set_shader(preview_draw_surface, noone,, BLEND.alpha);
				draw_surface_safe(_drawing_surface, 0, 0);
				
				draw_set_color(_col);
				if(isUsingTool("Selection")) {
					if(is_selected)
						draw_surface_safe(selection_surface, selection_position[0], selection_position[1]);
					else if(is_selecting) {
						var sel_x0 = min(selection_sx, mouse_cur_x);
						var sel_y0 = min(selection_sy, mouse_cur_y);
						draw_surface_safe(selection_mask, sel_x0, sel_y0);
					}
				} else if(isUsingTool("Pencil") || isUsingTool("Eraser")) {
					if(brush_sizing) {
						draw_point_size(brush_sizing_dx, brush_sizing_dy, _siz, _brush);
					} else if(mouse_holding) {
						if(isUsingTool("Eraser")) draw_set_color(c_white);
					
						if(key_mod_press(SHIFT))	draw_line_size(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, _siz, _brush);
						else						draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
					} else 
						draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
				} else if(isUsingTool("Rectangle"))	{
					if(mouse_holding) 
						draw_rect_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, isUsingTool("Rectangle", 1), _brush);
					else 
						draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
				} else if(isUsingTool("Ellipse")) {
					if(mouse_holding) 
						draw_ellp_size(mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, _siz, isUsingTool("Ellipse", 1), _brush); 
					else 
						draw_point_size(mouse_cur_x, mouse_cur_y, _siz, _brush);
				}
			surface_reset_shader();
			
			if(isUsingTool()) { 
				if(isUsingTool("Selection")) {
					if(is_selected) {
						var pos_x = _x + selection_position[0] * _s;
						var pos_y = _y + selection_position[1] * _s;
						var sel_w = surface_get_width_safe(selection_surface)  * _s;
						var sel_h = surface_get_height_safe(selection_surface) * _s;
						
						draw_set_color(c_white);
						draw_rectangle_dashed(pos_x, pos_y, pos_x + sel_w, pos_y + sel_h, true, 4);
						
						draw_surface_ext_safe(selection_surface, pos_x, pos_y, _s, _s, 0, c_white, 1);
					}
				} else {
					gpu_set_colorwriteenable(tool_attribute.channel[0], tool_attribute.channel[1], tool_attribute.channel[2], tool_attribute.channel[3]);
					draw_surface_ext_safe(preview_draw_surface, _x, _y, _s, _s, 0, isUsingTool("Eraser")? c_red : c_white, isUsingTool("Eraser")? 0.2 : _alp);
					gpu_set_colorwriteenable(true, true, true, true);
				}
				
				surface_set_target(_preview_draw_surface);
					DRAW_CLEAR
					draw_surface_ext_safe(preview_draw_surface, _x, _y, _s, _s, 0, c_white, 1);
				surface_reset_target();
				
				shader_set(sh_brush_outline);
					shader_set_f("dimension", surface_get_width_safe(_preview_draw_surface), surface_get_height_safe(_preview_draw_surface));
					draw_surface_ext_safe(_preview_draw_surface, 0, 0, 1, 1, 0, c_white, 1);
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
	} #endregion
	
	static update = function(frame = PROJECT.animator.current_frame) { #region
		var _dim   = getInputData(0);
		var _bg    = getInputData(8);
		var _bga   = getInputData(9);
		var _bgr   = getInputData(10);
		
		var cDep   = attrDepth();
		apply_surfaces();
		
		var _outSurf = outputs[| 0].getValue();
		
		if(attributes.frames == 1) {
			if(is_array(_outSurf)) {
				if(!array_empty(_outSurf)) _outSurf = _outSurf[0];
				else _outSurf = noone;
			}
			
			var _canvas_surface = getCanvasSurface(0);
			_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], cDep);
			
			surface_set_shader(_outSurf, noone,, BLEND.alpha);
				if(_bgr && is_surface(_bg))
					draw_surface_stretched_ext(_bg, 0, 0, _dim[0], _dim[1], c_white, _bga);
				draw_surface_safe(_canvas_surface, 0, 0);
			surface_reset_shader();
		} else {
			if(!is_array(_outSurf)) 
				_outSurf = array_create(attributes.frames);
			else if(array_length(_outSurf) != attributes.frames)
				array_resize(_outSurf, attributes.frames);
				
			for( var i = 0; i < attributes.frames; i++ ) {
				var _canvas_surface = getCanvasSurface(i);
				_outSurf[i] = surface_verify(_outSurf[i], _dim[0], _dim[1], cDep);
			
				surface_set_shader(_outSurf[i], noone,, BLEND.alpha);
					if(_bgr && is_surface(_bg))
						draw_surface_stretched_ext(_bg, 0, 0, _dim[0], _dim[1], c_white, _bga);
					draw_surface_safe(_canvas_surface, 0, 0);
				surface_reset_shader();
			
			}
		}
		
		outputs[| 0].setValue(_outSurf);
	} #endregion
	
	static doSerialize = function(_map) { #region
		surface_store_buffers();
		var _buff = array_create(attributes.frames);
		
		for( var i = 0; i < attributes.frames; i++ ) {
			var comp = buffer_compress(canvas_buffer[i], 0, buffer_get_size(canvas_buffer[i]));
			_buff[i] = buffer_base64_encode(comp, 0, buffer_get_size(comp));
		}
			
		_map.surfaces = _buff;
	} #endregion
	
	static doApplyDeserialize = function() { #region
		var _dim     = getInputData(0);
		
		if(!struct_has(load_map, "surfaces")) {
			if(struct_has(load_map, "surface")) {
				var buff = buffer_base64_decode(load_map.surface);
				
				canvas_buffer[0]  = buffer_decompress(buff);
				canvas_surface[0] = surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer[0]);
			}
			return;
		}
		
		canvas_buffer  = array_create(array_length(load_map.surfaces));
		canvas_surface = array_create(array_length(load_map.surfaces));
		
		for( var i = 0, n = array_length(load_map.surfaces); i < n; i++ ) {
			var buff = buffer_base64_decode(load_map.surfaces[i]);
			
			canvas_buffer[i]  = buffer_decompress(buff);
			canvas_surface[i] = surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer[i]);
		}
		
		apply_surfaces();
	} #endregion
	
	static onCleanUp = function() { #region
		surface_array_free(canvas_surface);
	} #endregion
}