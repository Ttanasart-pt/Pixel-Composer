function Node_Gradient_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Gradient Shift";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, new gradientObject(c_white) )
		.setDisplay(VALUE_DISPLAY.gradient)
		.setDisplay(true, true);
	
	inputs[| 1] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
	
	inputs[| 2] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	outputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, new gradientObject(c_white) )
		.setDisplay(VALUE_DISPLAY.gradient);
	
	_pal = -1;
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var pal = _data[0];
		var sft = _data[1];
		var lop = _data[2];
		
		_outSurf = new gradientObject();
		for( var i = 0; i < array_length(pal.keys); i++ ) {
			var k = pal.keys[i];
			_outSurf.keys[i] = new gradientKey(k.time + sft, k.value);
			if(lop) _outSurf.keys[i].time = frac(_outSurf.keys[i].time);
		}
		
		_outSurf.type = pal.type;
		return _outSurf;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = outputs[| 0].getValue();
		grad.draw(bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}