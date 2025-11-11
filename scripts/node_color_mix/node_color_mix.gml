function Node_Color_Mix(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mix Color";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Color("Color from", ca_white));
	
	newInput(1, nodeValue_Color("Color to", ca_white));
	
	newInput(2, nodeValue_Slider("Mix", 0.5));
	
	newInput(3, nodeValue_Enum_Button("Color space",  0, [ "RGB", "HSV", "OKLAB" ]));
	
	newOutput(0, nodeValue_Output("Color", VALUE_TYPE.color, c_white));
	
	input_display_list = [ 3, 0, 1, 2 ];
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var c = c_black;
		
		switch(_data[3]) {
			case 0 : c = merge_color_ext(  _data[0], _data[1], _data[2]); break;
			case 1 : c = merge_color_hsv(  _data[0], _data[1], _data[2]); break;
			case 2 : c = merge_color_oklab(_data[0], _data[1], _data[2]); break;
		}
		
		return c;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var col = outputs[0].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}