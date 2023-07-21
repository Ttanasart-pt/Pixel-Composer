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
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	input_display_list = [ 0, 
		["Palette",		false], 1, 2, 3, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [ ] )
		.setDisplay(VALUE_DISPLAY.palette);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var pal = _data[0];
		var pfr = _data[1];
		var pto = _data[2];
		var thr = _data[3];
		var palo = [];
		
		for( var i = 0; i < array_length(pal); i++ ) {
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
			
			if(fromIndex == -1)
				palo[i] = c;
			else 
				palo[i] = array_safe_get(pto, fromIndex, c, ARRAY_OVERFLOW.loop);
		}
		
		return palo;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[| 0].getValue();
		if(array_length(pal) && is_array(pal[0])) return;
		drawPalette(pal, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}