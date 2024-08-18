function Node_Gradient_Replace_Color(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient Replace";
	setDimension(96, 48);;
	
	inputs[0] = nodeValue_Gradient("Gradient", self, new gradientObject(cola(c_white)))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Palette("Color from", self, array_clone(DEF_PALETTE)));
	
	newInput(2, nodeValue_Palette("Color to", self, array_clone(DEF_PALETTE)));
	
	inputs[3] = nodeValue_Float("Threshold", self, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[0] = nodeValue_Output("Gradient", self, VALUE_TYPE.gradient, new gradientObject(cola(c_white)) );
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var gra  = _data[0];
		var pfr  = _data[1];
		var pto  = _data[2];
		var thr  = _data[3];
		var graO = new gradientObject();
		
		for( var i = 0, n = array_length(gra.keys); i < n; i++ ) {
			var k = gra.keys[i];
			
			var fromValue = 999;
			var fromIndex = -1;
			for( var j = 0; j < array_length(pfr); j++ ) {
				var fr = pfr[j];
				
				var dist = color_diff(k.value, fr);
				if(dist <= thr && dist < fromValue) {
					fromValue = dist;
					fromIndex = j;
				}
			}
			
			var cTo = fromIndex == -1? k.value : array_safe_get_fast(pto, fromIndex, k.value, ARRAY_OVERFLOW.loop);
			graO.keys[i] = new gradientKey(k.time, cTo);
		}
		
		graO.type = gra.type;
		
		return graO;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = outputs[0].getValue();
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