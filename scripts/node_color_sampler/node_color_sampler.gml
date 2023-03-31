function Node_Sampler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sampler";
	w = 96;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 2] = nodeValue("Sampling size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Size of square around the position to sample and average pixel color.")
		.setDisplay(VALUE_DISPLAY.slider, [1, 3, 1]);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	static getPreviewValue = function() { return inputs[| 0]; }
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _suf = current_data[0];
		if(!is_surface(_suf)) return;
		var ww = surface_get_width(_suf);
		var hh = surface_get_height(_suf);
		
		var _pos = current_data[1];
		var _sam = 1 + (current_data[2] - 1) * 2;
		
		var x0 = _pos[0] + 0.5 - _sam / 2;
		var x1 = _pos[0] + 0.5 + _sam / 2;
		var y0 = _pos[1] + 0.5 - _sam / 2;
		var y1 = _pos[1] + 0.5 + _sam / 2;
		
		x0 = clamp(x0, 0, ww);
		x1 = clamp(x1, 0, ww);
		y0 = clamp(y0, 0, hh);
		y1 = clamp(y1, 0, hh);
		
		x0 = _x + x0 * _s;
		x1 = _x + x1 * _s;
		y0 = _y + y0 * _s;
		y1 = _y + y1 * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_rectangle(x0, y0, x1, y1, true);
	}
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var _surf = _data[0];
		var _pos = _data[1];
		var _sam = _data[2];
		if(!is_surface(_surf)) return c_black;
		
		var ww = surface_get_width(_surf);
		var hh = surface_get_height(_surf);
		
		var r = 0, g = 0, b = 0, amo = 0;
		
		_sam -= 1;
		for( var i = -_sam; i <= _sam; i++ ) 
		for( var j = -_sam; j <= _sam; j++ ) {
			var px = _pos[0] + i;
			var py = _pos[1] + j;
			if(px < 0) continue;
			if(py < 0) continue;
			if(px >= ww) continue;
			if(py >= hh) continue;
			
			var cc = surface_get_pixel(_surf, px, py);
			
			r += color_get_red(cc);
			g += color_get_green(cc);
			b += color_get_blue(cc);
			amo++;
		}
		
		r /= amo;
		g /= amo;
		b /= amo;
		
		return make_color_rgb(r, g, b);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(bbox.h <= 0) return;
		
		var col = outputs[| 0].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		draw_set_color(col);
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 0);
	}
}