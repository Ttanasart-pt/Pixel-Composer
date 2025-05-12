function Node_Gradient_Sample(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sample Gradient";
	setDimension(96);
	
	newInput(0, nodeValue_Gradient("Gradient", self, new gradientObject([ca_black, ca_white])) )
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Step", self, 16));
	
	newInput(2, nodeValue_Float("Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	newOutput(0, nodeValue_Output("Colors", self, VALUE_TYPE.color, [ c_black ]))
		.setDisplay(VALUE_DISPLAY.palette);
	
	_pal = -1;
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var grad = _data[0];
		var stp  = _data[1];
		var shf  = _data[2];
		
		_outSurf = array_verify(_outSurf, stp);
		for( var i = 0; i < stp; i++ ) {
			var _t = frac(shf + i / stp);
			_outSurf[i] = grad.eval(_t);
		}
		
		return _outSurf;
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