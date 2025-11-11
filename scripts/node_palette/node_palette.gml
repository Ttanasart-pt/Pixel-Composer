function Node_Palette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Palette("Palette" ));
	
	newInput(1, nodeValue_Slider_Range("Trim range", [ 0, 1 ]));
	
	newOutput(0, nodeValue_Output("Palette", VALUE_TYPE.color, []))
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [0, 
		["Trim",	true],	1
	];
	
	static processData_prebatch = function() {
		setDimension(96, 16 + process_length[0] * 32);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var pal = _data[0];
		var ran = _data[1];
		
		var st = floor(clamp(min(ran[0], ran[1]), 0, 1) * array_length(pal));
		var en = floor(clamp(max(ran[0], ran[1]), 0, 1) * array_length(pal));
		var ar = [];
		
		for( var i = st; i < en; i++ )
			ar[i - st] = array_safe_get_fast(pal, i);
		
		return ar;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}