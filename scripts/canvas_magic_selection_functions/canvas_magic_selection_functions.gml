
function canvas_ms_fillable(colorBase, colorFill, _x, _y, _thres) { #region
	var c = _ff_getPixel(_x, _y);
	var d = color_diff(colorBase, c, true, true);
	return d <= _thres;
} #endregion

function canvas_magic_selection_scanline(_surf, _x, _y, _thres, _corner = false) { #region
	
	var colorBase = surface_getpixel_ext(_surf, _x, _y);
	var colorFill = colorBase;
	
	var x1, y1, x_start;
	var spanAbove, spanBelow;
	var thr = _thres * _thres;
	
	_ff_w    = surface_get_width(_surf);
	_ff_h    = surface_get_height(_surf);
	_ff_buff = buffer_create(_ff_w * _ff_h * 4, buffer_fixed, 4);
	buffer_get_surface(_ff_buff, _surf, 0);
	
	var queue = ds_queue_create();
	ds_queue_enqueue(queue, [_x, _y]);
	
	var sel_x0 = surface_w;
	var sel_y0 = surface_h;
	var sel_x1 = 0;
	var sel_y1 = 0;
	
	var _arr = array_create(surface_w * surface_h, 0);
	
	draw_set_color(c_white);
	while(!ds_queue_empty(queue)) {
		var pos = ds_queue_dequeue(queue);
		x1 = pos[0];
		y1 = pos[1];
		
		if(_arr[y1 * surface_w + x1] == 1) continue; //Color in queue is already filled
			
		while(x1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 - 1, y1, thr)) //Move to the leftmost connected pixel in the same row.
			x1--;
		x_start = x1;
			
		spanAbove = false;
		spanBelow = false;
			
		//print($"Searching {x1}, {y1} | {canvas_ms_fillable(colorBase, colorFill, x1, y1, thr)}");
		
		while(x1 < surface_w && canvas_ms_fillable(colorBase, colorFill, x1, y1, thr)) {
			draw_point(x1, y1);
			
			if(_arr[y1 * surface_w + x1] == 1) continue;
			_arr[y1 * surface_w + x1] = 1;
			
			sel_x0 = min(sel_x0, x1);
			sel_y0 = min(sel_y0, y1);
			sel_x1 = max(sel_x1, x1);
			sel_y1 = max(sel_y1, y1);
			    
			//print($"> Filling {x1}, {y1}: {canvas_get_color_buffer(x1, y1)}");
				
			if(y1 > 0) {
				if(_corner && x1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 - 1, y1 - 1, thr))		//Check top left pixel
					ds_queue_enqueue(queue, [x1 - 1, y1 - 1]);
					
				if(canvas_ms_fillable(colorBase, colorFill, x1, y1 - 1, thr))								//Check top pixel
					ds_queue_enqueue(queue, [x1, y1 - 1]);
			}
				
			if(y1 < surface_h - 1) {
				if(_corner && x1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 - 1, y1 + 1, thr))		//Check bottom left pixel
					ds_queue_enqueue(queue, [x1 - 1, y1 + 1]);
					
				if(canvas_ms_fillable(colorBase, colorFill, x1, y1 + 1, thr))								//Check bottom pixel
					ds_queue_enqueue(queue, [x1, y1 + 1]);
			}
				
			if(_corner && x1 < surface_w - 1) {
				if(y1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 + 1, y1 - 1, thr))				//Check top right pixel
					ds_queue_enqueue(queue, [x1 + 1, y1 - 1]);
					
				if(y1 < surface_h - 1 && canvas_ms_fillable(colorBase, colorFill, x1 + 1, y1 + 1, thr))	//Check bottom right pixel
					ds_queue_enqueue(queue, [x1 + 1, y1 + 1]);
			}
				
			x1++;
		}
	}
	
	ds_queue_destroy(queue);
	buffer_delete(_ff_buff);
	
	return [ sel_x0, sel_y0, sel_x1, sel_y1 ];
} #endregion