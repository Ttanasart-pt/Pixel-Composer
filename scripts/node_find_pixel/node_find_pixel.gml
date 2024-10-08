function Node_Find_Pixel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Find pixel";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Color("Search color", self, c_black));
	
	newInput(2, nodeValue_Float("Tolerance", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Find all", self, false));
	
	newInput(4, nodeValue_Bool("Include alpha", self, false));
	
	newInput(5, nodeValue_Float("Alpha tolerance", self, 0.2))
		.setDisplay(VALUE_DISPLAY.slider);
	
	// newInput(6, nodeValue_Enum_Button("Axis", self,  1, [ "X", "Y" ]));
	
	newOutput(0, nodeValue_Output("Position", self, VALUE_TYPE.integer, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0, 
		["Search", false], 1, 2, 3, 
		["Alpha",   true, 4], 5, 
	]
	
	static getPreviewValues = function() { return getInputData(0); }
	
	temp_surface = [ surface_create(1, 1) ];
	
	static step = function() { #region
		// var _all  = getInputData(3);
		
		// inputs[6].setVisible(_all);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _surf = _data[0];
		var _col  = _data[1];
		var _tol  = _data[2];
		var _all  = _data[3];
		
		var _alp  = _data[4];
		var _alpT = _data[5];
		// var _axis = _data[6];
		
		if(!is_surface(_surf)) return [0, 0];
		
		var _buff = buffer_from_surface(_surf, false);
		var _sw   = surface_get_width_safe(_surf);
		var _sh   = surface_get_height_safe(_surf);
		buffer_seek(_buff, buffer_seek_start, 0);
		
		var res = [];
		var r = _color_get_red(_col);
		var g = _color_get_green(_col);
		var b = _color_get_blue(_col);
		var a = _color_get_alpha(_col);
		
		for( var i = 0; i < _sh; i++ ) 
		for( var j = 0; j < _sw; j++ ) {
			var _c = buffer_read(_buff, buffer_u32);
			
			var _r = ((_c & 0x000000FF) >>  0) / 255;
			var _g = ((_c & 0x0000FF00) >>  8) / 255;
			var _b = ((_c & 0x00FF0000) >> 16) / 255;
			var _a = ((_c & 0xFF000000) >> 24) / 255;
			
			if(!_alp && _a == 0) continue;
			
			var colMatch = (abs(r - _r) + abs(g - _g) + abs(b - _b)) / 3 <= _tol;
			if(!colMatch) continue;
			
			if(!_alp || abs(a - _a) <= _alpT) {
				if(_all) array_push(res, [ j, i ]);
				else     return [ j, i ];
			}
		}
		
		buffer_delete(_buff);
		return _all? res : [ -1, -1 ];
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var col = getInputData(1);
		
		if(bbox.h <= 0) return;
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	} #endregion
}