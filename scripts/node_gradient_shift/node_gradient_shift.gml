function Node_Gradient_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient Shift";
	setDimension(96);
	
	inputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	inputs[| 2] = nodeValue("Wrap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 2, 0.01] });
	
	outputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	_pal = -1;
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
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
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = outputs[| 0].getValue();
		if(!is_array(grad)) grad = [ grad ];
		var _h = array_length(grad) * 32;
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(grad);
			
		for( var i = 0, n = array_length(grad); i < n; i++ ) {
			grad[i].draw(bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
		
		if(_h != min_h) will_setHeight = true;
		min_h = _h;	
	} #endregion
}