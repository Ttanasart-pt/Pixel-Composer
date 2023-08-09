function Node_Palette_Sort(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Sort Palette";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Palette in", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Brightness", -1, "Hue (HSV)", "Saturation (SHV)", "Value (VHS)", -1, "Red (RGB)", "Green (GBR)", "Blue (BRG)", -1, "Custom" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Reverse", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 3] = nodeValue("Sort Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "RGB");
	
	outputs[| 0] = nodeValue("Sorted palette", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	static step = function() {
		var _typ = inputs[| 1].getValue();
		
		inputs[| 3].setVisible(_typ == 10);
	}
	
	sort_string = "";
	static customSort = function(c) {
		var len = string_length(sort_string);
		var val = power(256, len);
		
		for( var i = 1; i <= len; i++ ) {
			var ch = string_lower(string_char_at(sort_string, i));
			
			switch(ch) {
				case "r" : return 
			}
			
			val /= 256;
		}
		
		return c;
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _arr = inputs[| 0].getValue();
		var _ord = inputs[| 1].getValue();
		var _rev = inputs[| 2].getValue();
		sort_string = inputs[| 3].getValue();
		if(!is_array(_arr)) return;
		
		var _pal = array_clone(_arr);
		
		switch(_ord) {
			case 0 : array_sort(_pal, __sortBright); break;
			
			case 2 : array_sort(_pal, __sortHue); break;
			case 3 : array_sort(_pal, __sortSat); break;
			case 4 : array_sort(_pal, __sortVal); break;
			
			case 6 : array_sort(_pal, __sortRed);	break;
			case 7 : array_sort(_pal, __sortGreen); break;
			case 8 : array_sort(_pal, __sortBlue);	break;
			
			case 10 : array_sort(_pal, function(c1, c2) { return customSort(c1) - customSort(c2); }); break;
		}
		
		if(_rev) _pal = array_reverse(_pal);
		
		outputs[| 0].setValue(_pal);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[| 0].getValue();
		if(array_length(pal) && is_array(pal[0])) return;
		
		drawPalette(pal, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}