function Node_Gradient_Extract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient Data";
	batch_output = false;
	setDimension(96);
	
	inputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(cola(c_white)) )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Colors", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [] )
		.setDisplay(VALUE_DISPLAY.palette);
	
	outputs[| 1] = nodeValue("Positions", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [] );
	outputs[| 1].array_depth = 1;
	
	outputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0 );
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
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
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = inputs[| 0].getValue();
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