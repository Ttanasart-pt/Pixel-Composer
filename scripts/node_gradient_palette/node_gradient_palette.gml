function Node_Gradient_Palette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette to Gradient";
	setDimension(96);
	
	newInput(0, nodeValue_Palette( "Palette" )).setVisible(true, true);
	newInput(1, nodeValue_Bool(    "Custom positions", false ));
	newInput(2, nodeValue_Float(   "Positions",        [],  "Array of number indicating color position (0 - 1)." )).setArrayDepth(1).setVisible(true, true);
	newInput(3, nodeValue_EButton( "Interpolation",    1,  ["None","RGB","HSV","OKLAB","sRGB"] ));
	
	newOutput(0, nodeValue_Output("Gradient", VALUE_TYPE.gradient, new gradientObject(ca_white) ))
	
	_pal = -1;
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var pal  = _data[0];
		var puse = _data[1];
		var _pos = _data[2];
		var type = _data[3];
		
		inputs[2].setVisible(puse, puse);
		
		var grad    = new gradientObject();
		var len		= min(128, array_length(pal));
		grad.keys   = array_create(len);
		
		var _stp = type == GRADIENT_INTER.none? 1 / (len - 1) : 1 / len;
		
		for( var i = 0; i < len; i++ ) {
			var clr = pal[i];
			var pos = puse? array_safe_get_fast(_pos, i, 0) : i * _stp;
			
			grad.keys[i] = new gradientKey(pos, clr);
		}
		
		switch(type) {
			case 0 : grad.type = GRADIENT_INTER.none;	break;
			case 1 : grad.type = GRADIENT_INTER.smooth; break;
			case 2 : grad.type = GRADIENT_INTER.hue;	break;
			case 3 : grad.type = GRADIENT_INTER.oklab;	break;
			case 4 : grad.type = GRADIENT_INTER.srgb;	break;
		}
		
		return grad;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
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