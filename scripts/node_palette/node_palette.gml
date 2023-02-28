function Node_Palette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Palette";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_white ])
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 1] = nodeValue("Trim range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
	
	outputs[| 0] = nodeValue("Palette", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [0, 
		["Trim",	true],	1
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var pal = _data[0];
		var ran = _data[1];
		
		var st = floor(clamp(min(ran[0], ran[1]), 0, 1) * array_length(pal));
		var en = floor(clamp(max(ran[0], ran[1]), 0, 1) * array_length(pal));
		var ar = [];
		
		for( var i = st; i < en; i++ )
			ar[i] = array_safe_get(pal, i);
		
		return ar;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[| 0].getValue();
		if(array_length(pal) && is_array(pal[0])) return;
		
		drawPalette(pal, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}