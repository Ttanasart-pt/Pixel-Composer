function Node_Gradient_Out(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient";
	setDimension(96);
	
	newInput(0, nodeValue_Gradient( "Gradient", self, new gradientObject([ ca_black, ca_white ])));
	newInput(1, nodeValue_Slider(   "Sample",   self, 0)).setTooltip("Position to sample a color from the gradient.").rejectArray();
	
	newOutput(0, nodeValue_Output("Gradient", self, VALUE_TYPE.gradient, new gradientObject(ca_white) ));
	newOutput(1, nodeValue_Output("Color",    self, VALUE_TYPE.color, c_white));
	
	_pal = -1;
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outData, _data, _array_index) {
		var pal = _data[0];
		var pos = _data[1];
		
		if(!is(pal, gradientObject)) return _outData;
		
		_outData[0] = pal;
		_outData[1] = pal.eval(pos);
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = outputs[0].getValue();
		if(!is_array(grad)) grad = [ grad ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(grad);
			
		for( var i = 0, n = array_length(grad); i < n; i++ ) {
			grad[i].draw(bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}