function Node_Gradient_Extract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient Data";
	setDimension(96);
	
	newInput(0, nodeValue_Gradient("Gradient", new gradientObject(ca_white))).setVisible(true, true);
	
	newOutput(0, nodeValue_Output( "Colors", VALUE_TYPE.color, [] )).setDisplay(VALUE_DISPLAY.palette);
	newOutput(1, nodeValue_Output( "Positions", VALUE_TYPE.float, [] )).setArrayDepth(1);
	newOutput(2, nodeValue_Output( "Type", VALUE_TYPE.integer, 0 ));
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outData, _data, _array_index) {
		gra = _data[0];
		len = array_length(gra.keys);
		
		_outData[0] = array_create_ext(len, function(i) /*=>*/ {return gra.keys[i].value});
		_outData[1] = array_create_ext(len, function(i) /*=>*/ {return gra.keys[i].time});
		_outData[2] = gra.type;
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var grad = getInputData(0);
		if(!is_array(grad)) grad = [ grad ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(grad);
			
		for( var i = 0, n = array_length(grad); i < n; i++ ) {
			grad[i].draw(bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}