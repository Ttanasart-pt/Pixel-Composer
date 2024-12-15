function tiler_tool_fill(node, _brush, toolAttr) : tiler_tool(node) constructor {
	self.brush = _brush;
	self.tool_attribute = toolAttr;
	
	mouse_cur_x = -1;
	mouse_cur_y = -1;
	mouse_pre_x = -1;
	mouse_pre_y = -1;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = floor(round((_mx - _x) / _s - 0.5) / tile_size[0]);
		mouse_cur_y = floor(round((_my - _y) / _s - 0.5) / tile_size[1]);
		
		surface_w	= surface_get_width(drawing_surface);
		surface_h	= surface_get_height(drawing_surface);
		
		var _auto = brush.autoterrain;
		
		if(mouse_press(mb_left, active) && point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, surface_w - 1, surface_h - 1)) {
			surface_set_target(drawing_surface);
				tiler_flood_fill_scanline(drawing_surface, mouse_cur_x, mouse_cur_y, brush, tool_attribute.fillType);
			surface_reset_target();
			
			if(_auto != noone) {
				_auto.drawing_start(drawing_surface, isEraser);
				tiler_flood_fill_scanline(drawing_surface, mouse_cur_x, mouse_cur_y, brush, tool_attribute.fillType);
				_auto.drawing_end();
			}
				
			apply_draw_surface();
		}
	}
}

function _tiler_ff_getPixel(_x, _y) { return round(buffer_read_at(_ff_buff, (_y * _ff_w + _x) * 8, buffer_f16)); }

function tiler_flood_fill_scanline(_surf, _x, _y, brush, _corner = false) {
	if(brush.brush_height * brush.brush_width == 0) return;
	
	var _index = brush.brush_erase? -1 : brush.brush_indices[0][0];
	var colorBase = surface_getpixel(_surf, _x, _y)[0];
	
	if(_index == colorBase) return; //Clicking on the same color as the fill color
	if(is_array(_index)) return;
	
	_ff_w    = surface_get_width(_surf);
	_ff_h    = surface_get_height(_surf);
	_ff_buff = buffer_create(_ff_w * _ff_h * 8, buffer_fixed, 2);
	buffer_get_surface(_ff_buff, _surf, 0);
	
	var x1, y1, x_start;
	var spanAbove, spanBelow;
    
	var qx = ds_queue_create();
	var qy = ds_queue_create();
	ds_queue_enqueue(qx, _x);
	ds_queue_enqueue(qy, _y);
	
	shader_set(sh_draw_tile_brush);
	BLEND_OVERRIDE
	shader_set_f("index", _index);
	
	while(!ds_queue_empty(qx)) {
		
		x1 = ds_queue_dequeue(qx);
		y1 = ds_queue_dequeue(qy);
		
// 		print($"----Checking {x1}, {y1} - {_tiler_ff_getPixel(x1, y1)}")
		
		if(_tiler_ff_getPixel(x1, y1) == _index) continue; //Color in queue is already filled
		
		while(x1 > 0 && colorBase == _tiler_ff_getPixel(x1 - 1, y1)) //Move to the leftmost connected pixel in the same row.
			x1--;
		x_start = x1;
		
		spanAbove = false;
		spanBelow = false;
		
		while(x1 < surface_w && colorBase == _tiler_ff_getPixel(x1, y1)) {
			draw_point(x1, y1);
			buffer_write_at(_ff_buff, (y1 * _ff_w + x1) * 8, buffer_f16, _index);
			
// 			print($"----Filling {x1}, {y1}")
			
			if(y1 > 0) {
				if(_corner && x1 > 0 && colorBase == _tiler_ff_getPixel(x1 - 1, y1 - 1)) {	//Check top left pixel
					ds_queue_enqueue(qx, x1 - 1);
					ds_queue_enqueue(qy, y1 - 1);
				}
					
				if(colorBase == _tiler_ff_getPixel(x1, y1 - 1)) {								//Check top pixel
					ds_queue_enqueue(qx, x1);
					ds_queue_enqueue(qy, y1 - 1);
				}
			}
				
			if(y1 < surface_h - 1) {
				if(_corner && x1 > 0 && colorBase == _tiler_ff_getPixel(x1 - 1, y1 + 1)) {	//Check bottom left pixel
					ds_queue_enqueue(qx, x1 - 1);
					ds_queue_enqueue(qy, y1 + 1);
				}
					
				if(colorBase == _tiler_ff_getPixel(x1, y1 + 1)) {								//Check bottom pixel
					ds_queue_enqueue(qx, x1);
					ds_queue_enqueue(qy, y1 + 1);
				}
			}
				
			if(_corner && x1 < surface_w - 1) {
				if(y1 > 0 && colorBase == _tiler_ff_getPixel(x1 + 1, y1 - 1)) {				//Check top right pixel
					ds_queue_enqueue(qx, x1 + 1);
					ds_queue_enqueue(qy, y1 - 1);
				}
					
				if(y1 < surface_h - 1 && colorBase == _tiler_ff_getPixel(x1 + 1, y1 + 1)) {	//Check bottom right pixel
					ds_queue_enqueue(qx, x1 + 1);
					ds_queue_enqueue(qy, y1 + 1);
				}
			}
				
			x1++;
		}
	}
	
	BLEND_NORMAL
	shader_reset();
	
	ds_queue_destroy(qx);
	ds_queue_destroy(qy);
		
	draw_set_alpha(1);
	buffer_delete(_ff_buff);
}