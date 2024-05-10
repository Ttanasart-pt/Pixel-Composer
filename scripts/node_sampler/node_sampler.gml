function Node_Sampler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sampler";
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 2] = nodeValue("Sampling size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Size of square around the position to sample and average pixel color.")
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 3, 0.1] });
	
	inputs[| 3] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	static getPreviewValues = function() { return getInputData(0); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		PROCESSOR_OVERLAY_CHECK
		
		inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _suf = current_data[0];
		if(!is_surface(_suf)) return;
		var ww = surface_get_width_safe(_suf);
		var hh = surface_get_height_safe(_suf);
		
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
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _surf = _data[0];
		var _pos  = _data[1];
		var _sam  = _data[2];
		var _alp  = _data[3];
		if(!is_surface(_surf)) return c_black;
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		var r = 0, g = 0, b = 0, a = 0, amo = 0;
		
		_sam -= 1;
		for( var i = -_sam; i <= _sam; i++ ) 
		for( var j = -_sam; j <= _sam; j++ ) {
			var px = _pos[0] + i;
			var py = _pos[1] + j;
			if(px < 0) continue;
			if(py < 0) continue;
			if(px >= ww) continue;
			if(py >= hh) continue;
			
			var cc = int64(surface_get_pixel_ext(_surf, px, py));
			
			r += color_get_red(cc);
			g += color_get_green(cc);
			b += color_get_blue(cc);
			a += color_get_alpha(cc);
			amo++;
		}
		
		r /= amo;
		g /= amo;
		b /= amo;
		a /= amo;
		
		return _alp? make_color_rgba(r, g, b, a) : make_color_rgb(r, g, b);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var col  = outputs[| 0].getValue();
		if(bbox.h <= 0) return;
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	} #endregion
}