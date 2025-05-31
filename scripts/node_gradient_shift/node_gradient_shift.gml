function Node_Gradient_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient Shift";
	setDimension(96);
	
	newInput(0, nodeValue_Gradient("Gradient", new gradientObject(ca_white)))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Slider("Shift", 0, [-1, 1, 0.01] ));
	
	newInput(2, nodeValue_Bool("Wrap", false))
	
	newInput(3, nodeValue_Slider("Scale", 1, [0, 2, 0.01] ));
	
	newOutput(0, nodeValue_Output("Gradient", VALUE_TYPE.gradient, new gradientObject(ca_white) ));
	
	_pal = -1;
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
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