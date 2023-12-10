function Node_Palette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette";
	w    = 96;
	
	inputs[| 0] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE)
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 1] = nodeValue("Trim range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	outputs[| 0] = nodeValue("Palette", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [0, 
		["Trim",	true],	1
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var pal = _data[0];
		var ran = _data[1];
		
		var st = floor(clamp(min(ran[0], ran[1]), 0, 1) * array_length(pal));
		var en = floor(clamp(max(ran[0], ran[1]), 0, 1) * array_length(pal));
		var ar = [];
		
		for( var i = st; i < en; i++ )
			ar[i - st] = array_safe_get(pal, i);
		
		return ar;
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