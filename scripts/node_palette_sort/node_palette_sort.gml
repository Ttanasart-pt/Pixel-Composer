function Node_Palette_Sort(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sort Palette";	
	setDimension(96);
	
	newInput(0, nodeValue_Palette("Palette in", self, array_clone(DEF_PALETTE)))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Button("Order", self,  0, [ "Brightness", -1, "Hue (HSV)", "Saturation (SHV)", "Value (VHS)", -1, "Red (RGB)", "Green (GBR)", "Blue (BRG)", -1, "Custom" ]))
		.rejectArray();
	
	newInput(2, nodeValue_Bool("Reverse", self, false));
	
	newInput(3, nodeValue_Text("Sort Order", self, "RGB", @"Compose sorting algorithm using string.
    - RGB: Red/Green/Blur channel
    - HSV: Hue/Saturation/Value
    - L:   Brightness
    - Use small letter for ascending, capital letter for descending order."));
	
	newOutput(0, nodeValue_Output("Sorted palette", self, VALUE_TYPE.color, []))
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [
		0, 1, 3, 2, 
	]
	
	static step = function() {
		var _typ = getInputData(1);
		
		inputs[3].setVisible(_typ == 10);
	}
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	sort_string = "";
	static customSort = function(c) {
		var len = string_length(sort_string);
		var val = power(256, len - 1);
		var res = 0;
		
		for( var i = 1; i <= len; i++ ) {
			var ch = string_char_at(sort_string, i);
			var _v = 0;
			
			switch(string_lower(ch)) {
				case "r" : _v += color_get_red(c);			break;
				case "g" : _v += color_get_green(c);		break;
				case "b" : _v += color_get_blue(c);			break;
				case "h" : _v += color_get_hue(c);			break;
				case "s" : _v += color_get_saturation(c);	break;
				case "v" : _v += color_get_value(c);		break;
				case "l" : _v += colorBrightness(c, false); break;
			}
			
			if(ord(ch) <= ord("Z")) res += _v * val;
			else					res += (256 - _v) * val;
			val /= 256;
		}
		
		return res;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _arr = _data[0];
		var _ord = _data[1];
		var _rev = _data[2];
		sort_string = _data[3];
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
			
			case 10 : array_sort(_pal, function(c1, c2) { return customSort(c2) - customSort(c1); }); break;
		}
		
		if(_rev) _pal = array_reverse(_pal);
		
		return _pal;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
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