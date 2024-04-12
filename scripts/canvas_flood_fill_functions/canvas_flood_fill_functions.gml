function _ff_getPixel(_x, _y) { return buffer_read_at(_ff_buff, (_y * _ff_w + _x) * 4, buffer_u32); }
	
function canvas_ff_fillable(colorBase, colorFill, _x, _y, _thres) { #region
	var c = _ff_getPixel(_x, _y);
	var d = color_diff(colorBase, c, true, true);
	return d <= _thres && c != colorFill;
} #endregion

function canvas_flood_fill_scanline(_surf, _x, _y, _thres, _corner = false) { #region
	var colorFill = tool_attribute.color;
	var colorBase = surface_getpixel_ext(_surf, _x, _y);
	
	if(colorFill == colorBase) return; //Clicking on the same color as the fill color
	
	var _c = tool_attribute.color;
	draw_set_color(_c);
	
	_ff_w    = surface_get_width(_surf);
	_ff_h    = surface_get_height(_surf);
	_ff_buff = buffer_create(_ff_w * _ff_h * 4, buffer_fixed, 4);
	buffer_get_surface(_ff_buff, _surf, 0);
	
	var x1, y1, x_start;
	var spanAbove, spanBelow;
	var thr = _thres * _thres;

	var queue = ds_queue_create();
	ds_queue_enqueue(queue, [_x, _y]);
	
	while(!ds_queue_empty(queue)) {
		var pos = ds_queue_dequeue(queue);
		x1 = pos[0];
		y1 = pos[1];
		
		if(_ff_getPixel(x1, y1) == colorFill) continue; //Color in queue is already filled
		
		while(x1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 - 1, y1, thr)) //Move to the leftmost connected pixel in the same row.
			x1--;
		x_start = x1;
		
		spanAbove = false;
		spanBelow = false;
		
		while(x1 < surface_w && canvas_ff_fillable(colorBase, colorFill, x1, y1, thr)) {
			draw_point(x1, y1);
			buffer_seek(_ff_buff, buffer_seek_start, (y1 * _ff_w + x1) * 4)
			buffer_write(_ff_buff, buffer_u32, _c);
			
			if(y1 > 0) {
				if(_corner && x1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 - 1, y1 - 1, thr))		//Check top left pixel
					ds_queue_enqueue(queue, [x1 - 1, y1 - 1]);
					
				if(canvas_ff_fillable(colorBase, colorFill, x1, y1 - 1, thr))								//Check top pixel
					ds_queue_enqueue(queue, [x1, y1 - 1]);
			}
				
			if(y1 < surface_h - 1) {
				if(_corner && x1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 - 1, y1 + 1, thr))		//Check bottom left pixel
					ds_queue_enqueue(queue, [x1 - 1, y1 + 1]);
					
				if(canvas_ff_fillable(colorBase, colorFill, x1, y1 + 1, thr))								//Check bottom pixel
					ds_queue_enqueue(queue, [x1, y1 + 1]);
			}
				
			if(_corner && x1 < surface_w - 1) {
				if(y1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 + 1, y1 - 1, thr))				//Check top right pixel
					ds_queue_enqueue(queue, [x1 + 1, y1 - 1]);
					
				if(y1 < surface_h - 1 && canvas_ff_fillable(colorBase, colorFill, x1 + 1, y1 + 1, thr))	//Check bottom right pixel
					ds_queue_enqueue(queue, [x1 + 1, y1 + 1]);
			}
				
			x1++;
		}
	}
		
	draw_set_alpha(1);
	buffer_delete(_ff_buff);
} #endregion

function canvas_fill(_x, _y, _surf, _thres) { #region
	var _alp = _color_get_alpha(tool_attribute.color);
		
	var w = surface_get_width_safe(_surf);
	var h = surface_get_height_safe(_surf);
		
	var _c1 = surface_getpixel_ext(_surf, _x, _y);
	var thr = _thres * _thres;
		
	draw_set_alpha(_alp);
	for( var i = 0; i < w; i++ ) {
		for( var j = 0; j < h; j++ ) {
			if(i == _x && j == _y) {
				draw_point(i, j);
				continue;
			}
				
			var _c2 = surface_getpixel_ext(_surf, i, j);
			if(color_diff(_c1, _c2, true) <= thr)
				draw_point(i, j);
		}
	}
	draw_set_alpha(1);
} #endregion
