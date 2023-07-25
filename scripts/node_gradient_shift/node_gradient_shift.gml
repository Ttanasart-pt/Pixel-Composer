function Node_Gradient_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Gradient Shift";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
		.setDisplay(true, true);
	
	inputs[| 1] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
	
	inputs[| 2] = nodeValue("Wrap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 2, 0.01]);
	
	outputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	_pal = -1;
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var pal = _data[0];
		var sft = _data[1];
		var lop = _data[2];
		var sca = _data[3];
		
		_outSurf = new gradientObject();
		_outSurf.keys = [];
		
		for( var i = 0, n = array_length(pal.keys); i < n; i++ ) {
			var k = pal.keys[i];
			var key = new gradientKey((0.5 + (k.time - 0.5) * sca) + sft, k.value);
			
			if(lop) {
				var t = frac(key.time);
				if(t < 0) t = 1 + t;
				
				key.time = t;
			}
			
			_outSurf.add(key);
		}
		
		_outSurf.type = pal.type;
		return _outSurf;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = outputs[| 0].getValue();
		grad.draw(bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}