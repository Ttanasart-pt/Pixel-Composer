function Node_Gradient_Palette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette to Gradient";
	setDimension(96);
	
	inputs[| 0] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, array_clone(DEF_PALETTE))
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Custom positions", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Positions", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [], "Array of number indicating color position (0 - 1).")
		.setVisible(true, true);
	inputs[| 2].array_depth = 1;
	
	inputs[| 3] = nodeValue("Interpolation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "None", "RGB", "HSV", "OKLAB", "sRGB" ]);
	
	outputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.gradient, new gradientObject(c_white) )
	
	_pal = -1;
	
	static step = function() { #region
		var usePos = array_safe_get_fast(current_data, 1);
		inputs[| 2].setVisible(usePos, usePos);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var pal     = _data[0];
		var pos_use = _data[1];
		var _pos    = _data[2];
		var type    = _data[3];
		
		var grad    = new gradientObject();
		var len		= min(128, array_length(pal));
		grad.keys   = array_create(len);
		
		var _stp = type == GRADIENT_INTER.none? 1 / (len - 1) : 1 / len;
		
		for( var i = 0; i < len; i++ ) {
			var clr = pal[i];
			var pos = pos_use? array_safe_get_fast(_pos, i, 0) : i * _stp;
			
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