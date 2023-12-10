function Node_Palette_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette Replace";
	
	w = 96;
	
	inputs[| 0] = nodeValue("Palette in", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Palette from", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Palette to", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 3] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	input_display_list = [ 0, 
		["Palette",		false], 1, 2, 3, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [ ] )
		.setDisplay(VALUE_DISPLAY.palette);
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var pal = _data[0];
		var pfr = _data[1];
		var pto = _data[2];
		var thr = _data[3];
		var palo = [];
		
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			var c = pal[i];
			
			var fromValue = 999;
			var fromIndex = -1;
			for( var j = 0; j < array_length(pfr); j++ ) {
				var fr = pfr[j];
				
				var dist = color_diff(c, fr);
				if(dist <= thr && dist < fromValue) {
					fromValue = dist;
					fromIndex = j;
				}
			}
			
			palo[i] = fromIndex == -1? c : array_safe_get(pto, fromIndex, c, ARRAY_OVERFLOW.loop);
		}
		
		return palo;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[| 0].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _h = array_length(pal) * 32;
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
		
		if(_h != min_h) will_setHeight = true;
		min_h = _h;	
	} #endregion
}