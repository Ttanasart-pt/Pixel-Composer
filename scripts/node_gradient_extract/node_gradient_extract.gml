function Node_Gradient_Extract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient Data";
	batch_output = false;
	setDimension(96);
	
	newInput(0, nodeValue_Gradient("Gradient", self, new gradientObject(cola(c_white))))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Colors", self, VALUE_TYPE.color, [] ))
		.setDisplay(VALUE_DISPLAY.palette);
	
	newOutput(1, nodeValue_Output("Positions", self, VALUE_TYPE.float, [] ));
	outputs[1].array_depth = 1;
	
	newOutput(2, nodeValue_Output("Type", self, VALUE_TYPE.integer, 0 ));
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var gra  = _data[0];
		
		switch(_output_index) {
			case 0 :
				var pal = [];
				for( var i = 0, n = array_length(gra.keys); i < n; i++ )
					pal[i] = gra.keys[i].value;
				return pal;
			case 1 :
				var pos = [];
				for( var i = 0, n = array_length(gra.keys); i < n; i++ )
					pos[i] = gra.keys[i].time;
				return pos;
			case 2 :
				return gra.type;
		}
		
		return 0;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = getInputData(0);
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
	}
}