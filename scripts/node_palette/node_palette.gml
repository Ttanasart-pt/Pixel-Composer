function Node_Palette(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Palette";
	previewable = false;
	
	min_h = 0;
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_white ])
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 1] = nodeValue(1, "Trim range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Palette", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [0, 
		["Trim",	true],	1
	];
	
	_pal = -1;
	_ran = [0, 1];
	static update = function() {
		var pal = inputs[| 0].getValue();
		var ran = inputs[| 1].getValue();
		
		if(pal != _pal) {
			_pal = pal;
		}
		var st = floor(min(ran[0], ran[1]) * array_length(pal));
		var en = floor(max(ran[0], ran[1]) * array_length(pal));
		var len = max(1, en - st);
		var ar = array_create(len);
		array_copy(ar, 0, pal, min(array_length(pal) - len, st), len);
		outputs[| 0].setValue(ar);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var x0 = xx + 8 * _s;
		var x1 = xx + (w - 8) * _s;
		var y0 = yy + 20 + 8 * _s;
		var y1 = yy + (h - 8) * _s;
		
		if(y1 > y0)
			drawPalette(outputs[| 0].getValue(), x0, y0, x1 - x0, y1 - y0);
	}
}