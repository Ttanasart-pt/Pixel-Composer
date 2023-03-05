function Node_Palette_Sort(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Sort Palette";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Palette in", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Brightness", -1, "Hue (HSV)", "Saturation (SHV)", "Value (VHS)", -1, "Red (RGB)", "Green (GBR)", "Blue (BRG)" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Reverse", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Sorted palette", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _arr = inputs[| 0].getValue();
		var _ord = inputs[| 1].getValue();
		var _rev = inputs[| 2].getValue();
		if(!is_array(_arr)) return;
		
		var _pal = array_clone(_arr);
		
		switch(_ord) {
			case 0 : array_sort(_pal, __sortBright); break;
			
			case 1 : array_sort(_pal, __sortHue); break;
			case 2 : array_sort(_pal, __sortSat); break;
			case 3 : array_sort(_pal, __sortVal); break;
			
			case 4 : array_sort(_pal, __sortRed);	break;
			case 5 : array_sort(_pal, __sortGreen); break;
			case 6 : array_sort(_pal, __sortBlue);	break;
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