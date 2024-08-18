function Node_Color(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Color("Color", self, c_white));
	
	outputs[0] = nodeValue_Output("Color", self, VALUE_TYPE.color, c_white);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		return _data[0];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var col = getInputData(0);
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}